Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA7B6B0253
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 05:09:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 76so2238784pfr.3
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 02:09:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t184si5957175pfd.381.2017.11.03.02.09.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 02:09:18 -0700 (PDT)
Date: Fri, 3 Nov 2017 10:09:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v2] prctl: prctl(PR_SET_IDLE, PR_IDLE_MODE_KILLME), for
 stateless idle loops
Message-ID: <20171103090915.uuaqo56phdbt6gnf@dhcp22.suse.cz>
References: <20171101053244.5218-1-slandden@gmail.com>
 <20171103063544.13383-1-slandden@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171103063544.13383-1-slandden@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Landden <slandden@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Thu 02-11-17 23:35:44, Shawn Landden wrote:
> It is common for services to be stateless around their main event loop.
> If a process sets PR_SET_IDLE to PR_IDLE_MODE_KILLME then it
> signals to the kernel that epoll_wait() and friends may not complete,
> and the kernel may send SIGKILL if resources get tight.
> 
> See my systemd patch: https://github.com/shawnl/systemd/tree/prctl
> 
> Android uses this memory model for all programs, and having it in the
> kernel will enable integration with the page cache (not in this
> series).
> 
> 16 bytes per process is kinda spendy, but I want to keep
> lru behavior, which mem_score_adj does not allow. When a supervisor,
> like Android's user input is keeping track this can be done in user-space.
> It could be pulled out of task_struct if an cross-indexing additional
> red-black tree is added to support pid-based lookup.

This is still an abuse and the patch is wrong. We really do have an API
to use I fail to see why you do not use it.

[...]
> @@ -1018,6 +1060,24 @@ bool out_of_memory(struct oom_control *oc)
>  			return true;
>  	}
>  
> +	/*
> +	 * Check death row for current memcg or global.
> +	 */
> +	l = oom_target_get_queue(current);
> +	if (!list_empty(l)) {
> +		struct task_struct *ts = list_first_entry(l,
> +				struct task_struct, se.oom_target_queue);
> +
> +		pr_debug("Killing pid %u from EPOLL_KILLME death row.",
> +			 ts->pid);
> +
> +		/* We use SIGKILL instead of the oom killer
> +		 * so as to cleanly interrupt ep_poll()
> +		 */
> +		send_sig(SIGKILL, ts, 1);
> +		return true;
> +	}

Still not NUMA aware and completely backwards. If this is a memcg OOM
then it is _memcg_ to evaluate not the current. The oom might happen up
the hierarchy due to hard limit.

But still, you should be very clear _why_ the existing oom tuning is not
appropropriate and we can think of a way to hanle it better but cramming
the oom selection this way is simply not acceptable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
