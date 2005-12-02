Message-ID: <438F961B.6060709@yahoo.com.au>
Date: Fri, 02 Dec 2005 11:32:27 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Free pages from local pcp lists under tight memory conditions
References: <20051122161000.A22430@unix-os.sc.intel.com>	<Pine.LNX.4.62.0511231128090.22710@schroedinger.engr.sgi.com>	<1132775194.25086.54.camel@akash.sc.intel.com>	<20051123115545.69087adf.akpm@osdl.org>	<1132779605.25086.69.camel@akash.sc.intel.com>	<20051123190237.3ba62bf0.pj@sgi.com>	<1133306336.24962.47.camel@akash.sc.intel.com> <20051201064446.c87049ad.pj@sgi.com>
In-Reply-To: <20051201064446.c87049ad.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Rohit Seth <rohit.seth@intel.com>, akpm@osdl.org, clameter@engr.sgi.com, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Rohit wrote:
> 
>>Can you please comment on the performance delta on the MPI workload
>>because of this change in batch values. 
> 
> 
> I can't -- all I know is what I read in Jack Steiner's posts
> of April 5, 2005, referenced earlier in this thread.
> 

It was something fairly large. Basically having a power of 2 batch size
meant that 2 concurrent allocators (presumably setting up the working
area) would alternately pull in power of 2 chunks of memory, which
caused each CPU to only get pages of ~half of its cache's possible
colours.

The fix is not by any means a single value for all workloads, it simply
avoids powers of 2 batch size. Note this will have very little effect
on single threaded allocators and will do nothing for cache colouring
there, however it is important for concurrent allocators.

Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
