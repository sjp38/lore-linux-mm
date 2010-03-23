Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9FE5F6B01C9
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:33:54 -0400 (EDT)
Date: Tue, 23 Mar 2010 13:31:43 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 11/11] Do not compact within a preferred zone after a
 compaction failure
In-Reply-To: <1269347146-7461-12-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1003231327580.10178@router.home>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-12-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Mar 2010, Mel Gorman wrote:

> The fragmentation index may indicate that a failure it due to external

s/it/is/

> fragmentation, a compaction run complete and an allocation failure still

???

> fail. There are two obvious reasons as to why
>
>   o Page migration cannot move all pages so fragmentation remains
>   o A suitable page may exist but watermarks are not met
>
> In the event of compaction and allocation failure, this patch prevents
> compaction happening for a short interval. It's only recorded on the

compaction is "recorded"? deferred?

> preferred zone but that should be enough coverage. This could have been
> implemented similar to the zonelist_cache but the increased size of the
> zonelist did not appear to be justified.

> @@ -1787,6 +1787,9 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
>  			 */
>  			count_vm_event(COMPACTFAIL);
>
> +			/* On failure, avoid compaction for a short time. */
> +			defer_compaction(preferred_zone, jiffies + HZ/50);
> +

20ms? How was that interval determined?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
