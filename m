Date: Wed, 19 Nov 2003 14:32:10 -0600
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH][2.6-mm] Fix 4G/4G X11/vm86 oops
Message-ID: <20031119203210.GC22139@waste.org>
References: <Pine.LNX.4.53.0311181113150.11537@montezuma.fsmlabs.com> <Pine.LNX.4.44.0311180830050.18739-100000@home.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0311180830050.18739-100000@home.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Zwane Mwaikambo <zwane@arm.linux.org.uk>, Ingo Molnar <mingo@elte.hu>, "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 18, 2003 at 08:37:25AM -0800, Linus Torvalds wrote:
> 
> On Tue, 18 Nov 2003, Zwane Mwaikambo wrote:
> > 
> > Here are diffs from the do_sys_vm86 only.
> 
> Ok. Much more readable.
> 
> And there is something very suspicious there.
> 
> The code with and without the printk() looks _identical_ apart from some 
> trivial label renumbering, and the added
> 
> 	pushl   $.LC6
> 	call    printk
> 	.. asm ..
> 	popl %esi
> 
> which all looks fine (esi is dead at that point, so the compiler is just
> using a "popl" as a shorter form of "addl $4,%esp").
> 
> Btw, you seem to compile with debugging, which makes the assembly 
> language pretty much unreadable and accounts for most of the 
> differences: the line numbers change. If you compile a kernel where the 
> line numbers don't change (by commenting _out_ the printk rather than 
> removing the whole line), your diff would be more readable.
> 
> Anyway, there are _zero_ differences.
> 
> Just for fun, try this: move the "printk()" to _below_ the "asm"  
> statement. It will never actually get executed, but if it's an issue of
> some subtle code or data placement things (cache lines etc), maybe that
> also hides the oops, since all the same code and data will be generated, 
> just not run...

Zwane's got a K6-2 500MHz. I've just managed to reproduce this on my
1.4GHz Opteron box (with Debian gcc 3.2). Here, the "ooh la la" bit
doesn't help. So my suspicion is that the printk is changing the
timing just enough on Zwane's box that he's getting a timer interrupt
knocking him out of vm86 mode before he hits a fatal bit in the fault
handling path for 4/4. Printks in handle_vm86_trap, handle_vm86_fault,
do_trap:vm86_trap, and do_general_protection:gp_in_vm86 never fire so
there's probably something amiss in the trampoline code.

-- 
Matt Mackall : http://www.selenic.com : Linux development and consulting
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
