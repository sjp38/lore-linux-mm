Message-ID: <3CD1FB78.B3314F4B@zip.com.au>
Date: Thu, 02 May 2002 19:52:40 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: page-flags.h
References: <20020501192737.R29327@suse.de> <20020501183414.A28790@infradead.org> <20020501200452.S29327@suse.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, kernel-janitor-discuss@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Jones wrote:
> 
> On Wed, May 01, 2002 at 06:34:14PM +0100, Christoph Hellwig wrote:
>  > This step is wasted work - it will NEVER compile.  Rationale:
>  > the page flags operate on page->flags and without having the definition
>  > of struct page from mm.h this won't do.
>  >
>  > The better idea is IMHO to replace page-flags.h by page.h that also
>  > contains the definition of struct page.
> 
> That's a good point, and something I completley overlooked.
> I wonder if Andrew Morton (who I'm guessing wrote that comment
> in mm.h) has some ingenious plan here..

who, me?

I'd envisaged those 119 files doing:

#include <linux/mm.h>
#include <linux/page-flags.h>

so then anything which includes mm.h but doesn't do any PageFoo()
operations doesn't have to process those macros.

I actually did those 119 edits, but dumped it - there are some
awkward forward, backward and sideward refs in pagemap.h and
highmem.h which need to be fixed up first.  umm..  Move
wait_on_page_locked() into page-flags.h and uninline bio_kmap_irq().

Also, moving bh_kmap(), bh_kunmap() and bh_offset() down into 
their only user, raid5.c will help solve a few ordering nasties.

The other low-hanging fruit here is pulling buffer_head.h
out of fs.h.  But as with page-flags.h, the first step
should be to sort out the .h files which refer to buffers,
then to do .c.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
