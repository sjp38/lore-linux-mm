Date: Mon, 7 Jun 1999 14:54:16 -0700
Message-Id: <199906072154.OAA07427@pizda.davem.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <199906072045.NAA71235@google.engr.sgi.com>
	(kanoj@google.engr.sgi.com)
Subject: Re: Questions on cache flushing in do_wp_page
References: <199906072045.NAA71235@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kanoj@google.engr.sgi.com
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, ralf@uni-koblenz.de
List-ID: <linux-mm.kvack.org>

   > As per virtual cache aliasing issues we handle them in other ways,
   > and it is done on a port-by-port basis since most machines need not
   > handle this brain damage.

   I am assuming then that in the above, your definition of "non-coherent"
   does not include virtual coherency/aliasing issues, since the above
   paragraph seems to imply that those issues are handled differently.

Yes, and I will say it again, broken caches like this are handled
by update_mmu_cache(), nowhere else.

It writes data back into the coherency space if necessary, that is all
these two things do, nothing more.  They do not remap pages, they do
not resolve alias conflicts, they are not meant to.

flush_cache_page(vma, page) is meant to also take care of the case
where for some reason the TLB entry must exist for the cache entry to
be valid as well.  This is the case on the HyperSparc's combined I/D
L2 cache (it has no L1 cache), you cannot flush out cache entries
which have no translation, it will make the cpu trap.  Sparc/sun4c's
mmu is like this too.

   Applying the above formalisms to the MIPS processor in do_wp_page,
   I still can't see why a cache wbinv would be done by the
   flush_page_to_ram(old_page); And if I can not use the argument of
   cache aliasing, I am at a complete loss to explain either of
   flush_page_to_ram(new_page); and flush_cache_page(vma, address);
   doing cache wbinv on the MIPS.

Point to note, the MIPS code in the kernel tree is ages out of date
and is by no means a good reference.  The Sparc code is up to date so
you can check what we do there, the 32-bit port has to deal with all
of these issues in various cache/mmu combinations.  Happily sparc64 is
several orders of magnitude easier and nops most of it out.

   You do mention in the general case where the primitives need to be
   invoked, except I still don't understand which processors can define
   the primitives as no-ops (Intel) and which should do some real work
   (like the MIPS seems to be doing). Is there some way to figure out
   how a given processor/architecture needs to define these routines?

The kernel implicitly aliases with userspace on "alias problematic"
caches, this is why flush_page_to_ram() is a seperate primitive.

View it this way, if physical page X is mapped in userspace at address
Y, and you write bytes into the page in the kernel at the kernel
mapping, and the user will not immediately see this data if he were to
just then read it at Y, you need flush_page_to_ram() to do something.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
