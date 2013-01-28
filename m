Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 6FDC66B0008
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 03:35:09 -0500 (EST)
Message-ID: <51063848.6070004@parallels.com>
Date: Mon, 28 Jan 2013 12:35:20 +0400
From: Lord Glauber Costa of Sealand <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 2/6] memcg: split part of memcg creation to css_online
References: <1358862461-18046-1-git-send-email-glommer@parallels.com> <1358862461-18046-3-git-send-email-glommer@parallels.com> <20130125155249.402c40dd.akpm@linux-foundation.org>
In-Reply-To: <20130125155249.402c40dd.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On 01/26/2013 03:52 AM, Andrew Morton wrote:
> On Tue, 22 Jan 2013 17:47:37 +0400
> Glauber Costa <glommer@parallels.com> wrote:
> 
>> This patch is a preparatory work for later locking rework to get rid of
>> big cgroup lock from memory controller code.
> 
> Is this complete?  From my reading, the patch is also a bugfix.  It
> prevents stale tunable values from getting installed into new children?
> 
No, it is not a bug fix. This used to be all protected by the cgroup
lock under the hood - we don't see it, but it is there from cgroup core.

Yes, this is ugly. But it is one of the very problems this patchset is
trying to get rid of  =p

>> The memory controller uses some tunables to adjust its operation. Those
>> tunables are inherited from parent to children upon children
>> intialization. For most of them, the value cannot be changed after the
>> parent has a new children.
>>
>> cgroup core splits initialization in two phases: css_alloc and css_online.
>> After css_alloc, the memory allocation and basic initialization are
>> done. But the new group is not yet visible anywhere, not even for cgroup
>> core code. It is only somewhere between css_alloc and css_online that it
>> is inserted into the internal children lists. Copying tunable values in
>> css_alloc will lead to inconsistent values: the children will copy the
>> old parent values, that can change between the copy and the moment in
>> which the groups is linked to any data structure that can indicate the
>> presence of children.
> 
> That describes the problem, but not the fix.  Don't we need something
> like "therefore move the propagation of tunables into the css_online
> handler".
> 
> What remains unclear is how we prevent races during the operation of
> the css_online handler.  Suppose mem_cgroup_css_online() is
> mid-execution and userspace comes in and starts modifying the parent's
> tunables?
> 

At this point, the very same old cgroup_lock() - since it is still
present. In a later patch, we will need the memcg mutex around the
assignments.

IOW, The figure looks a bit like:

css_alloc() --> cgroup_internal_datastructure_update -> css_online()

This is all protected by the cgroup_lock(). So at this point, wherever
we do those assignments, we're safe. When we move to local locking, the
situation changes. Assigning in css_alloc will mean that we'll have a
non-locked window where the assignment is made, but the cgroup does not
yet show up in the internal data structures - so the pertinence tests
will fail and the tunable values will be allowed to change.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
