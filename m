From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH resend] ramdisk: fix zeroed ramdisk pages on memory pressure
References: <200710151028.34407.borntraeger@de.ibm.com>
	<200710160123.32434.nickpiggin@yahoo.com.au>
	<m1zlyjiwdc.fsf@ebiederm.dsl.xmission.com>
	<200710161645.58686.nickpiggin@yahoo.com.au>
Date: Mon, 15 Oct 2007 22:57:14 -0600
In-Reply-To: <200710161645.58686.nickpiggin@yahoo.com.au> (Nick Piggin's
	message of "Tue, 16 Oct 2007 16:45:58 +1000")
Message-ID: <m1abqjirmd.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

>>
>> make_page_uptodate() is most hideous part I have run into.
>> It has to know details about other layers to now what not
>> to stomp.  I think my incorrect simplification of this is what messed
>> things up, last round.
>
> Not really, it's just named funny. That's just a minor utility
> function that more or less does what it says it should do.
>
> The main problem is really that it's implementing a block device
> who's data comes from its own buffercache :P. I think.

Well to put it another way, mark_page_uptodate() is the only
place where we really need to know about the upper layers.
Given that you can kill ramdisks by coding it as:

static void make_page_uptodate(struct page *page)
{
	clear_highpage(page);
	flush_dcache_page(page);
	SetPageUptodate(page);
}

Something is seriously non-intuitive about that function if
you understand the usual rules for how to use the page cache.

The problem is that we support a case in the buffer cache
where pages are partially uptodate and only the buffer_heads
remember which parts are valid.  Assuming we are using them
correctly.

Having to walk through all of the buffer heads in make_page_uptodate
seems to me to be a nasty layering violation in rd.c

>> > I guess it's not nice
>> > for operating on the pagecache from its request_fn, but the
>> > alternative is to duplicate pages for backing store and buffer
>> > cache (actually that might not be a bad alternative really).
>>
>> Cool. Triple buffering :)  Although I guess that would only
>> apply to metadata these days.
>
> Double buffering. You no longer serve data out of your buffer
> cache.  All filesystem data was already double buffered anyway,
> so we'd be just losing out on one layer of savings for metadata.

Yep we are in agreement there.

> I think it's worthwhile, given that we'd have a "real" looking
> block device and minus these bugs.

For testing purposes I think I can agree with that.

>> Having a separate store would 
>> solve some of the problems, and probably remove the need
>> for carefully specifying the ramdisk block size.  We would
>> still need the magic restictions on page allocations though
>> and it we would use them more often as the initial write to the
>> ramdisk would not populate the pages we need.
>
> What magic restrictions on page allocations? Actually we have
> fewer restrictions on page allocations because we can use
> highmem! 

With the proposed rewrite yes.

> And the lowmem buffercache pages that we currently pin
> (unsuccessfully, in the case of this bug) are now completely
> reclaimable. And all your buffer heads are now reclaimable.

Hmm.  Good point.  So in net it should save memory even if
it consumes a little more in the worst case.


> If you mean GFP_NOIO... I don't see any problem. Block device
> drivers have to allocate memory with GFP_NOIO; this may have
> been considered magic or deep badness back when the code was
> written, but it's pretty simple and accepted now.

Well I always figured it was a bit rude allocating large amounts
of memory GFP_NOIO but whatever.

>> A very ugly bit seems to be the fact that we assume we can
>> dereference bh->b_data without any special magic which
>> means the ramdisk must live in low memory on 32bit machines.
>
> Yeah but that's not rd.c. You need to rewrite the buffer layer
> to fix that (see fsblock ;)).

I'm not certain which way we should go.  Take fsblock and run it
in parallel until everything is converted or use fsblock as a
prototype and once we have figured out which way we should go
convert struct buffer_head into struct fsblock one patch at a time.

I'm inclined to think we should evolve the buffer_head.

Eric





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
