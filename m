Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id m3K8K61I017724
	for <linux-mm@kvack.org>; Sun, 20 Apr 2008 13:50:06 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3K8K2xn1265740
	for <linux-mm@kvack.org>; Sun, 20 Apr 2008 13:50:02 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m3K8KEga005649
	for <linux-mm@kvack.org>; Sun, 20 Apr 2008 08:20:14 GMT
Message-ID: <480AFBE5.1070702@linux.vnet.ibm.com>
Date: Sun, 20 Apr 2008 13:46:37 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][-mm] Memory controller hierarchy support (v1)
References: <20080419053551.10501.44302.sendpatchset@localhost.localdomain> <6599ad830804190849u31f13191m4dcca4e471493c2b@mail.gmail.com>
In-Reply-To: <6599ad830804190849u31f13191m4dcca4e471493c2b@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Fri, Apr 18, 2008 at 10:35 PM, Balbir Singh
> <balbir@linux.vnet.ibm.com> wrote:
>>  1. We need to hold cgroup_mutex while walking through the children
>>    in reclaim. We need to figure out the best way to do so. Should
>>    cgroups provide a helper function/macro for it?
> 
> There's already a function, cgroup_lock(). But it would be nice to
> avoid such a heavy locking here, particularly since memory allocations
> can occur with cgroup_mutex held, which could lead to a nasty deadlock
> if the allocation triggered reclaim.
> 

Hmm.. probably..

> One of the things that I've been considering was to put the
> parent/child/sibling hierarchy explicitly in cgroup_subsys_state. This
> would give subsystems their own copy to refer to, and could use their
> own internal locking to synchronize with callbacks from cgroups that
> might change the hierarchy. Cpusets could make use of this too, since
> it has to traverse hierarchies sometimes.
> 

Very cool! I look forward to that infrastructure. I'll also look at the cpuset
code and see how to traverse the hierarchy.

>>  2. Do not allow children to have a limit greater than their parents.
>>  3. Allow the user to select if hierarchial support is required
> 
> My thoughts on this would be:
> 
> 1) Never attach a first-level child's counter to its parent. As
> Yamamoto points out, otherwise we end up with extra global operations
> whenever any cgroup allocates or frees memory. Limiting the total
> system memory used by all user processes doesn't seem to be something
> that people are going to generally want to do, and if they really do
> want to they can just create a non-root child and move the whole
> system into that.
> 
> The one big advantage that you currently get from having all
> first-level children be attached to the root is that the reclaim logic
> automatically scans other groups when it reaches the top-level - but I
> think that can be provided as a special-case in the reclaim traversal,
> avoiding the overhead of hitting the root cgroup that we have in this
> patch.
> 

I've been doing some thinking along these lines, I'll think more about this.

> 2) Always attach other children's counters to their parents - if the
> user didn't want a hierarchy, they could create a flat grouping rather
> than nested groupings.
> 

Yes, that's a TODO

> Paul


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
