Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 782916B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 07:42:43 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 20/35] Use a pre-calculated value for num_online_nodes()
Date: Mon, 16 Mar 2009 22:42:34 +1100
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-21-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237196790-7268-21-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903162242.35341.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Monday 16 March 2009 20:46:15 Mel Gorman wrote:
> num_online_nodes() is called by the page allocator to decide whether the
> zonelist needs to be filtered based on cpusets or the zonelist cache.
> This is actually a heavy function and touches a number of cache lines.
> This patch stores the number of online nodes at boot time and when
> nodes get onlined and offlined.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/nodemask.h |   16 ++++++++++++++--
>  mm/page_alloc.c          |    6 ++++--
>  2 files changed, 18 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> index 848025c..4749e30 100644
> --- a/include/linux/nodemask.h
> +++ b/include/linux/nodemask.h
> @@ -449,13 +449,25 @@ static inline int num_node_state(enum node_states
> state) node;					\
>  })
>
> +/* Recorded value for num_online_nodes() */
> +extern int static_num_online_nodes;

__read_mostly, please. Check this for any other place you've added
global cachelines that are referenced by the allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
