Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 0BF326B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 00:34:17 -0400 (EDT)
Date: Wed, 19 Jun 2013 13:34:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 7/8] vrange: Add method to purge volatile ranges
Message-ID: <20130619043419.GA10961@bbox>
References: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
 <1371010971-15647-8-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371010971-15647-8-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jun 11, 2013 at 09:22:50PM -0700, John Stultz wrote:
> From: Minchan Kim <minchan@kernel.org>
> 
> This patch adds discarding function to purge volatile ranges under
> memory pressure. Logic is as following:
> 
> 1. Memory pressure happens
> 2. VM start to reclaim pages
> 3. Check the page is in volatile range.
> 4. If so, zap the page from the process's page table.
>    (By semantic vrange(2), we should mark it with another one to
>     make page fault when you try to access the address. It will
>     be introduced later patch)
> 5. If page is unmapped from all processes, discard it instead of swapping.
> 
> This patch does not address the case where there is no swap, which
> keeps anonymous pages from being aged off the LRUs. Minchan has
> additional patches that add support for purging anonymous pages
> 
> XXX: First pass at file purging. Seems to work, but is likely broken
> and needs close review.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Android Kernel Team <kernel-team@android.com>
> Cc: Robert Love <rlove@google.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Andrea Righi <andrea@betterlinux.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Mike Hommey <mh@glandium.org>
> Cc: Taras Glek <tglek@mozilla.com>
> Cc: Dhaval Giani <dgiani@mozilla.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> [jstultz: Reworked to add purging of file pages, commit log tweaks]
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> ---
>  include/linux/rmap.h   |  12 +-
>  include/linux/swap.h   |   1 +
>  include/linux/vrange.h |   7 ++
>  mm/ksm.c               |   2 +-
>  mm/rmap.c              |  30 +++--
>  mm/swapfile.c          |  36 ++++++
>  mm/vmscan.c            |  16 ++-
>  mm/vrange.c            | 332 +++++++++++++++++++++++++++++++++++++++++++++++++
>  8 files changed, 420 insertions(+), 16 deletions(-)

This patch has some bugs so below patch should fix them and pass my
simple cases.
