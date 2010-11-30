Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 28CA36B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 13:35:03 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id oAUIYwZh022690
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 10:34:58 -0800
Received: from pxi19 (pxi19.prod.google.com [10.243.27.19])
	by wpaz5.hot.corp.google.com with ESMTP id oAUIYccr024016
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 10:34:57 -0800
Received: by pxi19 with SMTP id 19so1166307pxi.29
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 10:34:57 -0800 (PST)
Date: Tue, 30 Nov 2010 10:34:41 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 3/3] Prevent activation of page in madvise_dontneed
In-Reply-To: <a0f2905bb64ce33909d7dd74146bfea826fec21a.1291043274.git.minchan.kim@gmail.com>
Message-ID: <alpine.LSU.2.00.1011301025010.7450@tigran.mtv.corp.google.com>
References: <cover.1291043273.git.minchan.kim@gmail.com> <a0f2905bb64ce33909d7dd74146bfea826fec21a.1291043274.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010, Minchan Kim wrote:

> Now zap_pte_range alwayas activates pages which are pte_young &&
> !VM_SequentialReadHint(vma). But in case of calling MADV_DONTNEED,
> it's unnecessary since the page wouldn't use any more.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> 
> Changelog since v2:
>  - remove unnecessary description
> Changelog since v1: 
>  - change word from promote to activate
>  - add activate argument to zap_pte_range and family function
> 
> ---
>  include/linux/mm.h |    4 ++--
>  mm/madvise.c       |    4 ++--
>  mm/memory.c        |   38 +++++++++++++++++++++++---------------
>  mm/mmap.c          |    4 ++--
>  4 files changed, 29 insertions(+), 21 deletions(-)

Everyone else seems pretty happy with this, and I've not checked
at all whether it achieves your purpose; but personally I'd much
prefer a smaller patch which adds your "activate" or "ignore_references"
flag to struct zap_details, instead of passing this exceptional arg
down lots of levels.  That's precisely the purpose of zap_details,
to gather together a few things that aren't needed in the common case
(though I admit the NULL details defaulting may be ugly).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
