Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 564DA6B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 07:50:50 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro2so10280222pbb.13
        for <linux-mm@kvack.org>; Thu, 13 Jun 2013 04:50:49 -0700 (PDT)
Date: Thu, 13 Jun 2013 19:50:35 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch 4/4 v4]swap: make cluster allocation per-cpu
Message-ID: <20130613115035.GC26947@kernel.org>
References: <20130326053843.GD19646@kernel.org>
 <20130612152231.d342ac905d8982db6935b739@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130612152231.d342ac905d8982db6935b739@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com, aquini@redhat.com

On Wed, Jun 12, 2013 at 03:22:31PM -0700, Andrew Morton wrote:
> On Tue, 26 Mar 2013 13:38:43 +0800 Shaohua Li <shli@kernel.org> wrote:
> 
> > swap cluster allocation is to get better request merge to improve performance.
> > But the cluster is shared globally, if multiple tasks are doing swap, this will
> > cause interleave disk access. While multiple tasks swap is quite common, for
> > example, each numa node has a kswapd thread doing swap or multiple
> > threads/processes do direct page reclaim.
> > 
> > We makes the cluster allocation per-cpu here. The interleave disk access issue
> > goes away. All tasks will do sequential swap.
> 
> Why per-cpu rather than, say, per-mm or per-task?

Good question. per-cpu is easier to implement :). per-mm or per-task is likely
to be more readahead friendly for sequential workload. per-cpu is better in
swapout side for random workload. Not sure which is more important. I choose to
solve the swapout issue. Definitely this should be revisit if we want a better
swapin readahead. But if you dislike this patch, I'm ok to drop it in next
post.

> > If one CPU can't get its per-cpu cluster, it will fallback to scan swap_map.
> 
> Under what circumstances can a cpu "not get its per-cpu cluster"?  A
> cpu can always "get" its per-cpu data, by definition (unless perhaps
> interrupts are involved).  Perhaps this description needs some
> expanding upon.

the circumstance is there is no free cluster. I'll rewrite the description.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
