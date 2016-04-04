Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id E58706B0279
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 09:20:10 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id td3so143897820pab.2
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 06:20:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s28si41738204pfi.238.2016.04.04.06.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 06:20:10 -0700 (PDT)
Date: Mon, 4 Apr 2016 06:20:09 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] android,lowmemorykiller: Don't abuse TIF_MEMDIE.
Message-ID: <20160404132009.GA9031@kroah.com>
References: <1457434892-12642-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160308141858.GJ13542@dhcp22.suse.cz>
 <20160311220109.GD11274@kroah.com>
 <201603212000.BJE57350.MOFOFFLQVJSHtO@I-love.SAKURA.ne.jp>
 <20160321111030.GA11284@kroah.com>
 <201604041948.EBJ39073.OVtFMFSFLOOQJH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604041948.EBJ39073.OVtFMFSFLOOQJH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.cz, devel@driverdev.osuosl.org, arve@android.com, riandrews@android.com, linux-mm@kvack.org

On Mon, Apr 04, 2016 at 07:48:15PM +0900, Tetsuo Handa wrote:
> Greg KH wrote:
> > On Mon, Mar 21, 2016 at 08:00:49PM +0900, Tetsuo Handa wrote:
> > > Greg Kroah-Hartman wrote:
> > > > On Tue, Mar 08, 2016 at 03:18:59PM +0100, Michal Hocko wrote:
> > > > > On Tue 08-03-16 20:01:32, Tetsuo Handa wrote:
> > > > > > Currently, lowmemorykiller (LMK) is using TIF_MEMDIE for two purposes.
> > > > > > One is to remember processes killed by LMK, and the other is to
> > > > > > accelerate termination of processes killed by LMK.
> > > > > > 
> > > > > > But since LMK is invoked as a memory shrinker function, there still
> > > > > > should be some memory available. It is very likely that memory
> > > > > > allocations by processes killed by LMK will succeed without using
> > > > > > ALLOC_NO_WATERMARKS via TIF_MEMDIE. Even if their allocations cannot
> > > > > > escape from memory allocation loop unless they use ALLOC_NO_WATERMARKS,
> > > > > > lowmem_deathpending_timeout can guarantee forward progress by choosing
> > > > > > next victim process.
> > > > > > 
> > > > > > On the other hand, mark_oom_victim() assumes that it must be called with
> > > > > > oom_lock held and it must not be called after oom_killer_disable() was
> > > > > > called. But LMK is calling it without holding oom_lock and checking
> > > > > > oom_killer_disabled. It is possible that LMK calls mark_oom_victim()
> > > > > > due to allocation requests by kernel threads after current thread
> > > > > > returned from oom_killer_disabled(). This will break synchronization
> > > > > > for PM/suspend.
> > > > > > 
> > > > > > This patch introduces per a task_struct flag for remembering processes
> > > > > > killed by LMK, and replaces TIF_MEMDIE with that flag. By applying this
> > > > > > patch, assumption by mark_oom_victim() becomes true.
> > > > > 
> > > > > Thanks for looking into this. A separate flag sounds like a better way
> > > > > to go (assuming that the flags are not scarce which doesn't seem to be
> > > > > the case here).
> > > > >  
> > > > > The LMK cannot kill the frozen tasks now but this shouldn't be a big deal
> > > > > because this is not strictly necessary for the system to move on. We are
> > > > > not OOM.
> > > > > 
> > > > > > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > > > > Cc: Michal Hocko <mhocko@suse.cz>
> > > > > > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > > > > > Cc: Arve Hjonnevag <arve@android.com>
> > > > > > Cc: Riley Andrews <riandrews@android.com>
> > > > > 
> > > > > Acked-by: Michal Hocko <mhocko@suse.com>
> > > > 
> > > > So, any objection for me taking this through the staging tree?
> > > > 
> > > Seems no objection. Please take this through the staging tree.
> > 
> > Ok, will do so after 4.6-rc1 is out.
> > 
> I haven't seen this patch in linux-next. Would you take this?

It's in my queue, I'll get to it soon, thanks.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
