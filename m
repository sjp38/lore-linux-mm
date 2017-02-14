Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4DC6B03B1
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:30:43 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id c7so57075963wjb.7
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 08:30:43 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u127si4039404wmg.84.2017.02.14.08.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 08:30:42 -0800 (PST)
Date: Tue, 14 Feb 2017 11:30:05 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] oom_reaper: switch to struct list_head for reap queue
Message-ID: <20170214163005.GA2450@cmpxchg.org>
References: <20170214150714.6195-1-asarai@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170214150714.6195-1-asarai@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aleksa Sarai <asarai@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cyphar@cyphar.com

On Wed, Feb 15, 2017 at 02:07:14AM +1100, Aleksa Sarai wrote:
> Rather than implementing an open addressing linked list structure
> ourselves, use the standard list_head structure to improve consistency
> with the rest of the kernel and reduce confusion.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: Aleksa Sarai <asarai@suse.de>
> ---
>  include/linux/sched.h |  6 +++++-
>  kernel/fork.c         |  4 ++++
>  mm/oom_kill.c         | 24 +++++++++++++-----------
>  3 files changed, 22 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index e93594b88130..d8bcd0f8c5fe 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1960,7 +1960,11 @@ struct task_struct {
>  #endif
>  	int pagefault_disabled;
>  #ifdef CONFIG_MMU
> -	struct task_struct *oom_reaper_list;
> +	/*
> +	 * List of threads that have to be reaped by OOM (rooted at
> +	 * &oom_reaper_list in mm/oom_kill.c).
> +	 */
> +	struct list_head oom_reaper_list;

This is an extra pointer to task_struct and more lines of code to
accomplish the same thing. Why would we want to do that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
