Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id ADD906B007E
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 15:22:11 -0400 (EDT)
Subject: Re: [Patch] mm tracepoints update - use case.
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <20090616170811.99A6.A69D9226@jp.fujitsu.com>
References: <20090423092933.F6E9.A69D9226@jp.fujitsu.com>
	 <4A36925D.4090000@redhat.com> <20090616170811.99A6.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Date: Thu, 18 Jun 2009 15:22:34 -0400
Message-Id: <1245352954.3212.67.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, =?UTF-8?Q?Fr=E9=A6=98=E9=A7=BBic?= Weisbecker <fweisbec@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, eduard.munteanu@linux360.ro, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rostedt@goodmis.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-06-18 at 16:57 +0900, KOSAKI Motohiro wrote:

Thanks for the feedback Kosaki!


> Scenario 1. OOM killer happend. why? and who bring it?

Doesnt the showmem() and stack trace to the console when the OOM kill
occurred show enough in the majority of cases?  I realize that direct
alloc_pages() calls are not accounted for here but that can be really
invasive.

> Scenario 2. page allocation failure by memory fragmentation

Are you talking about order>0 allocation failures here?  Most of the
slabs are single page allocations now.

> Scenario 3. try_to_free_pages() makes very long latency. why?

This is available in the mm tracepoints, they all include timestamps.

> Scenario 4. sar output that free memory dramatically reduced at 10 minute ago, and
>             it already recover now. What's happen?

Is this really important?  It would take buffering lots of data to
figure out what happened in the past.

> 
>   - suspects
>     - kernel memory leak

Other than direct callers to the page allocator isnt that covered with
the kmemtrace stuff?

>     - userland memory leak

The mm tracepoints track all user space allocations and frees(perhaps
too many?).

>     - stupid driver use too much memory

hopefully kmemtrace will catch this?

>     - userland application suddenly start to use much memory

The mm tracepoints track all user space allocations and frees.

> 
>   - what information are valuable?
>     - slab usage information (kmemtrace already does)
>     - page allocator usage information
>     - rss of all processes at oom happend
>     - why recent try_to_free_pages() can't reclaim any page?

The counters in the mm tracepoints do give counts but not the reasons
that the pagereclaim code fails.

>     - recent sycall history
>     - buddy fragmentation info
> 
> 
> Plus, another requirement here
> 1. trace page refault distance (likes past Rik's /proc/refault patch)
> 
> 2. file cache visualizer - Which file use many page-cache?
>    - afaik, Wu Fengguang is working on this issue.
> 
> 
> --------------------------------------------
> And, here is my reviewing comment to his patch.
> btw, I haven't full review it yet. perhaps I might be overlooking something.
> 
> 
> First, this is general review comment.
> 
> - Please don't display mm and/or another kernel raw pointer.
>   if we assume non stop system, we can't use kernel-dump. Thus kernel pointer
>   logging is not so useful.

OK, I just dont know how valuable the trace output is with out some raw
data like the mm_struct.

>   Any userland tools can't parse it. (/proc/kcore don't help this situation,
>   the pointer might be freed before parsing)
> - Please makes patch series. one big patch is harder review.

OK.

> - Please write patch description and use-case.

OK.

> - Please consider how do this feature works on mem-cgroup.
>   (IOW, please don't ignore many "if (scanning_global_lru())")
> - tracepoint caller shouldn't have any assumption of displaying representation.
>   e.g.
>     wrong)  trace_mm_pagereclaim_pgout(mapping, page->index<<PAGE_SHIFT, PageAnon(page));
>     good)   trace_mm_pagereclaim_pgout(mapping, page)

OK.

>   that's general and good callback and/or hook manner.
> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
