Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C6E7F6B006C
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 21:06:51 -0500 (EST)
Received: by wghk14 with SMTP id k14so37179366wgh.4
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 18:06:51 -0800 (PST)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id em4si21158334wid.73.2015.03.02.18.06.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 18:06:50 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Tue, 3 Mar 2015 10:06:40 +0800
Subject: [RFC V3] mm: change mm_advise_free to clear page dirty
Message-ID: <35FD53F367049845BC99AC72306C23D10458D6173BE7@CNBJMBX05.corpusers.net>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <20150224154318.GA14939@dhcp22.suse.cz> <20150225000809.GA6468@blaptop>
 <35FD53F367049845BC99AC72306C23D10458D6173BDC@CNBJMBX05.corpusers.net>
 <20150227210233.GA29002@dhcp22.suse.cz>
 <35FD53F367049845BC99AC72306C23D10458D6173BE0@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D10458D6173BE1@CNBJMBX05.corpusers.net>
 <20150302123850.GC26334@dhcp22.suse.cz>
In-Reply-To: <20150302123850.GC26334@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@suse.cz>, 'Minchan Kim' <minchan@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Rik van Riel' <riel@redhat.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'Shaohua Li' <shli@kernel.org>

This patch add ClearPageDirty() to clear AnonPage dirty flag,
if not clear page dirty for this anon page, the page will never be
treated as freeable. We also make sure the shared AnonPage is not
freeable, we implement it by dirty all copyed AnonPage pte,
so that make sure the Anonpage will not become freeable, unless
all process which shared this page call madvise_free syscall.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 mm/madvise.c | 16 +++++++++-------
 mm/memory.c  | 12 ++++++++++--
 2 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 6d0fcb8..b61070d 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -297,23 +297,25 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigne=
d long addr,
 			continue;
=20
 		page =3D vm_normal_page(vma, addr, ptent);
-		if (!page)
+		if (!page || !trylock_page(page))
 			continue;
=20
 		if (PageSwapCache(page)) {
-			if (!trylock_page(page))
-				continue;
-
 			if (!try_to_free_swap(page)) {
 				unlock_page(page);
 				continue;
 			}
-
-			ClearPageDirty(page);
-			unlock_page(page);
 		}
=20
 		/*
+		 * we clear page dirty flag for AnonPage, no matter if this
+		 * page is in swapcahce or not, AnonPage not in swapcache also set
+		 * dirty flag sometimes, this happened when a AnonPage is removed
+		 * from swapcahce by try_to_free_swap()
+		 */
+		ClearPageDirty(page);
+		unlock_page(page);
+		/*
 		 * Some of architecture(ex, PPC) don't update TLB
 		 * with set_pte_at and tlb_remove_tlb_entry so for
 		 * the portability, remap the pte with old|clean
diff --git a/mm/memory.c b/mm/memory.c
index 8068893..3d949b3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -874,10 +874,18 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_stru=
ct *src_mm,
 	if (page) {
 		get_page(page);
 		page_dup_rmap(page);
-		if (PageAnon(page))
+		if (PageAnon(page)) {
+			/*
+			 * we dirty the copyed pte for anon page,
+			 * this is useful for madvise_free_pte_range(),
+			 * this can prevent shared anon page freed by madvise_free
+			 * syscall
+			 */
+			pte =3D pte_mkdirty(pte);
 			rss[MM_ANONPAGES]++;
-		else
+		} else {
 			rss[MM_FILEPAGES]++;
+		}
 	}
=20
 out_set_pte:
--=20
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
