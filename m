Date: Fri, 26 May 2000 09:55:47 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200005261655.JAA90389@apollo.backplane.com>
Subject: Re: [RFC] 2.3/4 VM queues idea
References: <200005242057.NAA77059@apollo.backplane.com> <20000525115202.A19969@pcep-jamie.cern.ch> <200005251618.JAA82894@apollo.backplane.com> <20000525185059.A20563@pcep-jamie.cern.ch> <20000526120805.C10082@redhat.com> <20000526132219.C21510@pcep-jamie.cern.ch> <20000526141526.E10082@redhat.com> <20000526163129.B21662@pcep-jamie.cern.ch> <20000526153821.N10082@redhat.com> <20000526183640.A21731@pcep-jamie.cern.ch> <20000526174018.Q10082@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

:Hi,
:
:On Fri, May 26, 2000 at 06:36:40PM +0200, Jamie Lokier wrote:
:
:> That's ok.  VA == vma->pgoff + page_offset.  Move a vma and that's still
:> true.  The ptes are found by looking at the list of all vmas referring
:> to all the address_spaces that refer to a page.
:
:And that is _exactly_ the problem --- especially with heavy mprotect()
:use, processes can have enormous numbers of vmas.  Electric fence and
:distributed shared memory/persistent object stores are the two big,
:obvious cases here.
:
:--Stephen

    I don't think this will be a problem.  FreeBSD's vm_map_entry scheme 
    is very similar and we found it to be fairly trivial to optimize adjacent
    entries in many cases for both madvise() and mprotect().  In fact, half
    the madvise() calls (such as MADV_WILLNEED, MADV_DONTNEED, and MADV_FREE)
    have no effect on the vm_map_entry (VMA equivalent) at all, they operate
    directly on the associated pages.

    The only fragmentation issue I've ever seen with our vm_map_entry scheme
    occurs when you use mprotect() to create a guard page for each thread's
    stack.  The creation of the guard page forces the vm_map_entry to be
    broken up, preventing the vm_map_entries for adjacent stack segments
    from being collapsed together into a single entry.

    You wind up with two vm_map_entry's per thread.  Not really a problem,
    but somewhat of an eyesore.

    In regards to overhead, anything that collects a bunch of pages together
    (e.g. vm_map_entry, vm_object under FBsd, VMA in Jamie's scheme)
    simply does not create a memory overhead issue.  None at all.  It's
    the things that eat memory on a per-page basis that get annoying.

					-Matt
					Matthew Dillon 
					<dillon@backplane.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
