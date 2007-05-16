From: David Howells <dhowells@redhat.com>
In-Reply-To: <20070318233008.GA32597093@melbourne.sgi.com>
References: <20070318233008.GA32597093@melbourne.sgi.com>
Subject: Re: [PATCH 1 of 2] block_page_mkwrite() Implementation V2
Date: Wed, 16 May 2007 11:19:29 +0100
Message-ID: <18993.1179310769@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

David Chinner <dgc@sgi.com> wrote:

> +	ret = block_prepare_write(page, 0, end, get_block);

As I understand the way prepare_write() works, this is incorrect.

The start and end points passed to block_prepare_write() delimit the region of
the page that is going to be modified.  This means that prepare_write()
doesn't need to fill it in if the page is not up to date.  It does, however,
need to fill in the region before (if present) and the region after (if
present).  Look at it like this:

		+---------------+
		|               |
		|               |	<-- Filled in by prepare_write()
		|               |
	to->	|:::::::::::::::|
		|               |
		|               |	<-- Filled in by caller
		|               |
	offset->|:::::::::::::::|
		|               |
		|               |	<-- Filled in by prepare_write()
		|               |
	page->	+---------------+

However, page_mkwrite() isn't told which bit of the page is going to be
written to.  This means it has to ask prepare_write() to make sure the whole
page is filled in.  In other words, offset and to must be equal (in AFS I set
them both to 0).

With what you've got, if, say, 'offset' is 0 and 'to' is calculated at
PAGE_SIZE, then if the page is not up to date for any reason, then none of the
page will be updated before the page is written on by the faulting code.

You probably get away with this in a blockdev-based filesystem because it's
unlikely that the page will cease to be up to date.

However, if someone adds a syscall to punch holes in files, this may change...

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
