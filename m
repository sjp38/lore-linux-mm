Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id C7F546B0253
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 08:07:46 -0500 (EST)
Received: by mail-io0-f172.google.com with SMTP id l127so35537881iof.3
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:07:46 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h80si4925686ioh.83.2016.02.17.05.07.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 05:07:46 -0800 (PST)
Subject: Re: [PATCH 2/6] mm,oom: don't abort on exiting processes when selecting a victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
	<201602171930.AII18204.FMOSVFQFOJtLOH@I-love.SAKURA.ne.jp>
	<20160217125418.GF29196@dhcp22.suse.cz>
In-Reply-To: <20160217125418.GF29196@dhcp22.suse.cz>
Message-Id: <201602172207.GAG52105.FOtMJOFQOVSFHL@I-love.SAKURA.ne.jp>
Date: Wed, 17 Feb 2016 22:07:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 17-02-16 19:30:41, Tetsuo Handa wrote:
> > >From 22bd036766e70f0df38c38f3ecc226e857d20faf Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Wed, 17 Feb 2016 16:30:59 +0900
> > Subject: [PATCH 2/6] mm,oom: don't abort on exiting processes when selecting a victim.
> > 
> > Currently, oom_scan_process_thread() returns OOM_SCAN_ABORT when there
> > is a thread which is exiting. But it is possible that that thread is
> > blocked at down_read(&mm->mmap_sem) in exit_mm() called from do_exit()
> > whereas one of threads sharing that memory is doing a GFP_KERNEL
> > allocation between down_write(&mm->mmap_sem) and up_write(&mm->mmap_sem)
> > (e.g. mmap()). Under such situation, the OOM killer does not choose a
> > victim, which results in silent OOM livelock problem.
> 
> Again, such a thread/task will have fatal_signal_pending and so have
> access to memory reserves. So the text is slightly misleading imho.
> Sure if the memory reserves are depleted then we will not move on but
> then it is not clear whether the current patch helps either.

I don't think so.
Please see http://lkml.kernel.org/r/201602151958.HCJ48972.FFOFOLMHSQVJtO@I-love.SAKURA.ne.jp .
There is a race window before such a thread/task receives SIGKILL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
