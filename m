Date: Wed, 1 Aug 2007 14:17:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc1-mm2
Message-Id: <20070801141749.ecfe6803.akpm@linux-foundation.org>
In-Reply-To: <64bb37e0708011352q33053acdxa753cd198fb4233c@mail.gmail.com>
References: <20070731230932.a9459617.akpm@linux-foundation.org>
	<12639.1186000208@turing-police.cc.vt.edu>
	<20070801134055.7862b95e.akpm@linux-foundation.org>
	<64bb37e0708011352q33053acdxa753cd198fb4233c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Torsten Kaiser <just.for.lkml@googlemail.com>
Cc: Valdis.Kletnieks@vt.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Aug 2007 22:52:44 +0200
"Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:

> On 8/1/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Wed, 01 Aug 2007 16:30:08 -0400
> > Valdis.Kletnieks@vt.edu wrote:
> >
> > > As an aside, it looks like bits&pieces of dynticks-for-x86_64 are in there.
> > > In particular, x86_64-enable-high-resolution-timers-and-dynticks.patch is in
> > > there, adding a menu that depends on GENERIC_CLOCKEVENTS, but then nothing
> > > in the x86_64 tree actually *sets* it.  There's a few other dynticks-related
> > > prep patches in there as well.  Does this mean it's back to "coming soon to
> > > a CPU near you" status? :)
> >
> > I've lost the plot on that stuff: I'm just leaving things as-is for now,
> > wait for Thomas to return from vacation so we can have another run at it.
> 
> For what its worth: 2.6.22-rc6-mm1 with NO_HZ works for me on an AMD
> SMP system without trouble.
> 
> Next try with 2.6.23-rc1-mm2 and SPARSEMEM:
> Probably the same exception, but this time with Call Trace:
> [    0.000000] Bootmem setup node 0 0000000000000000-0000000080000000
> [    0.000000] Bootmem setup node 1 0000000080000000-0000000120000000
> [    0.000000] Zone PFN ranges:
> [    0.000000]   DMA             0 ->     4096
> [    0.000000]   DMA32        4096 ->  1048576
> [    0.000000]   Normal    1048576 ->  1179648
> [    0.000000] Movable zone start PFN for each node
> [    0.000000] early_node_map[4] active PFN ranges
> [    0.000000]     0:        0 ->      159
> [    0.000000]     0:      256 ->   524288
> [    0.000000]     1:   524288 ->   917488
> [    0.000000]     1:  1048576 ->  1179648
> PANIC: early exception rip ffffffff807cddb5 error 2 cr2 ffffe20003000010

It's cryptically telling us that the code tried to access 0xffffe20003000010

> [    0.000000]
> [    0.000000] Call Trace:
> [    0.000000]  [<ffffffff807cddb5>] memmap_init_zone+0xb5/0x130
> [    0.000000]  [<ffffffff807ce874>] init_currently_empty_zone+0x84/0x110
> [    0.000000]  [<ffffffff807cec93>] free_area_init_node+0x393/0x3e0
> [    0.000000]  [<ffffffff807cefea>] free_area_init_nodes+0x2da/0x320
> [    0.000000]  [<ffffffff807c9c97>] paging_init+0x87/0x90
> [    0.000000]  [<ffffffff807c0f85>] setup_arch+0x355/0x470
> [    0.000000]  [<ffffffff807bc967>] start_kernel+0x57/0x330
> [    0.000000]  [<ffffffff807bc12d>] _sinittext+0x12d/0x140
> [    0.000000]
> [    0.000000] RIP memmap_init_zone+0xb5/0x130
> 
> (gdb) list *0xffffffff807cddb5
> 0xffffffff807cddb5 is in memmap_init_zone (include/linux/list.h:32).
> 27      #define LIST_HEAD(name) \
> 28              struct list_head name = LIST_HEAD_INIT(name)
> 29
> 30      static inline void INIT_LIST_HEAD(struct list_head *list)
> 31      {
> 32              list->next = list;
> 33              list->prev = list;
> 34      }
> 35
> 36      /*
>
> I will test more tomorrow...

Thanks.  Please send the .config?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
