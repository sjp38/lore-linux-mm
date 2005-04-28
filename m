Message-ID: <4270C606.8040000@yahoo.com.au>
Date: Thu, 28 Apr 2005 21:16:22 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 0/4] VM: Manual and Automatic page cache reclaim
References: <20050427150848.GR8018@localhost> <20050427233335.492d0b6f.akpm@osdl.org>
In-Reply-To: <20050427233335.492d0b6f.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Martin Hicks <mort@sgi.com>, linux-mm@kvack.org, raybry@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Martin Hicks <mort@sgi.com> wrote:
> 
>>The patches introduce two different ways to free up page cache from a
>> node: manually through a syscall and automatically through flag
>> modifiers to a mempolicy.
> 
> 
> Backing up and thinking about this a bit more....
> 
> 
>> Currently if a job is started and there is page cache lying around on a
>> particular node then allocations will spill onto remote nodes and page
>> cache won't be reclaimed until the whole system is short on memory.
>> This can result in a signficiant performance hit for HPC applications
>> that planned on that memory being allocated locally.
> 
> 
> Why do it this way at all?
> 
> Is it not possible to change the page allocator's zone fallback mechanism
> so that once the local node's zones' pages are all allocated, we don't
> simply advance onto the next node?  Instead, could we not perform a bit of
> reclaim on this node's zones first?  Only advance onto the next nodes if
> things aren't working out?

Yeah. I got a patch that does this. It is quite possible - you have
to make some balance so you don't go to shit on workloads that have
a working set larger than a single node's memory, but...

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
