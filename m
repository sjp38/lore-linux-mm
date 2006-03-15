Date: Wed, 15 Mar 2006 14:47:42 -0600
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: page migration: Fail with error if swap not setup
Message-ID: <20060315204742.GB12432@dmt.cnet>
References: <Pine.LNX.4.64.0603141903150.24199@schroedinger.engr.sgi.com> <1142434053.5198.1.camel@localhost.localdomain> <Pine.LNX.4.64.0603150901530.26799@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0603150901530.26799@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, nickpiggin@yahoo.com.au, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 15, 2006 at 09:11:07AM -0800, Christoph Lameter wrote:
> On Wed, 15 Mar 2006, Lee Schermerhorn wrote:
> 
> > On Tue, 2006-03-14 at 19:05 -0800, Christoph Lameter wrote:
> > > Currently the migration of anonymous pages will silently fail if no swap 
> > > is setup. This patch makes page migration functions check for available 
> > > swap and fail with -ENODEV if no swap space is available.
> > 
> > Migration Cache, anyone?  ;-)
> 
> Yes, but please cleanly integrated into the way swap works.
> 
> At that point we can also follow Marcelo's suggestion and move the 
> migration code into mm/mmigrate.c because it then becomes easier to 
> separate the migration code from swap. 

Please - the migration code really does not belong to mm/vmscan.c.

> There are a couple of other pending things that are also listed in 
> the todo list in Documentation/vm/page-migration
> 
> 1. Somehow safely track the prior mm_structs that a pte was mapped to 
> (increase mm refcount?) and restore those mappings to avoid faults to 
> restore ptes after a page was moved.

On the assumption that those page mappings are going to be used, which
is questionable.

Lazily faulting the page mappings instead of "pre-faulting" really
depends on the load (tradeoff) - might be interesting to make it 
selectable.

> 2. Avoid dirty bit faults for dirty pages.

When prefaulting as you suggest, yep...

> More things to consider:
> 
> - Add migration support for more filesystems.
> 
> - Lazy migration in the fault paths (seems to depend on first implementing 
> proper policy support for file backed pages).
> 
> - Support migration of VM_LOCKED pages (First question is if we want to 
>   have that at all. Does VM_LOCKED imply that a page is fixed at a 
>   specific location in memory?).

No, mlock(2):

mlock disables paging for the memory in the range starting at addr with
length len bytes. All pages which contain a part of the specified  mem-
ory  range are guaranteed be resident in RAM when the mlock system call
returns successfully and they are guaranteed to stay in RAM  until  the
pages  are  unlocked  by  munlock  or  munlockall,  until the pages are
unmapped via munmap, or until the process terminates or starts  another
program  with exec.  Child processes do not inherit page locks across a
fork.

...

Cryptographic  security  software often handles critical bytes like passwords
or secret keys as data structures. As a result of paging, these secrets
could  be  transferred  onto a persistent swap store medium, where they
might be accessible to the enemy long after the security  software  has
erased  the secrets in RAM and terminated. 

> - Think about how to realize migration of kernel pages (some arches have
>   page table for kernel space, one could potentially remap the address 
>   instead of going through all the twists and turns of the existing 
>   hotplug approach. See also what virtual iron has done about this.).

Locking sounds tricky, how do you guarantee that nobody is going to
access such kernel virtual addresses (and their TLB-cached entries)
while they're physical address is being changed ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
