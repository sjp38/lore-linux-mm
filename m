Message-ID: <464AF224.30105@yahoo.com.au>
Date: Wed, 16 May 2007 21:59:32 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1 of 2] block_page_mkwrite() Implementation V2
References: <20070318233008.GA32597093@melbourne.sgi.com> <18993.1179310769@redhat.com>
In-Reply-To: <18993.1179310769@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: David Chinner <dgc@sgi.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

David Howells wrote:
> David Chinner <dgc@sgi.com> wrote:
> 
> 
>>+	ret = block_prepare_write(page, 0, end, get_block);
> 
> 
> As I understand the way prepare_write() works, this is incorrect.

I think it is actually OK.


> The start and end points passed to block_prepare_write() delimit the region of
> the page that is going to be modified.  This means that prepare_write()
> doesn't need to fill it in if the page is not up to date.  It does, however,
> need to fill in the region before (if present) and the region after (if
> present).  Look at it like this:
> 
> 		+---------------+
> 		|               |
> 		|               |	<-- Filled in by prepare_write()
> 		|               |
> 	to->	|:::::::::::::::|
> 		|               |
> 		|               |	<-- Filled in by caller
> 		|               |
> 	offset->|:::::::::::::::|
> 		|               |
> 		|               |	<-- Filled in by prepare_write()
> 		|               |
> 	page->	+---------------+
> 
> However, page_mkwrite() isn't told which bit of the page is going to be
> written to.  This means it has to ask prepare_write() to make sure the whole
> page is filled in.  In other words, offset and to must be equal (in AFS I set
> them both to 0).

Dave is using prepare_write here to ensure blocks are allocated in the
given range. The filesystem's ->nopage function must ensure it is uptodate
before allowing it to be mapped.


> With what you've got, if, say, 'offset' is 0 and 'to' is calculated at
> PAGE_SIZE, then if the page is not up to date for any reason, then none of the
> page will be updated before the page is written on by the faulting code.

Consider that the code currently works OK today _without_ page_mkwrite.
page_mkwrite is being added to do block allocation / reservation.


> You probably get away with this in a blockdev-based filesystem because it's
> unlikely that the page will cease to be up to date.
> 
> However, if someone adds a syscall to punch holes in files, this may change...

We have one. Strangely enough, it is done with madvise(MADV_REMOVE).

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
