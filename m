Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id A68096B0254
	for <linux-mm@kvack.org>; Sun, 29 Nov 2015 22:08:10 -0500 (EST)
Received: by wmvv187 with SMTP id v187so136712880wmv.1
        for <linux-mm@kvack.org>; Sun, 29 Nov 2015 19:08:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gm18si63943185wjc.247.2015.11.29.19.08.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Nov 2015 19:08:09 -0800 (PST)
Date: Sun, 29 Nov 2015 19:08:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] bugfix oom kill init lead panic
Message-Id: <20151129190802.dc66cf35.akpm@linux-foundation.org>
In-Reply-To: <1448880869-20506-1-git-send-email-chenjie6@huawei.com>
References: <1448880869-20506-1-git-send-email-chenjie6@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chenjie6@huawei.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David.Woodhouse@intel.com, zhihui.gao@huawei.com, lizefan@huawei.com, stable@vger.kernel.org

On Mon, 30 Nov 2015 18:54:29 +0800 <chenjie6@huawei.com> wrote:

> From: chenjie <chenjie6@huawei.com>
> 
> when oom happened we can see:
> Out of memory: Kill process 9134 (init) score 3 or sacrifice child                  
> Killed process 9134 (init) total-vm:1868kB, anon-rss:84kB, file-rss:572kB
> Kill process 1 (init) sharing same memory
> ...
> Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000009
> 
> That's because:
> 	the busybox init will vfork a process,oom_kill_process found
> the init not the children,their mm is the same when vfork.
> 
> ...
>
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -513,7 +513,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	rcu_read_lock();
>  	for_each_process(p)
>  		if (p->mm == mm && !same_thread_group(p, victim) &&
> -		    !(p->flags & PF_KTHREAD)) {
> +		    !(p->flags & PF_KTHREAD) && !is_global_init(p)) {
>  			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
>  				continue;

What kernel version are you using?

I don't think this can happen in current code...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
