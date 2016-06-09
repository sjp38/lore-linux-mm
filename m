Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB496B0005
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 11:15:36 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a69so67698903pfa.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 08:15:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s6si8052210pal.9.2016.06.09.08.15.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Jun 2016 08:15:33 -0700 (PDT)
Subject: Re: [PATCH 10/10] mm, oom: hide mm which is shared with kthread or global init
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
	<1465473137-22531-11-git-send-email-mhocko@kernel.org>
In-Reply-To: <1465473137-22531-11-git-send-email-mhocko@kernel.org>
Message-Id: <201606100015.HBB65678.LSOFFJOFMQHOVt@I-love.SAKURA.ne.jp>
Date: Fri, 10 Jun 2016 00:15:18 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> The only case where the oom_reaper is not triggered for the oom victim
> is when it shares the memory with a kernel thread (aka use_mm) or with
> the global init. After "mm, oom: skip vforked tasks from being selected"
> the victim cannot be a vforked task of the global init so we are left
> with clone(CLONE_VM) (without CLONE_SIGHAND). use_mm() users are quite
> rare as well.

CONFIG_MMU=n is the other case where the oom_reaper is not triggered for
the oom victim.

> 
> In order to guarantee a forward progress for the OOM killer make
> sure that this really rare cases will not get into the way and hide
> the mm from the oom killer by setting MMF_OOM_REAPED flag for it.
> oom_scan_process_thread will ignore any TIF_MEMDIE task if it has
> MMF_OOM_REAPED flag set to catch these oom victims.

Nobody will set MMF_OOM_REAPED flag if can_oom_reap == true on
CONFIG_MMU=n kernel. If a TIF_MEMDIE thread in CONFIG_MMU=n kernel
is blocked before exit_oom_victim() in exit_mm() from do_exit() is
called, the system will lock up. This is not handled in the patch
nor explained in the changelog.

> 
> After this patch we should guarantee a forward progress for the OOM
> killer even when the selected victim is sharing memory with a kernel
> thread or global init.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
