Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 949F89003C7
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 12:43:24 -0400 (EDT)
Received: by wicgb10 with SMTP id gb10so208841129wic.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 09:43:24 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id fp9si44826714wjc.103.2015.07.29.09.43.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 09:43:22 -0700 (PDT)
Date: Wed, 29 Jul 2015 12:42:45 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 7/8] memcg: get rid of mm_struct::owner
Message-ID: <20150729164245.GA12693@cmpxchg.org>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-8-git-send-email-mhocko@kernel.org>
 <20150710140533.GB29540@dhcp22.suse.cz>
 <20150714151823.GG17660@dhcp22.suse.cz>
 <20150729131454.GB10001@cmpxchg.org>
 <20150729150549.GL15801@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150729150549.GL15801@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 29, 2015 at 05:05:49PM +0200, Michal Hocko wrote:
> On Wed 29-07-15 09:14:54, Johannes Weiner wrote:
> > On Tue, Jul 14, 2015 at 05:18:23PM +0200, Michal Hocko wrote:
> [...]
> > > 3) fail mem_cgroup_can_attach if we are trying to migrate a task sharing
> > > mm_struct with a process outside of the tset. If I understand the
> > > tset properly this would require all the sharing tasks to be migrated
> > > together and we would never end up with task_css != &task->mm->css.
> > > __cgroup_procs_write doesn't seem to support multi pid move currently
> > > AFAICS, though. cgroup_migrate_add_src, however, seems to be intended
> > > for this purpose so this should be doable. Without that support we would
> > > basically disallow migrating these tasks - I wouldn't object if you ask
> > > me.
> > 
> > I'd prefer not adding controller-specific failure modes for attaching,
> 
> Does this mean that there is a plan to drop the return value from
> can_attach? I can see that both cpuset and cpu controllers currently
> allow to fail to attach. Are those going to change? I remember some
> discussions but no clear outcome of those.

Nothing but the realtime stuff needs to be able to fail migration due
to controller restraints. This should probably remain a fringe thing,
because it does make for a much more ambiguous interface.

So I think can_attach() will have to stay, but it should be avoided.

> > and this too would lead to very non-obvious behavior.
> 
> Yeah, the user will not get an error source with the current API but
> this is an inherent restriction currently. Maybe we can add a knob with
> the error source?
> 
> If there is a clear consensus that can_attach failures are clearly a no
> go then what about "silent" moving of the associated tasks? This would
> be similar to thread group except the group would be more generic term.
> 
> > > Do you see other options? From the above three options the 3rd one
> > > sounds the most sane to me and the 1st quite easy to implement. Both will
> > > require some cgroup core work though. But maybe we would be good enough
> > > with 3rd option without supporting moving schizophrenic tasks and that
> > > would be reduced to memcg code.
> > 
> > A modified form of 1) would be to track the mms referring to a memcg
> > but during offline search the process tree for a matching task.
> 
> But we might have many of those and all of them living in different
> cgroups. So which one do we take? The first encountered, the one with
> the majority? I am not sure this is much better.
> 
> I would really prefer if we could get rid of the schizophrenia if it is
> possible.

The first encountered.

This is just our model for sharing memory across groups. Page cache,
writeback, address space--we have always accounted based on who's
touching it first. We might as well stick with it for shared mms.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
