From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch][rfc] rewrite ramdisk
References: <200710151028.34407.borntraeger@de.ibm.com>
	<200710161747.12968.nickpiggin@yahoo.com.au>
	<m16416f2y8.fsf@ebiederm.dsl.xmission.com>
	<200710172249.13877.nickpiggin@yahoo.com.au>
Date: Wed, 17 Oct 2007 12:45:51 -0600
In-Reply-To: <200710172249.13877.nickpiggin@yahoo.com.au> (Nick Piggin's
	message of "Wed, 17 Oct 2007 22:49:13 +1000")
Message-ID: <m1k5pleg0w.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

> On Wednesday 17 October 2007 20:30, Eric W. Biederman wrote:
>> Nick Piggin <nickpiggin@yahoo.com.au> writes:
>> > On Tuesday 16 October 2007 18:08, Nick Piggin wrote:
>> >> On Tuesday 16 October 2007 14:57, Eric W. Biederman wrote:
>> >> > > What magic restrictions on page allocations? Actually we have
>> >> > > fewer restrictions on page allocations because we can use
>> >> > > highmem!
>> >> >
>> >> > With the proposed rewrite yes.
>> >
>> > Here's a quick first hack...
>> >
>> > Comments?
>>
>> I have beaten my version of this into working shape, and things
>> seem ok.
>>
>> However I'm beginning to think that the real solution is to remove
>> the dependence on buffer heads for caching the disk mapping for
>> data pages, and move the metadata buffer heads off of the block
>> device page cache pages.  Although I am just a touch concerned
>> there may be an issue with using filesystem tools while the
>> filesystem is mounted if I move the metadata buffer heads.
>>
>> If we were to move the metadata buffer heads (assuming I haven't
>> missed some weird dependency) then I think there a bunch of
>> weird corner cases that would be simplified.
>
> I'd prefer just to go along the lines of what I posted. It's
> a pure block device driver which knows absolutely nothing about
> vm or vfs.
>
> What are you guys using rd for, and is it really important to
> have this supposed buffercache optimisation?

Well what brought this up for me was old user space code using
an initial ramdisk.  The actual failure that I saw occurred on
the read path.  And fixing init_page_buffers was the real world
fix. 

At the moment I'm messing with it because it has become the
itch I've decided to scratch.  So at the moment I'm having fun,
learning the block layer, refreshing my VM knowledge and getting my
head around this wreck that we call buffer_heads.  The high level
concept of buffer_heads may be sane but the implementation seems to
export a lot of nasty state.

At this point my concern is what makes a clean code change in the
kernel.  Because user space can currently play with buffer_heads
by way of the block device and cause lots of havoc (see the recent
resierfs bug in this thread) that is why I increasingly think
metadata buffer_heads should not share storage with the block
device page cache.

If that change is made then it happens that the current ramdisk
would not need to worry about buffer heads and all of that
nastiness and could just lock pages in the page cache.  It would not
be quite as good for testing filesystems but retaining the existing
characteristics would be simple.

After having looked a bit deeper the buffer_heads and the block
devices don't look as intricately tied up as I had first thought.
We still have the nasty case of:
	if (buffer_new(bh))
		unmap_underlying_metadata(bh->b_bdev, bh->b_blocknr);
That I don't know how it got merged.  But otherwise the caches
are fully separate.

So currently it looks to me like there are two big things that will
clean up that part of the code a lot:
- moving the metadata buffer_heads to a magic filesystem inode.
- Using a simpler non-buffer_head returning version of get_block
  so we can make simple generic code for generating BIOs.


>> I guess that is where I look next.
>>
>> Oh for what it is worth I took a quick look at fsblock and I don't think
>> struct fsblock makes much sense as a block mapping translation layer for
>> the data path where the current page caches works well.
>
> Except the page cache doesn't store any such translation. fsblock
> works very nicely as a buffer_head and nobh-mode replacement there,
> but we could probably go one better (for many filesystems) by using
> a tree.
>
>> For less 
>> then the cost of 1 fsblock I can cache all of the translations for a
>> 1K filesystem on a 4K page.
>
> I'm not exactly sure what you mean, unless you're talking about an
> extent based data structure. fsblock is fairly slim as far as a
> generic solution goes. You could probably save 4 or 8 bytes in it,
> but I don't know if it's worth the trouble.

As a meta_data cache manager perhaps, for a translation cache we need
8 bytes per page max.

However all we need for a generic translation cache (assuming we still
want one) is an array of sector_t per page.

So what we would want is:
int blkbits_per_page = PAGE_CACHE_SHIFT - inode->i_blkbits;
if (blkbits_per_page <= 0)
	blkbits_per_page = 0;
sector_t *blocks = kmalloc(sizeof(sector_t) << blkbits_per_page);

And to remember if we have stored the translation:
#define UNMAPPED_SECTOR (-1(sector_t))

... 

The core of all of this being something like:
#define MAX_BLOCKS_PER_PAGE (1 << (PAGE_CACHE_SHIFT - 9))
typedef int (page_blocks_t)(struct page *page,
			    sector_t blocks[MAX_BLOCKS_PER_PAGE],
			    int create);


>> I haven't looked to see if fsblock makes sense to use as a buffer head
>> replacement yet.
>
> Well I don't want to get too far off topic on the subject of fsblock,
> and block mappings (because I think the ramdisk driver simply should
> have nothing to do with any of that)... 
Which I can agree with.

> but fsblock is exactly a buffer head replacement (so if it doesn't
> make sense, then I've screwed something up badly! ;))

By definition!

Eric



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
