Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 32E946B0279
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 10:41:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 12so5358638wmn.1
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 07:41:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d202si2846312wmd.169.2017.06.27.07.41.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 07:41:30 -0700 (PDT)
Date: Tue, 27 Jun 2017 16:41:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170627144125.GP28072@dhcp22.suse.cz>
References: <20170627112650.GK28072@dhcp22.suse.cz>
 <201706272039.HGG51520.QOMHFVOFtOSJFL@I-love.SAKURA.ne.jp>
 <20170627120317.GL28072@dhcp22.suse.cz>
 <201706272231.ABH00025.FMOFOJSVLOQHFt@I-love.SAKURA.ne.jp>
 <20170627135555.GN28072@dhcp22.suse.cz>
 <201706272326.BAG00561.LMJVHSFQtOOFFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706272326.BAG00561.LMJVHSFQtOOFFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, andrea@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Tue 27-06-17 23:26:22, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 27-06-17 22:31:58, Tetsuo Handa wrote:
[...]
> > > shouldn't we try __oom_reap_task_mm() before calling these down_write()
> > > if mm is OOM victim's?
> > 
> > This is what we try. We simply try to get mmap_sem for read and do our
> > work as soon as possible with the proposed patch. This is already an
> > improvement, no?
> 
> We can ask the OOM reaper kernel thread try to reap before the OOM killer
> releases oom_lock mutex. But that is not guaranteed. It is possible that
> the OOM victim thread is executed until down_write() in __ksm_exit() or
> __khugepaged_exit() and then the OOM reaper kernel thread starts calling
> down_read_trylock().

I strongly suspect we are getting tangent here. While I see your concern
and yes the approach can be probably improved, can we focus on one thing
at the time? I would like to fix the original problem first and only
then go deeper down the rat hole of other subtle details. Do you have
any fundamental objection to the suggested approach or see any issues
with it?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
