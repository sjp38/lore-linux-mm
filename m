Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E408C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25CD5217F5
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="emQSV/Lr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25CD5217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C08C16B0274; Wed, 27 Mar 2019 14:11:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB8016B0276; Wed, 27 Mar 2019 14:11:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A385F6B0277; Wed, 27 Mar 2019 14:11:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A70A6B0274
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:11:08 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h69so14629106pfd.21
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:11:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ie9IDzuRzDEggZMNI+wBt+yuU0GM45IC9DxWBR6/JZc=;
        b=DAjVsoSYugo1YwXGKaFiH+gkwc3kaENIdgZliaOzQdSGkL3k7A79LRHfXKSMrr6adc
         0okjsMc6Hk9JfTpNupTkbajZ5I1MryWF9TmxR07io8wHwaNwrA2JTlh7ccpYNk7GzzNn
         kaH8Ga/783GUX8SIIFhejUn56rUI72XykB9pYNner7ARHtPQtC1dyIcF7FlW48w5zibd
         2EmlQpmcZE2ia+Rvm2XTJBJRE218194XWzZ1Wz97NDHo5XgrVpSo6iTHSHmE7B7SpqdJ
         ifLM2CbjVJOUTTllqkZqGVZbQCnezZJx0TkLT8UjDG/QG+JumgU+3y6DI8SUHl/XxpQx
         ko6g==
X-Gm-Message-State: APjAAAWqnx6R0Zlwy0xFb+hkGK/KAaL2R5I3QFF6ui2x3AC8HVOhXoKy
	oM6uc25Ne2sxJM0eMUwiDLk24rVrh6lhuaRCvd9uIms4K5Yhs8ydJwfafOldbxJg7qj5X4jZdPn
	JujgyryphnZEmUj342BL8lyyMOLl7EBuV4VrV4YpXR1a4ooXItGl7/AI5SVFkVEYYAw==
X-Received: by 2002:a62:305:: with SMTP id 5mr15388919pfd.65.1553710267994;
        Wed, 27 Mar 2019 11:11:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyK1b0I548Tq+od38nOv+Qe3nAWT4++AlT1WJIpLjV+ASp3vwb04Hhsc0k6JahORZfsbSCe
X-Received: by 2002:a62:305:: with SMTP id 5mr15388823pfd.65.1553710267022;
        Wed, 27 Mar 2019 11:11:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710267; cv=none;
        d=google.com; s=arc-20160816;
        b=qVtjJCZG9B2TFLa4Ldtt3ixzj2LpuTjQwgBSgVdYIECleTToUPSnWYvsT4RhdeTf0/
         4tKnG/g70KokkLXgdUvpNNaZP3SRd2eqGWLJAwGO3y+RxcRL7bXvgwkK5WD+KKxwfebA
         IRTgtzpilkWFpZAK03AMCX3GsKtWRiqmYbKQ93KL9I6taWfYR/DV9a/9JwspJ+McoLAM
         Oa86fizy1CbdvNvjQdYSmj7jAcqlhJMB785UvYyNTVZ0bnrdEYobkjxde8td9Aqyafgl
         Ij2J4JFuIcbFkEyyfnAo+jeupdPDoNnPWwhaqKxqsZxnN7n2z2ocm7S/WhqPp9ntXa/k
         jWCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ie9IDzuRzDEggZMNI+wBt+yuU0GM45IC9DxWBR6/JZc=;
        b=0Jm1SADEZ4iCZDJ0BAi8SGezvM9hxGf+rzH0mlOag5OUXwcr2+dpx+oPyinyo35JqY
         AWVVkHptoB4bVo578/Lucjs/2dmn2wTrGBckg88E9JF+jiJfGmPzb7EgiGgqFS9II2xO
         0QbUH6k+ex1x6Io2S+OVGyRS6/V9P/8NfeqNbRdlJkXWn48/yPuryMR6rl96BJv0reuZ
         /RVLM73z1BDExD/I6BwbDMm6wUn3U52SV9W6dG6i7tr1x5aGxK8N4lx3zXMODifslgpc
         5wiOXBbYHwIfRHHy7EjFh4VZowOV9VqNfja8SuA3tvQzGCnKPsHWQNhf6QHP8Wjp9EPK
         r5yw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="emQSV/Lr";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y8si2684528pll.313.2019.03.27.11.11.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:11:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="emQSV/Lr";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1205121741;
	Wed, 27 Mar 2019 18:11:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710266;
	bh=+Xhq8faoi2KKC9uViiyoXBt3QVYHmA+7GhL1XAq+kkA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=emQSV/Lr6+a37qOiQiyaGjmxEPiEJT3irT0/1XdxQ3EXXIoW0+lbGW3v939vVl7kV
	 9kar51wzF91cK9QJeqzRKs/4l/tUswaSCOs9po+msEj+rQZuPDzgBeXmCYWqjTjFEc
	 Hfr/rN0z+396qQO5qwR/zkv/UEGggrMpuLdoJt94=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Andi Kleen <ak@linux.intel.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Omar Sandoval <osandov@fb.com>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Shaohua Li <shli@kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Tejun Heo <tj@kernel.org>,
	Will Deacon <will.deacon@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 024/192] mm, swap: bounds check swap_info array accesses to avoid NULL derefs
Date: Wed, 27 Mar 2019 14:07:36 -0400
Message-Id: <20190327181025.13507-24-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327181025.13507-1-sashal@kernel.org>
References: <20190327181025.13507-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Daniel Jordan <daniel.m.jordan@oracle.com>

[ Upstream commit c10d38cc8d3e43f946b6c2bf4602c86791587f30 ]

Dan Carpenter reports a potential NULL dereference in
get_swap_page_of_type:

  Smatch complains that the NULL checks on "si" aren't consistent.  This
  seems like a real bug because we have not ensured that the type is
  valid and so "si" can be NULL.

Add the missing check for NULL, taking care to use a read barrier to
ensure CPU1 observes CPU0's updates in the correct order:

     CPU0                           CPU1
     alloc_swap_info()              if (type >= nr_swapfiles)
       swap_info[type] = p              /* handle invalid entry */
       smp_wmb()                    smp_rmb()
       ++nr_swapfiles               p = swap_info[type]

Without smp_rmb, CPU1 might observe CPU0's write to nr_swapfiles before
CPU0's write to swap_info[type] and read NULL from swap_info[type].

Ying Huang noticed other places in swapfile.c don't order these reads
properly.  Introduce swap_type_to_swap_info to encourage correct usage.

Use READ_ONCE and WRITE_ONCE to follow the Linux Kernel Memory Model
(see tools/memory-model/Documentation/explanation.txt).

This ordering need not be enforced in places where swap_lock is held
(e.g.  si_swapinfo) because swap_lock serializes updates to nr_swapfiles
and the swap_info array.

Link: http://lkml.kernel.org/r/20190131024410.29859-1-daniel.m.jordan@oracle.com
Fixes: ec8acf20afb8 ("swap: add per-partition lock for swapfile")
Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Suggested-by: "Huang, Ying" <ying.huang@intel.com>
Reviewed-by: Andrea Parri <andrea.parri@amarulasolutions.com>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Omar Sandoval <osandov@fb.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Tejun Heo <tj@kernel.org>
Cc: Will Deacon <will.deacon@arm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/swapfile.c | 51 +++++++++++++++++++++++++++++----------------------
 1 file changed, 29 insertions(+), 22 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 340ef3177686..0047dcaf9369 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -98,6 +98,15 @@ static atomic_t proc_poll_event = ATOMIC_INIT(0);
 
 atomic_t nr_rotate_swap = ATOMIC_INIT(0);
 
+static struct swap_info_struct *swap_type_to_swap_info(int type)
+{
+	if (type >= READ_ONCE(nr_swapfiles))
+		return NULL;
+
+	smp_rmb();	/* Pairs with smp_wmb in alloc_swap_info. */
+	return READ_ONCE(swap_info[type]);
+}
+
 static inline unsigned char swap_count(unsigned char ent)
 {
 	return ent & ~SWAP_HAS_CACHE;	/* may include COUNT_CONTINUED flag */
@@ -1030,12 +1039,14 @@ int get_swap_pages(int n_goal, swp_entry_t swp_entries[], int entry_size)
 /* The only caller of this function is now suspend routine */
 swp_entry_t get_swap_page_of_type(int type)
 {
-	struct swap_info_struct *si;
+	struct swap_info_struct *si = swap_type_to_swap_info(type);
 	pgoff_t offset;
 
-	si = swap_info[type];
+	if (!si)
+		goto fail;
+
 	spin_lock(&si->lock);
-	if (si && (si->flags & SWP_WRITEOK)) {
+	if (si->flags & SWP_WRITEOK) {
 		atomic_long_dec(&nr_swap_pages);
 		/* This is called for allocating swap entry, not cache */
 		offset = scan_swap_map(si, 1);
@@ -1046,6 +1057,7 @@ swp_entry_t get_swap_page_of_type(int type)
 		atomic_long_inc(&nr_swap_pages);
 	}
 	spin_unlock(&si->lock);
+fail:
 	return (swp_entry_t) {0};
 }
 
@@ -1057,9 +1069,9 @@ static struct swap_info_struct *__swap_info_get(swp_entry_t entry)
 	if (!entry.val)
 		goto out;
 	type = swp_type(entry);
-	if (type >= nr_swapfiles)
+	p = swap_type_to_swap_info(type);
+	if (!p)
 		goto bad_nofile;
-	p = swap_info[type];
 	if (!(p->flags & SWP_USED))
 		goto bad_device;
 	offset = swp_offset(entry);
@@ -1708,10 +1720,9 @@ int swap_type_of(dev_t device, sector_t offset, struct block_device **bdev_p)
 sector_t swapdev_block(int type, pgoff_t offset)
 {
 	struct block_device *bdev;
+	struct swap_info_struct *si = swap_type_to_swap_info(type);
 
-	if ((unsigned int)type >= nr_swapfiles)
-		return 0;
-	if (!(swap_info[type]->flags & SWP_WRITEOK))
+	if (!si || !(si->flags & SWP_WRITEOK))
 		return 0;
 	return map_swap_entry(swp_entry(type, offset), &bdev);
 }
@@ -2269,7 +2280,7 @@ static sector_t map_swap_entry(swp_entry_t entry, struct block_device **bdev)
 	struct swap_extent *se;
 	pgoff_t offset;
 
-	sis = swap_info[swp_type(entry)];
+	sis = swp_swap_info(entry);
 	*bdev = sis->bdev;
 
 	offset = swp_offset(entry);
@@ -2707,9 +2718,7 @@ static void *swap_start(struct seq_file *swap, loff_t *pos)
 	if (!l)
 		return SEQ_START_TOKEN;
 
-	for (type = 0; type < nr_swapfiles; type++) {
-		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
-		si = swap_info[type];
+	for (type = 0; (si = swap_type_to_swap_info(type)); type++) {
 		if (!(si->flags & SWP_USED) || !si->swap_map)
 			continue;
 		if (!--l)
@@ -2729,9 +2738,7 @@ static void *swap_next(struct seq_file *swap, void *v, loff_t *pos)
 	else
 		type = si->type + 1;
 
-	for (; type < nr_swapfiles; type++) {
-		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
-		si = swap_info[type];
+	for (; (si = swap_type_to_swap_info(type)); type++) {
 		if (!(si->flags & SWP_USED) || !si->swap_map)
 			continue;
 		++*pos;
@@ -2838,14 +2845,14 @@ static struct swap_info_struct *alloc_swap_info(void)
 	}
 	if (type >= nr_swapfiles) {
 		p->type = type;
-		swap_info[type] = p;
+		WRITE_ONCE(swap_info[type], p);
 		/*
 		 * Write swap_info[type] before nr_swapfiles, in case a
 		 * racing procfs swap_start() or swap_next() is reading them.
 		 * (We never shrink nr_swapfiles, we never free this entry.)
 		 */
 		smp_wmb();
-		nr_swapfiles++;
+		WRITE_ONCE(nr_swapfiles, nr_swapfiles + 1);
 	} else {
 		kvfree(p);
 		p = swap_info[type];
@@ -3365,7 +3372,7 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 {
 	struct swap_info_struct *p;
 	struct swap_cluster_info *ci;
-	unsigned long offset, type;
+	unsigned long offset;
 	unsigned char count;
 	unsigned char has_cache;
 	int err = -EINVAL;
@@ -3373,10 +3380,10 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 	if (non_swap_entry(entry))
 		goto out;
 
-	type = swp_type(entry);
-	if (type >= nr_swapfiles)
+	p = swp_swap_info(entry);
+	if (!p)
 		goto bad_file;
-	p = swap_info[type];
+
 	offset = swp_offset(entry);
 	if (unlikely(offset >= p->max))
 		goto out;
@@ -3473,7 +3480,7 @@ int swapcache_prepare(swp_entry_t entry)
 
 struct swap_info_struct *swp_swap_info(swp_entry_t entry)
 {
-	return swap_info[swp_type(entry)];
+	return swap_type_to_swap_info(swp_type(entry));
 }
 
 struct swap_info_struct *page_swap_info(struct page *page)
-- 
2.19.1

