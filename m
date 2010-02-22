Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EC2276B004D
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 15:34:29 -0500 (EST)
Message-ID: <4B82EA4D.8040305@redhat.com>
Date: Mon, 22 Feb 2010 15:34:21 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 3/3] vmscan: detect mapped file pages used only once
References: <1266868150-25984-1-git-send-email-hannes@cmpxchg.org> <1266868150-25984-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1266868150-25984-4-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 02/22/2010 02:49 PM, Johannes Weiner wrote:
> The VM currently assumes that an inactive, mapped and referenced file
> page is in use and promotes it to the active list.
>
> However, every mapped file page starts out like this and thus a problem
> arises when workloads create a stream of such pages that are used only
> for a short time.  By flooding the active list with those pages, the VM
> quickly gets into trouble finding eligible reclaim canditates.  The
> result is long allocation latencies and eviction of the wrong pages.
>
> This patch reuses the PG_referenced page flag (used for unmapped file
> pages) to implement a usage detection that scales with the speed of
> LRU list cycling (i.e. memory pressure).
>
> If the scanner encounters those pages, the flag is set and the page
> cycled again on the inactive list.  Only if it returns with another
> page table reference it is activated.  Otherwise it is reclaimed as
> 'not recently used cache'.
>
> This effectively changes the minimum lifetime of a used-once mapped
> file page from a full memory cycle to an inactive list cycle, which
> allows it to occur in linear streams without affecting the stable
> working set of the system.
>
> Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
