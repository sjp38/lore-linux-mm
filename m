Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E48476B0025
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 09:44:10 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id k4-v6so1147731pls.15
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 06:44:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h1-v6si1611467pln.216.2018.03.20.06.44.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Mar 2018 06:44:09 -0700 (PDT)
Date: Tue, 20 Mar 2018 14:44:07 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/2] mm,oom_reaper: Correct MAX_OOM_REAP_RETRIES'th
 attempt.
Message-ID: <20180320134407.GQ23100@dhcp22.suse.cz>
References: <1521547076-3399-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1521547076-3399-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180320121246.GK23100@dhcp22.suse.cz>
 <201803202137.CAC35494.OFtJLHFSFOMVOQ@I-love.SAKURA.ne.jp>
 <20180320132404.GN23100@dhcp22.suse.cz>
 <201803202237.HFB51093.FOFLOtQMJVHFSO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201803202237.HFB51093.FOFLOtQMJVHFSO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com

On Tue 20-03-18 22:37:31, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 20-03-18 21:37:42, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Tue 20-03-18 20:57:56, Tetsuo Handa wrote:
> > > > > I got "oom_reaper: unable to reap pid:" messages when the victim thread
> > > > > was blocked inside free_pgtables() (which occurred after returning from
> > > > > unmap_vmas() and setting MMF_OOM_SKIP). We don't need to complain when
> > > > > __oom_reap_task_mm() returned true (by e.g. finding MMF_OOM_SKIP already
> > > > > set) when oom_reap_task() was trying MAX_OOM_REAP_RETRIES'th attempt.
> > > > > 
> > > > > [  663.593821] Killed process 7558 (a.out) total-vm:4176kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > > > > [  664.684801] oom_reaper: unable to reap pid:7558 (a.out)
> > > > 
> > > > I do not see "oom_reaper: reaped process..." so has the task been
> > > > reaped?
> > > 
> > > The log is http://I-love.SAKURA.ne.jp/tmp/serial-20180320.txt.xz .
> > 
> > xzgrep oom_reaper: serial-20180320.txt.xz
> > [   97.144805] oom_reaper: reaped process 2142 (cleanupd), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  103.447171] oom_reaper: reaped process 659 (NetworkManager), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  208.906879] oom_reaper: reaped process 1415 (postgres), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  214.179760] oom_reaper: reaped process 588 (irqbalance), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  215.013260] oom_reaper: reaped process 591 (systemd-logind), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  221.483724] oom_reaper: reaped process 7388 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  223.140437] oom_reaper: reaped process 9252 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  224.735597] oom_reaper: reaped process 9257 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  226.608508] oom_reaper: unable to reap pid:9261 (a.out)
> > [  354.342331] oom_reaper: unable to reap pid:16611 (a.out)
> > [  380.525910] oom_reaper: unable to reap pid:6927 (a.out)
> > [  408.397539] oom_reaper: unable to reap pid:6927 (a.out)
> > [  435.702005] oom_reaper: unable to reap pid:7554 (a.out)
> > [  466.269660] oom_reaper: unable to reap pid:7560 (a.out)
> > [  495.621196] oom_reaper: unable to reap pid:7563 (a.out)
> > [  534.279602] oom_reaper: reaped process 22038 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  536.271631] oom_reaper: unable to reap pid:6928 (a.out)
> > [  600.285293] oom_reaper: unable to reap pid:7550 (a.out)
> > [  664.684801] oom_reaper: unable to reap pid:7558 (a.out)
> > [  743.188067] oom_reaper: reaped process 7562 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  744.980868] oom_reaper: unable to reap pid:6928 (a.out)
> > 
> > None of the reaped taks is reported as "unable to reap..." So what
> > actually gets fixed by this patch?
> 
> This patch (which I sent as "[PATCH 2/2] mm,oom_reaper: Check for MMF_OOM_SKIP before complain.")
> makes the OOM reaper not to complain if MMF_OOM_SKIP was already set by exit_mmap().

Sigh. So can you send a patch with a meaningful changelog showing
the problem and explaining how it is fixed?

-- 
Michal Hocko
SUSE Labs
