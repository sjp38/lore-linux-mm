Date: Mon, 25 Jun 2007 08:29:06 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [patch 1/3] add the fsblock layer
Message-ID: <20070625122906.GB12446@think.oraclecorp.com>
References: <20070624014528.GA17609@wotan.suse.de> <20070624014613.GB17609@wotan.suse.de> <18046.63436.472085.535177@notabene.brown> <467F71C6.6040204@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <467F71C6.6040204@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Neil Brown <neilb@suse.de>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 25, 2007 at 05:41:58PM +1000, Nick Piggin wrote:
> Neil Brown wrote:
> >On Sunday June 24, npiggin@suse.de wrote:
> >
> >>
> >>+#define PG_blocks		20	/* Page has block mappings */
> >>+
> >
> >
> >I've only had a very quick look, but this line looks *very* wrong.
> >You should be using PG_private.
> >
> >There should never be any confusion about whether ->private has
> >buffers or blocks attached as the only routines that ever look in
> >->private are address_space operations  (or should be.  I think 'NULL'
> >is sometimes special cased, as in try_to_release_page.  It would be
> >good to do some preliminary work and tidy all that up).
> 
> There is a lot of confusion, actually :)
> But as you see in the patch, I added a couple more aops APIs, and
> am working toward decoupling it as much as possible. It's pretty
> close after the fsblock patch... however:
> 
> 
> >Why do you think you need PG_blocks?
> 
> Block device pagecache (buffer cache) has to be able to accept
> attachment of either buffers or blocks for filesystem metadata,
> and call into either buffer.c or fsblock.c based on that.
> 
> If the page flag is really important, we can do some awful hack
> like assuming the first long of the private data is flags, and
> those flags will tell us whether the structure is a buffer_head
> or fsblock ;) But for now it is just easier to use a page flag.

The block device pagecache isn't special, and certainly isn't that much
code.  I would suggest keeping it buffer head specific and making a
second variant that does only fsblocks.  This is mostly to keep the
semantics of PagePrivate sane, lets not fuzz the line.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
