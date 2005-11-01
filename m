Message-ID: <4366C188.5090607@yahoo.com.au>
Date: Tue, 01 Nov 2005 12:14:48 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Clean up of __alloc_pages
References: <20051028183326.A28611@unix-os.sc.intel.com>	 <4362DF80.3060802@yahoo.com.au> <1130792107.4853.24.camel@akash.sc.intel.com>
In-Reply-To: <1130792107.4853.24.camel@akash.sc.intel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rohit.seth@intel.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rohit Seth wrote:
> On Sat, 2005-10-29 at 12:33 +1000, Nick Piggin wrote:

>>If you don't do this, then a GFP_HIGH allocator can allocate right
>>down to its limit before it kicks kswapd, then it either will fail or
>>will have to do direct reclaim.
>>
> 
> 
> You are right if there are only GFP_HIGH requests coming in then the
> allocation will go down to (min - min/2) before kicking in kswapd.
> Though if the requester is not ready to wait, there is another good shot
> at allocation succeed before we get into direct reclaim (and this is
> happening based on can_try_harder flag).
> 

Still, it is a change in behaviour that I would rather not introduce
with a cleanup patch (and is something we don't want to introduce anyway).

So if you could fix that up it would be good.

>>How about moving the zone_statistics up into the 'if (page)'
>>test of get_page_from_freelist? This way we don't have to
>>evaluate page_zone().
>>
> 
> 
> Let us keep this as is for now.  Will revisit once after the
> pcp_prefer_allocation patches get in place. 
> 

Well page_zone is yet another cacheline that doesn't need to be touched,
and that is introduced by this patch. But the line is likely to be hot,
and get_page_from_freelist does not have the required 'zonelist' which
I didn't notice before.

So OK, revisit this later.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
