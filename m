Message-ID: <433F4F67.4090800@yahoo.com.au>
Date: Sun, 02 Oct 2005 13:09:27 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Clean up of __alloc_pages
References: <20051001120023.A10250@unix-os.sc.intel.com>
In-Reply-To: <20051001120023.A10250@unix-os.sc.intel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Seth, Rohit" <rohit.seth@intel.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Seth, Rohit wrote:
> 	[PATCH]: Below is the cleaning up of __alloc_pages code.  Few 
> 		 things different from original version are
> 
> 	1: remove the initial direct reclaim logic 
> 	2: order zero pages are now first looked into pcp list upfront
> 	3: GFP_HIGH pages are allowed to go little below low watermark sooner
> 	4: Search for free pages unconditionally after direct reclaim
> 
> 	Signed-off-by: Rohit Seth <rohit.seth@intel.com>
> 

Hi,

Seems pretty good at a quick glance.

Perhaps splitting it into 2 would be a good idea - ie. first
patch does the cleanup, second does the direct pcp list alloc.

Regarding the direct pcp list allocation - I think it is a good
idea, because we're currently already accounting pcp list pages
as being 'allocated' for the purposes of the reclaim watermarks.

Also, the structure is there to avoid touching cachelines whenever
possible so it makes sense to use it early here. Do you have any
performance numbers or allocation statistics (e.g. %pcp hits) to
show?

Also, I would really think about uninlining get_page_from_freelist,
and inlining buffered_rmqueue, so that the constant 'replenish'
argument can be propogated into buffered_rmqueue and should allow
for some nice optimisations. While not bloating the code too much
because your get_page_from_freelist becomes out of line.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
