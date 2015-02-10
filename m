Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2A22F6B0032
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 23:39:19 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id nt9so29139109obb.13
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 20:39:19 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id gq14si6936901obb.76.2015.02.09.20.39.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Feb 2015 20:39:18 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm: hwpoison: drop lru_add_drain_all() in
 __soft_offline_page()
Date: Tue, 10 Feb 2015 04:37:48 +0000
Message-ID: <1423543038-7478-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, Chen Gong <gong.chen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

A race condition starts to be visible in recent mmotm, where a PG_hwpoison
flag is set on a migration source page *before* it's back in buddy page poo=
l.
This is problematic because no page flag is supposed to be set when freeing
(see __free_one_page().) So the user-visible effect of this race is that it
could trigger the BUG_ON() when soft-offlining is called.

The root cause is that we call lru_add_drain_all() to make sure that the
page is in buddy, but that doesn't work because this function just schedule=
s
a work item and doesn't wait its completion. drain_all_pages() does drainin=
g
directly, so simply dropping lru_add_drain_all() solves this problem.

Fixes: commit f15bdfa802bf ("mm/memory-failure.c: fix memory leak in succes=
sful soft offlining")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org> [3.11+]
---
 mm/memory-failure.c | 2 --
 1 file changed, 2 deletions(-)

diff --git mmotm-2015-02-03-16-38.orig/mm/memory-failure.c mmotm-2015-02-03=
-16-38/mm/memory-failure.c
index b2a68bde8058..fa44054c205f 100644
--- mmotm-2015-02-03-16-38.orig/mm/memory-failure.c
+++ mmotm-2015-02-03-16-38/mm/memory-failure.c
@@ -1647,8 +1647,6 @@ static int __soft_offline_page(struct page *page, int=
 flags)
 			 * setting PG_hwpoison.
 			 */
 			if (!is_free_buddy_page(page))
-				lru_add_drain_all();
-			if (!is_free_buddy_page(page))
 				drain_all_pages(page_zone(page));
 			SetPageHWPoison(page);
 			if (!is_free_buddy_page(page))
--=20
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
