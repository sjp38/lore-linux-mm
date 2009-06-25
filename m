Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2916B004F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 15:09:49 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5PJ2eMh008637
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 13:02:40 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5PJA1RV222910
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 13:10:03 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5PJA0jY013656
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 13:10:01 -0600
Date: Thu, 25 Jun 2009 21:46:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Reduce the resource counter lock overhead
Message-ID: <20090625161611.GB8642@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090624170516.GT8642@balbir.in.ibm.com> <20090624161028.b165a61a.akpm@linux-foundation.org> <20090625085347.a64654a7.kamezawa.hiroyu@jp.fujitsu.com> <20090625032717.GX8642@balbir.in.ibm.com> <20090624204426.3dc9e108.akpm@linux-foundation.org> <20090625133908.6ae3dd40.kamezawa.hiroyu@jp.fujitsu.com> <20090625054042.GA8642@balbir.in.ibm.com> <20090625153033.17852d85.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090625153033.17852d85.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, nishimura@mxp.nes.nec.co.jp, menage@google.com, xemul@openvz.org, linux-mm@kvack.org, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-25 15:30:33]:

> On Thu, 25 Jun 2009 11:10:42 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-25 13:39:08]:
> > 
> > > On Wed, 24 Jun 2009 20:44:26 -0700
> > > Andrew Morton <akpm@linux-foundation.org> wrote:
> > > 
> > > > On Thu, 25 Jun 2009 08:57:17 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > 
> > > > > We do a read everytime before we charge.
> > > > 
> > > > See, a good way to fix that is to not do it.  Instead of
> > > > 
> > > > 	if (under_limit())
> > > > 		charge_some_more(amount);
> > > > 	else
> > > > 		goto fail;
> > > > 
> > > > one can do 
> > > > 
> > > > 	if (try_to_charge_some_more(amount) < 0)
> > > > 		goto fail;
> > > > 
> > > > which will halve the locking frequency.  Which may not be as beneficial
> > > > as avoiding the locking altogether on the read side, dunno.
> > > > 
> > > I don't think we do read-before-write ;)
> > >
> > 
> > I need to figure out the reason for read contention and why seqlock's
> > help. Like I said before I am seeing some strange values for
> > reclaim_stats on the root cgroup, even though it is not reclaimable or
> > not used for reclaim. There can be two reasons
> > 
> I don't remember but reclaim_stat goes bad ? new BUG ?
> reclaim_stat means zone_recaim_stat gotten by get_reclaim_stat() ?
> 
> IIUC, after your ROOT_CGROUP-no-LRU patch, reclaim_stat of root cgroup
> will never be accessed. Right ?
>

Correct!
 
> 
> > 1. Reclaim
> > 2. User space constantly reading the counters
> > 
> > I have no user space utilities I am aware of running on the system,
> > constantly reading the contents of the files. 
> > 
> 
> This is from your result.
> 
>                     Before                 After
> class name       &counter->lock:   &(&counter->lock)->lock
> con-bounces      1534627                   962193  
> contentions      1575341                   976349 
> waittime-min     0.57                      0.60  
> waittime-max     18.39                     14.07
> waittime-total   675713.23                 465926.04 
> acq-bounces      43330446                  21364165
> acquisitions     138524248                 66041988
> holdtime-min     0.43                      0.45
> holdtime-max     148.13                    88.31
> holdtime-total   54133607.05               25395513.12
> 
> >From this result, acquisitions is changed as
>  - 138524248 => 66041988
> Almost half.
> 

Yes, precisely! That is why I thought it was a great result.

> Then,
> - "read" should be half of all counter access.
> or
> - did you enabped swap cgroup in "after" test ?
> 
> BTW, if this result is against "Root" cgroup, no reclaim by memcg
> will happen after your no-ROOT-LRU patch.
>

The configuration was the same for both runs. I'll rerun and see why
that is.
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
