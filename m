Date: Fri, 5 Nov 2004 03:08:31 +0100
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: fix iounmap and a pageattr memleak (x86 and x86-64)
Message-ID: <20041105020831.GI8229@dualathlon.random>
References: <4188118A.5050300@us.ibm.com> <20041103013511.GC3571@dualathlon.random> <418837D1.402@us.ibm.com> <20041103022606.GI3571@dualathlon.random> <418846E9.1060906@us.ibm.com> <20041103030558.GK3571@dualathlon.random> <1099612923.1022.10.camel@localhost> <1099615248.5819.0.camel@localhost> <20041105005344.GG8229@dualathlon.random> <1099619740.5819.65.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1099619740.5819.65.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 04, 2004 at 05:55:40PM -0800, Dave Hansen wrote:
> What happens when a pte page is bootmem-allocated?  I *think* that's the
> situation that I'm hitting.  In that case, we can either try to hunt
> down the real 'struct pages' after everything is brought up, or we can
> just skip the BUG_ON() if the page is reserved.  Any thoughts?

Skipping BUG_ON if the page is reserved is something you can certainly
try.

However if all usages are symmetric, the only pte that should ever get
freed, is the pte that change_page_attr itself has allocated via
split_large_page.

I tried the debug option right now, without the fixes I get a crash in
X (but not in pageattr.c, it's an invalid page fault in some direct
mapping), that might be a real bug or another false positive.

with the fixes applied I get this, so I can reproduce at least ;)

------------[ cut here ]------------
kernel BUG at arch/i386/mm/pageattr.c:133!
invalid operand: 0000 [#1]
SMP DEBUG_PAGEALLOC
CPU:    0
EIP:    0060:[<c011979f>]    Not tainted
EFLAGS: 00010046   (2.6.5-0-andrea )
EIP is at change_page_attr+0x26f/0x2d0
eax: ffffffff   ebx: c1037de0   ecx: c1000100   edx: c1000100
esi: 00000001   edi: 00000000   ebp: 00000163   esp: c1bf3ee0
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 1, threadinfo=c1bf2000 task=c1bf1780)
Stack: 0000001b c0008fbc c1bef000 00000246 00000000 00000001 c1037de0
c1037de0
       00000001 00000000 00000001 c0119823 c0419780 c1037de0 c013fba5
c1bb049c
       00000000 00000078 00000000 00000001 00000000 c1bf1780 00000010
c041a380
Call Trace:
 [<c0119823>] kernel_map_pages+0x23/0x4f
 [<c013fba5>] __alloc_pages+0x2f8/0x33b
 [<c013fc44>] __get_free_pages+0x18/0x25
 [<c0142600>] cache_alloc_refill+0x28c/0x530
 [<c013d74b>] mempool_alloc_slab+0x0/0xb
 [<c0142907>] __kmalloc+0x63/0x65
 [<c013d995>] mempool_create+0x3f/0xbf
 [<c013d740>] mempool_free_slab+0x0/0xb
 [<c04c87fc>] init_bio+0xec/0x1a8
 [<c0103199>] init+0x131/0x2ca
 [<c0103068>] init+0x0/0x2ca
 [<c0106005>] kernel_thread_helper+0x5/0xb

Code: 0f 0b 85 00 23 e7 3a c0 e9 0f fe ff ff 8d 41 10 8b 15 38 6e
 <0>Kernel panic: Attempted to kill init!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
