Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 01F776B0035
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 16:17:49 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id ma3so1620866pbc.27
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 13:17:49 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id zo6si3414407pbc.13.2014.03.05.13.17.45
        for <linux-mm@kvack.org>;
        Wed, 05 Mar 2014 13:17:45 -0800 (PST)
Date: Wed, 5 Mar 2014 13:17:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 00/11] userspace out of memory handling
Message-Id: <20140305131743.b9a916fbc4e40fd895bc4e76@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Tue, 4 Mar 2014 19:58:38 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> This patchset implements userspace out of memory handling.
> 
> It is based on v3.14-rc5.  Individual patches will apply cleanly or you
> may pull the entire series from
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/rientjes/linux.git mm/oom
> 
> When the system or a memcg is oom, processes running on that system or
> attached to that memcg cannot allocate memory.  It is impossible for a
> process to reliably handle the oom condition from userspace.
> 
> First, consider only system oom conditions.  When memory is completely
> depleted and nothing may be reclaimed, the kernel is forced to free some
> memory; the only way it can do so is to kill a userspace process.  This
> will happen instantaneously and userspace can enforce neither its own
> policy nor collect information.
> 
> On system oom, there may be a hierarchy of memcgs that represent user
> jobs, for example.  Each job may have a priority independent of their
> current memory usage.  There is no existing kernel interface to kill the
> lowest priority job; userspace can now kill the lowest priority job or
> allow priorities to change based on whether the job is using more memory
> than its pre-defined reservation.
> 
> Additionally, users may want to log the condition or debug applications
> that are using too much memory.  They may wish to collect heap profiles
> or are able to do memory freeing without killing a process by throttling
> or ratelimiting.
> 
> Interactive users using X window environments may wish to have a dialogue
> box appear to determine how to proceed -- it may even allow them shell
> access to examine the state of the system while oom.
> 
> It's not sufficient to simply restrict all user processes to a subset of
> memory and oom handling processes to the remainder via a memcg hierarchy:
> kernel memory and other page allocations can easily deplete all memory
> that is not charged to a user hierarchy of memory.
> 
> This patchset allows userspace to do all of these things by defining a
> small memory reserve that is accessible only by processes that are
> handling the notification.
> 
> Second, consider memcg oom conditions.  Processes need no special
> knowledge of whether they are attached to the root memcg, where memcg
> charging will always succeed, or a child memcg where charging will fail
> when the limit has been reached.  This allows those processes handling
> memcg oom conditions to overcharge the memcg by the amount of reserved
> memory.  They need not create child memcgs with smaller limits and
> attach the userspace oom handler only to the parent; such support would
> not allow userspace to handle system oom conditions anyway.
> 
> This patchset introduces a standard interface through memcg that allows
> both of these conditions to be handled in the same clean way: users
> define memory.oom_reserve_in_bytes to define the reserve and this
> amount is allowed to be overcharged to the process handling the oom
> condition's memcg.  If used with the root memcg, this amount is allowed
> to be allocated below the per-zone watermarks for root processes that
> are handling such conditions (only root may write to
> cgroup.event_control for the root memcg).

If process A is trying to allocate memory, cannot do so and the
userspace oom-killer is invoked, there must be means via which process
A waits for the userspace oom-killer's action.  And there must be
fallbacks which occur if the userspace oom killer fails to clear the
oom condition, or times out.

Would be interested to see a description of how all this works.


It is unfortunate that this feature is memcg-only.  Surely it could
also be used by non-memcg setups.  Would like to see at least a
detailed description of how this will all be presented and implemented.
We should aim to make the memcg and non-memcg userspace interfaces and
user-visible behaviour as similar as possible.

Patches 1, 2, 3 and 5 appear to be independent and useful so I think
I'll cherrypick those, OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
