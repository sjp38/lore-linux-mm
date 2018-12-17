Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A10DF8E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 11:37:37 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t72so12298884pfi.21
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 08:37:37 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i4si11756276pfg.218.2018.12.17.08.37.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Dec 2018 08:37:36 -0800 (PST)
Date: Mon, 17 Dec 2018 17:27:13 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/6] psi: introduce psi monitor
Message-ID: <20181217162713.GE2218@hirez.programming.kicks-ass.net>
References: <20181214171508.7791-1-surenb@google.com>
 <20181214171508.7791-7-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214171508.7791-7-surenb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@android.com

On Fri, Dec 14, 2018 at 09:15:08AM -0800, Suren Baghdasaryan wrote:
> @@ -358,28 +526,23 @@ static void psi_update_work(struct work_struct *work)
>  {
>  	struct delayed_work *dwork;
>  	struct psi_group *group;
> +	u64 next_update;
>  
>  	dwork = to_delayed_work(work);
>  	group = container_of(dwork, struct psi_group, clock_work);
>  
>  	/*
> +	 * Periodically fold the per-cpu times and feed samples
> +	 * into the running averages.
>  	 */
>  
> +	psi_update(group);
>  
> +	/* Calculate closest update time */
> +	next_update = min(group->polling_next_update,
> +				group->avg_next_update);
> +	schedule_delayed_work(dwork, min(PSI_FREQ,
> +		nsecs_to_jiffies(next_update - sched_clock()) + 1));

See, so I don't at _all_ like how there is no idle option..

>  }
