Message-ID: <49316CAF.2010006@redhat.com>
Date: Sat, 29 Nov 2008 11:24:15 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: bail out of page reclaim after swap_cluster_max
 pages
References: <20081128140405.3D0B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <492FCFF6.1050808@redhat.com> <20081129164624.8134.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20081129164624.8134.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:

> The result talk about three things.
> 
>   - rvr and mine patch increase direct reclaim imbalancing, indeed.
>   - However, background reclaim scanning is _very_ much than direct reclaim.
>     Then, direct reclaim imbalancing is ignorable on the big view.
>     rvr patch doesn't reintroduce zone imbalancing issue.
>   - rvr's priority==DEF_PRIORITY condition checking doesn't improve
>     zone balancing at all.
>     we can drop it.
> 
> Again, I believe my patch improve vm scanning totally.
> 
> Any comments?

Reclaiming is very easy when the workload is just page cache,
because the application will be throttled when too many page
cache pages are dirty.

When using mmap or memory hogs writing to swap, applications
will not be throttled by the "too many dirty pages" logic,
but may instead end up being throttled in the direct reclaim
path instead.

At that point direct reclaim may become a lot more common,
making the imbalance more significant.

I'll run a few tests.

> Andrew, I hope add this mesurement result to rvr bailing out patch description too.

So far the performance numbers you have measured are very
encouraging and do indeed suggest that the priority==DEF_PRIORITY
thing does not make a difference.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
