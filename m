Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB8326B0291
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 10:22:10 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b9-v6so506235pgq.17
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 07:22:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e11-v6si1078812pga.150.2018.07.17.07.22.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Jul 2018 07:22:09 -0700 (PDT)
Date: Tue, 17 Jul 2018 16:21:57 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180717142157.GF2494@hirez.programming.kicks-ass.net>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712172942.10094-9-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:
> diff --git a/include/linux/sched/stat.h b/include/linux/sched/stat.h
> index 04f1321d14c4..ac39435d1521 100644
> --- a/include/linux/sched/stat.h
> +++ b/include/linux/sched/stat.h
> @@ -28,10 +28,14 @@ static inline int sched_info_on(void)
>  	return 1;
>  #elif defined(CONFIG_TASK_DELAY_ACCT)
>  	extern int delayacct_on;
> +	if (delayacct_on)
> +		return 1;
> +#elif defined(CONFIG_PSI)
> +	extern int psi_disabled;
> +	if (!psi_disabled)
> +		return 1;
>  #endif
> +	return 0;
>  }

Doesn't that want to be something like:

static inline bool sched_info_on(void)
{
#ifdef CONFIG_SCHEDSTAT
	return true;
#else /* !SCHEDSTAT */
#ifdef CONFIG_TASK_DELAY_ACCT
	extern int delayacct_on;
	if (delayacct_on)
		return true;
#endif /* DELAYACCT */
#ifdef CONFIG_PSI
	extern int psi_disabled;
	if (!psi_disabled)
		return true;
#endif
	return false;
#endif /* !SCHEDSTATE */
}

Such that if you build a TASK_DELAY_ACCT && PSI kernel, and boot with
nodelayacct, you still get sched_info_on().
