Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 113356B0055
	for <linux-mm@kvack.org>; Mon, 18 May 2009 21:11:24 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4J1BStj000494
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 May 2009 10:11:32 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4445245DD78
	for <linux-mm@kvack.org>; Tue, 19 May 2009 10:11:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 19B9A45DD74
	for <linux-mm@kvack.org>; Tue, 19 May 2009 10:11:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D1E31DB8018
	for <linux-mm@kvack.org>; Tue, 19 May 2009 10:11:28 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C8746E08004
	for <linux-mm@kvack.org>; Tue, 19 May 2009 10:11:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] vmscan: change the number of the unmapped files in zone reclaim
In-Reply-To: <20090518035319.GA7940@localhost>
References: <2f11576a0905172035k3f26b8d6r84af555a94b1d70e@mail.gmail.com> <20090518035319.GA7940@localhost>
Message-Id: <20090519094141.4EA2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 May 2009 10:11:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Mon, May 18, 2009 at 11:35:31AM +0800, KOSAKI Motohiro wrote:
> > >> --- a/mm/vmscan.c
> > >> +++ b/mm/vmscan.c
> > >> @@ -2397,6 +2397,7 @@ static int __zone_reclaim(struct zone *z
> > >> ? ? ? ? ? ? ? .isolate_pages = isolate_pages_global,
> > >> ? ? ? };
> > >> ? ? ? unsigned long slab_reclaimable;
> > >> + ? ? long nr_unmapped_file_pages;
> > >>
> > >> ? ? ? disable_swap_token();
> > >> ? ? ? cond_resched();
> > >> @@ -2409,9 +2410,11 @@ static int __zone_reclaim(struct zone *z
> > >> ? ? ? reclaim_state.reclaimed_slab = 0;
> > >> ? ? ? p->reclaim_state = &reclaim_state;
> > >>
> > >> - ? ? if (zone_page_state(zone, NR_FILE_PAGES) -
> > >> - ? ? ? ? ? ? zone_page_state(zone, NR_FILE_MAPPED) >
> > >> - ? ? ? ? ? ? zone->min_unmapped_pages) {
> > >> + ? ? nr_unmapped_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +
> > >> + ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?zone_page_state(zone, NR_ACTIVE_FILE) -
> > >> + ? ? ? ? ? ? ? ? ? ? ? ? ? ? ?zone_page_state(zone, NR_FILE_MAPPED);
> > >
> > > This can possibly go negative.
> > 
> > Is this a problem?
> > negative value mean almost pages are mapped. Thus
> > 
> >   (nr_unmapped_file_pages > zone->min_unmapped_pages)  => 0
> > 
> > is ok, I think.
> 
> I wonder why you didn't get a gcc warning, because zone->min_unmapped_pages
> is a "unsigned long".
> 
> Anyway, add a simple note to the code if it works *implicitly*?

hm, My gcc is wrong version? (gcc version 4.1.2 20070626 (Red Hat 4.1.2-14))
Anyway, you are right. thanks for good catch :)

incremental fixing patch is here.

Patch name: vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim-fix.patch
Applied after: vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
---
 mm/vmscan.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2397,7 +2397,9 @@ static int __zone_reclaim(struct zone *z
 		.isolate_pages = isolate_pages_global,
 	};
 	unsigned long slab_reclaimable;
-	long nr_unmapped_file_pages;
+	unsigned long nr_file_pages;
+	unsigned long nr_mapped;
+	unsigned long nr_unmapped_file_pages = 0;
 
 	disable_swap_token();
 	cond_resched();
@@ -2410,9 +2412,11 @@ static int __zone_reclaim(struct zone *z
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	nr_unmapped_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +
-				 zone_page_state(zone, NR_ACTIVE_FILE) -
-				 zone_page_state(zone, NR_FILE_MAPPED);
+	nr_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +
+			zone_page_state(zone, NR_ACTIVE_FILE);
+	nr_mapped = zone_page_state(zone, NR_FILE_MAPPED);
+	if (likely(nr_file_pages >= nr_mapped))
+		nr_unmapped_file_pages = nr_file_pages - nr_mapped;
 
 	if (nr_unmapped_file_pages > zone->min_unmapped_pages) {
 		/*



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
