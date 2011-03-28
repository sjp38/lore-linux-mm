Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5983A8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 07:44:35 -0400 (EDT)
Date: Mon, 28 Mar 2011 13:44:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
Message-ID: <20110328114430.GE5693@tiehlicka.suse.cz>
References: <20110328093957.089007035@suse.cz>
 <20110328200332.17fb4b78.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110328200332.17fb4b78.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 28-03-11 20:03:32, KAMEZAWA Hiroyuki wrote:
> On Mon, 28 Mar 2011 11:39:57 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
[...]
> 
> Isn't it the same result with the case where no cgroup is used ?

Yes and that is the point of the patchset. Memory cgroups will not give
you anything else but the top limit wrt. to the global memory activity.

> What is the problem ?

That we cannot prevent from paging out memory of process(es), even though
we have intentionaly isolated them in a group (read as we do not have
any other possibility for the isolation), because of unrelated memory
activity.

> Why it's not a problem of configuration ?
> IIUC, you can put all logins to some cgroup by using cgroupd/libgcgroup.

Yes, but this still doesn't bring the isolation.

> Maybe you just want "guarantee".
> At 1st thought, this approarch has 3 problems. And memcg is desgined
> never to prevent global vm scans,
> 
> 1. This cannot be used as "guarantee". Just a way for "don't steal from me!!!"
>    This just implements a "first come, first served" system.
>    I guess this can be used for server desgines.....only with very very careful play.
>    If an application exits and lose its memory, there is no guarantee anymore.

Yes, but once it got the memory and it needs to have it or benefits from
having it resindent what-ever happens around then there is no other
solution than mlocking the memory which is not ideal solution all the
time as I have described already.

> 
> 2. Even with isolation, a task in memcg can be killed by OOM-killer at
>    global memory shortage.

Yes it can but I think this is a different problem. Once you are that
short of memory you can hardly ask from any guarantees.
There is no 100% guarantee about anything in the system.

> 
> 3. it seems this will add more page fragmentation if implemented poorly, IOW,
>    can this be work with compaction ?

Why would it add any fragmentation. We are compacting memory based on
the pfn range scanning rather than walking global LRU list, aren't we?

> I think of other approaches.
> 
> 1. cpuset+nodehotplug enhances.
>    At boot, hide most of memory from the system by boot option.
>    You can rename node-id of "all unused memory" and create arbitrary nodes
>    if the kernel has an interface. You can add a virtual nodes and move
>    pages between nodes by renaming it.
> 
>    This will allow you to create a safe box dynamically. 

This sounds as it requires a completely new infrastructure for many
parts of VM code. 

>    If you move pages in
>    the order of MAX_ORDER, you don't add any fragmentation.
>    (But with this way, you need to avoid tasks in root cgrou, too.)
> 
> 
> 2. allow a mount option to link ROOT cgroup's LRU and add limit for
>    root cgroup. Then, softlimit will work well.
>    (If softlimit doesn't work, it's bug. That will be an enhancement point.)

So you mean that the root cgroup would be a normal group like any other?

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
