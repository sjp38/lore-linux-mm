Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC9456B06F2
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 11:24:04 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 24so20624207pfk.5
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 08:24:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h194si1155676pfe.672.2017.08.04.08.24.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 08:24:02 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: task_will_free_mem(current) should ignore MMF_OOM_SKIP for once.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1501718104-8099-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<a9a57062-a56d-4cc8-7027-6b80d12a8996@caviumnetworks.com>
In-Reply-To: <a9a57062-a56d-4cc8-7027-6b80d12a8996@caviumnetworks.com>
Message-Id: <201708050024.ABD87010.SFFOVQOFOJMHtL@I-love.SAKURA.ne.jp>
Date: Sat, 5 Aug 2017 00:24:01 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mjaggi@caviumnetworks.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, rientjes@google.com, mhocko@suse.com, oleg@redhat.com, vdavydov.dev@gmail.com

Manish Jaggi wrote:
> Hi Tetsuo Handa,
> 
> On 8/3/2017 5:25 AM, Tetsuo Handa wrote:
> > Manish Jaggi noticed that running LTP oom01/oom02 ltp tests with high core
> > count causes random kernel panics when an OOM victim which consumed memory
> > in a way the OOM reaper does not help was selected by the OOM killer.
> >
> > ----------
> > oom02       0  TINFO  :  start OOM testing for mlocked pages.
> > oom02       0  TINFO  :  expected victim is 4578.
> > oom02       0  TINFO  :  thread (ffff8b0e71f0), allocating 3221225472 bytes.
> > oom02       0  TINFO  :  thread (ffff8b8e71f0), allocating 3221225472 bytes.
> > (...snipped...)
> > oom02       0  TINFO  :  thread (ffff8a0e71f0), allocating 3221225472 bytes.
> > [  364.737486] oom02:4583 invoked oom-killer: gfp_mask=0x16080c0(GFP_KERNEL|__GFP_ZERO|__GFP_NOTRACK), nodemask=1,  order=0, oom_score_adj=0
> > (...snipped...)
> > [  365.036127] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
> > [  365.044691] [ 1905]     0  1905     3236     1714      10       4        0             0 systemd-journal
> > [  365.054172] [ 1908]     0  1908    20247      590       8       4        0             0 lvmetad
> > [  365.062959] [ 2421]     0  2421     3241      878       9       3        0         -1000 systemd-udevd
> > [  365.072266] [ 3125]     0  3125     3834      719       9       4        0         -1000 auditd
> > [  365.080963] [ 3145]     0  3145     1086      630       6       4        0             0 systemd-logind
> > [  365.090353] [ 3146]     0  3146     1208      596       7       3        0             0 irqbalance
> > [  365.099413] [ 3147]    81  3147     1118      625       5       4        0          -900 dbus-daemon
> > [  365.108548] [ 3149]   998  3149   116294     4180      26       5        0             0 polkitd
> > [  365.117333] [ 3164]   997  3164    19992      785       9       3        0             0 chronyd
> > [  365.126118] [ 3180]     0  3180    55605     7880      29       3        0             0 firewalld
> > [  365.135075] [ 3187]     0  3187    87842     3033      26       3        0             0 NetworkManager
> > [  365.144465] [ 3290]     0  3290    43037     1224      16       5        0             0 rsyslogd
> > [  365.153335] [ 3295]     0  3295   108279     6617      30       3        0             0 tuned
> > [  365.161944] [ 3308]     0  3308    27846      676      11       3        0             0 crond
> > [  365.170554] [ 3309]     0  3309     3332      616      10       3        0         -1000 sshd
> > [  365.179076] [ 3371]     0  3371    27307      364       6       3        0             0 agetty
> > [  365.187790] [ 3375]     0  3375    29397     1125      11       3        0             0 login
> > [  365.196402] [ 4178]     0  4178     4797     1119      14       4        0             0 master
> > [  365.205101] [ 4209]    89  4209     4823     1396      12       4        0             0 pickup
> > [  365.213798] [ 4211]    89  4211     4842     1485      12       3        0             0 qmgr
> > [  365.222325] [ 4491]     0  4491    27965     1022       8       3        0             0 bash
> > [  365.230849] [ 4513]     0  4513      670      365       5       3        0             0 oom02
> > [  365.239459] [ 4578]     0  4578 37776030 32890957   64257     138        0             0 oom02
> > [  365.248067] Out of memory: Kill process 4578 (oom02) score 952 or sacrifice child
> > [  365.255581] Killed process 4578 (oom02) total-vm:151104120kB, anon-rss:131562528kB, file-rss:1300kB, shmem-rss:0kB
> > [  365.266829] out_of_memory: Current (4583) has a pending SIGKILL
> > [  365.267347] oom_reaper: reaped process 4578 (oom02), now anon-rss:131559616kB, file-rss:0kB, shmem-rss:0kB
> > [  365.282658] oom_reaper: reaped process 4583 (oom02), now anon-rss:131561664kB, file-rss:0kB, shmem-rss:0kB
> > [  365.283361] oom02:4586 invoked oom-killer: gfp_mask=0x16040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK), nodemask=1,  order=0, oom_score_adj=0
> > (...snipped...)
> > [  365.576164] oom02:4585 invoked oom-killer: gfp_mask=0x16080c0(GFP_KERNEL|__GFP_ZERO|__GFP_NOTRACK), nodemask=1,  order=0, oom_score_adj=0
> > (...snipped...)
> > [  365.576298] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
> > [  365.576338] [ 2421]     0  2421     3241      878       9       3        0         -1000 systemd-udevd
> > [  365.576342] [ 3125]     0  3125     3834      719       9       4        0         -1000 auditd
> > [  365.576347] [ 3309]     0  3309     3332      616      10       3        0         -1000 sshd
> > [  365.576356] [ 4580]     0  4578 37776030 32890417   64258     138        0             0 oom02
> > [  365.576361] Kernel panic - not syncing: Out of memory and no killable processes...
> > ----------
> Wanted to understand the envisaged effect of this patch
> - would this patch kill the task fully or it will still take few more 
> iterations of oom-kill to kill other process to free memory
> - when I apply this patch I see other tasks getting killed, though I 
> didnt got panic in initial testing, I saw login process getting killed.
> So I am not sure if this patch works...

Thank you for testing. This patch is working as intended.

This patch (or any other patches) won't wait for the OOM victim (in this case
oom02) to be fully killed. We don't want to risk OOM lockup situation by waiting
for the OOM victim to be fully killed. If the OOM reaper kernel thread waits for
the OOM victim forever, different OOM stress will trigger OOM lockup situation.
Thus, the OOM reaper kernel thread gives up waiting for the OOM victim as soon as
memory which can be reclaimed before __mmput() from mmput() from exit_mm() from
do_exit() is called is reclaimed and sets MMF_OOM_SKIP.

Other tasks might be getting killed, for threads which task_will_free_mem(current)
returns false will call select_bad_process() and select_bad_process() will ignore
existing OOM victims with MMF_OOM_SKIP already set. Compared to older kernels
which do not have the OOM reaper support, this behavior looks like a regression.
But please be patient. This behavior is our choice for not to risk OOM lockup
situation.

This patch will prevent _all_ threads which task_will_free_mem(current) returns
true from calling select_bad_process(). And Michal's patch will prevent _most_
threads which task_will_free_mem(current) returns true from calling select_bad_process().
Since oom02 has many threads which task_will_free_mem(current) returns true,
this patch (or Michal's patch) will reduce possibility of killing all threads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
