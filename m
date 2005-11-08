Message-ID: <43703EFB.1010103@yahoo.com.au>
Date: Tue, 08 Nov 2005 17:00:27 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Cleanup of __alloc_pages
References: <20051107174349.A8018@unix-os.sc.intel.com>	<20051107175358.62c484a3.akpm@osdl.org>	<1131416195.20471.31.camel@akash.sc.intel.com>	<43701FC6.5050104@yahoo.com.au> <20051107214420.6d0f6ec4.pj@sgi.com>
In-Reply-To: <20051107214420.6d0f6ec4.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: rohit.seth@intel.com, akpm@osdl.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Nick wrote:
> 
>>The compiler will constant fold this out if it is halfway smart.
> 
> 
> How could that happen - when get_page_from_freelist() is called twice,
> once with skip_cpuset_chk == 0 and once with skip_cpuset_chk == 1?
> 

Because it is on the other side of an &&, which evaulates to a
constant zero when !CONFIG_CPUSETS.

> 
> 
>>+#define ALLOC_WATERMARKS	0x01 /* check watermarks */
>>+#define ALLOC_HARDER		0x02 /* try to alloc harder */
>>+#define ALLOC_HIGH		0x04 /* __GFP_HIGH set */
>>+#define ALLOC_CPUSET		0x08 /* check for correct cpuset */
> 
> 
> Names - bless you.
> 
> If these names were in a header, then calls to zone_watermark_ok()
> from mm/vmscan.c could use them too?
> 
> 
> 
>>+	 * reclaim. Now things get more complex, so st up alloc_flags according
> 
> 
> Typo: s/st/set/
> 
> 
> At first glance, I think you've expressed the cpuset flags correctly.
> Well, correctly maintained their current meaning.  Read on, and you
> will see that I think that is not right.
> 
> I'm just reading the raw patch, so likely I missed something here.
> But it seems to me that zone_watermark_ok() is called from __alloc_pages()
> only if the ALLOC_WATERMARKS flag is set, and it seems that the two
> alloc_flags values ALLOC_HARDER and ALLOC_HIGH are only of use if
> zone_watermark() is called.  So what use is it setting ALLOC_HARDER
> or ALLOC_HIGH if ALLOC_WATERMARKS is not set?  If the get_page_from_freelist()
> check:
> 	if (alloc_flags & ALLOC_WATERMARKS)
> was instead:
> 	if (alloc_flags & ALLOC_WATERMARKS|ALLOC_HARDER|ALLOC_HIGH)
> then this would make more sense to me.  Or changing ALLOC_WATERMARKS
> to ALLOC_EASY, and make it behave similarly to the HARDER & HIGH flags.
> Or maybe if the initialization of alloc_flags:
> 
>>+	alloc_flags = 0;
> 
> was instead:
>   +	alloc_flags = ALLOC_WATERMARKS;
> 

Yep that's a bug. Thanks. Maybe instead we should have a specific
flag for ALLOC_NO_WATERMARKS because that is the unusual case. The
use of the flag there would be a good annotation too.



> The cpuset check in the 'ignoring mins' code shortly after this for the
> PF_MEMALLOC or TIF_MEMDIE cases seems bogus.  This is the case where we
> should be most willing to use memory, regardless of where we find it.
> That cpuset check should be removed.
> 

OK that would be fine, but let's do that (and your suggested possible
consolidation of ALLOC_CPUSET) in another patch?

> My current inclination - check cpusets in the WATERMARKS or HARDER
> or (HIGH && wait) cases, but ignore cpusets in the (HIGH && !wait) or
> 'ignoring mins' cases.  Can "HIGH && wait" even happen ??  Are

Yes there is nothing preventing it.

> allocations either GFP_ATOMIC (aka GFP_HIGH) or (exclusive or)
> GFP_WAIT, never both?  Perhaps GFP_HIGH should be permanently
> deleted (another cleanup) in favor of the more popular and expressive
> GFP_ATOMIC, and __GFP_WAIT retired, in favor of !GFP_ATOMIC.
> 

Having __GFP_HIGH as its own flag gives some more flexibility. I
don't think it has a downside?

> However, I appreciate your preference to separate cleanup from semantic
> change.  Perhaps this means leaving the ALLOC_CPUSET flag in your
> cleanup patch, then one of us following on top of that with a patch to
> simplify and fix the cpuset invocation semantics and a second cleanup
> patch to remove ALLOC_CPUSET as a separate flag.
> 

That would be good. I'll send off a fresh patch with the
ALLOC_WATERMARKS fixed after Rohit gets around to looking over
it.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
