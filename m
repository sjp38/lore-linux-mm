Date: Sun, 1 Jun 2003 16:33:39 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: build problems on architectures where FIXADDR_* stuff is not constant
Message-ID: <20030601163339.D659@nightmaster.csn.tu-chemnitz.de>
References: <20030513122329.GA31609@namesys.com> <20030513134620.3dafeaf3.akpm@digeo.com> <20030513232450.Y626@nightmaster.csn.tu-chemnitz.de> <20030513181227.0c068200.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030513181227.0c068200.akpm@digeo.com>; from akpm@digeo.com on Tue, May 13, 2003 at 06:12:27PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

I finally got around to handle this issue.

On Tue, May 13, 2003 at 06:12:27PM -0700, Andrew Morton wrote:
> Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de> wrote:
> >
> > What, if you fold a part of my page_walker code (the special case
> >  for one page actually) into the baseline?
> > 
> >  This will resolve the issue and should remove the vma argument
> >  from get_user_pages().
> > 
> >  It will also speed up that path a little.
> > 
> >  What do you think?
> 
> I'd be interested in seeing a diff.  Especially if it
> digs that crap out of get_user_pages().

Yes, but the change would be quite big:
   - follow_hugetlb_pages() is not needed anymore, since
     follow_page() can handle them and every user of
     get_user_pages() needing to get a vma back is just needing
     exactly one page.

   Required users of a possible get_single_user_page():  
      fs/binfmt_elf.c:elf_core_dump()
      kernel/ptrace.c:access_process_vm()

   Recommended users (because they need only one page):
      kernel/futex.c:__pin_page()
      arch/i386/lib/usercopy.c:_copy_to_user_ll()
 
   - get_user_pages() will loose its last argument. 

     I could also remove the force argument then, since
     drivers/media/video/video-buf.c is the only user and it
     looks bogus to me wrt. this usage.

   - the FIXADDR handling would have its own inline function,
     degenerating into a assignement, if not needed and might be
     duplicated partially, if inlined.

   - the follow_page and faulting would become a own function.

   - all callers of both functions must be updated and it will
     affect the pgcl patches.

So the amount of changes is quite similiar to the inclusion of
the whole new page-walking-api.

If you want pieces, please tell me, which of the changes above
you want.

Regards

Ingo Oeser
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
