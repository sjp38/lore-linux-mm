Date: Mon, 23 Dec 2002 10:15:27 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: shared pagetable benchmarking
Message-ID: <45600000.1040660127@baldur.austin.ibm.com>
In-Reply-To: <3E037690.45419D64@digeo.com>
References: <3E02FACD.5B300794@digeo.com>
 <9490000.1040401847@baldur.austin.ibm.com> <3E037690.45419D64@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Friday, December 20, 2002 11:59:12 -0800 Andrew Morton
<akpm@digeo.com> wrote:

> So changing userspace to place its writeable memory on a new 4M boundary
> would be a big win?
> 
> It's years since I played with elf, but I think this is feasible.  Change
> the linker and just wait for it to propagate.

Actually it'd require changes to both the linker and the kernel memory
range allocator.  Right now ld.so maps all memory needed for an entire
shared library, then uses mprotect and MAP_FIXED to modify parts of it to
be writable (or at least that's what I see using strace).  If it was done
using separate mmap calls we could redirect the writable regions to be in a
different pmd.

>> Let's also not lose sight of what I consider the primary goal of shared
>> page tables, which is to greatly reduce the page table memory overhead of
>> massively shared large regions.
> 
> Well yes.  But this is optimising the (extremely) uncommon case while
> penalising the (very) common one.

I guess I don't see wasting extra pte pages on duplicated mappings of
shared memory as extremely uncommon.  Granted, it's not that significant
for small applications, but it can make a machine unusable with some large
applications.  I think being able to run applications that couldn't run
before to be worth some consideration.

I also have a couple of ideas for ways to eliminate the penalty for small
tasks.  Would you grant that it's a worthwhile effort if the penalty for
small applications was zero?

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
