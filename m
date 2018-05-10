Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE7966B0609
	for <linux-mm@kvack.org>; Thu, 10 May 2018 09:44:46 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id d4-v6so1439121wrn.15
        for <linux-mm@kvack.org>; Thu, 10 May 2018 06:44:46 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e5-v6si1173853edj.23.2018.05.10.06.44.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 May 2018 06:44:45 -0700 (PDT)
Date: Thu, 10 May 2018 09:46:36 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/7] sched: loadavg: make calc_load_n() public
Message-ID: <20180510134636.GB19348@cmpxchg.org>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-6-hannes@cmpxchg.org>
 <20180509094906.GI12217@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509094906.GI12217@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Wed, May 09, 2018 at 11:49:06AM +0200, Peter Zijlstra wrote:
> On Mon, May 07, 2018 at 05:01:33PM -0400, Johannes Weiner wrote:
> > +static inline unsigned long
> > +fixed_power_int(unsigned long x, unsigned int frac_bits, unsigned int n)
> > +{
> > +	unsigned long result = 1UL << frac_bits;
> > +
> > +	if (n) {
> > +		for (;;) {
> > +			if (n & 1) {
> > +				result *= x;
> > +				result += 1UL << (frac_bits - 1);
> > +				result >>= frac_bits;
> > +			}
> > +			n >>= 1;
> > +			if (!n)
> > +				break;
> > +			x *= x;
> > +			x += 1UL << (frac_bits - 1);
> > +			x >>= frac_bits;
> > +		}
> > +	}
> > +
> > +	return result;
> > +}
> 
> No real objection; but that does look a wee bit fat for an inline I
> suppose.

Fair enough, I'll put these back where I found them and make
calc_load_n() extern instead.
