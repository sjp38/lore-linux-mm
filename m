Date: Tue, 22 Apr 2003 18:57:46 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030422165746.GK23320@dualathlon.random>
References: <20030422145644.GG8978@holomorphy.com> <Pine.LNX.4.44.0304221110560.10400-100000@devserv.devel.redhat.com> <20030422162055.GJ8978@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030422162055.GJ8978@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@digeo.com>, mbligh@aracnet.com, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

could we focus and solve the remap_file_pages current breakage first?

I proposed my fix that IMHO is optimal and simple (I recall Hugh also
proposed something on these lines):

1) allow it only inside mmap(VM_NONLINAER) vmas only
2) have the VM skip over VM_NONLINEAR vmas enterely
3) set vma->vm_file to NULL for those vams and forbid paging and allow
   multiple files to be mapped in the same nonlinaer vma (add an fd
   parameter to the syscall)
4) enable it as non-root (w/o IPC_LOCK capability) only with a sysctl
   enabled
5) avoid any overhead connected with the potential paging of the
   nonlinaer vmas
6) populate it with pmd on hugetlbfs
7) if a truncate happens leave the page pinned outside the pagecache
   but still mapped into userspace, we don't care about it and it will
   be freed during the munmap of the nonlinear vma

Note: in the longer run if you want, you can as well change the kernel
internals to make this area pageable and then you won't need a sysctl
anymore.

The mmap and remap_file_pages kind of overlaps, remap_file_pages is the
"hack" that should be quick and simple IMHO. Everything not just
intersting as a pte mangling vm-bypass should happen in the mmap layer
IMHO.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
