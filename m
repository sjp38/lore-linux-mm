Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 5CD5E6B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 02:11:19 -0400 (EDT)
Received: by yenm8 with SMTP id m8so1829571yen.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 23:11:18 -0700 (PDT)
Date: Tue, 13 Mar 2012 23:11:12 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC REPOST] cgroup: removing css reference drain wait during
 cgroup removal
Message-ID: <20120314061112.GA3258@dhcp-172-17-108-109.mtv.corp.google.com>
References: <20120312213155.GE23255@google.com>
 <20120312213343.GF23255@google.com>
 <20120313151148.f8004a00.kamezawa.hiroyu@jp.fujitsu.com>
 <20120313163914.GD7349@google.com>
 <20120314092828.3321731c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120314092828.3321731c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, gthelen@google.com, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vivek Goyal <vgoyal@redhat.com>, Jens Axboe <axboe@kernel.dk>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, cgroups@vger.kernel.org

Hello,

On Wed, Mar 14, 2012 at 09:28:28AM +0900, KAMEZAWA Hiroyuki wrote:
> > I agree this isn't perfect but then again failing rmdir isn't perfect
> > either and given that the condition can be wholly avoided in
> > hierarchical mode, which should be the default anyway (is there any
> > reason to keep flat mode except for backward compatibility?), I don't
> > think the trade off is too bad.
> 
> One reason is 'performance'. You can see performance trouble when you
> creates deep tree of memcgs in hierarchy mode. The deeper memcg tree,
> the more res_coutners will be shared.
> 
> For example, libvirt creates cgroup tree as
> 
> 	/cgroup/memory/libvirt/qemu/GuestXXX/....
>         /cgroup/memory/libvirt/lxc/GuestXXX/...
> 
> No one don't want to count up 4 res_coutner, which is very very heavy,
> for handling independent workloads of "Guest".

Yes, performance definitely is a concern but I think that it would be
better to either avoid building deep hierarchies or provide a generic
way to skip some levels rather than implementing different behavior
mode per controller.  Per-controller behavior selection ends up
requiring highly specialized configuration which is very difficult to
generalize and automate.

> IIUC, in general, even in the processes are in a tree, in major case
> of servers, their workloads are independent.
> I think FLAT mode is the dafault. 'heararchical' is a crazy thing which
> cannot be managed.

I currently am hoping that cgroup core can provide a generic mechanism
to abbreviate, if you will, hierarchies so that controllers can be
used the same way, with hierarchy unaware controllers using the same
mechanism to essentially achieve flat view of the same hierarchy.  It
might as well be a pipe dream tho.  I'll think more about it.

Anyways, I'm building up updates on top of the patch to strip out
pre_destroy waiting and failure handling.  Is anyone interested in
doing the memcg part, pretty please?

Thank you very much.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
