Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 713769000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 04:01:25 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9FA173EE0B6
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:01:21 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 858D545DE59
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:01:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B13445DE5A
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:01:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A6EE1DB8042
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:01:21 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 23B6CE08002
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:01:21 +0900 (JST)
Date: Wed, 27 Apr 2011 16:54:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 1/8] Only isolate page we can handle
Message-Id: <20110427165437.bef6967a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1d9791f27df2341cb6750f5d6279b804151f57f9.1303833417.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<1d9791f27df2341cb6750f5d6279b804151f57f9.1303833417.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, 27 Apr 2011 01:25:18 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> There are some places to isolate lru page and I believe
> users of isolate_lru_page will be growing.
> The purpose of them is each different so part of isolated pages
> should put back to LRU, again.
> 
> The problem is when we put back the page into LRU,
> we lose LRU ordering and the page is inserted at head of LRU list.
> It makes unnecessary LRU churning so that vm can evict working set pages
> rather than idle pages.
> 
> This patch adds new filter mask when we isolate page in LRU.
> So, we don't isolate pages if we can't handle it.
> It could reduce LRU churning.
> 
> This patch shouldn't change old behavior.
> It's just used by next patches.
> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

nitpick below.

> ---
>  include/linux/swap.h |    3 ++-
>  mm/compaction.c      |    2 +-
>  mm/memcontrol.c      |    2 +-
>  mm/vmscan.c          |   26 ++++++++++++++++++++------
>  4 files changed, 24 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 384eb5f..baef4ad 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -259,7 +259,8 @@ extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  						unsigned int swappiness,
>  						struct zone *zone,
>  						unsigned long *nr_scanned);
> -extern int __isolate_lru_page(struct page *page, int mode, int file);
> +extern int __isolate_lru_page(struct page *page, int mode, int file,
> +				int not_dirty, int not_mapped);

Hmm, which is better to use 4 binary args or a flag with bitmask ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
