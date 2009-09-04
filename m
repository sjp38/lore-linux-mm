Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DB58E6B004F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 22:02:44 -0400 (EDT)
Date: Thu, 3 Sep 2009 19:01:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()
 sc->isolate_pages() return value.
Message-Id: <20090903190141.16ce4cf3.akpm@linux-foundation.org>
In-Reply-To: <28c262360909031837j4e1a9214if6070d02cb4fde04@mail.gmail.com>
References: <1251935365-7044-1-git-send-email-macli@brc.ubc.ca>
	<20090903140602.e0169ffc.akpm@linux-foundation.org>
	<28c262360909031837j4e1a9214if6070d02cb4fde04@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Vincent Li <macli@brc.ubc.ca>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Sep 2009 10:37:17 +0900 Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Sep 4, 2009 at 6:06 AM, Andrew Morton<akpm@linux-foundation.org> wrote:
> > On Wed, __2 Sep 2009 16:49:25 -0700
> > Vincent Li <macli@brc.ubc.ca> wrote:
> >
> >> If we can't isolate pages from LRU list, we don't have to account page movement, either.
> >> Already, in commit 5343daceec, KOSAKI did it about shrink_inactive_list.
> >>
> >> This patch removes unnecessary overhead of page accounting
> >> and locking in shrink_active_list as follow-up work of commit 5343daceec.
> >>
> >> Signed-off-by: Vincent Li <macli@brc.ubc.ca>
> >> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> >> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
> >> Acked-by: Rik van Riel <riel@redhat.com>
> >>
> >> ---
> >> __mm/vmscan.c | __ __9 +++++++--
> >> __1 files changed, 7 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> index 460a6f7..2d1c846 100644
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -1319,9 +1319,12 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> >> __ __ __ if (scanning_global_lru(sc)) {
> >> __ __ __ __ __ __ __ zone->pages_scanned += pgscanned;

Someone's email client is replacing 0x09 with 0xa0, dammit.

> >
> > IOW, with what frequency is `nr_taken' zero here?
> 
> I think It's not so simple.
> 
> In fact, the probability of (nr_taken == 0)
> would be very low in active list.
> 
> If we verify the benefit, we have to measure trade-off between
> loss of compare instruction in most case and
> gain of avoiding unnecessary overheads in rare case through
> micro-benchmark. I don't know which benchmark can do it.
> 
> but if we can know the number of frequent and it's very low,
> we can add 'unlikely(if (nr_taken==0))' at least, I think.

But the test-n-branch is not the only cost of this change.

The more worrisome effect is that we've added a rarely-taken long
branch which skips over a whole lot of code.  There's an appreciable
risk that we'll later add code to this function in the expectation that
the new code is always executed.  During testing, the code is executed
sufficiently often for the bug to not be noticed.  So we ship the buggy
code.

IOW, there is a maintainability cost as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
