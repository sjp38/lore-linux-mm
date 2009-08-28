Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8DFC56B00B0
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 08:56:02 -0400 (EDT)
Date: Fri, 28 Aug 2009 13:56:08 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] page-allocator: Split per-cpu list into
	one-list-per-migrate-type
Message-ID: <20090828125559.GD5054@csn.ul.ie>
References: <1251449067-3109-1-git-send-email-mel@csn.ul.ie> <1251449067-3109-2-git-send-email-mel@csn.ul.ie> <20090828205241.fc8dfa51.minchan.kim@barrios-desktop> <28c262360908280500tb47685btc9f36ca81605d55@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360908280500tb47685btc9f36ca81605d55@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 28, 2009 at 09:00:25PM +0900, Minchan Kim wrote:
> On Fri, Aug 28, 2009 at 8:52 PM, Minchan Kim<minchan.kim@gmail.com> wrote:
> > Hi, Mel.
> >
> > On Fri, 28 Aug 2009 09:44:26 +0100
> > Mel Gorman <mel@csn.ul.ie> wrote:
> >
> >> Currently the per-cpu page allocator searches the PCP list for pages of the
> >> correct migrate-type to reduce the possibility of pages being inappropriate
> >> placed from a fragmentation perspective. This search is potentially expensive
> >> in a fast-path and undesirable. Splitting the per-cpu list into multiple
> >> lists increases the size of a per-cpu structure and this was potentially
> >> a major problem at the time the search was introduced. These problem has
> >> been mitigated as now only the necessary number of structures is allocated
> >> for the running system.
> >>
> >> This patch replaces a list search in the per-cpu allocator with one list per
> >> migrate type. The potential snag with this approach is when bulk freeing
> >> pages. We round-robin free pages based on migrate type which has little
> >> bearing on the cache hotness of the page and potentially checks empty lists
> >> repeatedly in the event the majority of PCP pages are of one type.
> >>
> >> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> >> Acked-by: Nick Piggin <npiggin@suse.de>
> >> ---
> >>  include/linux/mmzone.h |    5 ++-
> >>  mm/page_alloc.c        |  106 ++++++++++++++++++++++++++---------------------
> >>  2 files changed, 63 insertions(+), 48 deletions(-)
> >>
> >> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> >> index 008cdcd..045348f 100644
> >> --- a/include/linux/mmzone.h
> >> +++ b/include/linux/mmzone.h
> >> @@ -38,6 +38,7 @@
> >>  #define MIGRATE_UNMOVABLE     0
> >>  #define MIGRATE_RECLAIMABLE   1
> >>  #define MIGRATE_MOVABLE       2
> >> +#define MIGRATE_PCPTYPES      3 /* the number of types on the pcp lists */
> >>  #define MIGRATE_RESERVE       3
> >>  #define MIGRATE_ISOLATE       4 /* can't allocate from here */
> >>  #define MIGRATE_TYPES         5
> >> @@ -169,7 +170,9 @@ struct per_cpu_pages {
> >>       int count;              /* number of pages in the list */
> >>       int high;               /* high watermark, emptying needed */
> >>       int batch;              /* chunk size for buddy add/remove */
> >> -     struct list_head list;  /* the list of pages */
> >> +
> >> +     /* Lists of pages, one per migrate type stored on the pcp-lists */
> >> +     struct list_head lists[MIGRATE_PCPTYPES];
> >>  };
> >>
> >>  struct per_cpu_pageset {
> >> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >> index ac3afe1..65eedb5 100644
> >> --- a/mm/page_alloc.c
> >> +++ b/mm/page_alloc.c
> >> @@ -522,7 +522,7 @@ static inline int free_pages_check(struct page *page)
> >>  }
> >>
> >>  /*
> >> - * Frees a list of pages.
> >> + * Frees a number of pages from the PCP lists
> >>   * Assumes all pages on list are in same zone, and of same order.
> >>   * count is the number of pages to free.
> >>   *
> >> @@ -532,23 +532,36 @@ static inline int free_pages_check(struct page *page)
> >>   * And clear the zone's pages_scanned counter, to hold off the "all pages are
> >>   * pinned" detection logic.
> >>   */
> >> -static void free_pages_bulk(struct zone *zone, int count,
> >> -                                     struct list_head *list, int order)
> >> +static void free_pcppages_bulk(struct zone *zone, int count,
> >> +                                     struct per_cpu_pages *pcp)
> >>  {
> >> +     int migratetype = 0;
> >> +
> >
> > How about caching the last sucess migratetype
> > with 'per_cpu_pages->last_alloc_type'?
>                                          ^^^^
>                                          free
> > I think it could prevent a litte spinning empty list.
> 
> Anyway, Ignore me.
> I didn't see your next patch.
> 

Nah, it's a reasonable suggestion. Patch 2 was one effort to reduce
spinning but the comment was in patch 1 in case someone thought of
something better. I tried what you suggested before but it didn't work
out. For any sort of workload that varies the type of allocation (very
frequent), it didn't reduce spinning significantly.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
