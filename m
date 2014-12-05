Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6E76B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 17:19:27 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id n12so2011914wgh.8
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 14:19:27 -0800 (PST)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id m10si51400097wje.26.2014.12.05.14.19.26
        for <linux-mm@kvack.org>;
        Fri, 05 Dec 2014 14:19:26 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH -v2 3/5] PM: convert printk to pr_* equivalent
Date: Fri, 05 Dec 2014 23:40:55 +0100
Message-ID: <6656448.TBhAod4SQC@vostro.rjw.lan>
In-Reply-To: <1417797707-31699-4-git-send-email-mhocko@suse.cz>
References: <20141110163055.GC18373@dhcp22.suse.cz> <1417797707-31699-1-git-send-email-mhocko@suse.cz> <1417797707-31699-4-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Friday, December 05, 2014 05:41:45 PM Michal Hocko wrote:
> While touching this area let's convert printk to pr_*. This also makes
> the printing of continuation lines done properly.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

This is fine by me.

Please let me know if you want me to take it.  Otherwise, please feel free to
push it through a different tree.

> ---
>  kernel/power/process.c | 29 +++++++++++++++--------------
>  1 file changed, 15 insertions(+), 14 deletions(-)
> 
> diff --git a/kernel/power/process.c b/kernel/power/process.c
> index 5a6ec8678b9a..3ac45f192e9f 100644
> --- a/kernel/power/process.c
> +++ b/kernel/power/process.c
> @@ -84,8 +84,8 @@ static int try_to_freeze_tasks(bool user_only)
>  	elapsed_msecs = elapsed_msecs64;
>  
>  	if (todo) {
> -		printk("\n");
> -		printk(KERN_ERR "Freezing of tasks %s after %d.%03d seconds "
> +		pr_cont("\n");
> +		pr_err("Freezing of tasks %s after %d.%03d seconds "
>  		       "(%d tasks refusing to freeze, wq_busy=%d):\n",
>  		       wakeup ? "aborted" : "failed",
>  		       elapsed_msecs / 1000, elapsed_msecs % 1000,
> @@ -101,7 +101,7 @@ static int try_to_freeze_tasks(bool user_only)
>  			read_unlock(&tasklist_lock);
>  		}
>  	} else {
> -		printk("(elapsed %d.%03d seconds) ", elapsed_msecs / 1000,
> +		pr_cont("(elapsed %d.%03d seconds) ", elapsed_msecs / 1000,
>  			elapsed_msecs % 1000);
>  	}
>  
> @@ -155,7 +155,7 @@ int freeze_processes(void)
>  		atomic_inc(&system_freezing_cnt);
>  
>  	pm_wakeup_clear();
> -	printk("Freezing user space processes ... ");
> +	pr_info("Freezing user space processes ... ");
>  	pm_freezing = true;
>  	oom_kills_saved = oom_kills_count();
>  	error = try_to_freeze_tasks(true);
> @@ -171,13 +171,13 @@ int freeze_processes(void)
>  		if (oom_kills_count() != oom_kills_saved &&
>  		    !check_frozen_processes()) {
>  			__usermodehelper_set_disable_depth(UMH_ENABLED);
> -			printk("OOM in progress.");
> +			pr_cont("OOM in progress.");
>  			error = -EBUSY;
>  		} else {
> -			printk("done.");
> +			pr_cont("done.");
>  		}
>  	}
> -	printk("\n");
> +	pr_cont("\n");
>  	BUG_ON(in_atomic());
>  
>  	if (error)
> @@ -197,13 +197,14 @@ int freeze_kernel_threads(void)
>  {
>  	int error;
>  
> -	printk("Freezing remaining freezable tasks ... ");
> +	pr_info("Freezing remaining freezable tasks ... ");
> +
>  	pm_nosig_freezing = true;
>  	error = try_to_freeze_tasks(false);
>  	if (!error)
> -		printk("done.");
> +		pr_cont("done.");
>  
> -	printk("\n");
> +	pr_cont("\n");
>  	BUG_ON(in_atomic());
>  
>  	if (error)
> @@ -224,7 +225,7 @@ void thaw_processes(void)
>  
>  	oom_killer_enable();
>  
> -	printk("Restarting tasks ... ");
> +	pr_info("Restarting tasks ... ");
>  
>  	__usermodehelper_set_disable_depth(UMH_FREEZING);
>  	thaw_workqueues();
> @@ -243,7 +244,7 @@ void thaw_processes(void)
>  	usermodehelper_enable();
>  
>  	schedule();
> -	printk("done.\n");
> +	pr_cont("done.\n");
>  	trace_suspend_resume(TPS("thaw_processes"), 0, false);
>  }
>  
> @@ -252,7 +253,7 @@ void thaw_kernel_threads(void)
>  	struct task_struct *g, *p;
>  
>  	pm_nosig_freezing = false;
> -	printk("Restarting kernel threads ... ");
> +	pr_info("Restarting kernel threads ... ");
>  
>  	thaw_workqueues();
>  
> @@ -264,5 +265,5 @@ void thaw_kernel_threads(void)
>  	read_unlock(&tasklist_lock);
>  
>  	schedule();
> -	printk("done.\n");
> +	pr_cont("done.\n");
>  }
> 

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
