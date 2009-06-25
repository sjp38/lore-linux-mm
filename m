Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BFC516B005C
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 02:31:11 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5P6W8ao031432
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 25 Jun 2009 15:32:08 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C000045DE5D
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 15:32:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6269D45DE4F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 15:32:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D497E08004
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 15:32:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F3A2A1DB8038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 15:32:06 +0900 (JST)
Date: Thu, 25 Jun 2009 15:30:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Reduce the resource counter lock overhead
Message-Id: <20090625153033.17852d85.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090625054042.GA8642@balbir.in.ibm.com>
References: <20090624170516.GT8642@balbir.in.ibm.com>
	<20090624161028.b165a61a.akpm@linux-foundation.org>
	<20090625085347.a64654a7.kamezawa.hiroyu@jp.fujitsu.com>
	<20090625032717.GX8642@balbir.in.ibm.com>
	<20090624204426.3dc9e108.akpm@linux-foundation.org>
	<20090625133908.6ae3dd40.kamezawa.hiroyu@jp.fujitsu.com>
	<20090625054042.GA8642@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, nishimura@mxp.nes.nec.co.jp, menage@google.com, xemul@openvz.org, linux-mm@kvack.org, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jun 2009 11:10:42 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-25 13:39:08]:
> 
> > On Wed, 24 Jun 2009 20:44:26 -0700
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > On Thu, 25 Jun 2009 08:57:17 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > We do a read everytime before we charge.
> > > 
> > > See, a good way to fix that is to not do it.  Instead of
> > > 
> > > 	if (under_limit())
> > > 		charge_some_more(amount);
> > > 	else
> > > 		goto fail;
> > > 
> > > one can do 
> > > 
> > > 	if (try_to_charge_some_more(amount) < 0)
> > > 		goto fail;
> > > 
> > > which will halve the locking frequency.  Which may not be as beneficial
> > > as avoiding the locking altogether on the read side, dunno.
> > > 
> > I don't think we do read-before-write ;)
> >
> 
> I need to figure out the reason for read contention and why seqlock's
> help. Like I said before I am seeing some strange values for
> reclaim_stats on the root cgroup, even though it is not reclaimable or
> not used for reclaim. There can be two reasons
> 
I don't remember but reclaim_stat goes bad ? new BUG ?
reclaim_stat means zone_recaim_stat gotten by get_reclaim_stat() ?

IIUC, after your ROOT_CGROUP-no-LRU patch, reclaim_stat of root cgroup
will never be accessed. Right ?


> 1. Reclaim
> 2. User space constantly reading the counters
> 
> I have no user space utilities I am aware of running on the system,
> constantly reading the contents of the files. 
> 

This is from your result.

                    Before                 After
class name       &counter->lock:   &(&counter->lock)->lock
con-bounces      1534627                   962193  
contentions      1575341                   976349 
waittime-min     0.57                      0.60  
waittime-max     18.39                     14.07
waittime-total   675713.23                 465926.04 
acq-bounces      43330446                  21364165
acquisitions     138524248                 66041988
holdtime-min     0.43                      0.45
holdtime-max     148.13                    88.31
holdtime-total   54133607.05               25395513.12

>From this result, acquisitions is changed as
 - 138524248 => 66041988
Almost half.

Then,
- "read" should be half of all counter access.
or
- did you enabped swap cgroup in "after" test ?

BTW, if this result is against "Root" cgroup, no reclaim by memcg
will happen after your no-ROOT-LRU patch.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
