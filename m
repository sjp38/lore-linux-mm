Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E4A2828F6
	for <linux-mm@kvack.org>; Sun, 31 Jul 2016 06:19:39 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p85so58922648lfg.3
        for <linux-mm@kvack.org>; Sun, 31 Jul 2016 03:19:39 -0700 (PDT)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id r133si11295619wma.97.2016.07.31.03.19.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Jul 2016 03:19:37 -0700 (PDT)
Received: by mail-wm0-f45.google.com with SMTP id q128so48436837wma.1
        for <linux-mm@kvack.org>; Sun, 31 Jul 2016 03:19:37 -0700 (PDT)
Date: Sun, 31 Jul 2016 12:19:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 08/10] exit, oom: postpone exit_oom_victim to later
Message-ID: <20160731101935.GA26220@dhcp22.suse.cz>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
 <1469734954-31247-9-git-send-email-mhocko@kernel.org>
 <201607301720.GHG43737.JLVtHOOSQOFFMF@I-love.SAKURA.ne.jp>
 <20160731093530.GB22397@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160731093530.GB22397@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com

On Sun 31-07-16 11:35:30, Michal Hocko wrote:
> On Sat 30-07-16 17:20:30, Tetsuo Handa wrote:
[...]
> > But safer way is to get rid of TIF_MEMDIE's triple meanings. The first
> > one which prevents the OOM killer from selecting next OOM victim was
> > removed by replacing TIF_MEMDIE test in oom_scan_process_thread() with
> > tsk_is_oom_victim(). The second one which allows the OOM victims to
> > deplete 100% of memory reserves wants some changes in order not to
> > block memory allocations by non OOM victims (e.g. GFP_ATOMIC allocations
> > by interrupt handlers, GFP_NOIO / GFP_NOFS allocations by subsystems
> > which are needed for making forward progress of threads in do_exit())
> > by consuming too much of memory reserves. The third one which blocks
> > oom_killer_disable() can be removed by replacing TIF_MEMDIE test in
> > exit_oom_victim() with PFA_OOM_WAITING test like below patch.
> 
> I plan to remove TIF_MEMDIE dependency for this as well but I would like
> to finish this pile first. We actually do not need any flag for that. We
> just need to detect last exiting thread and tsk_is_oom_victim. I have
> some preliminary code for that.

That being said. If you _really_ consider this patch to be controversial
I can drop it and handle it with other patches which should handle also
TIF_MEMDIE removal. The rest of the series doesn't really depend on it
in any way. I just though this would be easy enough to carry it with
this pile already. I do not insist on it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
