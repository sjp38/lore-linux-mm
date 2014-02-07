Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 72A2D6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 15:21:32 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id g10so3592362pdj.30
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:21:32 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id zk9si6234155pac.260.2014.02.07.12.21.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 12:21:30 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id y10so3583562pdj.4
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 12:21:30 -0800 (PST)
Date: Fri, 7 Feb 2014 12:20:44 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] cgroup: use an ordered workqueue for cgroup
 destruction
In-Reply-To: <20140207140402.GA3304@htj.dyndns.org>
Message-ID: <alpine.LSU.2.11.1402071130250.333@eggly.anvils>
References: <alpine.LSU.2.11.1402061541560.31342@eggly.anvils> <20140207140402.GA3304@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Filipe Brandenburger <filbranden@google.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Markus Blank-Burian <burian@muenster.de>, Shawn Bohrer <shawn.bohrer@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Tejun,

On Fri, 7 Feb 2014, Tejun Heo wrote:
> On Thu, Feb 06, 2014 at 03:56:01PM -0800, Hugh Dickins wrote:
> > Sometimes the cleanup after memcg hierarchy testing gets stuck in
> > mem_cgroup_reparent_charges(), unable to bring non-kmem usage down to 0.
> > 
> > There may turn out to be several causes, but a major cause is this: the
> > workitem to offline parent can get run before workitem to offline child;
> > parent's mem_cgroup_reparent_charges() circles around waiting for the
> > child's pages to be reparented to its lrus, but it's holding cgroup_mutex
> > which prevents the child from reaching its mem_cgroup_reparent_charges().
> > 
> > Just use an ordered workqueue for cgroup_destroy_wq.
> 
> Hmmm... I'm not really comfortable with this.  This would seal shut
> any possiblity of increasing concurrency in that path, which is okay
> now but I find the combination of such long term commitment and the
> non-obviousness (it's not apparent from looking at memcg code why it
> wouldn't deadlock) very unappealing.  Besides, the only reason
> offline() is currently called under cgroup_mutex is history.  We can
> move it out of cgroup_mutex right now.

Thanks for taking the patch into your tree for now,
and thanks to Michal and Hannes for supporting it.

Yes, we're not sealing a door shut with this one-liner.  My first
reaction to the deadlock was indeed, what's the cgroup_mutex for here?
and I've seen enough deadlocks on cgroup_mutex (though most from this
issue, I now believe) to welcome the idea of reducing its blanket use.

But I think there are likely to be bumps along that road (just as
there have been along the workqueue-ification road), so this ordered
workqueue appears much the safer option for now.  Please rip it out
again when the cgroup_mutex is safely removed from this path.

(I've certainly written memcg code myself that "knows" it's already
serialized by cgroup_mutex at the outer level: I think code that
never reached anyone else's tree, but I'm not certain of that.)

> 
> But even with offline being called outside cgroup_mutex, IIRC, the
> described problem would still be able to deadlock as long as the tree
> depth is deeper than max concurrency level of the destruction
> workqueue.  Sure, we can give it large enough number but it's
> generally nasty.

You worry me there: I certainly don't want to be introducing new
deadlocks.  You understand workqueues much better than most of us: I'm
not sure what "max concurrency level of the destruction workqueue" is,
but it sounds uncomfortably like an ordered workqueue's max_active 1.

You don't return to this concern in the following mails of the thread:
did you later decide that it actually won't be a problem?  I'll assume
so for the moment, since you took the patch, but please reassure me.

> 
> One thing I don't get is why memcg has such reverse dependency at all.
> Why does the parent wait for its descendants to do something during
> offline?  Shouldn't it be able to just bail and let whatever
> descendant which is stil busy propagate things upwards?  That's a
> usual pattern we use to tree shutdowns anyway.  Would that be nasty to
> implement in memcg?

I've no idea how nasty it would be to change memcg around, but Michal
and Hannes appear very open to doing so.  I do think that memcg's current
expectation is very reasonable: it's perfectly normal that a rmdir cannot
succeed until the directory is empty, and to depend upon that fact; but
the use of workqueue made some things asynchronous which were not before,
which has led to some surprises.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
