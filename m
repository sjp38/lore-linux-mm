Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D7D3D8E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 10:55:36 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 12so9412318plb.18
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 07:55:36 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e13si10928147pgh.251.2018.12.17.07.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Dec 2018 07:55:35 -0800 (PST)
Date: Mon, 17 Dec 2018 16:55:25 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 4/6] psi: introduce state_mask to represent stalled psi
 states
Message-ID: <20181217155525.GC2218@hirez.programming.kicks-ass.net>
References: <20181214171508.7791-1-surenb@google.com>
 <20181214171508.7791-5-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214171508.7791-5-surenb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@android.com

On Fri, Dec 14, 2018 at 09:15:06AM -0800, Suren Baghdasaryan wrote:
> The psi monitoring patches will need to determine the same states as
> record_times(). To avoid calculating them twice, maintain a state mask
> that can be consulted cheaply. Do this in a separate patch to keep the
> churn in the main feature patch at a minimum.
> 
> Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> ---
>  include/linux/psi_types.h |  3 +++
>  kernel/sched/psi.c        | 29 +++++++++++++++++++----------
>  2 files changed, 22 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/psi_types.h b/include/linux/psi_types.h
> index 2cf422db5d18..2c6e9b67b7eb 100644
> --- a/include/linux/psi_types.h
> +++ b/include/linux/psi_types.h
> @@ -53,6 +53,9 @@ struct psi_group_cpu {
>  	/* States of the tasks belonging to this group */
>  	unsigned int tasks[NR_PSI_TASK_COUNTS];
>  
> +	/* Aggregate pressure state derived from the tasks */
> +	u32 state_mask;
> +
>  	/* Period time sampling buckets for each state of interest (ns) */
>  	u32 times[NR_PSI_STATES];
>  

Since we spend so much time counting space in that line, maybe add a
note to the Changlog about how this fits.

Also, since I just had to re-count, you might want to add explicit
numbers to the psi_res and psi_states enums.

> +		if (state_mask & (1 << s))

We have the BIT() macro, but I'm honestly not sure that will improve
things.
