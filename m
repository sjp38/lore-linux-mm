Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <OFFBD08E4B.5FDF2864-ON88256D2B.0063F36A-88256D2B.0063F5EE@us.ibm.com>
From: Paul McKenney <Paul.McKenney@us.ibm.com>
Date: Mon, 19 May 2003 11:11:50 -0700
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@digeo.com>, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-kernel-owner@vger.kernel.org, linux-mm@kvack.org, mika.penttila@kolumbus.fi
List-ID: <linux-mm.kvack.org>




> On Sat, May 17, 2003 at 11:19:39AM -0700, Paul McKenney wrote:
> > > On Thu, May 15, 2003 at 02:20:00AM -0700, Andrew Morton wrote:
> > > not sure why you need a callback, the lowlevel if needed can
serialize
> > > using the same locking in the address space that vmtruncate uses. I
> > > would wait a real case need before adding a callback.
> >
> > FYI, we verified that the revalidate callback could also do the same
> > job that the proposed nopagedone callback does -- permitting
filesystems
> > that provide their on vm_operations_struct to avoid the race between
> > page faults and invalidating a page from a mapped file.
>
> don't you need two callbacks to avoid the race? (really I mean, to call
> two times a callback, the callback can be also the same)

I do not believe so -- though we could well be talking about
different race conditions.  The one that I am worried about
is where a distributed filesystem has a page fault against an
mmap race against an invalidation request.  The thought is
that the DFS takes one of its locks in the nopage callback,
and then releases it in the revalidate callback.  The
invalidation request would use the same DFS lock, and would
therefore not be able to run between nopage and revalidate.
It would call something like invalidate_mmap_range(), which
in turn calls zap_page_range(), which acquires the
mm->page_table_lock.  Since do_no_page() does not release
mm->page_table_lock until after it fills in the PTE, I believe
things are covered.

So, is there another race that I am missing here?  ;-)

                                    Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
