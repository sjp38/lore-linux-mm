Date: Fri, 20 Dec 2002 10:30:47 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: shared pagetable benchmarking
Message-ID: <9490000.1040401847@baldur.austin.ibm.com>
In-Reply-To: <3E02FACD.5B300794@digeo.com>
References: <3E02FACD.5B300794@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Friday, December 20, 2002 03:11:09 -0800 Andrew Morton
<akpm@digeo.com> wrote:

> The workload is application and removal of ~80 patches using
> my patch scripts.  Tons and tons of forks from bash.
> 
> 2.5 ends up being 13% slower than 2.4, after disabling highpte
> to make it fair.  3%-odd of this is HZ=1000.  So say 10%.
> 
> Pagetable sharing actually slowed this test down by several
> percent overall.  Which is unfortunate, because the main
> thing which Linus likes about shared pagetables is that it
> "speeds up forks".
> 
> Is there anything we can do to fix all of this up a bit?

Ok, let's consider just what shared page tables does for fork.

In fork without shared page tables, there is a fixed cost per mapped page
where the pte entry has to be copied from the parent's pte page to the
child's.  This cost is higher for resident pages in 2.5 than 2.4 because of
rmap.

What shared page tables does isn't reduce that cost, it just defers it by
marking each pte page copy-on-write.  The cost is incurred when either the
parent or the child first tries to write to a page in that pte page.  The
savings comes when there are pte pages that never have to be unshared,
either because they map a shared region or they're not written to
(typically because the child quickly does an exec).

The worst case condition for shared page tables is when every pte page has
to be unshared.  Unfortunately this is also a common case.  Almost every
parent or child will touch three pages after fork:  the current stack page,
libc's data page, and the application's data page.  Each one of these is in
a separate pte page.  Since each pte page maps 4M (2M for PAE), small
processes only have those three pte pages, and they're all unshared.
Unfortunately this includes most base utilities, in particular shells, so
shell scripts will not benefit from shared page tables.

There is a small penalty for deferring the pte page copy, as Andrew's tests
show.  However, as soon as even one pte page is not copied, fork
performance improves dramatically.  My tests show that fork/exit for a 4
pte page process is about 25% to 30% faster with shared page tables than
without, simply because of the single extra page that's not unshared.  This
savings is multiplied for each additional pte page that remains shared.

I'll look for ways to optimize the unsharing to reduce the penalty, but I'm
not optimistic that we can eliminate it entirely.

Let's also not lose sight of what I consider the primary goal of shared
page tables, which is to greatly reduce the page table memory overhead of
massively shared large regions.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
