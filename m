Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 464366B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 23:31:52 -0400 (EDT)
Received: by igbud6 with SMTP id ud6so119608985igb.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:31:52 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id d90si3554027ioj.27.2015.03.25.20.31.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 20:31:51 -0700 (PDT)
Received: by igcau2 with SMTP id au2so6251698igc.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:31:51 -0700 (PDT)
Date: Wed, 25 Mar 2015 20:31:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 03/12] mm: oom_kill: switch test-and-clear of known
 TIF_MEMDIE to clear
In-Reply-To: <1427264236-17249-4-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1503252025230.16714@chino.kir.corp.google.com>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org> <1427264236-17249-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

On Wed, 25 Mar 2015, Johannes Weiner wrote:

> exit_oom_victim() already knows that TIF_MEMDIE is set, and nobody
> else can clear it concurrently.  Use clear_thread_flag() directly.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

For the oom killer, that's true because of task_lock(): we always only set 
TIF_MEMDIE when there is a valid p->mm and it's cleared in the exit path 
after the unlock, acting as a barrier, when p->mm is set to NULL so it's 
no longer a valid victim.  So that part is fine.

The problem is the android low memory killer that does 
mark_tsk_oom_victim() without the protection of task_lock(), it's just rcu 
protected so the reference to the task itself is guaranteed to still be 
valid.

I assume that's why Michal implemented it this way and added the comment 
to the lmk in commit 49550b605587 ("oom: add helpers for setting and 
clearing TIF_MEMDIE") to avoid TIF_MEMDIE entirely there.

> ---
>  mm/oom_kill.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index b2f081fe4b1a..4b9547be9170 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -435,8 +435,7 @@ void mark_oom_victim(struct task_struct *tsk)
>   */
>  void exit_oom_victim(void)
>  {
> -	if (!test_and_clear_thread_flag(TIF_MEMDIE))
> -		return;
> +	clear_thread_flag(TIF_MEMDIE);
>  
>  	down_read(&oom_sem);
>  	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
