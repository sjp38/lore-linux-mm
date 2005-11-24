Date: Wed, 23 Nov 2005 19:02:37 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH]: Free pages from local pcp lists under tight memory
 conditions
Message-Id: <20051123190237.3ba62bf0.pj@sgi.com>
In-Reply-To: <1132779605.25086.69.camel@akash.sc.intel.com>
References: <20051122161000.A22430@unix-os.sc.intel.com>
	<Pine.LNX.4.62.0511231128090.22710@schroedinger.engr.sgi.com>
	<1132775194.25086.54.camel@akash.sc.intel.com>
	<20051123115545.69087adf.akpm@osdl.org>
	<1132779605.25086.69.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rohit.seth@intel.com>
Cc: akpm@osdl.org, clameter@engr.sgi.com, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, steiner@sgi.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Rohit wrote:
> I thought Nick et.al came up with some of the constant values like batch
> size to tackle the page coloring issue specifically. 

I think this came about on a linux-ia64 thread started by Jack Steiner:

  http://www.gelato.unsw.edu.au/archives/linux-ia64/0504/13668.html
  Subject: per_cpu_pagesets degrades MPI performance
  From: Jack Steiner <steiner_at_sgi.com>
  Date: 2005-04-05 05:28:27

Jack reported that per_cpu_pagesets were degrading some MPI benchmarks due
to adverse page coloring.  Nick responded, recommending a non-power of two
batch size.  Jack found that this helped nicely.  This thread trails off,
but seems to be the origins of the 2**n-1 batch size in:

	mm/page_alloc.c:zone_batchsize()
	 * Clamp the batch to a 2^n - 1 value. Having a power ...
        batch = (1 << fls(batch + batch/2)) - 1;

I don't see here evidence that "per_cpu_pagelist is ... one single main
reason the coloring effect is drastically reduced in 2.6 (over 2.4)
based kernels."  Rather in this case anyway a batch size not a power of
two was apparently needed to keep per_cpu_pagesets from hurting
performance due to page coloring affects on some workloads.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
