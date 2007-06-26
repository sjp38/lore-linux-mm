Message-ID: <46807D13.4070703@yahoo.com.au>
Date: Tue, 26 Jun 2007 12:42:27 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 1/3] add the fsblock layer
References: <20070624014528.GA17609@wotan.suse.de> <20070624014613.GB17609@wotan.suse.de> <20070625131917.GD12852@think.oraclecorp.com>
In-Reply-To: <20070625131917.GD12852@think.oraclecorp.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Chris Mason wrote:
> On Sun, Jun 24, 2007 at 03:46:13AM +0200, Nick Piggin wrote:
> 
>>Rewrite the buffer layer.
> 
> 
> Overall, I like the basic concepts, but it is hard to track the locking
> rules.  Could you please write them up?

Yeah I will do that.

Thanks for taking a look. One thing I am thinking about is to get
rid of the unmap_underlying_metadata calls from the generic code.
I found they were required for minix to prevent corruption, however
I don't know exactly what metadata is interfering here (maybe it
is indirect blocks or something?). Anyway, I think I will make it
a requirement that the filesystem has to already handle this before
returning a newly allocated block -- they can probably do it more
efficiently and we avoid the extra work on every block allocation.


> I like the way you split out the assoc_buffers from the main fsblock
> code, but the list setup is still something of a wart.  It also provides
> poor ordering of blocks for writeback.

Yeah, I didn't know how much effort to put in here because I don't
know whether modern filesystems are going to need to implement their
own management of this stuff or not.

I haven't actually instrumented this in something like ext2 to see
how much IO comes from the assoc buffers...


> I think it makes sense to replace the assoc_buffers list head with a
> radix tree sorted by block number.  mark_buffer_dirty_inode would up the
> reference count and put it into the radix, the various flushing routines
> would walk the radix etc.
> 
> If you wanted to be able to drop the reference count once the block was
> written you could have a back pointer to the appropriate inode.

I was actually thinking about a radix-tree :) One annoyance is that
unsigned long != sector_t :P rbtree would probably be OK.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
