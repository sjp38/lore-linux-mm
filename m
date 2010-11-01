Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4325F8D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 14:24:37 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id oA1IOWRK006700
	for <linux-mm@kvack.org>; Mon, 1 Nov 2010 11:24:32 -0700
Received: from pvg11 (pvg11.prod.google.com [10.241.210.139])
	by wpaz29.hot.corp.google.com with ESMTP id oA1IO7TS010780
	for <linux-mm@kvack.org>; Mon, 1 Nov 2010 11:24:31 -0700
Received: by pvg11 with SMTP id 11so592491pvg.30
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 11:24:26 -0700 (PDT)
Date: Mon, 1 Nov 2010 11:24:16 -0700
From: Mandeep Singh Baines <msb@chromium.org>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for
 protecting the working set
Message-ID: <20101101182416.GB31189@google.com>
References: <20101028191523.GA14972@google.com>
 <20101101012322.605C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101101012322.605C.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mandeep Singh Baines <msb@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro (kosaki.motohiro@jp.fujitsu.com) wrote:
> Hi
> 
> > On ChromiumOS, we do not use swap. When memory is low, the only way to
> > free memory is to reclaim pages from the file list. This results in a
> > lot of thrashing under low memory conditions. We see the system become
> > unresponsive for minutes before it eventually OOMs. We also see very
> > slow browser tab switching under low memory. Instead of an unresponsive
> > system, we'd really like the kernel to OOM as soon as it starts to
> > thrash. If it can't keep the working set in memory, then OOM.
> > Losing one of many tabs is a better behaviour for the user than an
> > unresponsive system.
> > 
> > This patch create a new sysctl, min_filelist_kbytes, which disables reclaim
> > of file-backed pages when when there are less than min_filelist_bytes worth
> > of such pages in the cache. This tunable is handy for low memory systems
> > using solid-state storage where interactive response is more important
> > than not OOMing.
> > 
> > With this patch and min_filelist_kbytes set to 50000, I see very little
> > block layer activity during low memory. The system stays responsive under
> > low memory and browser tab switching is fast. Eventually, a process a gets
> > killed by OOM. Without this patch, the system gets wedged for minutes
> > before it eventually OOMs. Below is the vmstat output from my test runs.
> 
> I've heared similar requirement sometimes from embedded people. then also
> don't use swap. then, I don't think this is hopeless idea. but I hope to 
> clarify some thing at first.
> 

swap would be intersting if we could somehow control swap thrashing. Maybe
we could add min_anonlist_kbytes. Just kidding:)

> Yes, a system often have should-not-be-evicted-file-caches. Typically, they
> are libc, libX11 and some GUI libraries. Traditionally, we was making tiny
> application which linked above important lib and call mlockall() at startup.
> such technique prevent reclaim. So, Q1: Why do you think above traditional way
> is insufficient? 
> 

mlock is too coarse grain. It requires locking the whole file in memory.
The chrome and X binaries are quite large so locking them would waste a lot
of memory. We could lock just the pages that are part of the working set but
that is difficult to do in practice. Its unmaintainable if you do it
statically. If you do it at runtime by mlocking the working set, you're
sort of giving up on mm's active list.

Like akpm, I'm sad that we need this patch. I'd rather the kernel did a better
job of identifying the working set. We did look at ways to do a better
job of keeping the working set in the active list but these were tricker
patches and never quite worked out. This patch is simple and works great.

Under memory pressure, I see the active list get smaller and smaller. Its
getting smaller because we're scanning it faster and faster, causing more
and more page faults which slows forward progress resulting in the active
list getting smaller still. One way to approach this might to make the
scan rate constant and configurable. It doesn't seem right that we scan
memory faster and faster under low memory. For us, we'd rather OOM than
evict pages that are likely to be accessed again so we'd prefer to make
a conservative estimate as to what belongs in the working set. Other
folks (long computations) might want to reclaim more aggressively.

> Q2: In the above you used min_filelist_kbytes=50000. How do you decide 
> such value? Do other users can calculate proper value?
> 

50M was small enough that we were comfortable with keeping 50M of file pages
in memory and large enough that it is bigger than the working set. I tested
by loading up a bunch of popular web sites in chrome and then observing what
happend when I ran out of memory. With 50M, I saw almost no thrashing and
the system stayed responsive even under low memory. but I wanted to be
conservative since I'm really just guessing.

Other users could calculate their value by doing something similar. Load
up the system (exhaust free memory) with a typical load and then observe
file io via vmstat. They can then set min_filelist_kbytes to the value
where they see a tolerable amounting of thrashing (page faults, block io).

> In addition, I have two request. R1: I think chromium specific feature is
> harder acceptable because it's harder maintable. but we have good chance to
> solve embedded generic issue. Please discuss Minchan and/or another embedded

I think this feature should be useful to a lot of embedded applications where
OOM is OK, especially web browsing applications where the user is OK with
losing 1 of many tabs they have open. However, I consider this patch a
stop-gap. I think the real solution is to do a better job of protecting
the active list.

> developers. R2: If you want to deal OOM combination, please consider to 
> combination of memcg OOM notifier too. It is most flexible and powerful OOM
> mechanism. Probably desktop and server people never use bare OOM killer intentionally.
> 

Yes, will definitely look at OOM notifier. Currently trying to see if we can
get by with oomadj. With OOM notifier you'd have to respond earlier so you
might OOM more. However, with a notifier you might be able to take action that
might prevent OOM altogether.

I see memcg more as an isolation mechanism but I guess you could use it to
isolate the working set from anon browser tab data as Kamezawa suggests.

Regards,
Mandeep

> Thanks.
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
