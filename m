Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id E9EE56B0044
	for <linux-mm@kvack.org>; Sun,  5 Aug 2012 23:03:29 -0400 (EDT)
Date: Mon, 6 Aug 2012 12:04:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/5] [RFC][HACK] Add LRU_VOLATILE support to the VM
Message-ID: <20120806030451.GA11468@bbox>
References: <1343447832-7182-1-git-send-email-john.stultz@linaro.org>
 <1343447832-7182-5-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343447832-7182-5-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, dan.magenheimer@oracle.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi John,

On Fri, Jul 27, 2012 at 11:57:11PM -0400, John Stultz wrote:
> In an attempt to push the volatile range managment even
> deeper into the VM code, this is my first attempt at
> implementing Minchan's idea of a LRU_VOLATILE list in
> the mm core.
> 
> This list sits along side the LRU_ACTIVE_ANON, _INACTIVE_ANON,
> _ACTIVE_FILE, _INACTIVE_FILE and _UNEVICTABLE lru lists.
> 
> When a range is marked volatile, the pages in that range
> are moved to the LRU_VOLATILE list. Since volatile pages
> can be quickly purged, this list is the first list we
> shrink when we need to free memory.
> 
> When a page is marked non-volatile, it is moved from the
> LRU_VOLATILE list to the appropriate LRU_ACTIVE_ list.

I think active list promotion is not good.
It should go to the inactive list and they get a chance to
activate from inactive to active sooner or later if it is
really touched.

> 
> This patch introduces the LRU_VOLATILE list, an isvolatile
> page flag, functions to mark and unmark a single page
> as volatile, and shrinker functions to purge volatile
> pages.
> 
> This is a very raw first pass, and is neither performant
> or likely bugfree. It works in my trivial testing, but
> I've not pushed it very hard yet.
> 
> I wanted to send it out just to get some inital thoughts
> on the approach and any suggestions should I be going too
> far in the wrong direction.

I look at this series and found several nitpicks about implemenataion
but I think it's not a good stage about concerning it.

Although naming is rather differet with I suggested, I think it's good idea.
So let's talk about it firstly.
I will call VOLATILE list as EReclaimale LRU list.

The purpose of it is that prevent unnecessary LRU churning and
reclaim unnecessary pages fastly so that latency-sensitive system
don't have a big latency when memory pressure happens.

Targets for the LRU list could be following as in future

1. volatile pages in this patchset.
2. ephemeral pages of tmem
3. madivse(DONTNEED)
4. fadvise(NOREUSE)
5. PG_reclaimed pages
6. clean pages if we write CFLRU(clean first LRU)

So if any guys have objection, please raise your hands
before further progress.

> 
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Android Kernel Team <kernel-team@android.com>
> CC: Robert Love <rlove@google.com>
> CC: Mel Gorman <mel@csn.ul.ie>
> CC: Hugh Dickins <hughd@google.com>
> CC: Dave Hansen <dave@linux.vnet.ibm.com>
> CC: Rik van Riel <riel@redhat.com>
> CC: Dmitry Adamushko <dmitry.adamushko@gmail.com>
> CC: Dave Chinner <david@fromorbit.com>
> CC: Neil Brown <neilb@suse.de>
> CC: Andrea Righi <andrea@betterlinux.com>
> CC: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> CC: Mike Hommey <mh@glandium.org>
> CC: Jan Kara <jack@suse.cz>
> CC: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> CC: Michel Lespinasse <walken@google.com>
> CC: Minchan Kim <minchan@kernel.org>
> CC: linux-mm@kvack.org <linux-mm@kvack.org>
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> ---
>  include/linux/fs.h         |    1 +
>  include/linux/mm_inline.h  |    2 ++
>  include/linux/mmzone.h     |    1 +
>  include/linux/page-flags.h |    3 ++
>  include/linux/swap.h       |    3 ++
>  mm/memcontrol.c            |    1 +
>  mm/page_alloc.c            |    1 +
>  mm/swap.c                  |   71 +++++++++++++++++++++++++++++++++++++++++
>  mm/vmscan.c                |   76 +++++++++++++++++++++++++++++++++++++++++---
>  9 files changed, 155 insertions(+), 4 deletions(-)
> 
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
