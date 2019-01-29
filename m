Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 093BBC3E8A4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B75A22184D
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B75A22184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C85FB8E0012; Tue, 29 Jan 2019 13:50:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C16898E0003; Tue, 29 Jan 2019 13:50:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A13188E0012; Tue, 29 Jan 2019 13:50:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 35C138E0003
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:28 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d41so8139751eda.12
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+/VkkUETllQIA07Icbpa2r7ErALoSIv6fRodU1kN9Fs=;
        b=SkIO++l8N8LJTe2DI7FFBWPLfVvHvzi7Huth+JL8IFMnIxA9sMnZz8PQoGNHD5cTNM
         cRTgSsgZYka0LVrIWjHLRpl87zLNSROmC1Fmkjb1Lvg7wpTguLj+nfsOL9SomK0fWHiJ
         iTpR4YXcBNJJz52l92sDHvzk8HXBm/8ikBR3CPrb558SHRBWA7cPW9y5dt42CWEXdwWm
         u7qQ6tQ3J6KAtMhzV0tJMC3ZP7kDeWkZqUa4frhrehz/AJHYJSoVF/ZzGLrqX5pg+xwc
         N8r2SsUQt+s5R6WwBQDLlzyxRPDXWUFYL/hbzG3iyzfseSF5ew90NzABQ0B81PDqtR52
         yyQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukcMknXg1PTQMyXu7nxveEWLxQausaagpi3tnoui9G8P0nhBdToL
	Z1Rkg0VQPRiVSc2fmMEu9K0wl7VSsrkI7axpQVwrcweGS7M38WUIUEcrvHHdgWF9D+YtkY3K9mm
	1DG+28njrGa87ab3iLe8xdKs2XovHdmgBYIW0wAe2kfryOReaR9HcUGvsPkjzsrPxYg==
X-Received: by 2002:a50:8bc9:: with SMTP id n9mr26805189edn.41.1548787827681;
        Tue, 29 Jan 2019 10:50:27 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6WZd1QvS2HSl0JR48aBN/S5MkzuN4LLc3/R+O8eg4j5u3z4Rh5iQfeSAFAryu2vkrvERRG
X-Received: by 2002:a50:8bc9:: with SMTP id n9mr26805123edn.41.1548787826561;
        Tue, 29 Jan 2019 10:50:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787826; cv=none;
        d=google.com; s=arc-20160816;
        b=lf+9TlL4ygzuI4nSpqjKuyWqkTmD4TIkCG0BQXv0XsG9/sXuWDV6awb0Pyuci+867D
         fY/ZL/T1YH1GMqqUSX8ly59kErJPdzYtG2udXNCz5S6YHwBj5zJ7uZmqA9UBscL05/sw
         QGdyHxwNkVvkA5Gp1kY0cSklCQVNwrV9mW31fncOUGWWC/+WS5iItC66Pq2dBYbqQ+Em
         b3vHdetIoxr7sH1CwZ6d7C9GWcejsrVPquTQaMp4hbxBHwNMTU+52Ey/KiaN7ZWmv5hd
         INFn156ommAtYGqpbl6x/oQXxmwOJVdrul1AvYYQCK4Igob0FaAWl4kLPLMFJKUZYgwZ
         b8wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=+/VkkUETllQIA07Icbpa2r7ErALoSIv6fRodU1kN9Fs=;
        b=Mdq6Ggsug2gBIJ2w0zUhIw0dT70cbi70KOB8bMVfhR69IhmJv2dApUCsO/v24WuegA
         FYfNWb/GBM2Af2V8PuI4HjkkkKBxhCfwrvYR6aaNPqTg+MV3ZxcCh57znYMYtytEOdVR
         x5d+ArOP8uqfR0WASNwR4+BjPY32WVDCS/3D382SEN3iW0nsA71CeGtNE0/VgR8vPaCI
         VDik0aC9AWyFBe1k0vg1ncaEP6TgRT7jNowA3oNxvh8APm+N9KScta8xiNVxicktMb2V
         ocLFl+RXP4dp1lo1F9SGCG5GdOZcJuf9cj9Dq+c8fWeXsNGEDkwVzF20H3pK1DyCXW4u
         z35w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f22si1914677ejw.196.2019.01.29.10.50.26
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:26 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 815EB15AB;
	Tue, 29 Jan 2019 10:50:25 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B11E93F557;
	Tue, 29 Jan 2019 10:50:22 -0800 (PST)
From: James Morse <james.morse@arm.com>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	Borislav Petkov <bp@alien8.de>,
	Marc Zyngier <marc.zyngier@arm.com>,
	Christoffer Dall <christoffer.dall@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Rafael Wysocki <rjw@rjwysocki.net>,
	Len Brown <lenb@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Dongjiu Geng <gengdongjiu@huawei.com>,
	Xie XiuQi <xiexiuqi@huawei.com>,
	james.morse@arm.com
Subject: [PATCH v8 16/26] ACPI / APEI: Let the notification helper specify the fixmap slot
Date: Tue, 29 Jan 2019 18:48:52 +0000
Message-Id: <20190129184902.102850-17-james.morse@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190129184902.102850-1-james.morse@arm.com>
References: <20190129184902.102850-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ghes_copy_tofrom_phys() uses a different fixmap slot depending on in_nmi().
This doesn't work when there are multiple NMI-like notifications, that
could interrupt each other.

As with the locking, move the chosen fixmap_idx to the notification helper.
This only matters for NMI-like notifications, anything calling
ghes_proc() can use the IRQ fixmap slot as its already holding an irqsave
spinlock.

This lets us collapse the ghes_ioremap_pfn_*() helpers.

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Borislav Petkov <bp@suse.de>
---

The fixmap-idx and vaddr are passed back to ghes_unmap()
to allow ioremap() to be used in process context in the
future. This will let us send tlbi-ipi for notifications
that don't mask irqs.

Changes since v7:
 * Wwitched unmap arg order for concistency, p/v addr is always first
 * use the enum name for the fixmap_idx, in the hope the compiler validates it.
---
 drivers/acpi/apei/ghes.c | 92 +++++++++++++++++-----------------------
 1 file changed, 39 insertions(+), 53 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index c6bc73281d6a..ccad57468ab7 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -41,6 +41,7 @@
 #include <linux/llist.h>
 #include <linux/genalloc.h>
 #include <linux/pci.h>
+#include <linux/pfn.h>
 #include <linux/aer.h>
 #include <linux/nmi.h>
 #include <linux/sched/clock.h>
@@ -127,38 +128,24 @@ static atomic_t ghes_estatus_cache_alloced;
 
 static int ghes_panic_timeout __read_mostly = 30;
 
-static void __iomem *ghes_ioremap_pfn_nmi(u64 pfn)
+static void __iomem *ghes_map(u64 pfn, enum fixed_addresses fixmap_idx)
 {
 	phys_addr_t paddr;
 	pgprot_t prot;
 
-	paddr = pfn << PAGE_SHIFT;
+	paddr = PFN_PHYS(pfn);
 	prot = arch_apei_get_mem_attribute(paddr);
-	__set_fixmap(FIX_APEI_GHES_NMI, paddr, prot);
+	__set_fixmap(fixmap_idx, paddr, prot);
 
-	return (void __iomem *) fix_to_virt(FIX_APEI_GHES_NMI);
+	return (void __iomem *) __fix_to_virt(fixmap_idx);
 }
 
-static void __iomem *ghes_ioremap_pfn_irq(u64 pfn)
+static void ghes_unmap(void __iomem *vaddr, enum fixed_addresses fixmap_idx)
 {
-	phys_addr_t paddr;
-	pgprot_t prot;
-
-	paddr = pfn << PAGE_SHIFT;
-	prot = arch_apei_get_mem_attribute(paddr);
-	__set_fixmap(FIX_APEI_GHES_IRQ, paddr, prot);
+	int _idx = virt_to_fix((unsigned long)vaddr);
 
-	return (void __iomem *) fix_to_virt(FIX_APEI_GHES_IRQ);
-}
-
-static void ghes_iounmap_nmi(void)
-{
-	clear_fixmap(FIX_APEI_GHES_NMI);
-}
-
-static void ghes_iounmap_irq(void)
-{
-	clear_fixmap(FIX_APEI_GHES_IRQ);
+	WARN_ON_ONCE(fixmap_idx != _idx);
+	clear_fixmap(fixmap_idx);
 }
 
 int ghes_estatus_pool_init(int num_ghes)
@@ -283,20 +270,16 @@ static inline int ghes_severity(int severity)
 }
 
 static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
-				  int from_phys)
+				  int from_phys,
+				  enum fixed_addresses fixmap_idx)
 {
 	void __iomem *vaddr;
-	int in_nmi = in_nmi();
 	u64 offset;
 	u32 trunk;
 
 	while (len > 0) {
 		offset = paddr - (paddr & PAGE_MASK);
-		if (in_nmi) {
-			vaddr = ghes_ioremap_pfn_nmi(paddr >> PAGE_SHIFT);
-		} else {
-			vaddr = ghes_ioremap_pfn_irq(paddr >> PAGE_SHIFT);
-		}
+		vaddr = ghes_map(PHYS_PFN(paddr), fixmap_idx);
 		trunk = PAGE_SIZE - offset;
 		trunk = min(trunk, len);
 		if (from_phys)
@@ -306,15 +289,13 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 		len -= trunk;
 		paddr += trunk;
 		buffer += trunk;
-		if (in_nmi) {
-			ghes_iounmap_nmi();
-		} else {
-			ghes_iounmap_irq();
-		}
+		ghes_unmap(vaddr, fixmap_idx);
 	}
 }
 
-static int ghes_read_estatus(struct ghes *ghes, u64 *buf_paddr)
+static int ghes_read_estatus(struct ghes *ghes, u64 *buf_paddr,
+			     enum fixed_addresses fixmap_idx)
+
 {
 	struct acpi_hest_generic *g = ghes->generic;
 	u32 len;
@@ -332,7 +313,7 @@ static int ghes_read_estatus(struct ghes *ghes, u64 *buf_paddr)
 		return -ENOENT;
 
 	ghes_copy_tofrom_phys(ghes->estatus, *buf_paddr,
-			      sizeof(*ghes->estatus), 1);
+			      sizeof(*ghes->estatus), 1, fixmap_idx);
 	if (!ghes->estatus->block_status) {
 		*buf_paddr = 0;
 		return -ENOENT;
@@ -348,7 +329,7 @@ static int ghes_read_estatus(struct ghes *ghes, u64 *buf_paddr)
 		goto err_read_block;
 	ghes_copy_tofrom_phys(ghes->estatus + 1,
 			      *buf_paddr + sizeof(*ghes->estatus),
-			      len - sizeof(*ghes->estatus), 1);
+			      len - sizeof(*ghes->estatus), 1, fixmap_idx);
 	if (cper_estatus_check(ghes->estatus))
 		goto err_read_block;
 	rc = 0;
@@ -361,7 +342,8 @@ static int ghes_read_estatus(struct ghes *ghes, u64 *buf_paddr)
 	return rc;
 }
 
-static void ghes_clear_estatus(struct ghes *ghes, u64 buf_paddr)
+static void ghes_clear_estatus(struct ghes *ghes, u64 buf_paddr,
+			       enum fixed_addresses fixmap_idx)
 {
 	ghes->estatus->block_status = 0;
 
@@ -369,7 +351,8 @@ static void ghes_clear_estatus(struct ghes *ghes, u64 buf_paddr)
 		return;
 
 	ghes_copy_tofrom_phys(ghes->estatus, buf_paddr,
-			      sizeof(ghes->estatus->block_status), 0);
+			      sizeof(ghes->estatus->block_status), 0,
+			      fixmap_idx);
 
 	/*
 	 * GHESv2 type HEST entries introduce support for error acknowledgment,
@@ -668,11 +651,12 @@ static void ghes_estatus_cache_add(
 	rcu_read_unlock();
 }
 
-static void __ghes_panic(struct ghes *ghes, u64 buf_paddr)
+static void __ghes_panic(struct ghes *ghes, u64 buf_paddr,
+			 enum fixed_addresses fixmap_idx)
 {
 	__ghes_print_estatus(KERN_EMERG, ghes->generic, ghes->estatus);
 
-	ghes_clear_estatus(ghes, buf_paddr);
+	ghes_clear_estatus(ghes, buf_paddr, fixmap_idx);
 
 	/* reboot to log the error! */
 	if (!panic_timeout)
@@ -685,12 +669,12 @@ static int ghes_proc(struct ghes *ghes)
 	u64 buf_paddr;
 	int rc;
 
-	rc = ghes_read_estatus(ghes, &buf_paddr);
+	rc = ghes_read_estatus(ghes, &buf_paddr, FIX_APEI_GHES_IRQ);
 	if (rc)
 		goto out;
 
 	if (ghes_severity(ghes->estatus->error_severity) >= GHES_SEV_PANIC) {
-		__ghes_panic(ghes, buf_paddr);
+		__ghes_panic(ghes, buf_paddr, FIX_APEI_GHES_IRQ);
 	}
 
 	if (!ghes_estatus_cached(ghes->estatus)) {
@@ -700,7 +684,7 @@ static int ghes_proc(struct ghes *ghes)
 	ghes_do_proc(ghes, ghes->estatus);
 
 out:
-	ghes_clear_estatus(ghes, buf_paddr);
+	ghes_clear_estatus(ghes, buf_paddr, FIX_APEI_GHES_IRQ);
 
 	return rc;
 }
@@ -866,36 +850,38 @@ static void __process_error(struct ghes *ghes)
 #endif
 }
 
-static int ghes_in_nmi_queue_one_entry(struct ghes *ghes)
+static int ghes_in_nmi_queue_one_entry(struct ghes *ghes,
+				       enum fixed_addresses fixmap_idx)
 {
 	u64 buf_paddr;
 	int sev;
 
-	if (ghes_read_estatus(ghes, &buf_paddr)) {
-		ghes_clear_estatus(ghes, buf_paddr);
+	if (ghes_read_estatus(ghes, &buf_paddr, fixmap_idx)) {
+		ghes_clear_estatus(ghes, buf_paddr, fixmap_idx);
 		return -ENOENT;
 	}
 
 	sev = ghes_severity(ghes->estatus->error_severity);
 	if (sev >= GHES_SEV_PANIC) {
 		ghes_print_queued_estatus();
-		__ghes_panic(ghes, buf_paddr);
+		__ghes_panic(ghes, buf_paddr, fixmap_idx);
 	}
 
 	__process_error(ghes);
-	ghes_clear_estatus(ghes, buf_paddr);
+	ghes_clear_estatus(ghes, buf_paddr, fixmap_idx);
 
 	return 0;
 }
 
-static int ghes_in_nmi_spool_from_list(struct list_head *rcu_list)
+static int ghes_in_nmi_spool_from_list(struct list_head *rcu_list,
+				       enum fixed_addresses fixmap_idx)
 {
 	int err, ret = -ENOENT;
 	struct ghes *ghes;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ghes, rcu_list, list) {
-		err = ghes_in_nmi_queue_one_entry(ghes);
+		err = ghes_in_nmi_queue_one_entry(ghes, fixmap_idx);
 		if (!err)
 			ret = 0;
 	}
@@ -920,7 +906,7 @@ int ghes_notify_sea(void)
 	int rv;
 
 	raw_spin_lock(&ghes_notify_lock_sea);
-	rv = ghes_in_nmi_spool_from_list(&ghes_sea);
+	rv = ghes_in_nmi_spool_from_list(&ghes_sea, FIX_APEI_GHES_NMI);
 	raw_spin_unlock(&ghes_notify_lock_sea);
 
 	return rv;
@@ -963,7 +949,7 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 		return ret;
 
 	raw_spin_lock(&ghes_notify_lock_nmi);
-	err = ghes_in_nmi_spool_from_list(&ghes_nmi);
+	err = ghes_in_nmi_spool_from_list(&ghes_nmi, FIX_APEI_GHES_NMI);
 	if (!err)
 		ret = NMI_HANDLED;
 	raw_spin_unlock(&ghes_notify_lock_nmi);
-- 
2.20.1

