Date: Wed, 18 Jun 2008 15:59:28 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/1] MM: virtual address debug
Message-ID: <20080618135928.GA12803@elte.hu>
References: <1213271800-1556-1-git-send-email-jirislaby@gmail.com> <20080618121221.GB13714@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080618121221.GB13714@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, tglx@linutronix.de, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, the arch/x86 maintainers <x86@kernel.org>, Mike Travis <travis@sgi.com>
List-ID: <linux-mm.kvack.org>

* Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Jiri Slaby <jirislaby@gmail.com> wrote:
> 
> > Add some (configurable) expensive sanity checking to catch wrong address
> > translations on x86.
> > 
> > - create linux/mmdebug.h file to be able include this file in
> >   asm headers to not get unsolvable loops in header files
> > - __phys_addr on x86_32 became a function in ioremap.c since
> >   PAGE_OFFSET, is_vmalloc_addr and VMALLOC_* non-constasts are undefined
> >   if declared in page_32.h
> > - add __phys_addr_const for initializing doublefault_tss.__cr3
> 
> applied, thanks Jiri. I have created a new tip/x86/mm-debug topic for 
> this because the patch touches mm/vmalloc.c and other MM bits.

-tip testing triggered an early boot crash and i have bisected it down 
to your patch. The crash:

No NUMA configuration found
Faking a node at 0000000000000000-000000003fff0000
Entering add_active_range(0, 0, 159) 0 entries of 25600 used
Entering add_active_range(0, 256, 262128) 1 entries of 25600 used
Bootmem setup node 0 0000000000000000-000000003fff0000
  NODE_DATA [000000000000a000 - 000000000003dfff]
PANIC: early exception 06 rip 10:ffffffff80ba7531 error 0 cr2 f06f53
Pid: 0, comm: swapper Not tainted 2.6.26-rc6 #7709

Call Trace:
 [<ffffffff80b9c196>] early_idt_handler+0x56/0x6a
 [<ffffffff80ba7531>] setup_node_bootmem+0x12a/0x2d4
 [<ffffffff80ba7505>] setup_node_bootmem+0xfe/0x2d4
 [<ffffffff80b9dd73>] setup_arch+0x2a2/0x3e7
 [<ffffffff8024e858>] clockevents_register_notifier+0x2d/0x31
 [<ffffffff80b9cb5d>] start_kernel+0x8d/0x30a
 [<ffffffff80b9f87d>] reserve_early+0x16/0xad
 [<ffffffff80b9c35f>] x86_64_start_kernel+0x16d/0x174

RIP 0x10

the config is at:

  http://redhat.com/~mingo/misc/config-Wed_Jun_18_14_51_18_CEST_2008.bad

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
