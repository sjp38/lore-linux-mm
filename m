Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 155F48E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 15:58:55 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id q16so1402052ios.1
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 12:58:55 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r76si6333317iod.14.2019.01.07.12.58.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 12:58:53 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, oom: marks all killed tasks as oom victims
References: <20190107143802.16847-1-mhocko@kernel.org>
 <20190107143802.16847-2-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <1054b5c6-19c0-53a4-206e-dd55f5a3d732@i-love.sakura.ne.jp>
Date: Tue, 8 Jan 2019 05:58:41 +0900
MIME-Version: 1.0
In-Reply-To: <20190107143802.16847-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 2019/01/07 23:38, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Historically we have called mark_oom_victim only to the main task
> selected as the oom victim because oom victims have access to memory
> reserves and granting the access to all killed tasks could deplete
> memory reserves very quickly and cause even larger problems.
> 
> Since only a partial access to memory reserves is allowed there is no
> longer this risk and so all tasks killed along with the oom victim
> can be considered as well.
> 
> The primary motivation for that is that process groups which do not
> shared signals would behave more like standard thread groups wrt oom
> handling (aka tsk_is_oom_victim will work the same way for them).
> 
> - Use find_lock_task_mm to stabilize mm as suggested by Tetsuo
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/oom_kill.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index f0e8cd9edb1a..0246c7a4e44e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -892,6 +892,7 @@ static void __oom_kill_process(struct task_struct *victim)
>  	 */
>  	rcu_read_lock();
>  	for_each_process(p) {
> +		struct task_struct *t;
>  		if (!process_shares_mm(p, mm))
>  			continue;
>  		if (same_thread_group(p, victim))
> @@ -911,6 +912,11 @@ static void __oom_kill_process(struct task_struct *victim)
>  		if (unlikely(p->flags & PF_KTHREAD))
>  			continue;
>  		do_send_sig_info(SIGKILL, SEND_SIG_PRIV, p, PIDTYPE_TGID);
> +		t = find_lock_task_mm(p);
> +		if (!t)
> +			continue;
> +		mark_oom_victim(t);
> +		task_unlock(t);

Thank you for updating this patch. This patch is correct from the point of
view of avoiding TIF_MEMDIE race. But if I recall correctly, the reason we
did not do this is to avoid depleting memory reserves. And we still grant
full access to memory reserves for CONFIG_MMU=n case. Shouldn't the changelog
mention CONFIG_MMU=n case?

>  	}
>  	rcu_read_unlock();
>  
> 
