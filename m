Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id BD5E26B0083
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 16:13:16 -0400 (EDT)
Message-ID: <4F8C7D59.1000402@redhat.com>
Date: Mon, 16 Apr 2012 16:13:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Followup: [PATCH -mm] make swapin readahead skip over holes
References: <7297ae3b-f3e1-480b-838f-69b0e09a733d@default>
In-Reply-To: <7297ae3b-f3e1-480b-838f-69b0e09a733d@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 04/16/2012 02:34 PM, Dan Magenheimer wrote:
> Hi Rik --
>
> I saw this patch in 3.4-rc1 (because it caused a minor merge
> conflict with frontswap) and wondered about its impact.
> Since I had a server still set up from running benchmarks
> before LSFMM, I ran my kernel compile -jN workload (with
> N varying from 4 to 40) on 1GB of RAM, on 3.4-rc2 both with
> and without this patch.
>
> For values of N=24 and N=28, your patch made the workload
> run 4-9% percent faster.  For N=16 and N=20, it was 5-10%
> slower.  And for N=36 and N=40, it was 30%-40% slower!
>
> Is this expected?  Since the swap "disk" is a partition
> on the one active drive, maybe the advantage is lost due
> to contention?

There are several things going on here:

1) you are running a workload that thrashes

2) the speed at which data is swapped in is increased
    with this patch

3) with only 1GB memory, the inactive anon list is
    the same size as the active anon list

4) the above points combined mean that less of the
    working set could be in memory at once

One solution may be to decrease the swap cluster for
small systems, when they are thrashing.

On the other hand, for most systems swap is very much
a special circumstance, and you want to focus on quickly
moving excess stuff into swap, and moving it back into
memory when needed.

Workloads that thrash are very much an exception, and
probably not what we should optimize for.


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
