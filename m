Message-ID: <4641DE7D.6000902@yahoo.com.au>
Date: Thu, 10 May 2007 00:45:17 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <4636FDD7.9080401@yahoo.com.au> <Pine.LNX.4.64.0705011931520.16502@blonde.wat.veritas.com> <4638009E.3070408@yahoo.com.au> <Pine.LNX.4.64.0705021418030.16517@blonde.wat.veritas.com> <4641BFCE.6090200@yahoo.com.au> <Pine.LNX.4.64.0705091522110.15345@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0705091522110.15345@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Wed, 9 May 2007, Nick Piggin wrote:
> 
>>Hugh Dickins wrote:
>>
>>>On Wed, 2 May 2007, Nick Piggin wrote:
>>
>>>>>But I'm pretty sure (to use your words!) regular truncate was not racy
>>>>>before: I believe Andrea's sequence count was handling that case fine,
>>>>>without a second unmap_mapping_range.
>>>>
>>>>OK, I think you're right. I _think_ it should also be OK with the
>>>>lock_page version as well: we should not be able to have any pages
>>>>after the first unmap_mapping_range call, because of the i_size
>>>>write. So if we have no pages, there is nothing to 'cow' from.
>>>
>>>I'd be delighted if you can remove those later unmap_mapping_ranges.
>>>As I recall, the important thing for the copy pages is to be holding
>>>the page lock (or whatever other serialization) on the copied page
>>>still while the copy page is inserted into pagetable: that looks
>>>to be so in your __do_fault.
>>
>>Hmm, on second thoughts, I think I was right the first time, and do
>>need the unmap after the pages are truncated. With the lock_page code,
>>after the first unmap, we can get new ptes mapping pages, and
>>subsequently they can be COWed and then the original pte zapped before
>>the truncate loop checks it.
> 
> 
> The filesystem (or page cache) allows pages beyond i_size to come
> in there?  That wasn't a problem before, was it?  But now it is?

The filesystem still doesn't, but if i_size is updated after the page
is returned, we can have a problem that was previously taken care of
with the truncate_count but now isn't.

>>However, I wonder if we can't test mapping_mapped before the spinlock,
>>which would make most truncates cheaper?
> 
> 
> Slightly cheaper, yes, though I doubt it'd be much in comparison with
> actually doing any work in unmap_mapping_range or truncate_inode_pages.

But if we're supposing the common case for truncate is unmapped mappings,
then the main cost there will be the locking, which I'm trying to avoid.
Hopefully with this patch, most truncate workloads would get faster, even
though truncate mapped files is going to be unavoidably slower.


> Suspect you'd need a barrier of some kind between the i_size_write and
> the mapping_mapped test?

The unmap_mapping_range that runs after the truncate_inode_pages should
run in the correct order, I believe.

>  But that's a change we could have made at
> any time if we'd bothered, it's not really the issue here.

I don't see how you could, because you need to increment truncate_count.

But I believe this is fixing the issue, even if it does so in a peripheral
manner, because it avoids the added cost for unmapped files.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
