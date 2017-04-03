Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 07E146B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 14:08:52 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 68so148306286pgj.23
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:08:51 -0700 (PDT)
Received: from mail-pg0-x229.google.com (mail-pg0-x229.google.com. [2607:f8b0:400e:c05::229])
        by mx.google.com with ESMTPS id y5si9512978pgj.38.2017.04.03.11.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 11:08:50 -0700 (PDT)
Received: by mail-pg0-x229.google.com with SMTP id x125so127690570pgb.0
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:08:50 -0700 (PDT)
Date: Mon, 3 Apr 2017 11:08:41 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: ksmd lockup - kernel 4.11-rc series
In-Reply-To: <20170403140850.twnkdiglzqlsfecy@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1704031104400.1118@eggly.anvils>
References: <003401d2a750$19f98190$4dec84b0$@net> <20170327233617.353obb3m4wz7n5kv@node.shutemov.name> <alpine.LSU.2.11.1703280008020.2599@eggly.anvils> <alpine.LSU.2.11.1704021651230.1618@eggly.anvils> <20170403140850.twnkdiglzqlsfecy@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Doug Smythies <dsmythies@telus.net>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

On Mon, 3 Apr 2017, Kirill A. Shutemov wrote:
> On Sun, Apr 02, 2017 at 05:03:00PM -0700, Hugh Dickins wrote:
> >  			return true;
> > -next_pte:	do {
> > +next_pte:
> > +		if (!PageTransHuge(pvmw->page) || PageHuge(pvmw->page))
> > +			return not_found(pvmw);
> 
> I guess it makes sense to drop the same check from the beginning of the
> function and move the comment here.
> 
> Otherwise looks good. Thanks for tracking this down.

Oh that's much better, thanks, it would have annoyed me to notice that
duplication later on.  Replacement patch...


[PATCH] mm: fix page_vma_mapped_walk() for ksm pages

Doug Smythies reports oops with KSM in this backtrace,
I've been seeing the same:

page_vma_mapped_walk+0xe6/0x5b0
page_referenced_one+0x91/0x1a0
rmap_walk_ksm+0x100/0x190
rmap_walk+0x4f/0x60
page_referenced+0x149/0x170
shrink_active_list+0x1c2/0x430
shrink_node_memcg+0x67a/0x7a0
shrink_node+0xe1/0x320
kswapd+0x34b/0x720

Just as 4b0ece6fa016 ("mm: migrate: fix remove_migration_pte() for ksm
pages") observed, you cannot use page->index calculations on ksm pages.
page_vma_mapped_walk() is relying on __vma_address(), where a ksm page
can lead it off the end of the page table, and into whatever nonsense
is in the next page, ending as an oops inside check_pte()'s pte_page().

KSM tells page_vma_mapped_walk() exactly where to look for the page,
it does not need any page->index calculation: and that's so also for
all the normal and file and anon pages - just not for THPs and their
subpages.  Get out early in most cases: instead of a PageKsm test,
move down the earlier not-THP-page test, as suggested by Kirill.

I'm also slightly worried that this loop can stray into other vmas,
so added a vm_end test to prevent surprises; though I have not imagined
anything worse than a very contrived case, in which a page mlocked in
the next vma might be reclaimed because it is not mlocked in this vma.

Fixes: ace71a19cec5 ("mm: introduce page_vma_mapped_walk()")
Reported-by: Doug Smythies <dsmythies@telus.net>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/page_vma_mapped.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

--- 4.11-rc5/mm/page_vma_mapped.c	2017-03-13 09:04:37.792808451 -0700
+++ linux/mm/page_vma_mapped.c	2017-04-03 10:40:30.389050027 -0700
@@ -111,12 +111,8 @@ bool page_vma_mapped_walk(struct page_vm
 	if (pvmw->pmd && !pvmw->pte)
 		return not_found(pvmw);
 
-	/* Only for THP, seek to next pte entry makes sense */
-	if (pvmw->pte) {
-		if (!PageTransHuge(pvmw->page) || PageHuge(pvmw->page))
-			return not_found(pvmw);
+	if (pvmw->pte)
 		goto next_pte;
-	}
 
 	if (unlikely(PageHuge(pvmw->page))) {
 		/* when pud is not present, pte will be NULL */
@@ -165,9 +161,14 @@ restart:
 	while (1) {
 		if (check_pte(pvmw))
 			return true;
-next_pte:	do {
+next_pte:
+		/* Seek to next pte only makes sense for THP */
+		if (!PageTransHuge(pvmw->page) || PageHuge(pvmw->page))
+			return not_found(pvmw);
+		do {
 			pvmw->address += PAGE_SIZE;
-			if (pvmw->address >=
+			if (pvmw->address >= pvmw->vma->vm_end ||
+			    pvmw->address >=
 					__vma_address(pvmw->page, pvmw->vma) +
 					hpage_nr_pages(pvmw->page) * PAGE_SIZE)
 				return not_found(pvmw);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
