Message-ID: <43BF2D03.2030908@yahoo.com.au>
Date: Sat, 07 Jan 2006 13:52:51 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] use local_t for page statistics
References: <20060106215332.GH8979@kvack.org> <20060106163313.38c08e37.akpm@osdl.org>
In-Reply-To: <20060106163313.38c08e37.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Benjamin LaHaise <bcrl@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Benjamin LaHaise <bcrl@kvack.org> wrote:
> 
>>The patch below converts the mm page_states counters to use local_t.  
>>mod_page_state shows up in a few profiles on x86 and x86-64 due to the 
>>disable/enable interrupts operations touching the flags register.  On 
>>both my laptop (Pentium M) and P4 test box this results in about 10 
>>additional /bin/bash -c exit 0 executions per second (P4 went from ~759/s 
>>to ~771/s).  Tested on x86 and x86-64.  Oh, also add a pgcow statistic 
>>for the number of COW page faults.
> 
> 
> Bah.  I think this is a better approach than the just-merged
> mm-page_state-opt.patch, so I should revert that patch first?
> 

No. On many load/store architectures there is no good way to do local_t,
so something like ppc32 or ia64 just uses all atomic operations for
local_t, and ppc64 uses 3 counters per-cpu thus tripling the cache
footprint.

Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
