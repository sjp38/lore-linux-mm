Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E2FAC4321B
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:41:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34A9921734
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:41:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Qsrqx7Gj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34A9921734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 609836B000A; Tue, 11 Jun 2019 10:41:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5421F6B000C; Tue, 11 Jun 2019 10:41:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 347216B000D; Tue, 11 Jun 2019 10:41:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 006A16B000A
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:41:45 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s22so3886178plp.5
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:41:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gzNr8cC+RcaEr7a/7B73Y02JTGGTEGr38/f2ngv8wBc=;
        b=YYGs34TaP1ASBOx8fOMSMq1zO6SYAVJmRc9YbiUIJJXY+M1YwUfgNo4qjxT8r8/jRq
         QGbKMX6nJ5wW3NmQGj2vcohK0T4ZiD2Lr6HI4diHt6rHQHbV8eaSuxbDs4kPfotIC0UT
         1dpALyqRjlmUlnAwfYfDYzhCfsQ74/xsPfUfAwCVvkprRqfuHyiA85qDvQaH8T+NAWJf
         yJtn3vWA+WhqaXQSJfB/7bnSKGw6OiO5bf/923hdMixsbGwe8WaF5nxyJuTML3QD3YlE
         AMSs3yYqwWd8oTo2h/eJQ2sdrhQJ/j2DKa7ZqG52qeOB1ywjhjP+kr4CbYMWpcxXRqsk
         W9IQ==
X-Gm-Message-State: APjAAAX6jYe9FC8UWuz0MkFh1MsyUH45F6tIs3MnctiDVsJHH9g3NL6f
	rEd1VuxT4zDlGviAMf+9FBCMnR0U7PE/w0YsEVgqR5Ly3HvN+GkTyJSZN4naUf9Sk+CjXJYVOIT
	W4IOzhHnwvVu8X6duM0l1ixkIdhOviuE7Z/hhZiiReF8/jA5eJ+9/Gk5rMZyLxf4=
X-Received: by 2002:a17:90a:3a85:: with SMTP id b5mr11138132pjc.84.1560264104572;
        Tue, 11 Jun 2019 07:41:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWhqy27WXAbze9JSwLdNF9RD/psb9O4o89xrlDyrYMgAue1HrsGxJhhKQ2gtq24uy7u5Zo
X-Received: by 2002:a17:90a:3a85:: with SMTP id b5mr11138066pjc.84.1560264103542;
        Tue, 11 Jun 2019 07:41:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560264103; cv=none;
        d=google.com; s=arc-20160816;
        b=PASDsw57eXtM6uJpnNsCW1Va9CtgLE47YRFxi57rJUeyT8ApyckRR/D7oL/Q/BACB1
         Bf/1zgU2aVJ2TUGiXiIvNvhnXOwawzPOFPlZd0bGlik8x41sYYfP8DSvmqb9bvk01beH
         znVFL6t3X35DNoKWk1spg59NHnUq3Y9D9NJIKQSi0U6Bu9+UmQ9iZCfoz/vMBuipM/2E
         nIVF1l3f/RgILhNr/2YfTZwh35GBpLkTTWjgRmSLUPskl7sjK2fvcqlPOj+HnwrO1D9n
         x4oxqRo5s/vlZxtbKiqYKPJAbubepzEHkmQg69P911W4+g3GXw+yECywe74NchSYarzw
         lZcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=gzNr8cC+RcaEr7a/7B73Y02JTGGTEGr38/f2ngv8wBc=;
        b=VzR8Y/D7qmA8+XzRQIEobpLZWZqGZM9iUbNjT9KIgxtSffDtpkJFR1Xca66xAoqiGe
         fZEzOlqJ33UMvM9GaBaIKzIQgxOHzhuRMUPVv2v76b3/yNAOkX4kRpn+yjFL4sj9mgAZ
         bK2d3uXFz9gVmX/jbOoSgxYD5qNlmeRe0pyzKDebhAnQge0KasrxMvppoXlDzrXLPiz9
         7PtAmntNbJTo/SNetCm0enFHoL+DCugW2ImD1fijaj2y6r8Xod/8wF8P07+F+//i1dv4
         Ckimxv2CyDWe20uq6RWMqipRw1U3Lbvz+qmatOXUGTmy7oAF5QnQviUpc+tPzA8L8lYX
         LJsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Qsrqx7Gj;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s2si12667711pgp.566.2019.06.11.07.41.43
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 11 Jun 2019 07:41:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Qsrqx7Gj;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=gzNr8cC+RcaEr7a/7B73Y02JTGGTEGr38/f2ngv8wBc=; b=Qsrqx7Gjl2GC8vf87J1kV0OBS9
	Tt5zTsC9u5FMT4aBrJhjCtE6a9K5hEj6huEHcTGHIZTp0lPnrD3O3q6Taf6l5zAkrj04NvtpjMFZz
	QSbVSiRFTFj1K1DWEpoIo8npKLbZp/icZRb4FmghwPVhUl2hQQ3GZ8V/iVwFa0djVedxsNvetvYQ/
	U8rrAK2RSgtkuzMw1qKgToiMIX3BNteGcXa0JARj45dk/04PT26mlULgR6rFGQSTQUrd9alXQpxPZ
	v2Ok1HiUy9mTgFSunZi7dGsxAIdFawyIN5trdPG1sAjbfv2nBSw2rK5taBkGiygEsnDU61sdcdRaz
	phR5Tu6w==;
Received: from mpp-cp1-natpool-1-037.ethz.ch ([82.130.71.37] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hahxZ-0005O7-RH; Tue, 11 Jun 2019 14:41:14 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 02/16] mm: simplify gup_fast_permitted
Date: Tue, 11 Jun 2019 16:40:48 +0200
Message-Id: <20190611144102.8848-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190611144102.8848-1-hch@lst.de>
References: <20190611144102.8848-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Pass in the already calculated end value instead of recomputing it, and
leave the end > start check in the callers instead of duplicating them
in the arch code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/s390/include/asm/pgtable.h   |  8 +-------
 arch/x86/include/asm/pgtable_64.h |  8 +-------
 mm/gup.c                          | 17 +++++++----------
 3 files changed, 9 insertions(+), 24 deletions(-)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 9f0195d5fa16..9b274fcaacb6 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1270,14 +1270,8 @@ static inline pte_t *pte_offset(pmd_t *pmd, unsigned long address)
 #define pte_offset_map(pmd, address) pte_offset_kernel(pmd, address)
 #define pte_unmap(pte) do { } while (0)
 
-static inline bool gup_fast_permitted(unsigned long start, int nr_pages)
+static inline bool gup_fast_permitted(unsigned long start, unsigned long end)
 {
-	unsigned long len, end;
-
-	len = (unsigned long) nr_pages << PAGE_SHIFT;
-	end = start + len;
-	if (end < start)
-		return false;
 	return end <= current->mm->context.asce_limit;
 }
 #define gup_fast_permitted gup_fast_permitted
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 0bb566315621..4990d26dfc73 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -259,14 +259,8 @@ extern void init_extra_mapping_uc(unsigned long phys, unsigned long size);
 extern void init_extra_mapping_wb(unsigned long phys, unsigned long size);
 
 #define gup_fast_permitted gup_fast_permitted
-static inline bool gup_fast_permitted(unsigned long start, int nr_pages)
+static inline bool gup_fast_permitted(unsigned long start, unsigned long end)
 {
-	unsigned long len, end;
-
-	len = (unsigned long)nr_pages << PAGE_SHIFT;
-	end = start + len;
-	if (end < start)
-		return false;
 	if (end >> __VIRTUAL_MASK_SHIFT)
 		return false;
 	return true;
diff --git a/mm/gup.c b/mm/gup.c
index 6bb521db67ec..3237f33792e6 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2123,13 +2123,9 @@ static void gup_pgd_range(unsigned long addr, unsigned long end,
  * Check if it's allowed to use __get_user_pages_fast() for the range, or
  * we need to fall back to the slow version:
  */
-bool gup_fast_permitted(unsigned long start, int nr_pages)
+static bool gup_fast_permitted(unsigned long start, unsigned long end)
 {
-	unsigned long len, end;
-
-	len = (unsigned long) nr_pages << PAGE_SHIFT;
-	end = start + len;
-	return end >= start;
+	return true;
 }
 #endif
 
@@ -2150,6 +2146,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
 
+	if (end <= start)
+		return 0;
 	if (unlikely(!access_ok((void __user *)start, len)))
 		return 0;
 
@@ -2165,7 +2163,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	 * block IPIs that come from THPs splitting.
 	 */
 
-	if (gup_fast_permitted(start, nr_pages)) {
+	if (gup_fast_permitted(start, end)) {
 		local_irq_save(flags);
 		gup_pgd_range(start, end, write ? FOLL_WRITE : 0, pages, &nr);
 		local_irq_restore(flags);
@@ -2224,13 +2222,12 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
 
-	if (nr_pages <= 0)
+	if (end <= start)
 		return 0;
-
 	if (unlikely(!access_ok((void __user *)start, len)))
 		return -EFAULT;
 
-	if (gup_fast_permitted(start, nr_pages)) {
+	if (gup_fast_permitted(start, end)) {
 		local_irq_disable();
 		gup_pgd_range(addr, end, gup_flags, pages, &nr);
 		local_irq_enable();
-- 
2.20.1

