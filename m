Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42C042802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 13:04:36 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k2so36363851ioe.4
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 10:04:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y81si4504601itc.118.2017.06.30.10.04.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 10:04:34 -0700 (PDT)
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170309180540.GA8678@cmpxchg.org>
	<20170310102010.GD3753@dhcp22.suse.cz>
	<201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
	<201706300914.CEH95859.FMQOLVFHJFtOOS@I-love.SAKURA.ne.jp>
	<20170630133236.GM22917@dhcp22.suse.cz>
In-Reply-To: <20170630133236.GM22917@dhcp22.suse.cz>
Message-Id: <201707010059.EAE43714.FOVOMOSLFHJFQt@I-love.SAKURA.ne.jp>
Date: Sat, 1 Jul 2017 00:59:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 30-06-17 09:14:22, Tetsuo Handa wrote:
> [...]
> > Ping? Ping? When are we going to apply this patch or watchdog patch?
> > This problem occurs with not so insane stress like shown below.
> > I can't test almost OOM situation because test likely falls into either
> > printk() v.s. oom_lock lockup problem or this too_many_isolated() problem.
> 
> So you are saying that the patch fixes this issue. Do I understand you
> corretly? And you do not see any other negative side effectes with it
> applied?

I hit this problem using http://lkml.kernel.org/r/20170626130346.26314-1-mhocko@kernel.org
on next-20170628. We won't be able to test whether the patch fixes this issue without
seeing any other negative side effects without sending this patch to linux-next.git.
But at least we know that even this patch is sent to linux-next.git, we will still see
bugs like http://lkml.kernel.org/r/201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp .

> 
> I am sorry I didn't have much time to think about feedback from Johannes
> yet. A more robust throttling method is surely due but also not trivial.
> So I am not sure how to proceed. It is true that your last test case
> with only 10 processes fighting resembles the reality much better than
> hundreds (AFAIR) that you were using previously.

Even if hundreds are running, most of them are simply blocked inside open()
at down_write() (like an example from serial-20170423-2.txt.xz shown below).
Actual number of processes fighting for memory is always less than 100.

 ? __schedule+0x1d2/0x5a0
 ? schedule+0x2d/0x80
 ? rwsem_down_write_failed+0x1f9/0x370
 ? walk_component+0x43/0x270
 ? call_rwsem_down_write_failed+0x13/0x20
 ? down_write+0x24/0x40
 ? path_openat+0x670/0x1210
 ? do_filp_open+0x8c/0x100
 ? getname_flags+0x47/0x1e0
 ? do_sys_open+0x121/0x200
 ? do_syscall_64+0x5c/0x140
 ? entry_SYSCALL64_slow_path+0x25/0x25

> 
> Rik, Johannes what do you think? Should we go with the simpler approach
> for now and think of a better plan longterm?

I don't hurry if we can check using watchdog whether this problem is occurring
in the real world. I have to test corner cases because watchdog is missing.

Watchdog does not introduce negative side effects, will avoid soft lockups like
http://lkml.kernel.org/r/CAM_iQpWuPVGc2ky8M-9yukECtS+zKjiDasNymX7rMcBjBFyM_A@mail.gmail.com ,
will avoid console_unlock() v.s. oom_lock mutext lockups due to warn_alloc(),
will catch similar bugs which people are failing to reproduce.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
