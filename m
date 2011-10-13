Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DD60E6B0031
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 04:10:12 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E0A823EE0C3
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 17:10:03 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BE3F745DF55
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 17:10:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A10EA45DF47
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 17:10:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 912B81DB8042
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 17:10:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 499191DB8037
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 17:10:03 +0900 (JST)
Date: Thu, 13 Oct 2011 17:09:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -v2 -mm] add extra free kbytes tunable
Message-Id: <20111013170907.80775c54.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111013073321.GA2784@barrios-desktop>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
	<20110901100650.6d884589.rdunlap@xenotime.net>
	<20110901152650.7a63cb8b@annuminas.surriel.com>
	<20110901145819.4031ef7c.akpm@linux-foundation.org>
	<65795E11DBF1E645A09CEC7EAEE94B9CAFB42677@USINDEVS02.corp.hds.com>
	<20111013073321.GA2784@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, "hughd@google.com" <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

On Thu, 13 Oct 2011 16:33:21 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Sep 02, 2011 at 12:31:14PM -0400, Satoru Moriya wrote:
> > On 09/01/2011 05:58 PM, Andrew Morton wrote:
> > > On Thu, 1 Sep 2011 15:26:50 -0400
> > > Rik van Riel <riel@redhat.com> wrote:
> > > 
> > >> Add a userspace visible knob
> > > 
> > > argh.  Fear and hostility at new knobs which need to be maintained for 
> > > ever, even if the underlying implementation changes.
> > > 
> > > Unfortunately, this one makes sense.
> > > 
> > >> to tell the VM to keep an extra amount of memory free, by increasing 
> > >> the gap between each zone's min and low watermarks.
> > >>
> > >> This is useful for realtime applications that call system calls and 
> > >> have a bound on the number of allocations that happen in any short 
> > >> time period.  In this application, extra_free_kbytes would be left at 
> > >> an amount equal to or larger than the maximum number of 
> > >> allocations that happen in any burst.
> > > 
> > > _is_ it useful?  Proof?
> > > 
> > > Who is requesting this?  Have they tested it?  Results?
> > 
> > This is interesting for me.
> > 
> > Some of our customers have realtime applications and they are concerned 
> > the fact that Linux uses free memory as pagecache. It means that
> > when their application allocate memory, Linux kernel tries to reclaim
> > memory at first and then allocate it. This may make memory allocation
> > latency bigger.
> > 
> > In many cases this is not a big issue because Linux has kswapd for
> > background reclaim and it is fast enough not to enter direct reclaim
> > path if there are a lot of clean cache. But under some situations -
> > e.g. Application allocates a lot of memory which is larger than delta
> > between watermark_low and watermark_min in a short time and kswapd
> > can't reclaim fast enough due to dirty page reclaim, direct reclaim
> > is executed and causes big latency.
> > 
> > We can avoid the issue above by using preallocation and mlock.
> > But it can't cover kmalloc used in systemcall. So I'd like to use
> > this patch with mlock to avoid memory allocation latency issue as
> > low as possible. It may not be a perfect solution but it is important
> > for customers in enterprise area to configure the amount of free
> > memory at their own risk.
> 
> I agree needs for such feature but don't like such primitive interface
> exporting to user.
> 
> As Satoru said, we can reserve free pages for user through preallocation and mlocking.
> The thing is free pages for kernel itself.
> Most desirable thing is we have to avoid syscall in critical realtime section.
> But if we can't avoid, my crazy idea is to use memcg for kernel pages.
> Of course, we should implement it and not simple stuff but AFAIK, memcg people
> always consider it and finally will do it. :)
> Recently, Glauber try "Basic kernel memory functionality" but I don't have reviewed
> it yet. I am not sure we can reuse it, anyway. Kame?
> 

I reviewed it and it seems good. It adds kmem.limit_in_bytes then we're ready
to go forward to kernel memory cgroup.
But it adds only interfaces now.

I think  Greg Thelen <gthelen@google.com> has some idea.


> My simple idea is as follows,
> 
> We can assign basic revered page pool and/or size of user-determined pages pool
> for each task registred at memcg-slab.

Hmm, memcg-mempool ?


> The application have to notify start of RT section to memcg before it goes to
> RT section. So, memcg could fill up page pool if it is short. In this case,
> application can stuck but it's okay as it doesn't go to RT section yet.
> The applicatoin have to notify end of RT section to memcg, too so that memcg
> could try to fill up reserved page pool in case of shortage.
> 

That 'notification' doesn't sounds good to me. When application died/moved to
other group without notification, memcg will be unstable.
It should be task's state rather than memcg's state.


> Why we need such notification is kswapd high prioiry, new knob and others never
> can meet application's deadline requirement in some situations(ex,
> there are so many dirty pages in LRU or fill up anon pages in non-swap case and so on)
> so that application might end up stuck at some point. The somepoint must be out of RT
> section of the task.
> 
> For implemenation, we might need new watermark setting for each memcg or/and
> kswapd prioirity promotion like thing for hurry reclaiming.
> Anyway, they are just implementaions and we could enhance/add further more through
> various techniques as time goes by.
> 
> Personally, I think it could a valuable featue.
> 

Hmm. For avoid latency at allocation, what we can do is only pre-allocation before it's
required. But the problem is that applications cannot forecast when the 'burst' allocation
happens and we need to prepare memory pool always.

I think we need 2 implemenations.

1. free-page mempool for a memcg.
2. a background reclaim thread for a memcg. This is triggered by mempool.
   Prioritity of this thread should be able to controlled by some ways.

If we take care of memcg's limit, watermark should trigger background reclaim.

?
But the memory reclaim routine should never be in sleep...


Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
