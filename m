Date: Wed, 15 Mar 2006 09:11:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page migration: Fail with error if swap not setup
In-Reply-To: <1142434053.5198.1.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0603150901530.26799@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603141903150.24199@schroedinger.engr.sgi.com>
 <1142434053.5198.1.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, nickpiggin@yahoo.com.au, akpm@osdl.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Mar 2006, Lee Schermerhorn wrote:

> On Tue, 2006-03-14 at 19:05 -0800, Christoph Lameter wrote:
> > Currently the migration of anonymous pages will silently fail if no swap 
> > is setup. This patch makes page migration functions check for available 
> > swap and fail with -ENODEV if no swap space is available.
> 
> Migration Cache, anyone?  ;-)

Yes, but please cleanly integrated into the way swap works.

At that point we can also follow Marcelo's suggestion and move the 
migration code into mm/mmigrate.c because it then becomes easier to 
separate the migration code from swap.

There are a couple of other pending things that are also listed in 
the todo list in Documentation/vm/page-migration

1. Somehow safely track the prior mm_structs that a pte was mapped to 
(increase mm refcount?) and restore those mappings to avoid faults to 
restore ptes after a page was moved.

2. Avoid dirty bit faults for dirty pages.

More things to consider:

- Add migration support for more filesystems.

- Lazy migration in the fault paths (seems to depend on first implementing 
proper policy support for file backed pages).

- Support migration of VM_LOCKED pages (First question is if we want to 
  have that at all. Does VM_LOCKED imply that a page is fixed at a 
  specific location in memory?).

- Think about how to realize migration of kernel pages (some arches have
  page table for kernel space, one could potentially remap the address 
  instead of going through all the twists and turns of the existing 
  hotplug approach. See also what virtual iron has done about this.).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
