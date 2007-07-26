Received: by py-out-1112.google.com with SMTP id f31so2041133pyh
        for <linux-mm@kvack.org>; Thu, 26 Jul 2007 10:54:14 -0700 (PDT)
Message-ID: <64bb37e0707261054j25691afnb1bbf3484af855f3@mail.gmail.com>
Date: Thu, 26 Jul 2007 19:54:13 +0200
From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.23-rc1-mm1
In-Reply-To: <20070726002543.de303fd7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070725040304.111550f4.akpm@linux-foundation.org>
	 <46A7411C.80202@fr.ibm.com> <200707251323.04594.lenb@kernel.org>
	 <20070725115804.5b8efe83.akpm@linux-foundation.org>
	 <64bb37e0707251213t6edcb0a5sabcf4a923c19bde7@mail.gmail.com>
	 <64bb37e0707251322w38d19814pacea61d8cf69be63@mail.gmail.com>
	 <20070725133655.849574b5.akpm@linux-foundation.org>
	 <64bb37e0707251452u6bca43b6i2618bf6e54972dbc@mail.gmail.com>
	 <20070726002543.de303fd7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Len Brown <lenb@kernel.org>, Cedric Le Goater <clg@fr.ibm.com>, linux-kernel@vger.kernel.org, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/26/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 25 Jul 2007 23:52:47 +0200 "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:
>
> > On 7/25/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > > On Wed, 25 Jul 2007 22:22:41 +0200
> > > "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:
> > > > [    0.000000] early_node_map[4] active PFN ranges
> > > > [    0.000000]     0:        0 ->      159
> > > > [    0.000000]     0:      256 ->   524288
> > > > [    0.000000]     1:   524288 ->   917488
> > > > [    0.000000]     1:  1048576 ->  1179648
> > > > PANIC: early exception rip ffffffff807caac5 error 2 cr2 ffffe20003000010
> > > > [    0.000000]
> > > > [    0.000000] Call Trace:
> > > >
> > > > ... but no Call Trace follows.
> > > >
> > > > (gdb) list *0xffffffff807caac5
> > > > 0xffffffff807caac5 is in memmap_init_zone (include/linux/list.h:32).
> > > > 27      #define LIST_HEAD(name) \
> > > > 28              struct list_head name = LIST_HEAD_INIT(name)
> > > > 29
> > > > 30      static inline void INIT_LIST_HEAD(struct list_head *list)
> > > > 31      {
> > > > 32              list->next = list;
> > > > 33              list->prev = list;
> > > > 34      }
> > > > 35
> > > > 36      /*
> > > >
> > > > Torsten
> > >
> > > Quite a few people have been playing in that area.  Can you please send the
> > > .config?
> >
> > #
> > # Automatically generated make config: don't edit
> > # Linux kernel version: 2.6.23-rc1-mm1
> > # Wed Jul 25 21:18:15 2007
>
> It boots OK on my test box, bummer.  Please test -mm2 and if it also fails,

I will test it...

> it'd be great if you could run through
> http://www.zip.com.au/~akpm/linux/patches/stuff/bisecting-mm-trees.txt - it
> doesn't take very long.

I did two major changes when upgrading from 22-rc6-mm1 to 23-rc1-mm1.
I switched from DISCONTIGMEM to SPARSEMEM and from SLAB to SLUB.

The other combinations:
SPARSEMEM+SLAB:
[    0.000000] early_node_map[4] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   524288
[    0.000000]     1:   524288 ->   917488
[    0.000000]     1:  1048576 ->  1179648
PANIC: early exception rip ffffffff807c4ac5 error 2 cr2 ffffe20003000010
[    0.000000]
[    0.000000] Call Trace:
DISCONTIGMEM+SLUB:
[   39.833272] ..MP-BIOS bug: 8254 timer not connected to IO-APIC
[   40.016659] Kernel panic - not syncing: IO-APIC + timer doesn't
work! Try using the 'noapic' kernel parameter
DISCONTIGMEM+SLAB:
Boots until it can't find / because I didn't append the correct initrd
It also hit the MP-BIOS bug, but was not bothered by it:
[   36.696965] ..MP-BIOS bug: 8254 timer not connected to IO-APIC
[   36.880537] Using local APIC timer interrupts.
[   36.932215] result 12500283
[   36.940581] Detected 12.500 MHz APIC timer.

So I think, I will postpone SPARSEMEM until -mm2, as there are seem to
be some problems in that area (Re: 2.6.23-rc1-mm1 sparsemem_vmemamp
fix)

But maybee I will get SLUB to work. ;)

Torsten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
