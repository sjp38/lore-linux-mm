Date: Sat, 15 Nov 2003 14:52:11 -0500 (EST)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: [PATCH][2.6-mm] Fix 4G/4G X11/vm86 oops
In-Reply-To: <Pine.LNX.4.53.0311151427080.30079@montezuma.fsmlabs.com>
Message-ID: <Pine.LNX.4.53.0311151447350.30079@montezuma.fsmlabs.com>
References: <Pine.LNX.4.44.0311141344290.5877-100000@home.osdl.org>
 <Pine.LNX.4.53.0311141954160.27998@montezuma.fsmlabs.com>
 <Pine.LNX.4.53.0311151427080.30079@montezuma.fsmlabs.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Sat, 15 Nov 2003, Zwane Mwaikambo wrote:

> The 4G/4G page fault handling path doesn't appear to handle faults 
> happening whilst in vm86. The regs->xcs != __USER_CS so it confused the in 
> kernel test.

Perhaps this would be more desirable?

Index: linux-2.6.0-test9-mm3/arch/i386/mm/fault.c
===================================================================
RCS file: /build/cvsroot/linux-2.6.0-test9-mm3/arch/i386/mm/fault.c,v
retrieving revision 1.1.1.1
diff -u -p -B -r1.1.1.1 fault.c
--- linux-2.6.0-test9-mm3/arch/i386/mm/fault.c	13 Nov 2003 08:07:17 -0000	1.1.1.1
+++ linux-2.6.0-test9-mm3/arch/i386/mm/fault.c	15 Nov 2003 19:40:17 -0000
@@ -264,7 +264,9 @@ asmlinkage void do_page_fault(struct pt_
 		if (error_code & 3)
 			goto bad_area_nosemaphore;
 
- 		goto vmalloc_fault;
+		/* If it's vm86 fall through */
+		if (!(regs->eflags & VM_MASK))
+			goto vmalloc_fault;
 	}
 #else
 	if (unlikely(address >= TASK_SIZE)) { 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
