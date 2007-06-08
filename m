Date: Fri, 8 Jun 2007 14:57:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 09 of 16] fallback killing more tasks if tif-memdie
 doesn't go away
In-Reply-To: <4a70e6a4142230fa161d.1181332987@v2.random>
Message-ID: <Pine.LNX.4.64.0706081455070.3646@schroedinger.engr.sgi.com>
References: <4a70e6a4142230fa161d.1181332987@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2007, Andrea Arcangeli wrote:

> @@ -276,13 +272,16 @@ static void __oom_kill_task(struct task_
>  	if (verbose)
>  		printk(KERN_ERR "Killed process %d (%s)\n", p->pid, p->comm);
>  
> +	if (!test_and_set_tsk_thread_flag(p, TIF_MEMDIE)) {
> +		last_tif_memdie_jiffies = jiffies;
> +		set_bit(0, &VM_is_OOM);
> +	}
>  	/*

You cannot set VM_is_OM here since __oom_kill_task can be called for
a process that has constrained allocations.

With this patch a user can cause an OOM by restricting access to a single
node using MPOL_BIND. Then VM_is_OOM will be set despite of lots of 
available memory elsewhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
