Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE6BA6B0069
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 18:10:37 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u27so3748341pgn.3
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 15:10:37 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m66si2024290pfg.114.2017.11.01.15.10.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 15:10:36 -0700 (PDT)
Subject: Re: [RFC] EPOLL_KILLME: New flag to epoll_wait() that subscribes
 process to death row (new syscall)
References: <20171101053244.5218-1-slandden@gmail.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <b98ae797-ce25-79bd-e405-35565256f673@I-love.SAKURA.ne.jp>
Date: Thu, 2 Nov 2017 07:10:24 +0900
MIME-Version: 1.0
In-Reply-To: <20171101053244.5218-1-slandden@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Landden <slandden@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 2017/11/01 14:32, Shawn Landden wrote:
> @@ -1029,6 +1030,22 @@ bool out_of_memory(struct oom_control *oc)
>  		return true;
>  	}
>  
> +	/*
> +	 * Check death row.
> +	 */
> +	if (!list_empty(eventpoll_deathrow_list())) {
> +		struct list_head *l = eventpoll_deathrow_list();

Unsafe traversal. List can become empty at this moment.

> +		struct task_struct *ts = list_first_entry(l,
> +					 struct task_struct, se.deathrow);
> +
> +		pr_debug("Killing pid %u from EPOLL_KILLME death row.",
> +			ts->pid);
> +
> +		/* We use SIGKILL so as to cleanly interrupt ep_poll() */
> +		kill_pid(task_pid(ts), SIGKILL, 1);

send_sig() ?

> +		return true;
> +	}
> +
>  	/*
>  	 * The OOM killer does not compensate for IO-less reclaim.
>  	 * pagefault_out_of_memory lost its gfp context so we have to
> 

And why is

  static int oom_fd = open("/proc/self/oom_score_adj", O_WRONLY);

and then toggling between

  write(fd, "1000", 4);

and

  write(fd, "0", 1);

not sufficient? Adding prctl() that do this might be handy though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
