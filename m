Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D49866B025E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 10:46:39 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 132so5168690lfz.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 07:46:39 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id nh6si1829931wjb.224.2016.06.08.07.46.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 07:46:38 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id k184so3570933wme.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 07:46:38 -0700 (PDT)
Date: Wed, 8 Jun 2016 16:46:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: oom: deduplicate victim selection code for memcg
 and global oom
Message-ID: <20160608144636.GN22570@dhcp22.suse.cz>
References: <40e03fd7aaf1f55c75d787128d6d17c5a71226c2.1464358556.git.vdavydov@virtuozzo.com>
 <3bbc7b70dae6ace0b8751e0140e878acfdfffd74.1464358556.git.vdavydov@virtuozzo.com>
 <20160608083334.GF22570@dhcp22.suse.cz>
 <20160608135204.GA30465@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160608135204.GA30465@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 08-06-16 16:52:04, Vladimir Davydov wrote:
> On Wed, Jun 08, 2016 at 10:33:34AM +0200, Michal Hocko wrote:
> > On Fri 27-05-16 17:17:42, Vladimir Davydov wrote:
> > [...]
> > > @@ -970,26 +1028,25 @@ bool out_of_memory(struct oom_control *oc)
> > >  	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
> > >  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
> > >  		get_task_struct(current);
> > > -		oom_kill_process(oc, current, 0, totalpages,
> > > -				 "Out of memory (oom_kill_allocating_task)");
> > > +		oom_kill_process(oc, current, 0, totalpages);
> > >  		return true;
> > >  	}
> > 
> > Do we really want to introduce sysctl_oom_kill_allocating_task to memcg
> > as well?
> 
> Not sure, but why not? We take into account dump_tasks and panic_on_oom
> on memcg oom so why should we treat this sysctl differently?

Well, for one thing nobody has requested that and it would be a user
visible change which might be unexpected. And as already said I think it
was a mistake to introduce this sysctl in the first place. The behavior
is so random that I am even not sure it is usable in the real life.
Spreading it more doesn't sound like a good idea to me.

[...]

> > Now if you look at out_of_memory() the only shared "heuristic" with the
> > memcg part is the bypass for the exiting tasks.
> 
> bypass exiting task (task_will_free_mem)
> check for panic (check_panic_on_oom)
> oom badness evaluation (oom_scan_process_thread or oom_evaluate_task
> after your patch)
> points calculation + kill (oom_kill_process)
> 
> And if you need to modify any of these function calls or add yet another
> check, you have to do it twice. Ugly.

Ideally all those changes would happen inside those helpers. Also if you
look at out_of_memory and mem_cgroup_out_of_memory it is much easier to
follow the later one because it doesn't have that different combinations
of heuristic which only make sense for sysrq or global oom.

> > Plus both need the oom_lock.
> 
> I believe locking could be unified for global/memcg oom cases too.
> 
> > You have to special case oom notifiers, panic on no victim handling and
> > I guess the oom_kill_allocating task is not intentional either. So I
> > am not really sure this is an improvement. I even hate how we conflate
> > sysrq vs. regular global oom context together but my cleanup for that
> > has failed in the past.
> > 
> > The victim selection code can be reduced because it is basically
> > shared between the two, only the iterator differs. But I guess that
> > can be eliminated by a simple helper.
> 
> IMHO exporting a bunch of very oom-specific helpers (like those I
> enumerated above), partially revealing oom implementation, instead of
> well defined memcg helpers that could be reused anywhere else looks
> ugly. It's like having shrink_zone implementation both in vmscan.c and
> memcontrol.c with shrink_slab, shrink_lruvec, etc. exported, because we
> need to iterate over cgroups there.

I agree that the API for OOM killer parts is not really great. I am just
little bit afraid that iterators are just over engineered. I am even not
sure whethers those have any other potential users. The diffstat of the
cleanup I have here right now sounds really encouranging.
---
 include/linux/oom.h | 17 ++++-------
 mm/memcontrol.c     | 48 +++--------------------------
 mm/oom_kill.c       | 87 ++++++++++++++++++++++++++++++-----------------------
 3 files changed, 60 insertions(+), 92 deletions(-)

compared to yours
 include/linux/memcontrol.h |  15 ++++
 include/linux/oom.h        |  51 -------------
 mm/memcontrol.c            | 112 ++++++++++-----------------
 mm/oom_kill.c              | 183 +++++++++++++++++++++++++++++----------------
 4 files changed, 176 insertions(+), 185 deletions(-)

we save more LOC with a smaller patch. I know this is not an absolute
metric but I would rather go with simplicity than an elaborate
APIs. This is all pretty much mm/memcg internal.

Anyway I do not have strong opinion and will not insist. I can post
the full cleanup with suggestions from Tetsuo integrated if you are
interested.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
