Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9848B62007E
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 20:06:46 -0400 (EDT)
Date: Tue, 6 Apr 2010 17:06:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 13/14] Do not compact within a preferred zone after a
 compaction failure
Message-Id: <20100406170616.7d0f24b1.akpm@linux-foundation.org>
In-Reply-To: <1270224168-14775-14-git-send-email-mel@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>
	<1270224168-14775-14-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri,  2 Apr 2010 17:02:47 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> The fragmentation index may indicate that a failure is due to external
> fragmentation but after a compaction run completes, it is still possible
> for an allocation to fail. There are two obvious reasons as to why
> 
>   o Page migration cannot move all pages so fragmentation remains
>   o A suitable page may exist but watermarks are not met
> 
> In the event of compaction followed by an allocation failure, this patch
> defers further compaction in the zone for a period of time. The zone that
> is deferred is the first zone in the zonelist - i.e. the preferred zone.
> To defer compaction in the other zones, the information would need to be
> stored in the zonelist or implemented similar to the zonelist_cache.
> This would impact the fast-paths and is not justified at this time.
> 

Your patch, it sucks!

> ---
>  include/linux/compaction.h |   35 +++++++++++++++++++++++++++++++++++
>  include/linux/mmzone.h     |    7 +++++++
>  mm/page_alloc.c            |    5 ++++-
>  3 files changed, 46 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index ae98afc..2a02719 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -18,6 +18,32 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
>  extern int fragmentation_index(struct zone *zone, unsigned int order);
>  extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			int order, gfp_t gfp_mask, nodemask_t *mask);
> +
> +/* defer_compaction - Do not compact within a zone until a given time */
> +static inline void defer_compaction(struct zone *zone, unsigned long resume)
> +{
> +	/*
> +	 * This function is called when compaction fails to result in a page
> +	 * allocation success. This is somewhat unsatisfactory as the failure
> +	 * to compact has nothing to do with time and everything to do with
> +	 * the requested order, the number of free pages and watermarks. How
> +	 * to wait on that is more unclear, but the answer would apply to
> +	 * other areas where the VM waits based on time.
> +	 */

c'mon, let's not make this rod for our backs.

The "A suitable page may exist but watermarks are not met" case can be
addressed by testing the watermarks up-front, surely?

I bet the "Page migration cannot move all pages so fragmentation
remains" case can be addressed by setting some metric in the zone, and
suitably modifying that as a result on ongoing activity.  To tell the
zone "hey, compaction migth be worth trying now".  that sucks too, but not
so much.

Or something.  Putting a wallclock-based throttle on it like this
really does reduce the usefulness of the whole feature.

Internet: "My application works OK on a hard disk but fails when I use an SSD!". 

akpm: "Tell Mel!"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
