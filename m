Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 69E206B0260
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 06:48:24 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id g8so21202871igr.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 03:48:24 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x18si7477091igx.85.2016.04.04.03.48.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Apr 2016 03:48:23 -0700 (PDT)
Subject: Re: [PATCH] android,lowmemorykiller: Don't abuse TIF_MEMDIE.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1457434892-12642-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160308141858.GJ13542@dhcp22.suse.cz>
	<20160311220109.GD11274@kroah.com>
	<201603212000.BJE57350.MOFOFFLQVJSHtO@I-love.SAKURA.ne.jp>
	<20160321111030.GA11284@kroah.com>
In-Reply-To: <20160321111030.GA11284@kroah.com>
Message-Id: <201604041948.EBJ39073.OVtFMFSFLOOQJH@I-love.SAKURA.ne.jp>
Date: Mon, 4 Apr 2016 19:48:15 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: mhocko@suse.cz, devel@driverdev.osuosl.org, linux-mm@kvack.org, arve@android.com, riandrews@android.com

Greg KH wrote:
> On Mon, Mar 21, 2016 at 08:00:49PM +0900, Tetsuo Handa wrote:
> > Greg Kroah-Hartman wrote:
> > > On Tue, Mar 08, 2016 at 03:18:59PM +0100, Michal Hocko wrote:
> > > > On Tue 08-03-16 20:01:32, Tetsuo Handa wrote:
> > > > > Currently, lowmemorykiller (LMK) is using TIF_MEMDIE for two purposes.
> > > > > One is to remember processes killed by LMK, and the other is to
> > > > > accelerate termination of processes killed by LMK.
> > > > > 
> > > > > But since LMK is invoked as a memory shrinker function, there still
> > > > > should be some memory available. It is very likely that memory
> > > > > allocations by processes killed by LMK will succeed without using
> > > > > ALLOC_NO_WATERMARKS via TIF_MEMDIE. Even if their allocations cannot
> > > > > escape from memory allocation loop unless they use ALLOC_NO_WATERMARKS,
> > > > > lowmem_deathpending_timeout can guarantee forward progress by choosing
> > > > > next victim process.
> > > > > 
> > > > > On the other hand, mark_oom_victim() assumes that it must be called with
> > > > > oom_lock held and it must not be called after oom_killer_disable() was
> > > > > called. But LMK is calling it without holding oom_lock and checking
> > > > > oom_killer_disabled. It is possible that LMK calls mark_oom_victim()
> > > > > due to allocation requests by kernel threads after current thread
> > > > > returned from oom_killer_disabled(). This will break synchronization
> > > > > for PM/suspend.
> > > > > 
> > > > > This patch introduces per a task_struct flag for remembering processes
> > > > > killed by LMK, and replaces TIF_MEMDIE with that flag. By applying this
> > > > > patch, assumption by mark_oom_victim() becomes true.
> > > > 
> > > > Thanks for looking into this. A separate flag sounds like a better way
> > > > to go (assuming that the flags are not scarce which doesn't seem to be
> > > > the case here).
> > > >  
> > > > The LMK cannot kill the frozen tasks now but this shouldn't be a big deal
> > > > because this is not strictly necessary for the system to move on. We are
> > > > not OOM.
> > > > 
> > > > > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > > > Cc: Michal Hocko <mhocko@suse.cz>
> > > > > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > > > > Cc: Arve Hjonnevag <arve@android.com>
> > > > > Cc: Riley Andrews <riandrews@android.com>
> > > > 
> > > > Acked-by: Michal Hocko <mhocko@suse.com>
> > > 
> > > So, any objection for me taking this through the staging tree?
> > > 
> > Seems no objection. Please take this through the staging tree.
> 
> Ok, will do so after 4.6-rc1 is out.
> 
I haven't seen this patch in linux-next. Would you take this?

Regards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
