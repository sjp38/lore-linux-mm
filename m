Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 04F1C6B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 06:49:42 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: oom-killer killing even if memory is available?
Date: Tue, 17 Mar 2009 21:49:35 +1100
References: <20090317100049.33f67964@osiris.boeblingen.de.ibm.com> <20090317111738.3cd32fa4@osiris.boeblingen.de.ibm.com> <20090317112842.3b8e7724@osiris.boeblingen.de.ibm.com>
In-Reply-To: <20090317112842.3b8e7724@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903172149.36136.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andreas Krebbel <krebbel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 17 March 2009 21:28:42 Heiko Carstens wrote:
> On Tue, 17 Mar 2009 11:17:38 +0100
>
> Heiko Carstens <heiko.carstens@de.ibm.com> wrote:
> > On Tue, 17 Mar 2009 02:46:05 -0700
> >
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> > > > Mar 16 21:40:40 t6360003 kernel: Active_anon:372 active_file:45
> > > > inactive_anon:154 Mar 16 21:40:40 t6360003 kernel:  inactive_file:152
> > > > unevictable:987 dirty:0 writeback:188 unstable:0 Mar 16 21:40:40
> > > > t6360003 kernel:  free:146348 slab:875833 mapped:805 pagetables:378
> > > > bounce:0 Mar 16 21:40:40 t6360003 kernel: DMA free:467728kB
> > > > min:4064kB low:5080kB high:6096kB active_anon:0kB inactive_anon:0kB
> > > > active_file:0kB inactive_file:116kB unevictable:0kB present:2068480kB
> > > > pages_scanned:0 all_unreclaimable? no Mar 16 21:40:40 t6360003
> > > > kernel: lowmem_reserve[]: 0 2020 2020 Mar 16 21:40:40 t6360003
> > > > kernel: Normal free:117664kB min:4064kB low:5080kB high:6096kB
> > > > active_anon:1488kB inactive_anon:616kB active_file:188kB
> > > > inactive_file:492kB unevictable:3948kB present:2068480kB
> > > > pages_scanned:128 all_unreclaimable? no Mar 16 21:40:40 t6360003
> > > > kernel: lowmem_reserve[]: 0 0 0
> > >
> > > The scanner has wrung pretty much all it can out of the reclaimable
> > > pages - the LRUs are nearly empty.  There's a few hundred MB free and
> > > apparently we don't have four physically contiguous free pages
> > > anywhere.  It's believeable.
> > >
> > > The question is: where the heck did all your memory go?  You have 2GB
> > > of ZONE_NORMAL memory in that machine, but only a tenth of it is
> > > visible to the page reclaim code.
> > >
> > > Something must have allocated (and possibly leaked) it.
> >
> > Looks like most of the memory went for dentries and inodes.
> > slabtop output:
> >
> >  Active / Total Objects (% used)    : 8172165 / 8326954 (98.1%)
> >  Active / Total Slabs (% used)      : 903692 / 903698 (100.0%)
> >  Active / Total Caches (% used)     : 91 / 144 (63.2%)
> >  Active / Total Size (% used)       : 3251262.44K / 3281384.22K (99.1%)
> >  Minimum / Average / Maximum Object : 0.02K / 0.39K / 1024.00K
> >
> >   OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
> > 3960036 3960017  99%    0.59K 660006        6   2640024K inode_cache
> > 4137155 3997581  96%    0.20K 217745       19    870980K dentry
> >  69776  69744  99%    0.80K  17444        4     69776K ext3_inode_cache
> >  96792  92892  95%    0.10K   2616       37     10464K buffer_head
> >  10024   9895  98%    0.54K   1432        7      5728K radix_tree_node
> >   1093   1087  99%    4.00K   1093        1      4372K size-4096
> >  14805  14711  99%    0.25K    987       15      3948K size-256
> >   2400   2381  99%    0.80K    480        5      1920K shmem_inode_cache
>
> FWIW, after "echo 3 > /proc/sys/vm/drop_caches" it looks like this:
>
>  Active / Total Objects (% used)    : 7965003 / 8153578 (97.7%)
>  Active / Total Slabs (% used)      : 882511 / 882511 (100.0%)
>  Active / Total Caches (% used)     : 90 / 144 (62.5%)
>  Active / Total Size (% used)       : 3173487.59K / 3211091.64K (98.8%)
>  Minimum / Average / Maximum Object : 0.02K / 0.39K / 1024.00K
>
>   OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
> 3960036 3960007  99%    0.59K 660006        6   2640024K inode_cache
> 4137155 3962636  95%    0.20K 217745       19    870980K dentry
>   1097   1097 100%    4.00K   1097        1      4388K size-4096
>  14805  14667  99%    0.25K    987       15      3948K size-256
>   2400   2381  99%    0.80K    480        5      1920K shmem_inode_cache
>   1404   1404 100%    1.00K    351        4      1404K size-1024
>    152    152 100%    5.59K    152        1      1216K task_struct
>   1302    347  26%    0.54K    186        7       744K radix_tree_node
>    370    359  97%    2.00K    185        2       740K size-2048
>   9381   4316  46%    0.06K    159       59       636K size-64
>      8      8 100%   64.00K      8        1       512K size-65536
>
> So, are we leaking dentries and inodes?

Yes, probably leaking dentries, which pin inodes. I don't know that slab
leak debugging is going to help you because it won't find what is holding
the refcount.

Cc linux-fsdevel. Which kernel this is? Config as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
