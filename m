Date: Wed, 26 Apr 2000 08:25:59 -0700
Message-Id: <200004261525.IAA13973@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <20000426162353.O3792@redhat.com> (sct@redhat.com)
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
References: <Pine.LNX.4.21.0004251757360.9768-100000@alpha.random> <Pine.LNX.4.21.0004251418520.10408-100000@duckman.conectiva> <20000425113616.A7176@stormix.com> <3905EB26.8DBFD111@mandrakesoft.com> <20000425120657.B7176@stormix.com> <20000426120130.E3792@redhat.com> <200004261125.EAA12302@pizda.ninka.net> <20000426140031.L3792@redhat.com> <200004261311.GAA13838@pizda.ninka.net> <20000426162353.O3792@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sct@redhat.com
Cc: sim@stormix.com, jgarzik@mandrakesoft.com, riel@nl.linux.org, andrea@suse.de, linux-mm@kvack.org, bcrl@redhat.com, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

   > Instead of talk, I'll show some code :-)  The following is the
   > anon layer I implemented for 2.3.x in my hacks.

   OK --- I'm assuming you allow all of these address spaces to act as 
   swapper address spaces for the purpose of the swap cache? 

Essentially, this is how it works yes.

   This looks good, do you have the rest of the VM changes in a usable
   (testable) state?

No, this is why I haven't posted the complete patch for general
consumption.  It's in an "almost works" state, very dangerous,
and I don't even try leaving single user mode when I'm testing
it :-)))

   On fork(), I assume you just leave multiple vmas attached to the
   same address space?  With things like mprotect, you'll still have a
   list of vmas to search for in this design, I'd think.

At fork, the code which copies the address space just calls
"anon_dup()" for non-NULL vma->vm_anon, to clone the anon_area in the
child's VMA.  anon_dup adds a new VMA to the mapping->i_mmap list and
bumps the anon_area reference count.

Actually, come to think of it, the anon_area reference count is
superfluous, because anon->mapping.i_mmap being NULL is equivalent to
the count going to zero.  Superb, I can just kill that special
anon_area structure and use "struct address_space *vm_anon;" in the
vm_area_struct.

I'll try to clean up and stabilize my changes and post a patch
in the next few days.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
