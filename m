Message-ID: <3D627740.E8C0FDC3@zip.com.au>
Date: Tue, 20 Aug 2002 10:07:12 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: kernel BUG at rmap.c:409! with 2.5.31 and akpm patches.
References: <1029794688.14756.353.camel@spc9.esa.lanl.gov> <1029850784.2045.363.camel@spc9.esa.lanl.gov>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Steven Cole wrote:
> 
> On Mon, 2002-08-19 at 16:04, Steven Cole wrote:
> > On Mon, 2002-08-19 at 15:21, Andrew Morton wrote:
> > > Steven Cole wrote:
> > > >
> > > > Here's a new one.
> > > >
> > > > With this patch applied to 2.5.31,
> > > > http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.31/stuff-sent-to-linus/everything.gz
> > > >
> [earlier problem snipped]
> >
> > [patch snipped]
> >
> > Patch applied, running dbench 1..128.  Up to 52 clients so far, and no
> > blam yet.  I'll run this test several times overnight and let you know
> > if anything else falls out.
> 
> Something else fell out.  I got kernel BUG at page_alloc.c:98! three
> times.

That's the infamous non-NULL page->pte.chain.

> ...
> 
> >>EIP; c0132733 <__free_pages_ok+93/310>   <=====
> Trace; c013315a <__pagevec_free+1a/20>
> Trace; c0131059 <__pagevec_release+f9/110>
> Trace; c0134190 <swap_free+20/40>
> Trace; c0134355 <remove_exclusive_swap_page+d5/110>
> Trace; c0129ff1 <exit_mmap+1a1/280>
> Trace; c0115cd0 <default_wake_function+0/40>
> Trace; c0117ab8 <mmput+48/70>
> Trace; c011adbf <do_exit+df/2c0>
> Trace; c0115c75 <schedule+325/380>

OK, it was mapped.

> ...
> >>EIP; c0132733 <__free_pages_ok+93/310>   <=====
> Trace; c013315a <__pagevec_free+1a/20>
> Trace; c0131059 <__pagevec_release+f9/110>
> Trace; c0173df6 <journal_unmap_buffer+106/190>
> Trace; c013e3db <wake_up_buffer+b/30>
> Trace; c012a32f <remove_from_page_cache+2f/40>
> Trace; c012a783 <truncate_list_pages+2b3/350>
> Trace; c016c6a9 <ext3_do_update_inode+2c9/350>
> Trace; c016c701 <ext3_do_update_inode+321/350>
> Trace; c012a90d <truncate_inode_pages+8d/d0>
> Trace; c015242d <generic_delete_inode+5d/140>
> Trace; c015268d <iput+5d/60>
> Trace; c0150f46 <d_delete+66/c0>
> Trace; c014719d <permission+3d/50>
> Trace; c0149723 <vfs_unlink+1b3/1d0>
> Trace; c01482e2 <lookup_hash+42/90>
> Trace; c01497c9 <sys_unlink+89/f0>
> Trace; c013c89d <sys_close+5d/70>

Odd.  Was this just running dbench?  If so, odd.  dbench
doesn't mmap files, yet here we seem to have a truncated,
mapped page.

I wonder where that came from?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
