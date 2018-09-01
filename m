Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 152356B5FDC
	for <linux-mm@kvack.org>; Sat,  1 Sep 2018 22:21:14 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id t23-v6so9165393pfe.20
        for <linux-mm@kvack.org>; Sat, 01 Sep 2018 19:21:14 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 35-v6si13524442pgo.639.2018.09.01.19.21.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Sep 2018 19:21:10 -0700 (PDT)
Message-Id: <20180901124811.644382292@intel.com>
Date: Sat, 01 Sep 2018 19:28:22 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH 4/5] [PATCH 4/5] kvm-ept-idle: EPT page table walk for A bits
References: <20180901112818.126790961@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0004-kvm-ept-idle-EPT-page-table-walk-for-A-bits.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Peng DongX <dongx.peng@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Huang Ying <ying.huang@intel.com>, Brendan Gregg <bgregg@netflix.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

This borrows host page table walk macros/functions to do EPT walk.
So it depends on them using the same level.

Dave Hansen raised the concern that hottest pages may be cached in TLB and
don't frequently set the accessed bits. The solution would be to invalidate TLB
for the mm being walked, when finished one round of scan.

Warning: read() also clears the accessed bit btw, in order to avoid one more
page table walk for write(). That may not be desirable for some use cases, so
we can avoid clearing accessed bit when opened in readonly mode.

The interface should be further improved to

1) report holes and huge pages in one go
2) represent huge pages and sparse page tables efficiently

(1) can be trivially fixed by extending the bitmap to more bits per PAGE_SIZE.

(2) would need fundemental changes to the interface. It seems existing solutions
for sparse files like SEEK_HOLE/SEEK_DATA and FIEMAP ioctl may not serve this
situation well. The most efficient way could be to fill user space read()
buffer with an array of small extents:

	struct idle_extent {
		unsigned type :  4; 
		unsigned nr   :  4; 
	};

where type can be one of

	4K_HOLE
	4K_IDLE
	4K_ACCESSED
	2M_HOLE
	2M_IDLE
	2M_ACCESSED
	1G_OR_LARGER_PAGE
	...

There can be up to 16 types, so more page sizes can be defined. The above names
are just for easy understanding the typical case. It's also possible that
PAGE_SIZE is not 4K, or PMD represents 4M pages. In which case we change type
names to more suitable ones like PTE_HOLE, PMD_ACCESSED. Since it's page table
walking, the user space should better know the exact page sizes. Either the
accessed bit or page migration are tied to the real page size.

Anyone interested in adding PTE_DIRTY or more types?

The main problem with such extent reporting interface is, the number of bytes
returned by read (variable extents) will mismatch the advanced file position
(fixed VA indexes), which is not POSIX compliant. Simple cp/cat may still work,
as they don't lseek based on read return value. If that's really a concern, we
may use ioctl() instead..

CC: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/kvm/ept_idle.c | 211 ++++++++++++++++++++++++++++++++++++++++++++++++
 arch/x86/kvm/ept_idle.h |  55 +++++++++++++
 2 files changed, 266 insertions(+)

diff --git a/arch/x86/kvm/ept_idle.c b/arch/x86/kvm/ept_idle.c
index 5b97dd01011b..8a233ab8656d 100644
--- a/arch/x86/kvm/ept_idle.c
+++ b/arch/x86/kvm/ept_idle.c
@@ -9,6 +9,217 @@
 
 #include "ept_idle.h"
 
+static int add_to_idle_bitmap(struct ept_idle_ctrl *eic,
+			      int idle, unsigned long addr_range)
+{
+	int nbits = addr_range >> PAGE_SHIFT;
+	int bits_left = EPT_IDLE_KBUF_BITS - eic->bits_read;
+	int ret = 0;
+
+	if (nbits >= bits_left) {
+		ret = EPT_IDLE_KBUF_FULL;
+		nbits = bits_left;
+	}
+
+	// TODO: this assumes u64 == unsigned long
+	if (!idle)
+		__bitmap_clear((unsigned long *)eic->kbuf, eic->bits_read, nbits);
+	eic->bits_read += nbits;
+
+	return ret;
+}
+
+static int ept_pte_range(struct ept_idle_ctrl *eic,
+			 pmd_t *pmd, unsigned long addr, unsigned long end)
+{
+	pte_t *pte;
+	int err = 0;
+	int idle;
+
+	pte = pte_offset_kernel(pmd, addr);
+	do {
+		if (!ept_pte_present(*pte) ||
+		    !ept_pte_accessed(*pte))
+			idle = 1;
+		else {
+			idle = 0;
+			pte_clear_flags(*pte, _PAGE_EPT_ACCESSED);
+		}
+
+		err = add_to_idle_bitmap(eic, idle, PAGE_SIZE);
+		if (err)
+			break;
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+
+	return err;
+}
+
+static int ept_pmd_range(struct ept_idle_ctrl *eic,
+			 pud_t *pud, unsigned long addr, unsigned long end)
+{
+	pmd_t *pmd;
+	unsigned long next;
+	int err = 0;
+	int idle;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		idle = -1;
+		if (!ept_pmd_present(*pmd) ||
+		    !ept_pmd_accessed(*pmd)) {
+			idle = 1;
+		} else if (pmd_large(*pmd)) {
+			idle = 0;
+			pmd_clear_flags(*pmd, _PAGE_EPT_ACCESSED);
+		}
+		if (idle >= 0)
+			err = add_to_idle_bitmap(eic, idle, next - addr);
+		else
+			err = ept_pte_range(eic, pmd, addr, next);
+		if (err)
+			break;
+	} while (pmd++, addr = next, addr != end);
+
+	return err;
+}
+
+static int ept_pud_range(struct ept_idle_ctrl *eic,
+			 p4d_t *p4d, unsigned long addr, unsigned long end)
+{
+	pud_t *pud;
+	unsigned long next;
+	int err = 0;
+	int idle;
+
+	pud = pud_offset(p4d, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		idle = -1;
+		if (!ept_pud_present(*pud) ||
+		    !ept_pud_accessed(*pud)) {
+			idle = 1;
+		} else if (pud_large(*pud)) {
+			idle = 0;
+			pud_clear_flags(*pud, _PAGE_EPT_ACCESSED);
+		}
+		if (idle >= 0)
+			err = add_to_idle_bitmap(eic, idle, next - addr);
+		else
+			err = ept_pmd_range(eic, pud, addr, next);
+		if (err)
+			break;
+	} while (pud++, addr = next, addr != end);
+
+	return err;
+}
+
+static int ept_p4d_range(struct ept_idle_ctrl *eic,
+			 pgd_t *pgd, unsigned long addr, unsigned long end)
+{
+	p4d_t *p4d;
+	unsigned long next;
+	int err = 0;
+
+	p4d = p4d_offset(pgd, addr);
+	do {
+		next = p4d_addr_end(addr, end);
+		if (!ept_p4d_present(*p4d))
+			err = add_to_idle_bitmap(eic, 1, next - addr);
+		else
+			err = ept_pud_range(eic, p4d, addr, next);
+		if (err)
+			break;
+	} while (p4d++, addr = next, addr != end);
+
+	return err;
+}
+
+static int ept_page_range(struct ept_idle_ctrl *eic,
+			  pgd_t *ept_root, unsigned long addr, unsigned long end)
+{
+	pgd_t *pgd;
+	unsigned long next;
+	int err = 0;
+
+	BUG_ON(addr >= end);
+	pgd = pgd_offset_pgd(ept_root, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (!ept_pgd_present(*pgd))
+			err = add_to_idle_bitmap(eic, 1, next - addr);
+		else
+			err = ept_p4d_range(eic, pgd, addr, next);
+		if (err)
+			break;
+	} while (pgd++, addr = next, addr != end);
+
+	return err;
+}
+
+static void init_ept_idle_ctrl_buffer(struct ept_idle_ctrl *eic)
+{
+	eic->bits_read = 0;
+	memset(eic->kbuf, 0xff, EPT_IDLE_KBUF_BYTES);
+}
+
+static int ept_idle_walk_gfn_range(struct ept_idle_ctrl *eic,
+				   unsigned long gfn_start,
+				   unsigned long gfn_end)
+{
+	struct kvm_vcpu *vcpu = kvm_get_vcpu(eic->kvm, 0);
+	struct kvm_mmu *mmu = &vcpu->arch.mmu;
+	pgd_t *ept_root;
+	unsigned long gpa_start = gfn_to_gpa(gfn_start);
+	unsigned long gpa_end = gfn_to_gpa(gfn_end);
+	unsigned long gpa_addr;
+	int bytes_read;
+	int ret = -EINVAL;
+
+	init_ept_idle_ctrl_buffer(eic);
+
+	spin_lock(&eic->kvm->mmu_lock);
+	if (mmu->base_role.ad_disabled) {
+		printk(KERN_NOTICE "CPU does not support EPT A/D bits tracking\n");
+		goto out_unlock;
+	}
+
+	if (mmu->shadow_root_level != 4 + (!!pgtable_l5_enabled())) {
+		printk(KERN_NOTICE "Unsupported EPT level %d\n", mmu->shadow_root_level);
+		goto out_unlock;
+	}
+
+	if (!VALID_PAGE(mmu->root_hpa)) {
+		goto out_unlock;
+	}
+
+	ept_root = __va(mmu->root_hpa);
+
+	for (gpa_addr = gpa_start;
+	     gpa_addr < gpa_end;
+	     gpa_addr += EPT_IDLE_KBUF_BITS << PAGE_SHIFT) {
+		ept_page_range(eic, ept_root, gpa_addr, gpa_end);
+		spin_unlock(&eic->kvm->mmu_lock);
+
+		bytes_read = eic->bits_read / 8;
+
+		ret = copy_to_user(eic->buf, eic->kbuf, bytes_read);
+		if (ret)
+			return -EFAULT;
+
+		eic->buf += bytes_read;
+		eic->bytes_copied += bytes_read;
+		if (eic->bytes_copied >= eic->buf_size)
+			return 0;
+
+		init_ept_idle_ctrl_buffer(eic);
+		cond_resched();
+		spin_lock(&eic->kvm->mmu_lock);
+	}
+out_unlock:
+	spin_unlock(&eic->kvm->mmu_lock);
+	return ret;
+}
 
 // mindless copy from kvm_handle_hva_range().
 // TODO: handle order and hole.
diff --git a/arch/x86/kvm/ept_idle.h b/arch/x86/kvm/ept_idle.h
index e0b9dcecf50b..b715ec7b7513 100644
--- a/arch/x86/kvm/ept_idle.h
+++ b/arch/x86/kvm/ept_idle.h
@@ -1,6 +1,61 @@
 #ifndef _EPT_IDLE_H
 #define _EPT_IDLE_H
 
+#define _PAGE_BIT_EPT_ACCESSED 8
+#define _PAGE_EPT_ACCESSED	(_AT(pteval_t, 1) << _PAGE_BIT_EPT_ACCESSED)
+
+#define _PAGE_EPT_PRESENT	(_AT(pteval_t, 7))
+
+static inline int ept_pte_present(pte_t a)
+{
+	return pte_flags(a) & _PAGE_EPT_PRESENT;
+}
+
+static inline int ept_pmd_present(pmd_t a)
+{
+	return pmd_flags(a) & _PAGE_EPT_PRESENT;
+}
+
+static inline int ept_pud_present(pud_t a)
+{
+	return pud_flags(a) & _PAGE_EPT_PRESENT;
+}
+
+static inline int ept_p4d_present(p4d_t a)
+{
+	return p4d_flags(a) & _PAGE_EPT_PRESENT;
+}
+
+static inline int ept_pgd_present(pgd_t a)
+{
+	return pgd_flags(a) & _PAGE_EPT_PRESENT;
+}
+
+static inline int ept_pte_accessed(pte_t a)
+{
+	return pte_flags(a) & _PAGE_EPT_ACCESSED;
+}
+
+static inline int ept_pmd_accessed(pmd_t a)
+{
+	return pmd_flags(a) & _PAGE_EPT_ACCESSED;
+}
+
+static inline int ept_pud_accessed(pud_t a)
+{
+	return pud_flags(a) & _PAGE_EPT_ACCESSED;
+}
+
+static inline int ept_p4d_accessed(p4d_t a)
+{
+	return p4d_flags(a) & _PAGE_EPT_ACCESSED;
+}
+
+static inline int ept_pgd_accessed(pgd_t a)
+{
+	return pgd_flags(a) & _PAGE_EPT_ACCESSED;
+}
+
 #define IDLE_BITMAP_CHUNK_SIZE	sizeof(u64)
 #define IDLE_BITMAP_CHUNK_BITS	(IDLE_BITMAP_CHUNK_SIZE * BITS_PER_BYTE)
 
-- 
2.15.0
