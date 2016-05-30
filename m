Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id B8D686B025F
	for <linux-mm@kvack.org>; Mon, 30 May 2016 07:57:21 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id q17so84766637lbn.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 04:57:21 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id f123si30363390wmf.1.2016.05.30.04.57.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 04:57:20 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id a136so22036232wme.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 04:57:20 -0700 (PDT)
Date: Mon, 30 May 2016 13:57:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom_reaper: do not attempt to reap a task more
 than twice
Message-ID: <20160530115719.GV22928@dhcp22.suse.cz>
References: <201605271931.AGD82810.QFOFOOFLMVtHSJ@I-love.SAKURA.ne.jp>
 <20160527122308.GJ27686@dhcp22.suse.cz>
 <201605272218.JID39544.tFOQHJOMVFLOSF@I-love.SAKURA.ne.jp>
 <20160527133502.GN27686@dhcp22.suse.cz>
 <201605280124.EJB71319.SHOtOVFFFQMOJL@I-love.SAKURA.ne.jp>
 <201605282122.HAD09894.SFOFHtOVJLOQMF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605282122.HAD09894.SFOFHtOVJLOQMF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, oleg@redhat.com, vdavydov@parallels.com

On Sat 28-05-16 21:22:08, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > We could very well do 
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index bcb6d3b26c94..d9017b8c7300 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -813,6 +813,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> > >  			 * memory might be still used.
> > >  			 */
> > >  			can_oom_reap = false;
> > > +			set_bit(MMF_OOM_REAPED, mm->flags);
> > >  			continue;
> > >  		}
> > >  		if (p->signal->oom_score_adj == OOM_ADJUST_MIN)
> > > 
> > > with the same result. If you _really_ think that this would make a
> > > difference I could live with that. But I am highly skeptical this
> > > matters all that much.
> 
> Usage of set_bit() above and below are both wrong. The mm used by
> kernel thread via use_mm() will become OOM reapable after unuse_mm().

Please note that all other holders of that mm are gone by that time. So
unuse_mm will simply drop the last reference of the mm and do the
remaining clean up. There is no real reason this mm should be around and
visible by the oom killer.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
