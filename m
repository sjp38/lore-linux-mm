Message-ID: <3D3F893D.4074CDE5@zip.com.au>
Date: Wed, 24 Jul 2002 22:14:37 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: page_add/remove_rmap costs
References: <3D3E4A30.8A108B45@zip.com.au> <20020725045040.GD2907@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> On Tue, Jul 23, 2002 at 11:33:20PM -0700, Andrew Morton wrote:
> > Been taking a look at the page_add_rmap/page_remove_rmap cost in 2.5.27
> > on the quad pIII.  The workload is ten instances of this script running
> > concurrently:
> 
> The workload is 16 instances of the same script running on a 16 cpu NUMA-Q
> with 16GB of RAM. oprofile results attached.

These results look funny.

What I do is:

1) rm -rf /var/opd
2) start test
3) op_start --map-file=/boot/System.map --vmlinux=/boot/vmlinux --ctr0-event=CPU_CLK_UNHALTED --ctr0-count=600000
4) sleep 20
5) op_stop
6) oprofpp -l -i /boot/vmlinux


> 
> c0105340 3309367  51.0125     default_idle            /boot/vmlinux-2.5.28-3

How come?

> c0135667 1095488  16.8865     .text.lock.page_alloc   /boot/vmlinux-2.5.28-3

zone->lock?

> 00000fec 475107   7.32358     dump_one                /lib/modules/2.5.28-3/kern

that's part of oprofile.

> el/arch/i386/oprofile/oprofile.o
> c0129c10 349662   5.3899      do_anonymous_page       /boot/vmlinux-2.5.28-3

OK.

> c01353e4 236718   3.64891     get_page_state          /boot/vmlinux-2.5.28-3

whoa.  Who's calling that so often?  Any patches applied there?

> c0112a84 213189   3.28622     load_balance            /boot/vmlinux-2.5.28-3

I thought you'd disabled this?

> c013d31c 71599    1.10367     page_add_rmap           /boot/vmlinux-2.5.28-3
> c013d3cc 67122    1.03466     page_remove_rmap        /boot/vmlinux-2.5.28-3

page_add_rmap is more expensive than page_remove_rmap.
So again, the list length isn't the #1 problem.

> c013d85a 64302    0.991189    .text.lock.rmap         /boot/vmlinux-2.5.28-3

pte_chain_freelist_lock?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
