Date: Tue, 22 Apr 2003 20:08:51 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030422180851.GL23320@dualathlon.random>
References: <20030422145644.GG8978@holomorphy.com> <Pine.LNX.4.44.0304221110560.10400-100000@devserv.devel.redhat.com> <20030422162055.GJ8978@holomorphy.com> <20030422165746.GK23320@dualathlon.random> <20030422172110.GK8978@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030422172110.GK8978@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@digeo.com>, mbligh@aracnet.com, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2003 at 10:21:10AM -0700, William Lee Irwin III wrote:
> On Tue, Apr 22, 2003 at 06:57:46PM +0200, Andrea Arcangeli wrote:
> > could we focus and solve the remap_file_pages current breakage first?
> > I proposed my fix that IMHO is optimal and simple (I recall Hugh also
> > proposed something on these lines):
> > 1) allow it only inside mmap(VM_NONLINAER) vmas only
> > 2) have the VM skip over VM_NONLINEAR vmas enterely
> > 3) set vma->vm_file to NULL for those vams and forbid paging and allow
> >    multiple files to be mapped in the same nonlinaer vma (add an fd
> >    parameter to the syscall)
> > 4) enable it as non-root (w/o IPC_LOCK capability) only with a sysctl
> >    enabled
> > 5) avoid any overhead connected with the potential paging of the
> >    nonlinaer vmas
> 
> Some of these are controversial; it _can_ be fixed in other ways, but

which ones, could you elaborate? I don't see anything controversial in
the above points.

> I'm trying to be objective here, though my own bias is in favor of full
> retention of functionality (i.e. best of both worlds, maximal code
> complexity).

I'm not at all against code complexity when it is worthwhile, but given
the potential ram and cpu overhead of the complex code and considering
this stuff should be ready in a few months I would prefer to keep things
simple.  Especially because if you really want, as said you could make
things complex (and slower ;) behind this new API w/o userspace
noticing.  Then you can drop the sysctl (or make it insignificant).

> On Tue, Apr 22, 2003 at 06:57:46PM +0200, Andrea Arcangeli wrote:
> > 6) populate it with pmd on hugetlbfs
> > 7) if a truncate happens leave the page pinned outside the pagecache
> >    but still mapped into userspace, we don't care about it and it will
> >    be freed during the munmap of the nonlinear vma
> 
> I'll implement the hugetlbfs part; it should fit nicely into the
> infrastructure introduced with the rest of the virtwin patch, all it
> really needs is some additional error checking. hugetlbfs is 100%
> CAP_IPC_LOCK -- there should be no issue under either scheme.

yes.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
