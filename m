Message-ID: <46424A27.2030103@yahoo.com.au>
Date: Thu, 10 May 2007 08:24:39 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <4636FDD7.9080401@yahoo.com.au> <Pine.LNX.4.64.0705011931520.16502@blonde.wat.veritas.com> <4638009E.3070408@yahoo.com.au> <Pine.LNX.4.64.0705021418030.16517@blonde.wat.veritas.com> <4641BFCE.6090200@yahoo.com.au> <Pine.LNX.4.64.0705091522110.15345@blonde.wat.veritas.com> <4641DE7D.6000902@yahoo.com.au> <Pine.LNX.4.64.0705091612100.18822@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0705091612100.18822@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Thu, 10 May 2007, Nick Piggin wrote:
> 
>>>The filesystem (or page cache) allows pages beyond i_size to come
>>>in there?  That wasn't a problem before, was it?  But now it is?
>>
>>The filesystem still doesn't, but if i_size is updated after the page
>>is returned, we can have a problem that was previously taken care of
>>with the truncate_count but now isn't.
> 
> 
> But... I thought the page lock was now taking care of that in your
> scheme?  truncate_inode_pages has to wait for the page lock, then
> it finds the page is mapped and... ahh, it finds the copiee page
> is not mapped, so doesn't do its own little unmap_mapping_range,
> and the copied page squeaks through.  Drat.
> 
> I really think the truncate_count solution worked better, for
> truncation anyway.  There may be persuasive reasons you need the
> page lock for invalidation: I gave up on trying to understand the
> required behaviour(s) for invalidation.
> 
> So, bring back (the original use of, not my tree marker use of)
> truncate_count?  Hmm, you probably don't want to do that, because
> there was some pleasure in removing the strange barriers associated
> with it.
> 
> A second unmap_mapping_range is just one line of code - but it sure
> feels like a defeat to me, calling the whole exercise into question.
> (But then, you'd be right to say my perfectionism made it impossible
> for me to come up with any solution to the invalidation issues.)

Well we could bring back the truncate_count, but I think that sucks
because that's moving work into the page fault handler in order to
avoid a bit of work when truncating mapped files.


>>>But that's a change we could have made at
>>>any time if we'd bothered, it's not really the issue here.
>>
>>I don't see how you could, because you need to increment truncate_count.
> 
> 
> Though indeed we did so, I don't see that we needed to increment
> truncate_count in that case (nobody could be coming through
> do_no_page on that file, when there are no mappings of it).

Of course :P

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
