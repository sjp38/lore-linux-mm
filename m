Date: Fri, 4 Aug 2000 19:05:47 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: RFC: design for new VM
In-Reply-To: <200008050152.SAA89298@apollo.backplane.com>
Message-ID: <Pine.LNX.4.10.10008041854240.1727-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dillon <dillon@apollo.backplane.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Chris Wedgwood <cw@f00f.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Fri, 4 Aug 2000, Matthew Dillon wrote:
> :
> :Right. But what about the TLB?
> 
>     I'm not advocating trying to share TLB entries, that would be 
>     a disaster.

You migth have to, if the machine has a virtually mapped cache.. 

Ugh. That gets too ugly to even contemplate, actually. Just forget the
idea.

>     If it were a long-held lock I'd worry, but if it's a lock on a pte
>     I don't think it can hurt.  After all, even with separate page tables
>     if 300 processes fault on the same backing file offset you are going
>     to hit a bottleneck with MP locking anyway, just at a deeper level
>     (the filesystem rather then the VM system).  The BSDI folks did a lot
>     of testing with their fine-grained MP implementation and found that
>     putting a global lock around the entire VM system had absolutely no 
>     impact on MP performance.

Hmm.. That may be load-dependent, but I know it wasn't true for Linux. The
kernel lock for things like brk() were some of the worst offenders, and
people worked hard on making mmap() and friends not need the BKL exactly
because it showed up very clearly in the lock profiles.

> :>     (Linux falls on its face for other reasons, mainly the fact that it
> :>     maps all of physical memory into KVM in order to manage it).
> :
> :Not true any more.. Trying to map 64GB of RAM convinced us otherwise ;)
> 
>     Oh, that's cool!  I don't think anyone in FreeBSDland has bothered with
>     large-memory (> 4GB) memory configurations, there doesn't seem to be 
>     much demand for such a thing on IA32.

Not normally no. Linux didn't start seeing the requirement until last year
or so, when running big databases and big benchmarks just required it
because the working set was so big. "dbench" with a lot of clients etc.

Now, whether such a working set is realistic or not is another issue, of
course. 64GB isn't as much memory as it used to be, though, and we
couldn't have beated the mindcraft NT numbers without large memory
support.

>     Well, I don't think this is x86-specific.  Or, that is, I don't think it
>     would pollute the machine-independant code.  FreeBSD has virtually no
>     notion of 'page tables' outside the i386-specific VM files... it doesn't
>     use page tables (or two-level page-like tables... is Linux still using
>     those?) to store meta information at all in the higher levels of the
>     kernel.  It uses architecture-independant VM objects and vm_map_entry
>     structures for that.  Physical page tables on FreeBSD are 
>     throw-away-at-any-time entities.  The actual implementation of the
>     'page table' in the IA32 sense occurs entirely in the machine-dependant
>     subdirectory for IA32.  

It's not the page tables themselves I worry about, but all the meta-data
synchronization requirements. But hey. Go wild, prove me wrong.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
