Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E26F76B02C3
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 16:31:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d62so47526436pfb.13
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 13:31:05 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id w20si656454pfi.382.2017.06.21.13.31.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 13:31:05 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id e7so10295540pfk.0
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 13:31:05 -0700 (PDT)
Date: Wed, 21 Jun 2017 13:31:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Re: [PATCH] mm,oom_kill: Close race window of needlessly selecting
 new victims.
In-Reply-To: <201706210217.v5L2HAZc081021@www262.sakura.ne.jp>
Message-ID: <alpine.DEB.2.10.1706211325340.101895@chino.kir.corp.google.com>
References: <201706171417.JHG48401.JOQLHMFSVOOFtF@I-love.SAKURA.ne.jp> <alpine.DEB.2.10.1706201509170.109574@chino.kir.corp.google.com> <201706210217.v5L2HAZc081021@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 21 Jun 2017, Tetsuo Handa wrote:

> Umm... So, you are pointing out that select_bad_process() aborts based on
> TIF_MEMDIE or MMF_OOM_SKIP is broken because victim threads can be removed
>  from global task list or cgroup's task list. Then, the OOM killer will have to
> wait until all mm_struct of interested OOM domain (system wide or some cgroup)
> is reaped by the OOM reaper. Simplest way is to wait until all mm_struct are
> reaped by the OOM reaper, for currently we are not tracking which memory cgroup
> each mm_struct belongs to, are we? But that can cause needless delay when
> multiple OOM events occurred in different OOM domains. Do we want to (and can we)
> make it possible to tell whether each mm_struct queued to the OOM reaper's list
> belongs to the thread calling out_of_memory() ?
> 

I am saying that taking mmget() in mark_oom_victim() and then only 
dropping it with mmput_async() after it can grab mm->mmap_sem, which the 
exit path itself takes, or the oom reaper happens to schedule, causes 
__mmput() to be called much later and thus we remove the process from the 
tasklist or call cgroup_exit() earlier than the memory can be unmapped 
with your patch.  As a result, subsequent calls to the oom killer kills 
everything before the original victim's mm can undergo __mmput() because 
the oom reaper still holds the reference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
