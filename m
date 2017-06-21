Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 694046B0292
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 22:17:22 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id i93so3514576iod.4
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 19:17:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q123si11787750itg.131.2017.06.20.19.17.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Jun 2017 19:17:21 -0700 (PDT)
Message-Id: <201706210217.v5L2HAZc081021@www262.sakura.ne.jp>
Subject: Re: Re: [PATCH] =?ISO-2022-JP?B?bW0sb29tX2tpbGw6IENsb3NlIHJhY2Ugd2luZG93?=
 =?ISO-2022-JP?B?IG9mIG5lZWRsZXNzbHkgc2VsZWN0aW5nIG5ldyB2aWN0aW1zLg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Wed, 21 Jun 2017 11:17:09 +0900
References: <201706171417.JHG48401.JOQLHMFSVOOFtF@I-love.SAKURA.ne.jp> <alpine.DEB.2.10.1706201509170.109574@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1706201509170.109574@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

David Rientjes wrote:
> This doesn't prevent serial oom killing for either the system oom killer 
> or for the memcg oom killer.
> 
> The oom killer cannot detect tsk_is_oom_victim() if the task has either 
> been removed from the tasklist or has already done cgroup_exit().  For 
> memcg oom killings in particular, cgroup_exit() is usually called very 
> shortly after the oom killer has sent the SIGKILL.  If the oom reaper does 
> not fail (for example by failing to grab mm->mmap_sem) before another 
> memcg charge after cgroup_exit(victim), additional processes are killed 
> because the iteration does not view the victim.
> 
> This easily kills all processes attached to the memcg with no memory 
> freeing from any victim.

Umm... So, you are pointing out that select_bad_process() aborts based on
TIF_MEMDIE or MMF_OOM_SKIP is broken because victim threads can be removed
 from global task list or cgroup's task list. Then, the OOM killer will have to
wait until all mm_struct of interested OOM domain (system wide or some cgroup)
is reaped by the OOM reaper. Simplest way is to wait until all mm_struct are
reaped by the OOM reaper, for currently we are not tracking which memory cgroup
each mm_struct belongs to, are we? But that can cause needless delay when
multiple OOM events occurred in different OOM domains. Do we want to (and can we)
make it possible to tell whether each mm_struct queued to the OOM reaper's list
belongs to the thread calling out_of_memory() ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
