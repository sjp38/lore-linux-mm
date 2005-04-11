Date: Tue, 12 Apr 2005 08:41:43 +0900 (JST)
Message-Id: <20050412.084143.41655902.taka@valinux.co.jp>
Subject: Re: question on page-migration code
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <425AC268.4090704@engr.sgi.com>
References: <4255B13E.8080809@engr.sgi.com>
	<20050407180858.GB19449@logos.cnet>
	<425AC268.4090704@engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raybry@engr.sgi.com
Cc: marcelo.tosatti@cyclades.com, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ray,

> >>Hirokazu (and Marcelo),
> >>
> >>In testing my manual page migration code, I've run up against a situation
> >>where the migrations are occasionally very slow.  They work ok, but they
> >>can take minutes to migrate a few megabytes of memory.
> >>
> >>Dropping into kdb shows that the migration code is waiting in msleep() in
> >>migrate_page_common() due to an -EAGAIN return from page_migratable().
> >>A little further digging shows that the specific return in page_migratable()
> >>is the very last one there at the bottom of the routine.
> >>
> >>I'm puzzled as to why the page is still busy in this case.  Previous code
> >>in page_migratable() has unmapped the page, its not in PageWriteback()
> >>because we would have taken a different return statement in that case.
> >>
> >>According to /proc/meminfo, there are no pages in either SwapCache or
> >>Dirty state, and the system has been sync'd before the migrate_pages()
> >>call was issued.
> > 
> > 
> > Who is using the page? 
> > 
> > A little debugging might help similar to what bad_page does can help: 
> > 
> >         printk(KERN_EMERG "flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
> >                 (int)(2*sizeof(page_flags_t)), (unsigned long)page->flags,
> >                 page->mapping, page_mapcount(page), page_count(page));
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> > 
> A little further digging shows that when we go into -EAGAIN case in
> migrate_page_common(), we have flag bits 0x104D set, and when we finally
> exit the routine, we have flags bits 0x004D set.  The 1 bit there is
> PG_private, as near as I can tell (not PG_arch_1, I guess I can't count).
> 
> PagePrivate() is cleared by truncation specific code in migrate_onepage(),
> but it doesn't appear to be cleared (directly) by code on the
> generic_migrate_page() patch.  I wonder if this has something to do with
> the problem I am seeing.

I understand what happened on your machine.

PG_private is a filesystem specific flag, setting some filesystem
depending data in page->private. When the flag is set on a page,
only the local filesystem on which the page depends can handle it. 

Most of the filesystems uses page->private to manage buffers while
others may use it for different purposes. Each filesystem can
implement migrate_page method to handles page->private.
At this moment, only ext2 and ext3 have this method, which migrates
buffers without any I/Os.

If the method isn't implemented for the page, the migration code
calls pageout() and try_to_release_page() to release page->private
instead. 

Which filesystem are you using? I guess it might be XFS which
doesn't have the method yet.

Thank you,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
