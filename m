Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0EB186B006C
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 15:25:15 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so9044377wiv.7
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 12:25:14 -0800 (PST)
Received: from mail-wg0-x229.google.com (mail-wg0-x229.google.com. [2a00:1450:400c:c00::229])
        by mx.google.com with ESMTPS id eb2si20637858wib.105.2014.12.22.12.25.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Dec 2014 12:25:13 -0800 (PST)
Received: by mail-wg0-f41.google.com with SMTP id y19so7542432wgg.14
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 12:25:13 -0800 (PST)
Date: Mon, 22 Dec 2014 21:25:11 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
Message-ID: <20141222202511.GA9485@dhcp22.suse.cz>
References: <201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
 <20141218153341.GB832@dhcp22.suse.cz>
 <201412192107.IGJ09885.OFHSMJtLFFOVQO@I-love.SAKURA.ne.jp>
 <20141219124903.GB18397@dhcp22.suse.cz>
 <201412201813.JJF95860.VSLOQOFHFJOFtM@I-love.SAKURA.ne.jp>
 <201412202042.ECJ64551.FHOOJOQLFFtVMS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412202042.ECJ64551.FHOOJOQLFFtVMS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Sat 20-12-14 20:42:08, Tetsuo Handa wrote:
[...]
> >From a2ebb5b873ec5af45e0bea9ea6da2a93c0f06c35 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 20 Dec 2014 20:05:14 +0900
> Subject: [PATCH] oom: Close race of setting TIF_MEMDIE to mm-less process.
> 
> exit_mm() and oom_kill_process() could race with regard to handling of
> TIF_MEMDIE flag if sequence described below occurred.
> 
> P1 calls out_of_memory(). out_of_memory() calls select_bad_process().
> select_bad_process() calls oom_scan_process_thread(P2). If P2->mm != NULL
> and task_will_free_mem(P2) == false, oom_scan_process_thread(P2) returns
> OOM_SCAN_OK. And if P2 is chosen as a victim task, select_bad_process()
> returns P2 after calling get_task_struct(P2). Then, P1 goes to sleep and
> P2 is woken up. P2 enters into do_exit() and gets PF_EXITING at exit_signals()
> and releases mm at exit_mm(). Then, P2 goes to sleep and P1 is woken up.
> P1 calls oom_kill_process(P2). oom_kill_process() sets TIF_MEMDIE on P2
> because task_will_free_mem(P2) == true due to PF_EXITING already set.
> Afterward, oom_scan_process_thread(P2) will return OOM_SCAN_ABORT because
> test_tsk_thread_flag(P2, TIF_MEMDIE) is checked before P2->mm is checked.
> 
> If TIF_MEMDIE was again set to P2, the OOM killer will be blocked by P2
> sitting in the final schedule() waiting for P2's parent to reap P2.
> It will trigger an OOM livelock if P2's parent is unable to reap P2 due to
> doing an allocation and waiting for the OOM killer to kill P2.
>
> To close this race window, clear TIF_MEMDIE if P2->mm == NULL after
> set_tsk_thread_flag(P2, TIF_MEMDIE) is done.

I do not think this patch is sufficient. P2 could pass exit_mm() right
after task_unlock in oom_kill_process and we would set TIF_MEMDIE to
this task as well. Something like the following should work and it
doesn't add memory barriers trickery.
---
