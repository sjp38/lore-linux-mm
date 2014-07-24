Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id CB0256B0036
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 10:56:59 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id j107so3435311qga.36
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 07:56:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a13si11405754qge.120.2014.07.24.07.56.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jul 2014 07:56:59 -0700 (PDT)
From: Mark Salter <msalter@redhat.com>
Subject: [PATCH] arm64: fix soft lockup due to large tlb flush range
Date: Thu, 24 Jul 2014 10:56:15 -0400
Message-Id: <1406213775-28617-1-git-send-email-msalter@redhat.com>
In-Reply-To: <20140724142417.GE13371@arm.com>
References: <20140724142417.GE13371@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Eric Miao <eric.y.miao@gmail.com>, Will Deacon <Will.Deacon@arm.com>, Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, Mark Salter <msalter@redhat.com>

Under certain loads, this soft lockup has been observed:

   BUG: soft lockup - CPU#2 stuck for 22s! [ip6tables:1016]
   Modules linked in: ip6t_rpfilter ip6t_REJECT cfg80211 rfkill xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw vfat fat efivarfs xfs libcrc32c

   CPU: 2 PID: 1016 Comm: ip6tables Not tainted 3.13.0-0.rc7.30.sa2.aarch64 #1
   task: fffffe03e81d1400 ti: fffffe03f01f8000 task.ti: fffffe03f01f8000
   PC is at __cpu_flush_kern_tlb_range+0xc/0x40
   LR is at __purge_vmap_area_lazy+0x28c/0x3ac
   pc : [<fffffe000009c5cc>] lr : [<fffffe0000182710>] pstate: 80000145
   sp : fffffe03f01fbb70
   x29: fffffe03f01fbb70 x28: fffffe03f01f8000
   x27: fffffe0000b19000 x26: 00000000000000d0
   x25: 000000000000001c x24: fffffe03f01fbc50
   x23: fffffe03f01fbc58 x22: fffffe03f01fbc10
   x21: fffffe0000b2a3f8 x20: 0000000000000802
   x19: fffffe0000b2a3c8 x18: 000003fffdf52710
   x17: 000003ff9d8bb910 x16: fffffe000050fbfc
   x15: 0000000000005735 x14: 000003ff9d7e1a5c
   x13: 0000000000000000 x12: 000003ff9d7e1a5c
   x11: 0000000000000007 x10: fffffe0000c09af0
   x9 : fffffe0000ad1000 x8 : 000000000000005c
   x7 : fffffe03e8624000 x6 : 0000000000000000
   x5 : 0000000000000000 x4 : 0000000000000000
   x3 : fffffe0000c09cc8 x2 : 0000000000000000
   x1 : 000fffffdfffca80 x0 : 000fffffcd742150

The __cpu_flush_kern_tlb_range() function looks like:

  ENTRY(__cpu_flush_kern_tlb_range)
	dsb	sy
	lsr	x0, x0, #12
	lsr	x1, x1, #12
  1:	tlbi	vaae1is, x0
	add	x0, x0, #1
	cmp	x0, x1
	b.lo	1b
	dsb	sy
	isb
	ret
  ENDPROC(__cpu_flush_kern_tlb_range)

The above soft lockup shows the PC at tlbi insn with:

  x0 = 0x000fffffcd742150
  x1 = 0x000fffffdfffca80

So __cpu_flush_kern_tlb_range has 0x128ba930 tlbi flushes left
after it has already been looping for 23 seconds!.

Looking up one frame at __purge_vmap_area_lazy(), there is:

	...
	list_for_each_entry_rcu(va, &vmap_area_list, list) {
		if (va->flags & VM_LAZY_FREE) {
			if (va->va_start < *start)
				*start = va->va_start;
			if (va->va_end > *end)
				*end = va->va_end;
			nr += (va->va_end - va->va_start) >> PAGE_SHIFT;
			list_add_tail(&va->purge_list, &valist);
			va->flags |= VM_LAZY_FREEING;
			va->flags &= ~VM_LAZY_FREE;
		}
	}
	...
	if (nr || force_flush)
		flush_tlb_kernel_range(*start, *end);

So if two areas are being freed, the range passed to
flush_tlb_kernel_range() may be as large as the vmalloc
space. For arm64, this is ~240GB for 4k pagesize and ~2TB
for 64kpage size.

This patch works around this problem by adding a loop limit.
If the range is larger than the limit, use flush_tlb_all()
rather than flushing based on individual pages. The limit
chosen is arbitrary and would be better if based on the
actual size of the tlb. I looked through the ARM ARM but
didn't see any easy way to get the actual tlb size, so for
now the arbitrary limit is better than the soft lockup.

Signed-off-by: Mark Salter <msalter@redhat.com>
---
 arch/arm64/include/asm/tlbflush.h | 25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/include/asm/tlbflush.h b/arch/arm64/include/asm/tlbflush.h
index b9349c4..af3e572 100644
--- a/arch/arm64/include/asm/tlbflush.h
+++ b/arch/arm64/include/asm/tlbflush.h
@@ -98,8 +98,8 @@ static inline void flush_tlb_page(struct vm_area_struct *vma,
 	dsb(ish);
 }
 
-static inline void flush_tlb_range(struct vm_area_struct *vma,
-					unsigned long start, unsigned long end)
+static inline void __flush_tlb_range(struct vm_area_struct *vma,
+				     unsigned long start, unsigned long end)
 {
 	unsigned long asid = (unsigned long)ASID(vma->vm_mm) << 48;
 	unsigned long addr;
@@ -112,7 +112,9 @@ static inline void flush_tlb_range(struct vm_area_struct *vma,
 	dsb(ish);
 }
 
-static inline void flush_tlb_kernel_range(unsigned long start, unsigned long end)
+#define MAX_TLB_LOOP 1024
+
+static inline void __flush_tlb_kernel_range(unsigned long start, unsigned long end)
 {
 	unsigned long addr;
 	start >>= 12;
@@ -124,6 +126,23 @@ static inline void flush_tlb_kernel_range(unsigned long start, unsigned long end
 	dsb(ish);
 }
 
+static inline void flush_tlb_range(struct vm_area_struct *vma,
+				   unsigned long start, unsigned long end)
+{
+	if (((end - start) >> PAGE_SHIFT) < MAX_TLB_LOOP)
+		__flush_tlb_range(vma, start, end);
+	else
+		flush_tlb_mm(vma->vm_mm);
+}
+
+static inline void flush_tlb_kernel_range(unsigned long start, unsigned long end)
+{
+	if (((end - start) >> PAGE_SHIFT) < MAX_TLB_LOOP)
+		__flush_tlb_kernel_range(start, end);
+	else
+		flush_tlb_all();
+}
+
 /*
  * On AArch64, the cache coherency is handled via the set_pte_at() function.
  */
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
