Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BF3666B0012
	for <linux-mm@kvack.org>; Fri,  6 May 2011 10:23:12 -0400 (EDT)
Date: Fri, 6 May 2011 16:22:57 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
Message-ID: <20110506142257.GI10278@cmpxchg.org>
References: <20110429133313.GB306@tiehlicka.suse.cz>
 <20110501150410.75D2.A69D9226@jp.fujitsu.com>
 <20110503064945.GA18927@tiehlicka.suse.cz>
 <BANLkTimmpHcSJuO_8+P=GjYf+wB=Nyq=4w@mail.gmail.com>
 <20110503082550.GD18927@tiehlicka.suse.cz>
 <BANLkTikZtOdzsnjH=43AegLCpYc6ecfKsg@mail.gmail.com>
 <20110504085851.GC1375@tiehlicka.suse.cz>
 <BANLkTinxuSaCEvN4_vB=uA1rdGUwCpovog@mail.gmail.com>
 <20110505065901.GC11529@tiehlicka.suse.cz>
 <20110506142834.90e0b363.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110506142834.90e0b363.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Fri, May 06, 2011 at 02:28:34PM +0900, KAMEZAWA Hiroyuki wrote:
> Hmm, so, the interface should be
> 
>   memory.watermark  --- the total usage which kernel's memory shrinker starts.
> 
> ?
> 
> I'm okay with this. And I think this parameter should be fully independent from
> the limit.
> 
> Memcg can work without watermark reclaim. I think my patch just adds a new
> _limit_ which a user can shrink usage of memory on deamand with kernel's help.
> Memory reclaim works in background but this is not a kswapd, at all.
> 
> I guess performance benefit of using watermark under a cgroup which has limit
> is very small and I think this is not for a performance tuning parameter. 
> This is just a new limit.
> 
> Comparing 2 cases,
> 
>  cgroup A)
>    - has limit of 300M, no watermaks.
>  cgroup B)
>    - has limit of UNLIMITED, watermarks=300M
> 
> A) has hard limit and memory reclaim cost is paid by user threads, and have
> risks of OOM under memcg.
> B) has no hard limit and memory reclaim cost is paid by kernel threads, and
> will not have risk of OOM under memcg, but can be CPU burning.
> 
> I think this should be called as soft-limit ;) But we have another soft-limit now.
> Then, I call this as watermark. This will be useful to resize usage of memory
> in online because application will not hit limit and get big latency even while
> an admin makes watermark smaller.

I have two thoughts to this:

1. Even though the memcg will not hit the limit and the application
will not be forced to do memcg target reclaim, the watermark reclaim
will steal pages from the memcg and the application will suffer the
page faults, so it's not an unconditional win.

2. I understand how the feature is supposed to work, but I don't
understand or see a use case for the watermark being configurable.
Don't get me wrong, I completely agree with watermark reclaim, it's a
good latency optimization.  But I don't see why you would want to
manually push back a memcg by changing the watermark.

Ying wrote in another email that she wants to do this to make room for
another job that is about to get launched.  My reply to that was that
you should just launch the job and let global memory pressure push
back that memcg instead.  So instead of lowering the watermark, you
could lower the soft limit and don't do any reclaim at all until real
pressure arises.  You said yourself that the new feature should be
called soft limit.  And I think it is because it is a reimplementation
of the soft limit!

I am sorry that I am such a drag regarding this, please convince me so
I can crawl back to my cave ;)

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
