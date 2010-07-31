Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4D6A96B02AC
	for <linux-mm@kvack.org>; Sat, 31 Jul 2010 13:55:59 -0400 (EDT)
Received: by iwn2 with SMTP id 2so2908675iwn.14
        for <linux-mm@kvack.org>; Sat, 31 Jul 2010 10:55:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100731173328.GA21072@infradead.org>
References: <20100728071705.GA22964@localhost>
	<20100731161358.GA5147@localhost>
	<20100731173328.GA21072@infradead.org>
Date: Sat, 31 Jul 2010 20:55:57 +0300
Message-ID: <AANLkTi=+muw_2jWq1QKsxp6A_fAtdhdns7MD_bKQo-72@mail.gmail.com>
Subject: Re: [PATCH] vmscan: raise the bar to PAGEOUT_IO_SYNC stalls
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jul 31, 2010 at 8:33 PM, Christoph Hellwig <hch@infradead.org> wrot=
e:
> On Sun, Aug 01, 2010 at 12:13:58AM +0800, Wu Fengguang wrote:
>> FYI I did some memory stress test and find there are much more order-1
>> (and higher) users than fork(). This means lots of running applications
>> may stall on direct reclaim.
>>
>> Basically all of these slab caches will do high order allocations:
>
> It looks much, much worse on my system. =A0Basically all inode structures=
,
> and also tons of frequently allocated xfs structures fall into this
> category, =A0None of them actually anywhere near the size of a page, whic=
h
> makes me wonder why we do such high order allocations:

Do you have CONFIG_SLUB enabled? It does high order allocations by
default for performance reasons.

> slabinfo - version: 2.1
> # name =A0 =A0 =A0 =A0 =A0 =A0<active_objs> <num_objs> <objsize> <objpers=
lab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabda=
ta <active_slabs> <num_slabs> <sharedavail>
> nfsd4_stateowners =A0 =A0 =A00 =A0 =A0 =A00 =A0 =A0424 =A0 19 =A0 =A02 : =
tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A00 =A0 =A0 =A00 =
=A0 =A0 =A00
> kvm_vcpu =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A00 =A010400 =A0 =A03 =A0=
 =A08 : tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A00 =A0 =A0=
 =A00 =A0 =A0 =A00
> kmalloc_dma-512 =A0 =A0 =A0 32 =A0 =A0 32 =A0 =A0512 =A0 16 =A0 =A02 : tu=
nables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A02 =A0 =A0 =A02 =A0 =
=A0 =A00
> mqueue_inode_cache =A0 =A0 18 =A0 =A0 18 =A0 =A0896 =A0 18 =A0 =A04 : tun=
ables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A01 =A0 =A0 =A01 =A0 =
=A0 =A00
> xfs_inode =A0 =A0 =A0 =A0 279008 279008 =A0 1024 =A0 16 =A0 =A04 : tunabl=
es =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A017438 =A017438 =A0 =A0 =A00
> xfs_efi_item =A0 =A0 =A0 =A0 =A044 =A0 =A0 44 =A0 =A0360 =A0 22 =A0 =A02 =
: tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A02 =A0 =A0 =A02 =
=A0 =A0 =A00
> xfs_efd_item =A0 =A0 =A0 =A0 =A044 =A0 =A0 44 =A0 =A0368 =A0 22 =A0 =A02 =
: tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A02 =A0 =A0 =A02 =
=A0 =A0 =A00
> xfs_trans =A0 =A0 =A0 =A0 =A0 =A0 40 =A0 =A0 40 =A0 =A0800 =A0 20 =A0 =A0=
4 : tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A02 =A0 =A0 =A0=
2 =A0 =A0 =A00
> xfs_da_state =A0 =A0 =A0 =A0 =A032 =A0 =A0 32 =A0 =A0488 =A0 16 =A0 =A02 =
: tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A02 =A0 =A0 =A02 =
=A0 =A0 =A00
> nfs_inode_cache =A0 =A0 =A0 =A00 =A0 =A0 =A00 =A0 1016 =A0 16 =A0 =A04 : =
tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A00 =A0 =A0 =A00 =
=A0 =A0 =A00
> isofs_inode_cache =A0 =A0 =A00 =A0 =A0 =A00 =A0 =A0632 =A0 25 =A0 =A04 : =
tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A00 =A0 =A0 =A00 =
=A0 =A0 =A00
> fat_inode_cache =A0 =A0 =A0 =A00 =A0 =A0 =A00 =A0 =A0664 =A0 12 =A0 =A02 =
: tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A00 =A0 =A0 =A00 =
=A0 =A0 =A00
> hugetlbfs_inode_cache =A0 =A0 14 =A0 =A0 14 =A0 =A0584 =A0 14 =A0 =A02 : =
tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A01 =A0 =A0 =A01 =
=A0 =A0 =A00
> ext4_inode_cache =A0 =A0 =A0 0 =A0 =A0 =A00 =A0 =A0968 =A0 16 =A0 =A04 : =
tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A00 =A0 =A0 =A00 =
=A0 =A0 =A00
> ext2_inode_cache =A0 =A0 =A021 =A0 =A0 21 =A0 =A0776 =A0 21 =A0 =A04 : tu=
nables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A01 =A0 =A0 =A01 =A0 =
=A0 =A00
> ext3_inode_cache =A0 =A0 =A0 0 =A0 =A0 =A00 =A0 =A0800 =A0 20 =A0 =A04 : =
tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A00 =A0 =A0 =A00 =
=A0 =A0 =A00
> rpc_inode_cache =A0 =A0 =A0 19 =A0 =A0 19 =A0 =A0832 =A0 19 =A0 =A04 : tu=
nables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A01 =A0 =A0 =A01 =A0 =
=A0 =A00
> UDP-Lite =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A00 =A0 =A0768 =A0 21 =A0=
 =A04 : tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A00 =A0 =A0=
 =A00 =A0 =A0 =A00
> ip_dst_cache =A0 =A0 =A0 =A0 170 =A0 =A0378 =A0 =A0384 =A0 21 =A0 =A02 : =
tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 18 =A0 =A0 18 =A0 =
=A0 =A00
> RAW =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 63 =A0 =A0 63 =A0 =A0768 =A0 21 =
=A0 =A04 : tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A03 =A0 =
=A0 =A03 =A0 =A0 =A00
> UDP =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 52 =A0 =A0 84 =A0 =A0768 =A0 21 =
=A0 =A04 : tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A04 =A0 =
=A0 =A04 =A0 =A0 =A00
> TCP =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 60 =A0 =A0100 =A0 1600 =A0 20 =A0=
 =A08 : tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A05 =A0 =A0=
 =A05 =A0 =A0 =A00
> blkdev_queue =A0 =A0 =A0 =A0 =A042 =A0 =A0 42 =A0 2216 =A0 14 =A0 =A08 : =
tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A03 =A0 =A0 =A03 =
=A0 =A0 =A00
> sock_inode_cache =A0 =A0 650 =A0 =A0713 =A0 =A0704 =A0 23 =A0 =A04 : tuna=
bles =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 31 =A0 =A0 31 =A0 =A0 =
=A00
> skbuff_fclone_cache =A0 =A0 36 =A0 =A0 36 =A0 =A0448 =A0 18 =A0 =A02 : tu=
nables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A02 =A0 =A0 =A02 =A0 =
=A0 =A00
> shmem_inode_cache =A0 3620 =A0 3948 =A0 =A0776 =A0 21 =A0 =A04 : tunables=
 =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0188 =A0 =A0188 =A0 =A0 =A00
> proc_inode_cache =A0 =A01818 =A0 1875 =A0 =A0632 =A0 25 =A0 =A04 : tunabl=
es =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 75 =A0 =A0 75 =A0 =A0 =A00
> bdev_cache =A0 =A0 =A0 =A0 =A0 =A057 =A0 =A0 57 =A0 =A0832 =A0 19 =A0 =A0=
4 : tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A03 =A0 =A0 =A0=
3 =A0 =A0 =A00
> inode_cache =A0 =A0 =A0 =A0 7934 =A0 7938 =A0 =A0584 =A0 14 =A0 =A02 : tu=
nables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0567 =A0 =A0567 =A0 =A0 =
=A00
> files_cache =A0 =A0 =A0 =A0 =A0689 =A0 =A0713 =A0 =A0704 =A0 23 =A0 =A04 =
: tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 31 =A0 =A0 31 =A0 =
=A0 =A00
> signal_cache =A0 =A0 =A0 =A0 301 =A0 =A0342 =A0 =A0896 =A0 18 =A0 =A04 : =
tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 19 =A0 =A0 19 =A0 =
=A0 =A00
> sighand_cache =A0 =A0 =A0 =A0192 =A0 =A0210 =A0 2112 =A0 15 =A0 =A08 : tu=
nables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 14 =A0 =A0 14 =A0 =A0 =
=A00
> task_struct =A0 =A0 =A0 =A0 =A0311 =A0 =A0325 =A0 5616 =A0 =A05 =A0 =A08 =
: tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 65 =A0 =A0 65 =A0 =
=A0 =A00
> idr_layer_cache =A0 =A0 =A0578 =A0 =A0585 =A0 =A0544 =A0 15 =A0 =A02 : tu=
nables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 39 =A0 =A0 39 =A0 =A0 =
=A00
> radix_tree_node =A0 =A074738 =A074802 =A0 =A0560 =A0 14 =A0 =A02 : tunabl=
es =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 5343 =A0 5343 =A0 =A0 =A00
> kmalloc-8192 =A0 =A0 =A0 =A0 =A029 =A0 =A0 32 =A0 8192 =A0 =A04 =A0 =A08 =
: tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A08 =A0 =A0 =A08 =
=A0 =A0 =A00
> kmalloc-4096 =A0 =A0 =A0 =A0 194 =A0 =A0208 =A0 4096 =A0 =A08 =A0 =A08 : =
tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 26 =A0 =A0 26 =A0 =
=A0 =A00
> kmalloc-2048 =A0 =A0 =A0 =A0 310 =A0 =A0352 =A0 2048 =A0 16 =A0 =A08 : tu=
nables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 22 =A0 =A0 22 =A0 =A0 =
=A00
> kmalloc-1024 =A0 =A0 =A0 =A01607 =A0 1616 =A0 1024 =A0 16 =A0 =A04 : tuna=
bles =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0101 =A0 =A0101 =A0 =A0 =
=A00
> kmalloc-512 =A0 =A0 =A0 =A0 =A0484 =A0 =A0512 =A0 =A0512 =A0 16 =A0 =A02 =
: tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 32 =A0 =A0 32 =A0 =
=A0 =A00
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
