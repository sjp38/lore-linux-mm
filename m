Message-ID: <48341A57.1030505@redhat.com>
Date: Wed, 21 May 2008 09:49:27 -0300
From: Glauber Costa <gcosta@redhat.com>
MIME-Version: 1.0
Subject: Re: 2.6.26: x86/kernel/pci_dma.c: gfp |= __GFP_NORETRY ?
References: <20080521113028.GA24632@xs4all.net>
In-Reply-To: <20080521113028.GA24632@xs4all.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miquel van Smoorenburg <miquels@cistron.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi-suse@firstfloor.org
List-ID: <linux-mm.kvack.org>

Miquel van Smoorenburg wrote:
> I've recently switched some of my boxes from a 32 to a
> 64 bit kernel. These are usenet server boxes that do
> a lot of I/O. They are running 2.6.24 / 2.6.25
> 
> Every 15 minutes a cronjob calls a management utility, tw_cli,
>  to read the raid status of the 3ware disk arrays. That
> often fails with a segmentation violation .. 
> 
> tw_cli: page allocation failure. order:0, mode:0x10d0
> Pid: 9296, comm: tw_cli Not tainted 2.6.25.4 #2
> 
> Call Trace:
>  [<ffffffff802604b6>] __alloc_pages+0x336/0x390
>  [<ffffffff80210ff4>] dma_alloc_pages+0x24/0xa0
>  [<ffffffff80211113>] dma_alloc_coherent+0xa3/0x2e0
>  [<ffffffff8804a58f>] :3w_9xxx:twa_chrdev_ioctl+0x11f/0x810
>  [<ffffffff802826c0>] chrdev_open+0x0/0x1c0
>  [<ffffffff8027d997>] __dentry_open+0x197/0x210
>  [<ffffffff8028c4ed>] vfs_ioctl+0x7d/0xa0
>  [<ffffffff8028c584>] do_vfs_ioctl+0x74/0x2d0
>  [<ffffffff8028c829>] sys_ioctl+0x49/0x80
>  [<ffffffff8020b29b>] system_call_after_swapgs+0x7b/0x80
> 
> Mem-info:
> DMA per-cpu:
> CPU    0: hi:    0, btch:   1 usd:   0
> CPU    1: hi:    0, btch:   1 usd:   0
> CPU    2: hi:    0, btch:   1 usd:   0
> CPU    3: hi:    0, btch:   1 usd:   0
> DMA32 per-cpu:
> CPU    0: hi:  186, btch:  31 usd:  60
> CPU    1: hi:  186, btch:  31 usd: 185
> CPU    2: hi:  186, btch:  31 usd: 176
> CPU    3: hi:  186, btch:  31 usd: 165
> Normal per-cpu:
> CPU    0: hi:  186, btch:  31 usd: 120
> CPU    1: hi:  186, btch:  31 usd: 164
> CPU    2: hi:  186, btch:  31 usd: 177
> CPU    3: hi:  186, btch:  31 usd: 182
> Active:265929 inactive:1657355 dirty:663189 writeback:62890 unstable:0
>  free:49079 slab:65923 mapped:1238 pagetables:927 bounce:0
> DMA free:12308kB min:184kB low:228kB high:276kB active:0kB inactive:0kB present:11816kB pages_scanned:0 all_unreclaimable? yes
> lowmem_reserve[]: 0 3255 8053 8053
> DMA32 free:94200kB min:52912kB low:66140kB high:79368kB active:440616kB inactive:2505772kB present:3333792kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 4797 4797
> Normal free:86792kB min:77968kB low:97460kB high:116952kB active:623100kB inactive:4126872kB present:4912640kB pages_scanned:32 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> DMA: 3*4kB 5*8kB 2*16kB 6*32kB 4*64kB 4*128kB 0*256kB 0*512kB 1*1024kB 1*2048kB 2*4096kB = 12308kB
> DMA32: 150*4kB 5*8kB 2299*16kB 120*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 13*4096kB = 94512kB
> Normal: 462*4kB 3803*8kB 123*16kB 24*32kB 2*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 18*4096kB = 109760kB
> 1653409 total pagecache pages
> Swap cache: add 5748, delete 5411, find 4317/4852
> Free swap  = 4588488kB
> Total swap = 4594580kB
> Free swap:       4588488kB
> 2293760 pages of RAM
> 249225 reserved pages
> 1658761 pages shared
> 337 pages swap cached
> 
> (this is easily reproducible by pinning a lot of memory with
>  mmap/mlock, say 6 GB on an 8 GB box, while running
>  cat /dev/zero > filename, then invoking tw_cli)
> 
> Now this appears to happen because dma_alloc_coherent() in
> pci-dma_64.c does this:
> 
>         /* Don't invoke OOM killer */
>         gfp |= __GFP_NORETRY;
> 
> However, if you read mm/page_alloc.c you can see that this not only
> prevents invoking the OOM killer, it also does what it says:
> no retries when allocating memory.
> 
> That means that dma_alloc_coherent(..., GFP_KERNEL) can become
> unreliable. Bad news.
> 
> pci-dma_32 does not do this.
> 
> And in 2.6.26-rc1, pci-dma_32.c and pci-dma_64.c were merged,
> so now the 32 bit kernel has the same problem.
> 
> Does anyone know why this was added on x86_64 ?
> 
> If not I think this patch should go into 2.6.26:
> 
> diff -ruN linux-2.6.26-rc3.orig/arch/x86/kernel/pci-dma.c linux-2.6.26-rc3/arch/x86/kernel/pci-dma.c
> --- linux-2.6.26-rc3.orig/arch/x86/kernel/pci-dma.c	2008-05-18 23:36:41.000000000 +0200
> +++ linux-2.6.26-rc3/arch/x86/kernel/pci-dma.c	2008-05-21 13:15:54.000000000 +0200
> @@ -397,9 +397,6 @@
>  	if (dev->dma_mask == NULL)
>  		return NULL;
>  
> -	/* Don't invoke OOM killer */
> -	gfp |= __GFP_NORETRY;
> -
>  #ifdef CONFIG_X86_64
>  	/* Why <=? Even when the mask is smaller than 4GB it is often
>  	   larger than 16MB and in this case we have a chance of
> 
> 
> Ideas ? Maybe a __GFP_NO_OOMKILLER ? 
probably andi has a better idea on why it was added, since it used to 
live in his tree?

> Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
