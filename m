Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 22E016B00B8
	for <linux-mm@kvack.org>; Sun,  1 Mar 2009 23:40:57 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n224elhG021512
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 10:10:47 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n224bnDG4370632
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 10:07:50 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n224ejH3006041
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 15:40:45 +1100
Date: Mon, 2 Mar 2009 10:10:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-ID: <20090302044043.GC11421@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain> <20090302092404.1439d2a6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090302092404.1439d2a6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 09:24:04]:

> On Sun, 01 Mar 2009 11:59:59 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > Changelog v3...v2
> > 1. Implemented several review comments from Kosaki-San and Kamezawa-San
> >    Please see individual changelogs for changes
> > 
> > Changelog v2...v1
> > 1. Soft limits now support hierarchies
> > 2. Use spinlocks instead of mutexes for synchronization of the RB tree
> > 
> > Here is v3 of the new soft limit implementation. Soft limits is a new feature
> > for the memory resource controller, something similar has existed in the
> > group scheduler in the form of shares. The CPU controllers interpretation
> > of shares is very different though. 
> > 
> > Soft limits are the most useful feature to have for environments where
> > the administrator wants to overcommit the system, such that only on memory
> > contention do the limits become active. The current soft limits implementation
> > provides a soft_limit_in_bytes interface for the memory controller and not
> > for memory+swap controller. The implementation maintains an RB-Tree of groups
> > that exceed their soft limit and starts reclaiming from the group that
> > exceeds this limit by the maximum amount.
> > 
> > If there are no major objections to the patches, I would like to get them
> > included in -mm.
> > 
> > TODOs
> > 
> > 1. The current implementation maintains the delta from the soft limit
> >    and pushes back groups to their soft limits, a ratio of delta/soft_limit
> >    might be more useful
> > 2. It would be nice to have more targetted reclaim (in terms of pages to
> >    recalim) interface. So that groups are pushed back, close to their soft
> >    limits.
> > 
> > Tests
> > -----
> > 
> > I've run two memory intensive workloads with differing soft limits and
> > seen that they are pushed back to their soft limit on contention. Their usage
> > was their soft limit plus additional memory that they were able to grab
> > on the system. Soft limit can take a while before we see the expected
> > results.
> > 
> > Please review, comment.
> > 
> Please forgive me to say....that the code itself is getting better but far from
> what I want. Maybe I have to show my own implementation to show my idea
> and the answer is between yours and mine. If now was the last year, I have enough
> time until distro's target kernel and may welcome any innovative patches even if
> it seems to give me concerns, but I have to be conservative now.

I am not asking for an immediate push to mainline, but for integration
into -mm and more test. Let me address your concern below

> 
> At first, it's said "When cgroup people adds something, the kernel gets slow".
> This is my start point of reviewing. Below is comments to this version of patch.
> 
>  1. I think it's bad to add more hooks to res_counter. It's enough slow to give up
>     adding more fancy things..

res_counters was desgined to be extensible, why is adding anything to
it going to make it slow, unless we turn on soft_limits?

> 
>  2. please avoid to add hooks to hot-path. In your patch, especially a hook to
>     mem_cgroup_uncharge_common() is annoying me.

If soft limits are not enabled, the function does a small check and
leaves. 

> 
>  3. please avoid to use global spinlock more. 
>     no lock is best. mutex is better, maybe.
> 

No lock to update a tree which is update concurrently?

>  4. RB-tree seems broken. Following is example. (please note you do all ops
>     in lazy manner (once in HZ/4.)
> 
>    i). while running, the tree is constructed as following
> 
>              R           R=exceed=300M
>             / \ 
>            A   B      A=exceed=200M  B=exceed=400M
>    ii) A process B exits, but and usage goes down.

That is why we have the hook in uncharge. Even if we update and the
usage goes down, the tree is ordered by usage_in_excess which is
updated only when the tree is updated. So what you show below does not
occur. I think I should document the design better.

> 
>    iii)      R          R=exceed=300M
>             / \
>            A   B      A=exceed=200M  B=exceed=10M
> 
>    vi) A new node inserted
>              R         R=exceed=300M
>             / \       
>            A   B       A=exceed=200M B=exceed=10M
>               / \
>              nil C     C=exceed=310M
> 
>    v) Time expires and remove "R" and do rotate.
> 
>    Hmm ? Is above status is allowed ? I'm sorry if I misunderstand RBtree.
> 
> I'll post my own version in this week (more conservative version, maybe).
> please discuss and compare trafe-offs.
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
