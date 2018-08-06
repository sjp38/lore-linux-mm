Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E627D6B0003
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 12:03:40 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d22-v6so8864105pfn.3
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 09:03:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h71-v6si12923274pge.13.2018.08.06.09.03.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 Aug 2018 09:03:39 -0700 (PDT)
Date: Mon, 6 Aug 2018 18:03:29 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180806160329.GP2494@hirez.programming.kicks-ass.net>
References: <20180801151958.32590-1-hannes@cmpxchg.org>
 <20180801151958.32590-9-hannes@cmpxchg.org>
 <20180803165641.GA2476@hirez.programming.kicks-ass.net>
 <20180806151928.GB9888@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180806151928.GB9888@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, Peter Enderborg <peter.enderborg@sony.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Aug 06, 2018 at 11:19:28AM -0400, Johannes Weiner wrote:
> On Fri, Aug 03, 2018 at 06:56:41PM +0200, Peter Zijlstra wrote:
> > On Wed, Aug 01, 2018 at 11:19:57AM -0400, Johannes Weiner wrote:

> > > +		u32 uninitialized_var(nonidle);
> > 
> > urgh.. I can see why the compiler got confused. Dodgy :-)
> 
> :-) I think we can make this cleaner. Something like this (modulo the
> READ_ONCE/WRITE_ONCE you pointed out in the other email)?
> 

> @@ -244,60 +287,17 @@ static bool psi_update_stats(struct psi_group *group)
>  	 */
>  	for_each_online_cpu(cpu) {
>  		struct psi_group_cpu *groupc = per_cpu_ptr(group->pcpu, cpu);
> +		u32 nonidle;
> +
> +		nonidle = read_update_delta(groupc, PSI_NONIDLE, cpu);
> +		nonidle = nsecs_to_jiffies(nonidle);
> +		nonidle_total += nonidle;
> +
> +		for (s = 0; s < PSI_NONIDLE; s++) {
> +			u32 delta;
> +
> +			delta = read_update_delta(groupc, s, cpu);
> +			deltas[s] += (u64)delta * nonidle;
>  		}
>  	}

Yes, much clearer, thanks!
