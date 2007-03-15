Date: Thu, 15 Mar 2007 01:22:45 -0400 (EDT)
From: Ashif Harji <asharji@cs.uwaterloo.ca>
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
In-Reply-To: <45F8A301.90301@cse.ohio-state.edu>
Message-ID: <Pine.GSO.4.64.0703150045550.18191@cpu102.cs.uwaterloo.ca>
References: <Pine.GSO.4.64.0703081612290.1080@cpu102.cs.uwaterloo.ca>
 <20070312142012.GH30777@atrey.karlin.mff.cuni.cz>  <20070312143900.GB6016@wotan.suse.de>
 <20070312151355.GB23532@duck.suse.cz>  <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca>
  <20070312173500.GF23532@duck.suse.cz>  <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca>
  <20070313185554.GA5105@duck.suse.cz>  <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca>
  <1173905741.8763.36.camel@kleikamp.austin.ibm.com>
 <20070314213317.GA22234@rhlx01.hs-esslingen.de> <1173910138.8763.45.camel@kleikamp.austin.ibm.com>
 <45F8A301.90301@cse.ohio-state.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Xiaoning Ding <dingxn@cse.ohio-state.edu>
Cc: Dave Kleikamp <shaggy@linux.vnet.ibm.com>, Andreas Mohr <andi@rhlx01.fht-esslingen.de>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>


On Wed, 14 Mar 2007, Xiaoning Ding wrote:

> Dave Kleikamp wrote:
>> On Wed, 2007-03-14 at 22:33 +0100, Andreas Mohr wrote:
>>> Hi,
>>> 
>>> On Wed, Mar 14, 2007 at 03:55:41PM -0500, Dave Kleikamp wrote:
>>>> On Wed, 2007-03-14 at 15:58 -0400, Ashif Harji wrote:
>>>>> This patch unconditionally calls mark_page_accessed to prevent pages, 
>>>>> especially for small files, from being evicted from the page cache 
>>>>> despite frequent access.
>>>> I guess the downside to this is if a reader is reading a large file, or
>>>> several files, sequentially with a small read size (smaller than
>>>> PAGE_SIZE), the pages will be marked active after just one read pass.
>>>> My gut says the benefits of this patch outweigh the cost.  I would
>>>> expect real-world backup apps, etc. to read at least PAGE_SIZE.
>>> I also think that the patch is somewhat problematic, since the original
>>> intention seems to have been a reduction of the number of (expensive?)
>>> mark_page_accessed() calls,
>> 
>> mark_page_accessed() isn't expensive.  If called repeatedly, starting
>> with the third call, it will check two page flags and return.  The only
>> real expense is that the page appears busier than it may be and will be
>> retained in memory longer than it should.
>> 
> If we allow mark_page_accessed() called multiple times for a single page,
> a scan of large file with small-size reads would flush the buffer cache.
> mark_page_accessed() also requests lru_lock when moving page from
> inactive_list to active_list. It may also increase lock contention.

The problem with the existing logic is that it is too coarse.  In trying 
to deal with one usage pattern it is negatively impacting performance for 
other reasonable access patterns.

Further, consider the extreme case of scanning a file 1 byte at a time. 
In this case, you are going to access a page over 4000 times, but that 
page is not going to be marked as active and hence that page is likely to 
be evicted from the cache.  Clearly, there are cases when scanning a file 
that you would like the pages to be kept in the cache.

Finally, the existing code is problematic as there is no reasonable way to 
circumvent the negative impact for small files.

Hence, I think a change is necessary.  The question is whether the 
intent of conditionally calling mark_page_accessed() is still reasonable 
and whether the amount of bookkeeping required to detect that usage 
pattern but not create a problem for other usage patterns is reasonable.

I would tend to agree with David that:  "Any application doing many 
tiny-sized reads isn't exactly asking for great performance."  As well, 
applications concerned with performance and caching problems can read in a 
file in PAGE_SIZE chunks.  I still think the simple fix of removing the 
condition is the best approach, but I'm certainly open to alternatives.

ashif.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
