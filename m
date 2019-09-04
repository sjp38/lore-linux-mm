Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4EBFC3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:53:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D85721670
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:53:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="t3HiszGl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D85721670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00C346B0006; Wed,  4 Sep 2019 09:53:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F01AD6B0007; Wed,  4 Sep 2019 09:53:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC8716B0008; Wed,  4 Sep 2019 09:53:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0200.hostedemail.com [216.40.44.200])
	by kanga.kvack.org (Postfix) with ESMTP id B964D6B0006
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 09:53:15 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 344A0824CA2E
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:53:15 +0000 (UTC)
X-FDA: 75897379950.17.tree57_1c47c7dd5ec45
X-HE-Tag: tree57_1c47c7dd5ec45
X-Filterd-Recvd-Size: 6396
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net [95.108.205.193])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:53:14 +0000 (UTC)
Received: from mxbackcorp1o.mail.yandex.net (mxbackcorp1o.mail.yandex.net [IPv6:2a02:6b8:0:1a2d::301])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 7EDB42E1B27;
	Wed,  4 Sep 2019 16:53:11 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTP id mLwgbAJwYJ-rBN8VOE7;
	Wed, 04 Sep 2019 16:53:11 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1567605191; bh=lTB5juDz41QpnMFucOhR5p9H8tWOOdh3MISjDg6Qtyo=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=t3HiszGlnoa0G41kFf87kWHWUfY/hTsAHUKmF5h9fmsvsFu3c8o8tu/MlWtpddOFA
	 tesrmKHUH/r2B0Pu47yB4Ay2NuVX3+tF/9dbtV51c1AkmtwGVs7gSzp/ehwzFqbFdU
	 6ycbxiL/tz7fm+BIVbdgZH5gdafWmJqj0BCqsuys=
Authentication-Results: mxbackcorp1o.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:c142:79c2:9d86:677a])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id J9CNPMyWdF-rBfqrSjj;
	Wed, 04 Sep 2019 16:53:11 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH v1 1/7] mm/memcontrol: move locking page out of
 mem_cgroup_move_account
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>
Date: Wed, 04 Sep 2019 16:53:10 +0300
Message-ID: <156760519049.6560.475471327815521193.stgit@buzz>
In-Reply-To: <156760509382.6560.17364256340940314860.stgit@buzz>
References: <156760509382.6560.17364256340940314860.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Required for calling mem_cgroup_move_account() for already locked page.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/memcontrol.c |   64 +++++++++++++++++++++++++++----------------------------
 1 file changed, 31 insertions(+), 33 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9ec5e12486a7..40ddc233e973 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5135,7 +5135,8 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
  * @from: mem_cgroup which the page is moved from.
  * @to:	mem_cgroup which the page is moved to. @from != @to.
  *
- * The caller must make sure the page is not on LRU (isolate_page() is useful.)
+ * The caller must lock the page and make sure it is not on LRU
+ * (isolate_page() is useful.)
  *
  * This function doesn't do "charge" to new cgroup and doesn't do "uncharge"
  * from old cgroup.
@@ -5147,24 +5148,15 @@ static int mem_cgroup_move_account(struct page *page,
 {
 	unsigned long flags;
 	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
-	int ret;
 	bool anon;
 
 	VM_BUG_ON(from == to);
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageLRU(page), page);
 	VM_BUG_ON(compound && !PageTransHuge(page));
 
-	/*
-	 * Prevent mem_cgroup_migrate() from looking at
-	 * page->mem_cgroup of its source page while we change it.
-	 */
-	ret = -EBUSY;
-	if (!trylock_page(page))
-		goto out;
-
-	ret = -EINVAL;
 	if (page->mem_cgroup != from)
-		goto out_unlock;
+		return -EINVAL;
 
 	anon = PageAnon(page);
 
@@ -5204,18 +5196,14 @@ static int mem_cgroup_move_account(struct page *page,
 	page->mem_cgroup = to;
 	spin_unlock_irqrestore(&from->move_lock, flags);
 
-	ret = 0;
-
 	local_irq_disable();
 	mem_cgroup_charge_statistics(to, page, compound, nr_pages);
 	memcg_check_events(to, page);
 	mem_cgroup_charge_statistics(from, page, compound, -nr_pages);
 	memcg_check_events(from, page);
 	local_irq_enable();
-out_unlock:
-	unlock_page(page);
-out:
-	return ret;
+
+	return 0;
 }
 
 /**
@@ -5535,36 +5523,42 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	struct vm_area_struct *vma = walk->vma;
 	pte_t *pte;
 	spinlock_t *ptl;
-	enum mc_target_type target_type;
 	union mc_target target;
 	struct page *page;
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (ptl) {
+		bool device = false;
+
 		if (mc.precharge < HPAGE_PMD_NR) {
 			spin_unlock(ptl);
 			return 0;
 		}
-		target_type = get_mctgt_type_thp(vma, addr, *pmd, &target);
-		if (target_type == MC_TARGET_PAGE) {
-			page = target.page;
-			if (!isolate_lru_page(page)) {
-				if (!mem_cgroup_move_account(page, true,
-							     mc.from, mc.to)) {
-					mc.precharge -= HPAGE_PMD_NR;
-					mc.moved_charge += HPAGE_PMD_NR;
-				}
-				putback_lru_page(page);
-			}
-			put_page(page);
-		} else if (target_type == MC_TARGET_DEVICE) {
+
+		switch (get_mctgt_type_thp(vma, addr, *pmd, &target)) {
+		case MC_TARGET_DEVICE:
+			device = true;
+			/* fall through */
+		case MC_TARGET_PAGE:
 			page = target.page;
+			if (!trylock_page(page))
+				goto put_huge;
+			if (!device && isolate_lru_page(page))
+				goto unlock_huge;
 			if (!mem_cgroup_move_account(page, true,
 						     mc.from, mc.to)) {
 				mc.precharge -= HPAGE_PMD_NR;
 				mc.moved_charge += HPAGE_PMD_NR;
 			}
+			if (!device)
+				putback_lru_page(page);
+unlock_huge:
+			unlock_page(page);
+put_huge:
 			put_page(page);
+			break;
+		default:
+			break;
 		}
 		spin_unlock(ptl);
 		return 0;
@@ -5596,8 +5590,10 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 			 */
 			if (PageTransCompound(page))
 				goto put;
-			if (!device && isolate_lru_page(page))
+			if (!trylock_page(page))
 				goto put;
+			if (!device && isolate_lru_page(page))
+				goto unlock;
 			if (!mem_cgroup_move_account(page, false,
 						mc.from, mc.to)) {
 				mc.precharge--;
@@ -5606,6 +5602,8 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 			}
 			if (!device)
 				putback_lru_page(page);
+unlock:
+			unlock_page(page);
 put:			/* get_mctgt_type() gets the page */
 			put_page(page);
 			break;


