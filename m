Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4056B04D9
	for <linux-mm@kvack.org>; Wed,  9 May 2018 06:26:59 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b192-v6so6426746wmb.1
        for <linux-mm@kvack.org>; Wed, 09 May 2018 03:26:59 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id c49-v6si23755470wrc.256.2018.05.09.03.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 03:26:58 -0700 (PDT)
Date: Wed, 9 May 2018 12:26:46 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/7] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180509102646.GO12217@hirez.programming.kicks-ass.net>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-7-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180507210135.1823-7-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Mon, May 07, 2018 at 05:01:34PM -0400, Johannes Weiner wrote:
> +static void psi_clock(struct work_struct *work)
> +{

> +	dwork = to_delayed_work(work);
> +	group = container_of(dwork, struct psi_group, clock_work);
> +

> +
> +	/* Keep the clock ticking only when there is action */
> +	if (nonidle_total)
> +		schedule_delayed_work(dwork, MY_LOAD_FREQ);
> +}

Note that this doesn't generate a stable frequency for the callback.
The (nondeterministic) time spend doing the actual work is added to each
period, this gives an unconditional downward bias to the frequency, but
also makes it very unstable.

You want explicit management of timer->expires, and add MY_LOAD_FREQ
(which is a misnomer) to it and not reset it based on jiffies.
