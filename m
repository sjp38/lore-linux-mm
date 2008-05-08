Date: Wed, 7 May 2008 19:38:38 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080508003838.GA9878@sgi.com>
References: <6b384bb988786aa78ef0.1210170958@duo.random> <alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org> <20080507212650.GA8276@duo.random> <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2008 at 02:36:57PM -0700, Linus Torvalds wrote:
> On Wed, 7 May 2008, Andrea Arcangeli wrote:
> > 
> > I think the spinlock->rwsem conversion is ok under config option, as
> > you can see I complained myself to various of those patches and I'll
> > take care they're in a mergeable state the moment I submit them. What
> > XPMEM requires are different semantics for the methods, and we never
> > had to do any blocking I/O during vmtruncate before, now we have to.
> 
> I really suspect we don't really have to, and that it would be better to 
> just fix the code that does that.

That fix is going to be fairly difficult.  I will argue impossible.

First, a little background.  SGI allows one large numa-link connected
machine to be broken into seperate single-system images which we call
partitions.

XPMEM allows, at its most extreme, one process on one partition to
grant access to a portion of its virtual address range to processes on
another partition.  Those processes can then fault pages and directly
share the memory.

In order to invalidate the remote page table entries, we need to message
(uses XPC) to the remote side.  The remote side needs to acquire the
importing process's mmap_sem and call zap_page_range().  Between the
messaging and the acquiring a sleeping lock, I would argue this will
require sleeping locks in the path prior to the mmu_notifier invalidate_*
callouts().

On a side note, we currently have XPMEM working on x86_64 SSI, and
ia64 cross-partition.  We are in the process of getting XPMEM working
on x86_64 cross-partition in support of UV.

Thanks,
Robin Holt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
