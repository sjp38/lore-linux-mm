Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18CFEC41514
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:53:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4EC723402
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:53:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="Eembe5Ls"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4EC723402
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E4D66B0008; Wed,  4 Sep 2019 09:53:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 148FF6B000A; Wed,  4 Sep 2019 09:53:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED9536B000C; Wed,  4 Sep 2019 09:53:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0044.hostedemail.com [216.40.44.44])
	by kanga.kvack.org (Postfix) with ESMTP id CE5A36B0008
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 09:53:19 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 70FBD52B0
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:53:19 +0000 (UTC)
X-FDA: 75897380118.08.kick81_1cebb66dbb52a
X-HE-Tag: kick81_1cebb66dbb52a
X-Filterd-Recvd-Size: 6381
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net [77.88.29.217])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:53:18 +0000 (UTC)
Received: from mxbackcorp1o.mail.yandex.net (mxbackcorp1o.mail.yandex.net [IPv6:2a02:6b8:0:1a2d::301])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id 53C752E160A;
	Wed,  4 Sep 2019 16:53:15 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTP id QfOvctjG4A-rEN8L11r;
	Wed, 04 Sep 2019 16:53:15 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1567605195; bh=FKXul/4983ZBoHHq4ipo38Vdx5JAQEjK+xyNcL5XG/o=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=Eembe5LspBdMt9h2FqQbMeEXSQ77B3oYjZdnfPSHj4lgjdTwEOxdK+7wZvEZxreve
	 X11uBDqxc7NATKNpghw11W6j7IVoLAustrV0Jh7zA00z6OLgnDkLnbFBKIKcVvqAlr
	 A0OlBRpBj/NZW06uM4G84V1qr5Tt3/5zJEk0rVkI=
Authentication-Results: mxbackcorp1o.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:c142:79c2:9d86:677a])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id HV7s2MPeWC-rE7arYEF;
	Wed, 04 Sep 2019 16:53:14 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH v1 3/7] mm/mlock: add vma argument for mlock_vma_page()
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>
Date: Wed, 04 Sep 2019 16:53:14 +0300
Message-ID: <156760519431.6560.14636274673495137289.stgit@buzz>
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

This will be used for recharging memory cgroup accounting.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/gup.c         |    2 +-
 mm/huge_memory.c |    4 ++--
 mm/internal.h    |    4 ++--
 mm/ksm.c         |    2 +-
 mm/migrate.c     |    2 +-
 mm/mlock.c       |    2 +-
 mm/rmap.c        |    2 +-
 7 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 98f13ab37bac..f0accc229266 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -306,7 +306,7 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 			 * know the page is still mapped, we don't even
 			 * need to check for file-cache page truncation.
 			 */
-			mlock_vma_page(page);
+			mlock_vma_page(vma, page);
 			unlock_page(page);
 		}
 	}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index de1f15969e27..157faa231e26 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1513,7 +1513,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 			goto skip_mlock;
 		lru_add_drain();
 		if (page->mapping && !PageDoubleMap(page))
-			mlock_vma_page(page);
+			mlock_vma_page(vma, page);
 		unlock_page(page);
 	}
 skip_mlock:
@@ -3009,7 +3009,7 @@ void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page *new)
 		page_add_file_rmap(new, true);
 	set_pmd_at(mm, mmun_start, pvmw->pmd, pmde);
 	if ((vma->vm_flags & VM_LOCKED) && !PageDoubleMap(new))
-		mlock_vma_page(new);
+		mlock_vma_page(vma, new);
 	update_mmu_cache_pmd(vma, address, pvmw->pmd);
 }
 #endif
diff --git a/mm/internal.h b/mm/internal.h
index e32390802fd3..9f91992ef281 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -305,7 +305,7 @@ static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
 /*
  * must be called with vma's mmap_sem held for read or write, and page locked.
  */
-extern void mlock_vma_page(struct page *page);
+extern void mlock_vma_page(struct vm_area_struct *vma, struct page *page);
 extern unsigned int munlock_vma_page(struct page *page);
 
 /*
@@ -364,7 +364,7 @@ vma_address(struct page *page, struct vm_area_struct *vma)
 
 #else /* !CONFIG_MMU */
 static inline void clear_page_mlock(struct page *page) { }
-static inline void mlock_vma_page(struct page *page) { }
+static inline void mlock_vma_page(struct vm_area_struct *, struct page *) { }
 static inline void mlock_migrate_page(struct page *new, struct page *old) { }
 
 #endif /* !CONFIG_MMU */
diff --git a/mm/ksm.c b/mm/ksm.c
index 3dc4346411e4..cb5705d6f26c 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1274,7 +1274,7 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 		if (!PageMlocked(kpage)) {
 			unlock_page(page);
 			lock_page(kpage);
-			mlock_vma_page(kpage);
+			mlock_vma_page(vma, kpage);
 			page = kpage;		/* for final unlock */
 		}
 	}
diff --git a/mm/migrate.c b/mm/migrate.c
index a42858d8e00b..1f6151cb7310 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -269,7 +269,7 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 				page_add_file_rmap(new, false);
 		}
 		if (vma->vm_flags & VM_LOCKED && !PageTransCompound(new))
-			mlock_vma_page(new);
+			mlock_vma_page(vma, new);
 
 		if (PageTransHuge(page) && PageMlocked(page))
 			clear_page_mlock(page);
diff --git a/mm/mlock.c b/mm/mlock.c
index a90099da4fb4..73d477aaa411 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -85,7 +85,7 @@ void clear_page_mlock(struct page *page)
  * Mark page as mlocked if not already.
  * If page on LRU, isolate and putback to move to unevictable list.
  */
-void mlock_vma_page(struct page *page)
+void mlock_vma_page(struct vm_area_struct *vma, struct page *page)
 {
 	/* Serialize with page migration */
 	BUG_ON(!PageLocked(page));
diff --git a/mm/rmap.c b/mm/rmap.c
index 003377e24232..de88f4897c1d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1410,7 +1410,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 					 * Holding pte lock, we do *not* need
 					 * mmap_sem here
 					 */
-					mlock_vma_page(page);
+					mlock_vma_page(vma, page);
 				}
 				ret = false;
 				page_vma_mapped_walk_done(&pvmw);


