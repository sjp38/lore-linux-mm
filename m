Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 185046B028D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 18:32:04 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id l15-v6so11010259pff.5
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 15:32:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m38si14512514pgl.125.2018.11.05.15.32.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 15:32:02 -0800 (PST)
Date: Mon, 5 Nov 2018 15:31:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] z3fold: fix possible reclaim races
Message-Id: <20181105153159.0c1825bcb956c53a1d02a6ca@linux-foundation.org>
In-Reply-To: <20181105162225.74e8837d03583a9b707cf559@gmail.com>
References: <20181105162225.74e8837d03583a9b707cf559@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Oleksiy.Avramchenko@sony.com, Guenter Roeck <linux@roeck-us.net>, snild@sony.com, Jongseok Kim <ks77sj@gmail.com>

On Mon, 5 Nov 2018 16:22:25 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:

> Reclaim and free can race on an object which is basically fine but
> in order for reclaim to be able to  map "freed" object we need to
> encode object length in the handle. handle_to_chunks() is then
> introduced to extract object length from a handle and use it during
> mapping.
> 
> Moreover, to avoid racing on a z3fold "headless" page release, we
> should not try to free that page in z3fold_free() if the reclaim
> bit is set. Also, in the unlikely case of trying to reclaim a page
> being freed, we should not proceed with that page.
> 
> While at it, fix the page accounting in reclaim function.
> 
> This patch supersedes "[PATCH] z3fold: fix reclaim lock-ups".

This conflicts with z3fold-fix-wrong-handling-of-headless-pages.patch,
below.  What should we do?

(I think we're still awaiting your input on this one.  Or I might have
missed an amail.)



From: Jongseok Kim <ks77sj@gmail.com>
Subject: mm/z3fold.c: fix wrong handling of headless pages

During the processing of headless pages in z3fold_reclaim_page(), there
was a problem that the zhdr pointed to another page or a page was already
released in z3fold_free().  So, the wrong page is encoded in headless, or
test_bit does not work properly in z3fold_reclaim_page().  This patch
fixed these problems.

Link: http://lkml.kernel.org/r/1530853846-30215-1-git-send-email-ks77sj@gmail.com
Signed-off-by: Jongseok Kim <ks77sj@gmail.com>
Cc: Vitaly Wool <vitalywool@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/z3fold.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

--- a/mm/z3fold.c~z3fold-fix-wrong-handling-of-headless-pages
+++ a/mm/z3fold.c
@@ -746,6 +746,9 @@ static void z3fold_free(struct z3fold_po
 	}
 
 	if (bud == HEADLESS) {
+		if (test_bit(UNDER_RECLAIM, &page->private))
+			return;
+
 		spin_lock(&pool->lock);
 		list_del(&page->lru);
 		spin_unlock(&pool->lock);
@@ -836,20 +839,20 @@ static int z3fold_reclaim_page(struct z3
 		}
 		list_for_each_prev(pos, &pool->lru) {
 			page = list_entry(pos, struct page, lru);
+			zhdr = page_address(page);
 			if (test_bit(PAGE_HEADLESS, &page->private))
 				/* candidate found */
 				break;
 
-			zhdr = page_address(page);
 			if (!z3fold_page_trylock(zhdr))
 				continue; /* can't evict at this point */
 			kref_get(&zhdr->refcount);
 			list_del_init(&zhdr->buddy);
 			zhdr->cpu = -1;
-			set_bit(UNDER_RECLAIM, &page->private);
 			break;
 		}
 
+		set_bit(UNDER_RECLAIM, &page->private);
 		list_del_init(&page->lru);
 		spin_unlock(&pool->lock);
 
@@ -898,6 +901,7 @@ next:
 		if (test_bit(PAGE_HEADLESS, &page->private)) {
 			if (ret == 0) {
 				free_z3fold_page(page);
+				atomic64_dec(&pool->pages_nr);
 				return 0;
 			}
 			spin_lock(&pool->lock);
_
