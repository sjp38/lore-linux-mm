Date: Tue, 1 May 2007 03:13:57 -0400
From: Jakub Jelinek <jakub@redhat.com>
Subject: Re: MADV_FREE functionality
Message-ID: <20070501071357.GV355@devserv.devel.redhat.com>
Reply-To: Jakub Jelinek <jakub@redhat.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <46368FAA.3080104@redhat.com> <20070430181839.c548c4da.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070430181839.c548c4da.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk-manpages@gmx.net>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 30, 2007 at 06:18:39PM -0700, Andrew Morton wrote:
> > In short:
> > - both MADV_FREE and MADV_DONTNEED only unmap file pages
> > - after MADV_DONTNEED the application will always get back
> >    fresh zero filled anonymous pages when accessing the
> >    memory
> > - after MADV_FREE the application can either get back the
> >    original data (without a page fault) or zero filled
> >    anonymous memory
> > 
> > The Linux MADV_DONTNEED behavior is not POSIX compliant.
> > POSIX says that with MADV_DONTNEED the application's data
> > will be preserved.
> > 
> > Currently glibc simply ignores POSIX_MADV_DONTNEED requests
> > from applications on Linux.  Changing the behaviour which
> > some Linux applications may rely on might not be the best
> > idea.
> 
> OK, thanks.  I stuck that in the changelog.

FYI, Solaris man page on MADV_FREE says:

      MADV_FREE
            Tells  the  kernel  that  contents  in  the  specified
            address  range  are  no longer important and the range
            will be overwritten. When there is demand for  memory,
            the  system will free pages associated with the speci-
            fied address range. In this instance, the next time  a
            page  in the address range is referenced, it will con-
            tail all zeroes.  Otherwise, it will contain the  data
            that was there prior to the MADV_FREE call. References
            made to the address range will  not  make  the  system
            read from backing store (swap space) until the page is
            modified again.

            This value cannot be used on mappings that have under-
            lying file objects.

The last paragraph seems to be just about the operation being
undefined, madvise MADV_FREE on MAP_SHARED file mapping returns 0
rather than flagging an error.

FreeBSD man page:

        MADV_FREE        Gives the VM system the freedom to free pages, and tells
                         the system that information in the specified page range
                         is no longer important.  This is an efficient way of
                         allowing malloc(3) to free pages anywhere in the address
                         space, while keeping the address space valid.  The next
                         time that the page is referenced, the page might be
                         demand zeroed, or might contain the data that was there
                         before the MADV_FREE call.  References made to that
                         address space range will not make the VM system page the
                         information back in from backing store until the page is
                         modified again.

> Also, where did we end up with the Solaris compatibility?
> 
> The patch I have at present retains MADV_FREE=0x05 for sparc and sparc64
> which should be good.
> 
> Did we decide that the Solaris and Linux implementations of MADV_FREE are
> compatible?

SPARC Solaris binary compatibility in Linux is in really bad shape, madvise
in Solaris is implemented using memcntl syscall (at least according to truss(1))
and that syscall is
systbl.S:       .word solaris_unimplemented     /* memcntl              131     */
When/if anyone decides to put more effort into the Solaris binary compatibility
(I'm quite doubtful anyone will), codes which don't match can be simply translated into
other codes, ignored etc., we can't use sys_madvise to implement memcntl
syscall anyway.  While Solaris MADV_FREE is the same as Linux MADV_FREE proposed
by Rik (except perhaps the documented undefined behavior with file mappings,
on
#include <sys/mman.h>
#include <unistd.h>
#include <fcntl.h>

int
main (void)
{
  getpid ();
  int fd = open ("test", O_RDWR);
  void *p = mmap (0, 8192, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
  memset (p, ' ', 8192);
  madvise (p, 8192, MADV_FREE);
  return 0;
}
on Solaris the spaces actually made it into the file), MADV_DONTNEED is not,
but that doesn't really matter except for arch/sparc*/solaris/ layer if anyone
cares.  We certainly can't change current MADV_DONTNEED behavior, all we
can do is implement a new MADV_* code with a different behavior and let glibc
translate POSIX_MADV_* codes on posix_madvise to the Linux specific MADV_*.

	Jakub

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
