Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id D4E0B6B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 10:28:53 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id n186so23558132wmn.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:28:53 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id lp7si11611181wjb.73.2016.03.11.07.28.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 07:28:52 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id n205so3080381wmf.2
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:28:52 -0800 (PST)
Date: Fri, 11 Mar 2016 16:28:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160311152851.GU27701@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <201603111945.FHI64215.JVOFLHQFOMOSFt@I-love.SAKURA.ne.jp>
 <20160311130847.GP27701@dhcp22.suse.cz>
 <201603112232.AEJ78150.LOHQJtMFSVOFOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603112232.AEJ78150.LOHQJtMFSVOFOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 11-03-16 22:32:02, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 11-03-16 19:45:29, Tetsuo Handa wrote:
> > > (Posting as a reply to this thread.)
> > 
> > I really do not see how this is related to this thread.
> 
> All allocating tasks are looping at
> 
>                         /*
>                          * If we didn't make any progress and have a lot of
>                          * dirty + writeback pages then we should wait for
>                          * an IO to complete to slow down the reclaim and
>                          * prevent from pre mature OOM
>                          */
>                         if (!did_some_progress && 2*(writeback + dirty) > reclaimable) {
>                                 congestion_wait(BLK_RW_ASYNC, HZ/10);
>                                 return true;
>                         }
> 
> in should_reclaim_retry().
> 
> should_reclaim_retry() was added by OOM detection rework, wan't it?

What happens without this patch applied. In other words, it all smells
like the IO got stuck somewhere and the direct reclaim cannot perform it
so we have to wait for the flushers to make a progress for us. Are those
stuck? Is the IO making any progress at all or it is just too slow and
it would finish actually.  Wouldn't we just wait somewhere else in the
direct reclaim path instead.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
