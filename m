Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FF8FC43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F5C0218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F5C0218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96E538E0014; Wed, 26 Dec 2018 08:37:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D989B8E000B; Wed, 26 Dec 2018 08:37:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 331328E0012; Wed, 26 Dec 2018 08:37:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id F060C8E000F
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id j8so14043785plb.1
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=6JH+5134M+Wd4TDdow5m8EKsrfFes0kHVggXCeZOfv0=;
        b=I3N/EAx180/+wPSbW+Zrehm9CyrS6NmzOZCC9uzzOOPjsLrRHIbMleMPORu1mmu6ev
         b5/vZX6puEk1SuOZyHF+LpoNVWNazKPxEgSCOtGPEp/wYxJRZzFv6lcomvlVbKvx7JMe
         yk3AP8ceSVUG8jPaCMJCPAW+A5yUcHNujPtD9htJ4XCRu/p+gVY4vRidB2BDGo6OVLo3
         TgQAce6MgONdf/SKai+J6wLA64sEDqxQQh8evhnuwSx9Ju7Kfn+KPymltydt8QHU9FIm
         fipi3/PwsyYZPZMsXcpOIn8RgzPnzmZ5wCu0EVFdYlHLBFqlK1h5Ufy4DVuTkZ8hfEsD
         q8KA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AA+aEWZxio+8XHxqGv089KdmA4+jz4hitEXsJr2KnfgQKRxxzIy2awOM
	lclUQVjet1s35FLcbBKXQ5eVfsVDcu5hLp43/JbqTB52x4q5HtvwGl68DCyhtBSEDxJlbL3961U
	y9Zbw7WJWgQAI+0If7525rzqtseyaytSRySZKSUGFPPHGfepJlDWJQeCR0iZtXnC5WA==
X-Received: by 2002:a62:8dd9:: with SMTP id p86mr19985990pfk.143.1545831427660;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-Smtp-Source: AFSGD/WfAIrtd9BaOkQrMtJIFLpT4mJ5+LIWkSNtPQmGicS4oNPDbPrH3gchuEXzsqb981Uu2ZFy
X-Received: by 2002:a62:8dd9:: with SMTP id p86mr19985958pfk.143.1545831427092;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831427; cv=none;
        d=google.com; s=arc-20160816;
        b=EKxwVVGHfuEtwAjiunUz68FOWSr3pWUnMVatEpnsszkV3YQJhgY3E2pYjPS+4Z8qT0
         QW5SNakTPA8syQt+UwcLq7XckVcyylRtUwECewodRa/n3W5dflY7jYYBuIdHNDSIxBta
         Lgd2xC3O6N4Yepr75TREhoUC5ElIPhgL8ToMFRKCkL1y9zzZG2FLgzS0b+bJwBIj5nHd
         GWmDEaXtI/pSXQHm4XYV2vQl7sHne8P5SHurS6//ZK8vCG60ymxK87KL83dbJb2kYxpX
         JsOkS4Q5OVWZ88tW+f0c6nsr2d7H1IvmUhg48bHS0ArbYE5lnt9xLH+auT+x5XPfm9ju
         GVFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=6JH+5134M+Wd4TDdow5m8EKsrfFes0kHVggXCeZOfv0=;
        b=XE/nkR7Q71/VqXvZ26AZ4ONZZPPr8GljfJ2lGr8thYGj9iRpD0CcZrjvB8nAsD4879
         AsXOVI2CpQqt/see+p75dlatMGkLVKGh42kHaPnhEn9FfedDGZGVPxknnU2Jbbsopi0h
         Wy5ut4eptNo6GJgdV8Ec/fn0fEhgAl7mpQipz8qMPLcrrCn3+mEEMMvGriqZqKwIraQQ
         Z/CYRKcYqd5A831VaiJUNTQpEDS3ShT9SxH5AHelKsz/mwFHX/YsfQfmgaPr+4G4Fqfs
         RR26oDKnAEGzdpmuVYc2uAAqsbB5fBqA/5w3ih/ABFVxIo2HiZM+Um6KIfLY09v0ML6h
         k+qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id c7si33395890pgg.339.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:06 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="121185476"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by FMSMGA003.fm.intel.com with ESMTP; 26 Dec 2018 05:37:02 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005P3-JE; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133351.956098465@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:15:01 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Dave Hansen <dave.hansen@intel.com>,
 Peng Dong <dongx.peng@intel.com>,
 Liu Jingqi <jingqi.liu@intel.com>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Fan Du <fan.du@intel.com>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Huang Ying <ying.huang@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 15/21] ept-idle: EPT walk for virtual machine
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0014-kvm-ept-idle-EPT-page-table-walk-for-A-bits.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131501.laS3Q8VhDZjNU1Sdvcd4JVAyXOew2IGchiUBl2pTHRs@z>

For virtual machines, "accessed" bits will be set in guest page tables
and EPT/NPT. So for qemu-kvm process, convert HVA to GFN to GPA, then do
EPT/NPT walks.

This borrows host page table walk macros/functions to do EPT/NPT walk.
So it depends on them using the same level.

As proposed by Dave Hansen, invalidate TLB when finished one round of
scan, in order to ensure HW will set accessed bit for super-hot pages.

V2: convert idle_bitmap to idle_pages to be more efficient on
- huge pages
- sparse page table
- ranges of similar pages

The new idle_pages file contains a series of records of different size
reporting ranges of different page size to user space. That interface
has a major downside: it breaks read() assumption about range_to_read ==
read_buffer_size. Now we workaround this problem by deducing
range_to_read from read_buffer_size, and let read() return when either
read_buffer_size is filled, or range_to_read is fully scanned.

To make a more precise interface, we may need further switch to ioctl().

CC: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Peng Dong <dongx.peng@intel.com>
Signed-off-by: Liu Jingqi <jingqi.liu@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/kvm/ept_idle.c |  637 ++++++++++++++++++++++++++++++++++++++
 arch/x86/kvm/ept_idle.h |  116 ++++++
 2 files changed, 753 insertions(+)
 create mode 100644 arch/x86/kvm/ept_idle.c
 create mode 100644 arch/x86/kvm/ept_idle.h

--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/x86/kvm/ept_idle.c	2018-12-26 20:38:07.298994533 +0800
@@ -0,0 +1,637 @@
+// SPDX-License-Identifier: GPL-2.0
+#include <linux/pagemap.h>
+#include <linux/mm.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/proc_fs.h>
+#include <linux/uaccess.h>
+#include <linux/kvm.h>
+#include <linux/kvm_host.h>
+#include <linux/bitmap.h>
+#include <linux/sched/mm.h>
+#include <asm/tlbflush.h>
+
+#include "ept_idle.h"
+
+/* #define DEBUG 1 */
+
+#ifdef DEBUG
+
+#define debug_printk trace_printk
+
+#define set_restart_gpa(val, note)	({			\
+	unsigned long old_val = eic->restart_gpa;		\
+	eic->restart_gpa = (val);				\
+	trace_printk("restart_gpa=%lx %luK  %s  %s %d\n",	\
+		     (val), (eic->restart_gpa - old_val) >> 10,	\
+		     note, __func__, __LINE__);			\
+})
+
+#define set_next_hva(val, note)	({				\
+	unsigned long old_val = eic->next_hva;			\
+	eic->next_hva = (val);					\
+	trace_printk("   next_hva=%lx %luK  %s  %s %d\n",	\
+		     (val), (eic->next_hva - old_val) >> 10,	\
+		     note, __func__, __LINE__);			\
+})
+
+#else
+
+#define debug_printk(...)
+
+#define set_restart_gpa(val, note)	({			\
+	eic->restart_gpa = (val);				\
+})
+
+#define set_next_hva(val, note)	({				\
+	eic->next_hva = (val);					\
+})
+
+#endif
+
+static unsigned long pagetype_size[16] = {
+	[PTE_ACCESSED]	= PAGE_SIZE,	/* 4k page */
+	[PMD_ACCESSED]	= PMD_SIZE,	/* 2M page */
+	[PUD_PRESENT]	= PUD_SIZE,	/* 1G page */
+
+	[PTE_DIRTY]	= PAGE_SIZE,
+	[PMD_DIRTY]	= PMD_SIZE,
+
+	[PTE_IDLE]	= PAGE_SIZE,
+	[PMD_IDLE]	= PMD_SIZE,
+	[PMD_IDLE_PTES] = PMD_SIZE,
+
+	[PTE_HOLE]	= PAGE_SIZE,
+	[PMD_HOLE]	= PMD_SIZE,
+};
+
+static void u64_to_u8(uint64_t n, uint8_t *p)
+{
+	p += sizeof(uint64_t) - 1;
+
+	*p-- = n; n >>= 8;
+	*p-- = n; n >>= 8;
+	*p-- = n; n >>= 8;
+	*p-- = n; n >>= 8;
+
+	*p-- = n; n >>= 8;
+	*p-- = n; n >>= 8;
+	*p-- = n; n >>= 8;
+	*p   = n;
+}
+
+static void dump_eic(struct ept_idle_ctrl *eic)
+{
+	debug_printk("ept_idle_ctrl: pie_read=%d pie_read_max=%d buf_size=%d "
+		     "bytes_copied=%d next_hva=%lx restart_gpa=%lx "
+		     "gpa_to_hva=%lx\n",
+		     eic->pie_read,
+		     eic->pie_read_max,
+		     eic->buf_size,
+		     eic->bytes_copied,
+		     eic->next_hva,
+		     eic->restart_gpa,
+		     eic->gpa_to_hva);
+}
+
+static void eic_report_addr(struct ept_idle_ctrl *eic, unsigned long addr)
+{
+	unsigned long hva;
+	eic->kpie[eic->pie_read++] = PIP_CMD_SET_HVA;
+	hva = addr;
+	u64_to_u8(hva, &eic->kpie[eic->pie_read]);
+	eic->pie_read += sizeof(uint64_t);
+	debug_printk("eic_report_addr %lx\n", addr);
+	dump_eic(eic);
+}
+
+static int eic_add_page(struct ept_idle_ctrl *eic,
+			unsigned long addr,
+			unsigned long next,
+			enum ProcIdlePageType page_type)
+{
+	int page_size = pagetype_size[page_type];
+
+	debug_printk("eic_add_page addr=%lx next=%lx "
+		     "page_type=%d pagesize=%dK\n",
+		     addr, next, (int)page_type, (int)page_size >> 10);
+	dump_eic(eic);
+
+	/* align kernel/user vision of cursor position */
+	next = round_up(next, page_size);
+
+	if (!eic->pie_read ||
+	    addr + eic->gpa_to_hva != eic->next_hva) {
+		/* merge hole */
+		if (page_type == PTE_HOLE ||
+		    page_type == PMD_HOLE) {
+			set_restart_gpa(next, "PTE_HOLE|PMD_HOLE");
+			return 0;
+		}
+
+		if (addr + eic->gpa_to_hva < eic->next_hva) {
+			debug_printk("ept_idle: addr moves backwards\n");
+			WARN_ONCE(1, "ept_idle: addr moves backwards");
+		}
+
+		if (eic->pie_read + sizeof(uint64_t) + 2 >= eic->pie_read_max) {
+			set_restart_gpa(addr, "EPT_IDLE_KBUF_FULL");
+			return EPT_IDLE_KBUF_FULL;
+		}
+
+		eic_report_addr(eic, round_down(addr, page_size) +
+							eic->gpa_to_hva);
+	} else {
+		if (PIP_TYPE(eic->kpie[eic->pie_read - 1]) == page_type &&
+		    PIP_SIZE(eic->kpie[eic->pie_read - 1]) < 0xF) {
+			set_next_hva(next + eic->gpa_to_hva, "IN-PLACE INC");
+			set_restart_gpa(next, "IN-PLACE INC");
+			eic->kpie[eic->pie_read - 1]++;
+			WARN_ONCE(page_size < next-addr, "next-addr too large");
+			return 0;
+		}
+		if (eic->pie_read >= eic->pie_read_max) {
+			set_restart_gpa(addr, "EPT_IDLE_KBUF_FULL");
+			return EPT_IDLE_KBUF_FULL;
+		}
+	}
+
+	set_next_hva(next + eic->gpa_to_hva, "NEW-ITEM");
+	set_restart_gpa(next, "NEW-ITEM");
+	eic->kpie[eic->pie_read] = PIP_COMPOSE(page_type, 1);
+	eic->pie_read++;
+
+	return 0;
+}
+
+static int ept_pte_range(struct ept_idle_ctrl *eic,
+			 pmd_t *pmd, unsigned long addr, unsigned long end)
+{
+	pte_t *pte;
+	enum ProcIdlePageType page_type;
+	int err = 0;
+
+	pte = pte_offset_kernel(pmd, addr);
+	do {
+		if (!ept_pte_present(*pte))
+			page_type = PTE_HOLE;
+		else if (!test_and_clear_bit(_PAGE_BIT_EPT_ACCESSED,
+					     (unsigned long *) &pte->pte))
+			page_type = PTE_IDLE;
+		else {
+			page_type = PTE_ACCESSED;
+		}
+
+		err = eic_add_page(eic, addr, addr + PAGE_SIZE, page_type);
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
+	enum ProcIdlePageType page_type;
+	enum ProcIdlePageType pte_page_type;
+	int err = 0;
+
+	if (eic->flags & SCAN_HUGE_PAGE)
+		pte_page_type = PMD_IDLE_PTES;
+	else
+		pte_page_type = IDLE_PAGE_TYPE_MAX;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+
+		if (!ept_pmd_present(*pmd))
+			page_type = PMD_HOLE;	/* likely won't hit here */
+		else if (!test_and_clear_bit(_PAGE_BIT_EPT_ACCESSED,
+					     (unsigned long *)pmd)) {
+			if (pmd_large(*pmd))
+				page_type = PMD_IDLE;
+			else if (eic->flags & SCAN_SKIM_IDLE)
+				page_type = PMD_IDLE_PTES;
+			else
+				page_type = pte_page_type;
+		} else if (pmd_large(*pmd)) {
+			page_type = PMD_ACCESSED;
+		} else
+			page_type = pte_page_type;
+
+		if (page_type != IDLE_PAGE_TYPE_MAX)
+			err = eic_add_page(eic, addr, next, page_type);
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
+
+	pud = pud_offset(p4d, addr);
+	do {
+		next = pud_addr_end(addr, end);
+
+		if (!ept_pud_present(*pud)) {
+			set_restart_gpa(next, "PUD_HOLE");
+			continue;
+		}
+
+		if (pud_large(*pud))
+			err = eic_add_page(eic, addr, next, PUD_PRESENT);
+		else
+			err = ept_pmd_range(eic, pud, addr, next);
+
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
+		if (!ept_p4d_present(*p4d)) {
+			set_restart_gpa(next, "P4D_HOLE");
+			continue;
+		}
+
+		err = ept_pud_range(eic, p4d, addr, next);
+		if (err)
+			break;
+	} while (p4d++, addr = next, addr != end);
+
+	return err;
+}
+
+static int ept_page_range(struct ept_idle_ctrl *eic,
+			  unsigned long addr,
+			  unsigned long end)
+{
+	struct kvm_vcpu *vcpu;
+	struct kvm_mmu *mmu;
+	pgd_t *ept_root;
+	pgd_t *pgd;
+	unsigned long next;
+	int err = 0;
+
+	BUG_ON(addr >= end);
+
+	spin_lock(&eic->kvm->mmu_lock);
+
+	vcpu = kvm_get_vcpu(eic->kvm, 0);
+	if (!vcpu) {
+		err = -EINVAL;
+		goto out_unlock;
+	}
+
+	mmu = vcpu->arch.mmu;
+	if (!VALID_PAGE(mmu->root_hpa)) {
+		err = -EINVAL;
+		goto out_unlock;
+	}
+
+	ept_root = __va(mmu->root_hpa);
+
+	local_irq_disable();
+	pgd = pgd_offset_pgd(ept_root, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (!ept_pgd_present(*pgd)) {
+			set_restart_gpa(next, "PGD_HOLE");
+			continue;
+		}
+
+		err = ept_p4d_range(eic, pgd, addr, next);
+		if (err)
+			break;
+	} while (pgd++, addr = next, addr != end);
+	local_irq_enable();
+out_unlock:
+	spin_unlock(&eic->kvm->mmu_lock);
+	return err;
+}
+
+static void init_ept_idle_ctrl_buffer(struct ept_idle_ctrl *eic)
+{
+	eic->pie_read = 0;
+	eic->pie_read_max = min(EPT_IDLE_KBUF_SIZE,
+				eic->buf_size - eic->bytes_copied);
+	/* reserve space for PIP_CMD_SET_HVA in the end */
+	eic->pie_read_max -= sizeof(uint64_t) + 1;
+	memset(eic->kpie, 0, sizeof(eic->kpie));
+}
+
+static int ept_idle_copy_user(struct ept_idle_ctrl *eic,
+			      unsigned long start, unsigned long end)
+{
+	int bytes_read;
+	int lc = 0;	/* last copy? */
+	int ret;
+
+	debug_printk("ept_idle_copy_user %lx %lx\n", start, end);
+	dump_eic(eic);
+
+	/* Break out of loop on no more progress. */
+	if (!eic->pie_read) {
+		lc = 1;
+		if (start < end)
+			start = end;
+	}
+
+	if (start >= end && start > eic->next_hva) {
+		set_next_hva(start, "TAIL-HOLE");
+		eic_report_addr(eic, start);
+	}
+
+	bytes_read = eic->pie_read;
+	if (!bytes_read)
+		return 1;
+
+	ret = copy_to_user(eic->buf, eic->kpie, bytes_read);
+	if (ret)
+		return -EFAULT;
+
+	eic->buf += bytes_read;
+	eic->bytes_copied += bytes_read;
+	if (eic->bytes_copied >= eic->buf_size)
+		return EPT_IDLE_BUF_FULL;
+	if (lc)
+		return lc;
+
+	init_ept_idle_ctrl_buffer(eic);
+	cond_resched();
+	return 0;
+}
+
+/*
+ * Depending on whether hva falls in a memslot:
+ *
+ * 1) found => return gpa and remaining memslot size in *addr_range
+ *
+ *                 |<----- addr_range --------->|
+ *         [               mem slot             ]
+ *                 ^hva
+ *
+ * 2) not found => return hole size in *addr_range
+ *
+ *                 |<----- addr_range --------->|
+ *                                              [   first mem slot above hva  ]
+ *                 ^hva
+ *
+ * If hva is above all mem slots, *addr_range will be ~0UL. We can finish read(2).
+ */
+static unsigned long ept_idle_find_gpa(struct ept_idle_ctrl *eic,
+				       unsigned long hva,
+				       unsigned long *addr_range)
+{
+	struct kvm *kvm = eic->kvm;
+	struct kvm_memslots *slots;
+	struct kvm_memory_slot *memslot;
+	unsigned long hva_end;
+	gfn_t gfn;
+
+	*addr_range = ~0UL;
+	mutex_lock(&kvm->slots_lock);
+	slots = kvm_memslots(eic->kvm);
+	kvm_for_each_memslot(memslot, slots) {
+		hva_end = memslot->userspace_addr +
+		    (memslot->npages << PAGE_SHIFT);
+
+		if (hva >= memslot->userspace_addr && hva < hva_end) {
+			gpa_t gpa;
+			gfn = hva_to_gfn_memslot(hva, memslot);
+			*addr_range = hva_end - hva;
+			gpa = gfn_to_gpa(gfn);
+			debug_printk("ept_idle_find_gpa slot %lx=>%llx %lx=>%llx "
+				     "delta %llx size %lx\n",
+				     memslot->userspace_addr,
+				     gfn_to_gpa(memslot->base_gfn),
+				     hva, gpa,
+				     hva - gpa,
+				     memslot->npages << PAGE_SHIFT);
+			mutex_unlock(&kvm->slots_lock);
+			return gpa;
+		}
+
+		if (memslot->userspace_addr > hva)
+			*addr_range = min(*addr_range,
+					  memslot->userspace_addr - hva);
+	}
+	mutex_unlock(&kvm->slots_lock);
+	return INVALID_PAGE;
+}
+
+static int ept_idle_supports_cpu(struct kvm *kvm)
+{
+	struct kvm_vcpu *vcpu;
+	struct kvm_mmu *mmu;
+	int ret;
+
+	vcpu = kvm_get_vcpu(kvm, 0);
+	if (!vcpu)
+		return -EINVAL;
+
+	spin_lock(&kvm->mmu_lock);
+	mmu = vcpu->arch.mmu;
+	if (mmu->mmu_role.base.ad_disabled) {
+		printk(KERN_NOTICE
+		       "CPU does not support EPT A/D bits tracking\n");
+		ret = -EINVAL;
+	} else if (mmu->shadow_root_level != 4 + (! !pgtable_l5_enabled())) {
+		printk(KERN_NOTICE "Unsupported EPT level %d\n",
+		       mmu->shadow_root_level);
+		ret = -EINVAL;
+	} else
+		ret = 0;
+	spin_unlock(&kvm->mmu_lock);
+
+	return ret;
+}
+
+static int ept_idle_walk_hva_range(struct ept_idle_ctrl *eic,
+				   unsigned long start, unsigned long end)
+{
+	unsigned long gpa_addr;
+	unsigned long addr_range;
+	int ret;
+
+	ret = ept_idle_supports_cpu(eic->kvm);
+	if (ret)
+		return ret;
+
+	init_ept_idle_ctrl_buffer(eic);
+
+	for (; start < end;) {
+		gpa_addr = ept_idle_find_gpa(eic, start, &addr_range);
+
+		if (gpa_addr == INVALID_PAGE) {
+			eic->gpa_to_hva = 0;
+			if (addr_range == ~0UL) /* beyond max virtual address */
+				set_restart_gpa(TASK_SIZE, "EOF");
+			else {
+				start += addr_range;
+				set_restart_gpa(start, "OUT-OF-SLOT");
+			}
+		} else {
+			eic->gpa_to_hva = start - gpa_addr;
+			ept_page_range(eic, gpa_addr, gpa_addr + addr_range);
+		}
+
+		start = eic->restart_gpa + eic->gpa_to_hva;
+		ret = ept_idle_copy_user(eic, start, end);
+		if (ret)
+			break;
+	}
+
+	if (eic->bytes_copied)
+		ret = 0;
+	return ret;
+}
+
+static ssize_t ept_idle_read(struct file *file, char *buf,
+			     size_t count, loff_t *ppos)
+{
+	struct mm_struct *mm = file->private_data;
+	struct ept_idle_ctrl *eic;
+	unsigned long hva_start = *ppos;
+	unsigned long hva_end = hva_start + (count << (3 + PAGE_SHIFT));
+	int ret;
+
+	if (hva_start >= TASK_SIZE) {
+		debug_printk("ept_idle_read past TASK_SIZE: %lx %lx\n",
+			     hva_start, TASK_SIZE);
+		return 0;
+	}
+
+	if (!mm_kvm(mm))
+		return mm_idle_read(file, buf, count, ppos);
+
+	if (hva_end <= hva_start) {
+		debug_printk("ept_idle_read past EOF: %lx %lx\n",
+			     hva_start, hva_end);
+		return 0;
+	}
+	if (*ppos & (PAGE_SIZE - 1)) {
+		debug_printk("ept_idle_read unaligned ppos: %lx\n",
+			     hva_start);
+		return -EINVAL;
+	}
+	if (count < EPT_IDLE_BUF_MIN) {
+		debug_printk("ept_idle_read small count: %lx\n",
+			     (unsigned long)count);
+		return -EINVAL;
+	}
+
+	eic = kzalloc(sizeof(*eic), GFP_KERNEL);
+	if (!eic)
+		return -ENOMEM;
+
+	if (!mm || !mmget_not_zero(mm)) {
+		ret = -ESRCH;
+		goto out_free_eic;
+	}
+
+	eic->buf = buf;
+	eic->buf_size = count;
+	eic->mm = mm;
+	eic->kvm = mm_kvm(mm);
+	if (!eic->kvm) {
+		ret = -EINVAL;
+		goto out_mm;
+	}
+
+	kvm_get_kvm(eic->kvm);
+
+	ret = ept_idle_walk_hva_range(eic, hva_start, hva_end);
+	if (ret)
+		goto out_kvm;
+
+	ret = eic->bytes_copied;
+	*ppos = eic->next_hva;
+	debug_printk("ppos=%lx bytes_copied=%d\n",
+		     eic->next_hva, ret);
+out_kvm:
+	kvm_put_kvm(eic->kvm);
+out_mm:
+	mmput(mm);
+out_free_eic:
+	kfree(eic);
+	return ret;
+}
+
+static int ept_idle_open(struct inode *inode, struct file *file)
+{
+	if (!try_module_get(THIS_MODULE))
+		return -EBUSY;
+
+	return 0;
+}
+
+static int ept_idle_release(struct inode *inode, struct file *file)
+{
+	struct mm_struct *mm = file->private_data;
+	struct kvm *kvm;
+	int ret = 0;
+
+	if (!mm) {
+		ret = -EBADF;
+		goto out;
+	}
+
+	kvm = mm_kvm(mm);
+	if (!kvm) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	spin_lock(&kvm->mmu_lock);
+	kvm_flush_remote_tlbs(kvm);
+	spin_unlock(&kvm->mmu_lock);
+
+out:
+	module_put(THIS_MODULE);
+	return ret;
+}
+
+extern struct file_operations proc_ept_idle_operations;
+
+static int ept_idle_entry(void)
+{
+	proc_ept_idle_operations.owner = THIS_MODULE;
+	proc_ept_idle_operations.read = ept_idle_read;
+	proc_ept_idle_operations.open = ept_idle_open;
+	proc_ept_idle_operations.release = ept_idle_release;
+
+	return 0;
+}
+
+static void ept_idle_exit(void)
+{
+	memset(&proc_ept_idle_operations, 0, sizeof(proc_ept_idle_operations));
+}
+
+MODULE_LICENSE("GPL");
+module_init(ept_idle_entry);
+module_exit(ept_idle_exit);
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/x86/kvm/ept_idle.h	2018-12-26 20:32:09.775444685 +0800
@@ -0,0 +1,116 @@
+#ifndef _EPT_IDLE_H
+#define _EPT_IDLE_H
+
+#define SCAN_HUGE_PAGE		O_NONBLOCK	/* only huge page */
+#define SCAN_SKIM_IDLE		O_NOFOLLOW	/* stop on PMD_IDLE_PTES */
+
+enum ProcIdlePageType {
+	PTE_ACCESSED,	/* 4k page */
+	PMD_ACCESSED,	/* 2M page */
+	PUD_PRESENT,	/* 1G page */
+
+	PTE_DIRTY,
+	PMD_DIRTY,
+
+	PTE_IDLE,
+	PMD_IDLE,
+	PMD_IDLE_PTES,	/* all PTE idle */
+
+	PTE_HOLE,
+	PMD_HOLE,
+
+	PIP_CMD,
+
+	IDLE_PAGE_TYPE_MAX
+};
+
+#define PIP_TYPE(a)		(0xf & (a >> 4))
+#define PIP_SIZE(a)		(0xf & a)
+#define PIP_COMPOSE(type, nr)	((type << 4) | nr)
+
+#define PIP_CMD_SET_HVA		PIP_COMPOSE(PIP_CMD, 0)
+
+#define _PAGE_BIT_EPT_ACCESSED	8
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
+extern struct file_operations proc_ept_idle_operations;
+
+#define EPT_IDLE_KBUF_FULL	1
+#define EPT_IDLE_BUF_FULL	2
+#define EPT_IDLE_BUF_MIN	(sizeof(uint64_t) * 2 + 3)
+
+#define EPT_IDLE_KBUF_SIZE	8000
+
+struct ept_idle_ctrl {
+	struct mm_struct *mm;
+	struct kvm *kvm;
+
+	uint8_t kpie[EPT_IDLE_KBUF_SIZE];
+	int pie_read;
+	int pie_read_max;
+
+	void __user *buf;
+	int buf_size;
+	int bytes_copied;
+
+	unsigned long next_hva;		/* GPA for EPT; VA for PT */
+	unsigned long gpa_to_hva;
+	unsigned long restart_gpa;
+	unsigned long last_va;
+
+	unsigned int flags;
+};
+
+#endif


