Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 44C176B0253
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 11:08:01 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id js7so38594389obc.0
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 08:08:01 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l2si5444709obh.64.2016.04.19.08.07.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Apr 2016 08:08:00 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm, oom_reaper: clear TIF_MEMDIE for all tasks queued for oom_reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160408113425.GF29820@dhcp22.suse.cz>
	<201604161151.ECG35947.FFLtSFVQJOHOOM@I-love.SAKURA.ne.jp>
	<20160417115422.GA21757@dhcp22.suse.cz>
	<201604182059.JFB76917.OFJMHFLSOtQVFO@I-love.SAKURA.ne.jp>
	<20160419141722.GB4126@dhcp22.suse.cz>
In-Reply-To: <20160419141722.GB4126@dhcp22.suse.cz>
Message-Id: <201604200007.IFD52169.FLSOOVQHJOFFtM@I-love.SAKURA.ne.jp>
Date: Wed, 20 Apr 2016 00:07:50 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

Michal Hocko wrote:
> On Mon 18-04-16 20:59:51, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > Here is what should work - I have only compile tested it. I will prepare
> > > the proper patch later this week with other oom reaper patches or after
> > > I come back from LSF/MM.
> > 
> > Excuse me, but is system_wq suitable for queuing operations which may take
> > unpredictable duration to flush?
> > 
> >   system_wq is the one used by schedule[_delayed]_work[_on]().
> >   Multi-CPU multi-threaded.  There are users which expect relatively
> >   short queue flush time.  Don't queue works which can run for too
> >   long.
> 
> An alternative would be using a dedicated WQ with WQ_MEM_RECLAIM which I
> am not really sure would be justified considering we are talking about a
> highly unlikely event. You do not want to consume resources permanently
> for an eventual and not fatal event.

Yes, the reason SysRq-f is still not using a dedicated WQ with WQ_MEM_RECLAIM
will be the same.

> 
> > We
> > haven't guaranteed that SysRq-f can always fire and select a different OOM
> > victim, but you proposed always clearing TIF_MEMDIE without thinking the
> > possibility of the OOM victim with mmap_sem held for write being stuck at
> > unkillable wait.
> > 
> > I wonder about your definition of "robustness". You are almost always missing
> > the worst scenario. You are trying to manage OOM without defining default:
> > label in a switch statement. I don't think your approach is robust.
> 
> I am trying to be as robust as it is viable. You have to realize we are
> in the catastrophic path already and there is simply no deterministic
> way out.

I know we are talking about the catastrophic situation. Since you insist on
deterministic approach, we are struggling so much.
If you tolerate
http://lkml.kernel.org/r/201604152111.JBD95763.LMFOOHQOtFSFJV@I-love.SAKURA.ne.jp
approach as the fastpath (deterministic but could fail) and
http://lkml.kernel.org/r/201604200006.FBG45192.SOHFQJFOOLFMtV@I-love.SAKURA.ne.jp
approach as the slowpath (non-deterministic but never fail), we don't need to
use a dedicated WQ with WQ_MEM_RECLAIM for avoiding this mmput() trap and the
SysRq-f trap. What a simple answer. ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
