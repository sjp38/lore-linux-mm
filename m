Date: Sat, 5 Apr 2003 11:01:13 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030405100113.GA15766@mail.jlokier.co.uk>
References: <Pine.LNX.4.44.0304041453160.1708-100000@localhost.localdomain> <20030404105417.3a8c22cc.akpm@digeo.com> <20030404214547.GB16293@dualathlon.random> <20030404150744.7e213331.akpm@digeo.com> <20030405000352.GF16293@dualathlon.random> <20030404163154.77f19d9e.akpm@digeo.com> <20030405013143.GJ16293@dualathlon.random> <20030404205248.C21819@redhat.com> <20030405022250.GM16293@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030405022250.GM16293@dualathlon.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Benjamin LaHaise <bcrl@redhat.com>, Andrew Morton <akpm@digeo.com>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> > It is still useful for things outside of the pure databases on 32 bits 
> > realm.  Consider a fast bochs running 32 bit apps on a 64 bit machine -- 
> > should it have to deal with the overhead of zillions of vmas for emulating 
> > page tables?
> 
> I can't understand this very well so it maybe my fault, but it doesn't
> make any sense to me. I don't know how bochs works but for certain you
> won't get any help from the API of remap_file_pages implemented in
> 2.5.66 in a 64bit arch.
> 
> If you think you can get any benefit, then I tell you, rather than using
> remap_file_pages, just go ahead mmap the whole file for me, as large as
> it is, likely you're dealing with a 32bit address space so it will be
> a mere 4G. I doubt you're dealing with 1 terabytes files with bochs that
> is by definintion a 32bit thing.

1. You missed the "fast" in "fast bochs".

The idea is to have a file representing the simulated RAM (anything up
to 64G in size), and to map that the same way as the simulated page tables.

Then the virtual machine can address the memory directly, which is very fast.
Doing it your way, the virtual machine would have to do a virtual TLB
lookup for every memory access, which slows down the simulation considerably.

2. Another use of non-linear mappings is when you want different per
page memory protections.  In this case you don't need different
pg_offset per page, you just want to write protect and unprotect
individual pages.  This comes up in the context of some garbage
collector algorithms.

Again, the idea is that the mapping (and in this case SIGSEGV
handling) costs a little, but it is less than the cost of checking
each memory access in the main code.


Both of these use many thousands of VMAs when done using mmap().  I
don't think either of these uses of non-linear mappings are covered by
your suggestion to use a 64 bit address space.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
