Date: Fri, 16 Mar 2001 13:34:45 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH/RFC] fix missing tlb flush on x86 smp+pae
Message-ID: <20010316133445.N30889@redhat.com>
References: <Pine.LNX.4.30.0103151438140.16542-100000@today.toronto.redhat.com> <20010316141234.B1805@pcep-jamie.cern.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010316141234.B1805@pcep-jamie.cern.ch>; from lk@tantalophile.demon.co.uk on Fri, Mar 16, 2001 at 02:12:34PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Ben LaHaise <bcrl@redhat.com>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Mar 16, 2001 at 02:12:34PM +0100, Jamie Lokier wrote:
> Ben LaHaise wrote:
> > Below is a patch for 2.4 (it's against 2.4.2-ac20) that fixes a case where
> > pmd_alloc could install a new entry without causing a tlb flush on other
> > CPUs.  This was fatal with PAE because the CPU caches the top level of the
> > page tables, which was showing up as an infinite stream of identical page
> > faults.
> 
> Ew.  Is this the only case where adding a new entry requires a tlb
> flush?  It is quite an unusual requirement.

On Intel, yes.  The PAE case is a special case: we lose one bit of
addressing for each level of page table because the pte width has
doubled, so the two-level page table is short of two bits of address
coverage in PAE mode.  The CPU solves this by implementing a third
level page table, but it's just a tiny four-entry table, and because
it is so small the CPU just caches the whole pgd internally.

So, updating the pgd contents in this special case requires a tlb
flush because it's the only case where the CPU is caching the contents
of page tables other than the leaf pte entries.

Fortunately, the pgd being so tiny also implies that we hardly ever
need to add new entries: we can only ever do so three times per
process, and exec will almost always populate it fully before it is
finished as we load the binary into the first pmd, the libraries into
the second and the stack into the third (the fourth is the kernel
address space).

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
