Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC7EE6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 11:45:20 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id c42so3388528wrc.13
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 08:45:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l38si3668669edb.74.2017.11.02.08.45.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 08:45:19 -0700 (PDT)
Date: Thu, 2 Nov 2017 16:45:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] EPOLL_KILLME: New flag to epoll_wait() that subscribes
 process to death row (new syscall)
Message-ID: <20171102154518.fbd6pb533asd7wfo@dhcp22.suse.cz>
References: <20171101053244.5218-1-slandden@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171101053244.5218-1-slandden@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Landden <slandden@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

[Always cc linux-api mailing list when proposing user visible api
 changes]

On Tue 31-10-17 22:32:44, Shawn Landden wrote:
> It is common for services to be stateless around their main event loop.
> If a process passes the EPOLL_KILLME flag to epoll_wait5() then it
> signals to the kernel that epoll_wait5() may not complete, and the kernel
> may send SIGKILL if resources get tight.
> 
> See my systemd patch: https://github.com/shawnl/systemd/tree/killme
> 
> Android uses this memory model for all programs, and having it in the
> kernel will enable integration with the page cache (not in this
> series).

I have to say I completely hate the idea. You are abusing epoll_wait5
for the out of memory handling? Why is this syscall any special from any
other one which sleeps and waits idle for an event? We do have per task
oom_score_adj for that purposes.

Besides that the patch is simply wrong because

[...]
> @@ -1029,6 +1030,22 @@ bool out_of_memory(struct oom_control *oc)
>  		return true;
>  	}
>  
> +	/*
> +	 * Check death row.
> +	 */
> +	if (!list_empty(eventpoll_deathrow_list())) {
> +		struct list_head *l = eventpoll_deathrow_list();
> +		struct task_struct *ts = list_first_entry(l,
> +					 struct task_struct, se.deathrow);
> +
> +		pr_debug("Killing pid %u from EPOLL_KILLME death row.",
> +			ts->pid);
> +
> +		/* We use SIGKILL so as to cleanly interrupt ep_poll() */
> +		kill_pid(task_pid(ts), SIGKILL, 1);
> +		return true;
> +	}
> +

this doesn't reflect the oom domain (is this memcg, mempolicy/tastset constrained
OOM). You might be killing tasks which are not in the target domain.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
