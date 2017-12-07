Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4786B0038
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 06:01:07 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id i66so178979itf.0
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 03:01:07 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d68si3491163iog.92.2017.12.07.03.01.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 03:01:05 -0800 (PST)
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with exit_mmap
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1712052323170.119719@chino.kir.corp.google.com>
	<20171206090019.GE16386@dhcp22.suse.cz>
	<201712070720.vB77KlBQ009754@www262.sakura.ne.jp>
	<20171207082801.GB20234@dhcp22.suse.cz>
In-Reply-To: <20171207082801.GB20234@dhcp22.suse.cz>
Message-Id: <201712072000.FCE30281.FOFHOOtVMQLJFS@I-love.SAKURA.ne.jp>
Date: Thu, 7 Dec 2017 20:00:58 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, aarcange@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> Hmm, so you are creating a separate process (from the signal point of
> view) and I suspect it is one of those that holds the last reference to
> the mm_struct which is released here and it has tsk_oom_victim = F

Right.

> So we need a more robust test for the oom victim. Your suggestion is
> basically what I came up with originally [1] and which was deemed
> ineffective because we took the mmap_sem even for regular paths and
> Kirill was afraid this adds some unnecessary cycles to the exit path
> which is quite hot.
> 
> So I guess we have to do something else instead. We have to store the
> oom flag to the mm struct as well. Something like the patch below.

Yes, adding a new flag for this purpose will work.

Also, setting MMF_UNSTABLE flag between after sending SIGKILL and before
victim->mm becomes NULL and testing MMF_UNSTABLE at exit_mm() should work.

But I prefer simple revert + mmget()/mmput_async() approach at
http://lkml.kernel.org/r/201712062037.DAF90168.SVFQOJFMOOtHLF@I-love.SAKURA.ne.jp , for
my approach not only saves lines but also fixes unexpected change for nommu at
http://lkml.kernel.org/r/201711091949.BDB73475.OSHFOMQtLFOFVJ@I-love.SAKURA.ne.jp .
Also, if we replace asynchronous OOM reaping by the OOM reaper kernel thread with
synchronous OOM reaping by the OOM killer, we can close MMF_OOM_SKIP race window
because it is guaranteed that __oom_reap_task_mm() is called before __mmput() is
called.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
