Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 30B726B0384
	for <linux-mm@kvack.org>; Wed,  9 May 2018 05:49:25 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s17-v6so5519858pgq.23
        for <linux-mm@kvack.org>; Wed, 09 May 2018 02:49:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 5-v6si25326539plx.148.2018.05.09.02.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 02:49:22 -0700 (PDT)
Date: Wed, 9 May 2018 11:49:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 5/7] sched: loadavg: make calc_load_n() public
Message-ID: <20180509094906.GI12217@hirez.programming.kicks-ass.net>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-6-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180507210135.1823-6-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Mon, May 07, 2018 at 05:01:33PM -0400, Johannes Weiner wrote:
> +static inline unsigned long
> +fixed_power_int(unsigned long x, unsigned int frac_bits, unsigned int n)
> +{
> +	unsigned long result = 1UL << frac_bits;
> +
> +	if (n) {
> +		for (;;) {
> +			if (n & 1) {
> +				result *= x;
> +				result += 1UL << (frac_bits - 1);
> +				result >>= frac_bits;
> +			}
> +			n >>= 1;
> +			if (!n)
> +				break;
> +			x *= x;
> +			x += 1UL << (frac_bits - 1);
> +			x >>= frac_bits;
> +		}
> +	}
> +
> +	return result;
> +}

No real objection; but that does look a wee bit fat for an inline I
suppose.
