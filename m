Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 45DCC6B0032
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 22:37:52 -0500 (EST)
Received: by padbj1 with SMTP id bj1so19262636pad.5
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 19:37:52 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id o1si3717892pap.77.2015.02.26.19.37.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Feb 2015 19:37:51 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 27 Feb 2015 11:37:18 +0800
Subject: [RFC] mm: change mm_advise_free to clear page dirty
Message-ID: <35FD53F367049845BC99AC72306C23D10458D6173BDC@CNBJMBX05.corpusers.net>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <20150224154318.GA14939@dhcp22.suse.cz> <20150225000809.GA6468@blaptop>
In-Reply-To: <20150225000809.GA6468@blaptop>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>

This patch add ClearPageDirty() to clear AnonPage dirty flag,
the Anonpage mapcount must be 1, so that this page is only used by
the current process, not shared by other process like fork().
if not clear page dirty for this anon page, the page will never be
treated as freeable.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 mm/madvise.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 6d0fcb8..257925a 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -297,22 +297,17 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigne=
d long addr,
 			continue;
=20
 		page =3D vm_normal_page(vma, addr, ptent);
-		if (!page)
+		if (!page || !PageAnon(page) || !trylock_page(page))
 			continue;
=20
 		if (PageSwapCache(page)) {
-			if (!trylock_page(page))
+			if (!try_to_free_swap(page))
 				continue;
-
-			if (!try_to_free_swap(page)) {
-				unlock_page(page);
-				continue;
-			}
-
-			ClearPageDirty(page);
-			unlock_page(page);
 		}
=20
+		if (page_mapcount(page) =3D=3D 1)
+			ClearPageDirty(page);
+		unlock_page(page);
 		/*
 		 * Some of architecture(ex, PPC) don't update TLB
 		 * with set_pte_at and tlb_remove_tlb_entry so for
--=20
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
