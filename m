Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 005756B00CF
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 01:37:06 -0500 (EST)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id n226acsU031842
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 17:36:38 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n226bIvJ405942
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 17:37:18 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n226axFB000485
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 17:37:00 +1100
Date: Mon, 2 Mar 2009 12:06:49 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-ID: <20090302063649.GJ11421@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain> <20090302092404.1439d2a6.kamezawa.hiroyu@jp.fujitsu.com> <20090302044043.GC11421@balbir.in.ibm.com> <20090302143250.f47758f9.kamezawa.hiroyu@jp.fujitsu.com> <20090302060519.GG11421@balbir.in.ibm.com> <20090302152128.e74f51ef.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090302152128.e74f51ef.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 15:21:28]:

> On Mon, 2 Mar 2009 11:35:19 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 14:32:50]:
> > 
> > > On Mon, 2 Mar 2009 10:10:43 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 09:24:04]:
> > > > 
> > > > > On Sun, 01 Mar 2009 11:59:59 +0530
> > > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > > 
> > > > > > 
> > > > > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > 
> > > > > 
> > > > > At first, it's said "When cgroup people adds something, the kernel gets slow".
> > > > > This is my start point of reviewing. Below is comments to this version of patch.
> > > > > 
> > > > >  1. I think it's bad to add more hooks to res_counter. It's enough slow to give up
> > > > >     adding more fancy things..
> > > > 
> > > > res_counters was desgined to be extensible, why is adding anything to
> > > > it going to make it slow, unless we turn on soft_limits?
> > > > 
> > > You inserted new "if" logic in the core loop.
> > > (What I want to say here is not that this is definitely bad but that "isn't there
> > >  any alternatives which is less overhead.)
> > > 
> > > 
> > > > > 
> > > > >  2. please avoid to add hooks to hot-path. In your patch, especially a hook to
> > > > >     mem_cgroup_uncharge_common() is annoying me.
> > > > 
> > > > If soft limits are not enabled, the function does a small check and
> > > > leaves. 
> > > > 
> > > &soft_fail_res is passed always even if memory.soft_limit==ULONG_MAX
> > > res_counter_soft_limit_excess() adds one more function call and spinlock, and irq-off.
> > >
> > 
> > OK, I see that overhead.. I'll figure out a way to work around it.
> >  
> > > > > 
> > > > >  3. please avoid to use global spinlock more. 
> > > > >     no lock is best. mutex is better, maybe.
> > > > > 
> > > > 
> > > > No lock to update a tree which is update concurrently?
> > > > 
> > > Using tree/sort itself is nonsense, I believe.
> > > 
> > 
> > I tried using prio trees in the past, but they are not easy to update
> > either. I won't mind asking for suggestions for a data structure that
> > can scaled well, allow quick insert/delete and search.
> > 
> Now, because the routine is called by kswapd() not by try_to_free.....
> 
> It's not necessary to be very very fast. That's my point.
>

OK, I get your point, but whay does that make RB-Tree data structure non-sense?
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
