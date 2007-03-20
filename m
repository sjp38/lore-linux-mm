Message-ID: <460017B9.2060002@redhat.com>
Date: Tue, 20 Mar 2007 13:19:53 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] split file and anonymous page queues #2
References: <45FF3052.0@redhat.com> <1174407897.5664.38.camel@localhost>
In-Reply-To: <1174407897.5664.38.camel@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:
> On Mon, 2007-03-19 at 20:52 -0400, Rik van Riel wrote:
>> Split the anonymous and file backed pages out onto their own pageout
>> queues.  This we do not unnecessarily churn through lots of anonymous
>> pages when we do not want to swap them out anyway.
>>
>> This should (with additional tuning) be a great step forward in
>> scalability, allowing Linux to run well on very large systems where
>> scanning through the anonymous memory (on our way to the page cache
>> memory we do want to evict) is slowing systems down significantly.
>>
>> This patch has been stress tested and seems to work, but has not
>> been fine tuned or benchmarked yet.  For now the swappiness parameter
>> can be used to tweak swap aggressiveness up and down as desired, but
>> in the long run we may want to simply measure IO cost of page cache
>> and anonymous memory and auto-adjust.
>>
>> We apply pressure to each of sets of the pageout queues based on:
>> - the size of each queue
>> - the fraction of recently referenced pages in each queue,
>>     not counting used-once file pages
>> - swappiness (file IO is more efficient than swap IO)
>>
>> Please take this patch for a spin and let me know what goes well
>> and what goes wrong.
> 
> Rick:  Which tree is the patch against.  Diffs say 2.6.20.x86_64, but
> doesn't apply to 2.6.20 which doesn't use __inc_zone_state() for things
> like nr_active, nr_inactive, ...

I built it against a recent rawhide kernel, which is 2.6.21-rc3
and a few more days of git changes.

> Also, in the snippet:
> 
>> --- linux-2.6.20.x86_64/mm/swap_state.c.vmsplit 2007-02-04
>> 13:44:54.000000000 -0500
>> +++ linux-2.6.20.x86_64/mm/swap_state.c 2007-03-19 12:00:23.000000000
> -0400
>> @@ -354,7 +354,7 @@ struct page *read_swap_cache_async(swp_e
>>                        /*
>>                         * Initiate read into locked page and return.
>>                         */
>> -                       lru_cache_add_active(new_page);
>> +                       lru_cache_add_anon(new_page);
>>                        swap_readpage(NULL, new_page);
>>                        return new_page;
>>                }
> 
> Should that be lru_cache_add_active_anon()? Or did you intend to add it
> to the inactive anon list?

We have noticed some problems with swapin readahead flushing
the working set from memory due to it reading in potentially
unrelated data.

The reading in of the data isn't a problem, since we do no
extra disk seeks, but we do want unused swap cache to be
flushed out of memory again quickly.

Swap cache pages that do get used will have page table
entries with the referenced bit mapping them, and will
get promoted to the active list quickly.

> Finally, could you [should you?] skip scanning the anon lists--or at
> least the inactive anon list--when nr_swap_pages == 0?  The anon pages
> aren't going anywhere, right?  I think this would obviate Christoph L's
> patch to exclude anon pages from the LRU when there is no swap.  

Yes, that can be added easily.

However, the condition should probably be something like:

"nr_swap_pages == 0 && total_swap_cache_pages < (anon / 20)"

That way we will not stop scanning until we have reclaimed
the swap space that is being pinned (but not used) by the
pages that are also resident.

I suspect that would be a change for a second patch, though.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
