Date: Fri, 27 Dec 2002 19:10:58 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: shared pagetable benchmarking
In-Reply-To: <3E0D0D99.5EB318E5@digeo.com>
Message-ID: <Pine.LNX.4.44.0212271846100.2759-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Dave McCracken <dmccr@us.ibm.com>, Daniel Phillips <phillips@arcor.de>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Dec 2002, Andrew Morton wrote:
> 
> I think we can do a few things still in the 2.6 context.  The fact that
> my "apply seventy patches with patch-scripts" test takes 350,000 pagefaults
> in 13 seconds makes one go "hmm".

Hmm.. Whatever happened to the MAP_POPULATE tests?

The current "filemap_populate()" function is extremely stupid (it takes 
advantage neither of the locality of the page tables _nor_ of the radix 
tree layout), but even so it would probably be a win to pre-populate at 
mmap time.

But having a better "populate()" function that actually does multiple
pages at once by just accessing the radix trees and page table trees
directly should really be very low-overhead for the normal case, and be a
_big_ win in avoiding page faults.

Even with the existing stupid populate function, it might be interesting
seeing what would happen just from doing something silly like

===== arch/i386/kernel/sys_i386.c 1.10 vs edited =====
--- 1.10/arch/i386/kernel/sys_i386.c	Sat Dec 21 08:24:45 2002
+++ edited/arch/i386/kernel/sys_i386.c	Fri Dec 27 19:08:30 2002
@@ -54,6 +54,8 @@
 		file = fget(fd);
 		if (!file)
 			goto out;
+		if (prot & PROT_EXEC)
+			flags |= MAP_POPULATE | MAP_NONBLOCK;
 	}
 
 	down_write(&current->mm->mmap_sem);

(yeah, yeah, and maybe do the same in binfmt_elf.c too)

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
