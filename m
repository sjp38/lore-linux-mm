Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 81EB16B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 10:21:49 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id j12so4534889lbo.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 07:21:49 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id y13si27720933wmh.72.2016.06.08.07.21.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 07:21:48 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id r5so3426441wmr.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 07:21:48 -0700 (PDT)
Date: Wed, 8 Jun 2016 16:21:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: oom: deduplicate victim selection code for memcg
 and global oom
Message-ID: <20160608142146.GM22570@dhcp22.suse.cz>
References: <40e03fd7aaf1f55c75d787128d6d17c5a71226c2.1464358556.git.vdavydov@virtuozzo.com>
 <3bbc7b70dae6ace0b8751e0140e878acfdfffd74.1464358556.git.vdavydov@virtuozzo.com>
 <20160608083334.GF22570@dhcp22.suse.cz>
 <201606082018.EDC09327.HMQOFOVJFSOFtL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606082018.EDC09327.HMQOFOVJFSOFtL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: vdavydov@virtuozzo.com, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 08-06-16 20:18:24, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > The victim selection code can be reduced because it is basically
> > shared between the two, only the iterator differs. But I guess that
> > can be eliminated by a simple helper.
> 
> Thank you for CC: me. I like this clean up.
> 
> > ---
> >  include/linux/oom.h |  5 +++++
> >  mm/memcontrol.c     | 47 ++++++-----------------------------------
> >  mm/oom_kill.c       | 60 ++++++++++++++++++++++++++++-------------------------
> >  3 files changed, 43 insertions(+), 69 deletions(-)
> 
> I think we can apply your version with below changes folded into your version.
> (I think totalpages argument can be passed via oom_control as well. Also, according to
> http://lkml.kernel.org/r/201602192336.EJF90671.HMFLFSVOFJOtOQ@I-love.SAKURA.ne.jp ,
> we can safely replace oc->memcg in oom_badness() in oom_evaluate_task() with NULL. )

yes oom_badness can never see a task from outside of the memcg
hierarchy.

[...]
> +static enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
> +					       struct task_struct *task)
>  {
>  	if (oom_unkillable_task(task, NULL, oc->nodemask))
>  		return OOM_SCAN_CONTINUE;
> @@ -307,6 +314,9 @@ int oom_evaluate_task(struct oom_control *oc, struct task_struct *p, unsigned lo
>  	case OOM_SCAN_CONTINUE:
>  		return 1;
>  	case OOM_SCAN_ABORT:
> +		if (oc->chosen)
> +			put_task_struct(oc->chosen);
> +		oc->chosen = (void *) -1UL;

true including the memcg fixup.

>  		return 0;
>  	case OOM_SCAN_OK:
>  		break;

Thanks! I've updated the patch locally but I will wait for Vladimir what
he thinks about this wrt. the original approach.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
