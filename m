Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2146B0264
	for <linux-mm@kvack.org>; Sat,  9 Nov 2013 10:15:21 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so3497499pab.12
        for <linux-mm@kvack.org>; Sat, 09 Nov 2013 07:15:21 -0800 (PST)
Received: from psmtp.com ([74.125.245.199])
        by mx.google.com with SMTP id ru9si10247099pbc.18.2013.11.09.07.15.19
        for <linux-mm@kvack.org>;
        Sat, 09 Nov 2013 07:15:20 -0800 (PST)
Date: Sat, 9 Nov 2013 16:16:39 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3] mm, oom: Fix race when selecting process to kill
Message-ID: <20131109151639.GB14249@redhat.com>
References: <20131108184515.GA11555@redhat.com> <1383940173-16480-1-git-send-email-snanda@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1383940173-16480-1-git-send-email-snanda@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sameer Nanda <snanda@chromium.org>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, rusty@rustcorp.com.au, semenzato@google.com, murzin.v@gmail.com, dserrg@gmail.com, msb@chromium.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/08, Sameer Nanda wrote:
>
> @@ -413,12 +413,20 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  					      DEFAULT_RATELIMIT_BURST);
> @@ -456,10 +463,18 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  			}
>  		}
>  	} while_each_thread(p, t);
> -	read_unlock(&tasklist_lock);
>  
>  	rcu_read_lock();
> +
>  	p = find_lock_task_mm(victim);
> +
> +	/*
> +	 * Since while_each_thread is currently not RCU safe, this unlock of
> +	 * tasklist_lock may need to be moved further down if any additional
> +	 * while_each_thread loops get added to this function.
> +	 */
> +	read_unlock(&tasklist_lock);

Well, ack... but with this change find_lock_task_mm() relies on tasklist,
so it makes sense to move rcu_read_lock() down before for_each_process().
Otherwise this looks confusing, but I won't insist.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
