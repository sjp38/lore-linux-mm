Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0E2D6B025E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 03:27:44 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id rs7so84905382lbb.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 00:27:44 -0700 (PDT)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id 8si549659wmu.15.2016.06.08.00.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 00:27:43 -0700 (PDT)
Received: by mail-wm0-f43.google.com with SMTP id m124so3430058wme.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 00:27:43 -0700 (PDT)
Date: Wed, 8 Jun 2016 09:27:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/10 -v3] Handle oom bypass more gracefully
Message-ID: <20160608072741.GE22570@dhcp22.suse.cz>
References: <20160603122030.GG20676@dhcp22.suse.cz>
 <201606040017.HDI52680.LFFOVMJQOFSOHt@I-love.SAKURA.ne.jp>
 <20160606083651.GE11895@dhcp22.suse.cz>
 <201606072330.AHH81886.OOMVHFOFLtFSQJ@I-love.SAKURA.ne.jp>
 <20160607150534.GO12305@dhcp22.suse.cz>
 <201606080649.DGF51523.FLMOSHVtFFOJOQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606080649.DGF51523.FLMOSHVtFFOJOQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 08-06-16 06:49:24, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > OK, so you are arming the timer for each mark_oom_victim regardless
> > of the oom context. This means that you have replaced one potential
> > lockup by other potential livelocks. Tasks from different oom domains
> > might interfere here...
> > 
> > Also this code doesn't even seem easier. It is surely less lines of
> > code but it is really hard to realize how would the timer behave for
> > different oom contexts.
> 
> If you worry about interference, we can use per signal_struct timestamp.
> I used per task_struct timestamp in my earlier versions (where per
> task_struct TIF_MEMDIE check was used instead of per signal_struct
> oom_victims).

This would allow pre-mature new victim selection for very large victims
(note that exit_mmap can take a while depending on the mm size). It also
pushed the timeout heuristic for everybody which will sooner or later
open a question why is this $NUMBER rathen than $NUMBER+$FOO.

[...]
> But expiring timeout by sleeping inside oom_kill_process() prevents other
> threads which are OOM-killed from obtaining TIF_MEMDIE, for anybody needs
> to wait for oom_lock in order to obtain TIF_MEMDIE.

True, but please note that this will happen only for the _unlikely_ case
when the mm is shared with kthread or init. All other cases would rely
on the oom_reaper which has a feedback mechanism to tell the oom killer
to move on if something bad is going on.

> Unless you set TIF_MEMDIE to all OOM-killed threads from
> oom_kill_process() or allow the caller context to use
> ALLOC_NO_WATERMARKS by checking whether current was already OOM-killed
> rather than TIF_MEMDIE, attempt to expiring timeout by sleeping inside
> oom_kill_process() is useless.

Well this is a rather strong statement for a highly unlikely corner
case, don't you think? I do not mind fortifying this class of cases some
more if we ever find out they are a real problem but I would rather make
sure they cannot lockup at this stage rather than optimize for them.

To be honest I would rather explore ways to handle kthread case (which
is the only real one IMHO from the two) gracefully and made them a
nonissue - e.g. enforce EFAULT on a dead mm during the kthread page fault
or something similar.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
