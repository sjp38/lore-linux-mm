Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id B0D846B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 09:00:08 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id b205so157014899wmb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 06:00:08 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id 19si4681935wmk.17.2016.02.17.06.00.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 06:00:07 -0800 (PST)
Received: by mail-wm0-f50.google.com with SMTP id c200so215020856wme.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 06:00:07 -0800 (PST)
Date: Wed, 17 Feb 2016 15:00:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/6] mm,oom: don't abort on exiting processes when
 selecting a victim.
Message-ID: <20160217140006.GM29196@dhcp22.suse.cz>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
 <201602171930.AII18204.FMOSVFQFOJtLOH@I-love.SAKURA.ne.jp>
 <20160217125418.GF29196@dhcp22.suse.cz>
 <201602172207.GAG52105.FOtMJOFQOVSFHL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602172207.GAG52105.FOtMJOFQOVSFHL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 17-02-16 22:07:31, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 17-02-16 19:30:41, Tetsuo Handa wrote:
> > > >From 22bd036766e70f0df38c38f3ecc226e857d20faf Mon Sep 17 00:00:00 2001
> > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Date: Wed, 17 Feb 2016 16:30:59 +0900
> > > Subject: [PATCH 2/6] mm,oom: don't abort on exiting processes when selecting a victim.
> > > 
> > > Currently, oom_scan_process_thread() returns OOM_SCAN_ABORT when there
> > > is a thread which is exiting. But it is possible that that thread is
> > > blocked at down_read(&mm->mmap_sem) in exit_mm() called from do_exit()
> > > whereas one of threads sharing that memory is doing a GFP_KERNEL
> > > allocation between down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem)
> > > (e.g. mmap()). Under such situation, the OOM killer does not choose a
> > > victim, which results in silent OOM livelock problem.
> > 
> > Again, such a thread/task will have fatal_signal_pending and so have
> > access to memory reserves. So the text is slightly misleading imho.
> > Sure if the memory reserves are depleted then we will not move on but
> > then it is not clear whether the current patch helps either.
> 
> I don't think so.
> Please see http://lkml.kernel.org/r/201602151958.HCJ48972.FFOFOLMHSQVJtO@I-love.SAKURA.ne.jp .

I have missed this one. Reading...

Hmm, so you are not referring to OOM killed task but naturally exiting
thread which is racing with the OOM killer. I guess you have a point
there! Could you update the changelog with the above example and repost
please?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
