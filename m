Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 55FF4600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 13:28:46 -0500 (EST)
Date: Mon, 30 Nov 2009 18:28:41 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] mm: don't discard unused swap slots by default
In-Reply-To: <20091130172243.GA30779@lst.de>
Message-ID: <Pine.LNX.4.64.0911301752070.10043@sister.anvils>
References: <20091030065102.GA2896@lst.de> <Pine.LNX.4.64.0910301629030.4106@sister.anvils>
 <20091118171232.GB25541@lst.de> <20091130172243.GA30779@lst.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <jens.axboe@oracle.com>, Matthew Wilcox <matthew@wil.cx>, linux-mm@kvack.org, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Nov 2009, Christoph Hellwig wrote:

> Current TRIM/UNMAP/etc implementation are slow enough that discarding
> small chunk during run time is a bad idea.  So only discard the whole
> swap space on swapon by default, but require the admin to enable it
> for run-time discards using the new vm.discard_swapspace sysctl.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Thanks: you having suggested it, I guess it's no coincidence that
this looks a little like what I'm currently experimenting with, on
2.6.32-rc8-mm1 which contains your mods, on Vertex with 1.4 firmware.

There's several variables (not the least my own idiocy), and too soon
for me to say anything definite; but the impression I'm getting from
numbers so far is that (on that SSD anyway) the dubious discards from
SWP_DISCARDABLE are actually beneficial - more so than the initial
discard of the whole partition.

Each SWP_DISCARDABLE discard is of a 1MB range (if 4kB pagesize, and
if swap partition - if swapping to fragmented regular file, they would
often be of less, so indeed less efficient).

Please could you send me, on or offlist, the tests you have which show
them to be worth suppressing?  I do prefer to avoid tunables if we can;
and although this sysctl you suggested is the easiest way, it doesn't
seem the correct way.

Something in /sys/block/<device>/queue/ would be more correct: but
perhaps more trouble than it's worth; and so very specific to swap
(and whatever mm/swapfile.c happens to be doing in any release)
that it wouldn't belong very well there either.

You mentioned an "-o discard" mount option before: so I think what
we ought to be doing is an option to swapon.  But you can imagine
that I'd prefer to avoid that too, if we can work this out without it.

If I could see how bad these SWP_DISCARDABLE discards are for
myself, I might for the moment prefer just to cut out that code,
until we can be more intelligent about it (instead of fixing visible
sysctl/sysfs/swapon options which limit to the current implementation).

Thanks,
Hugh

> 
> Index: linux-2.6/include/linux/swap.h
> ===================================================================
> --- linux-2.6.orig/include/linux/swap.h	2009-11-27 11:50:47.319003920 +0100
> +++ linux-2.6/include/linux/swap.h	2009-11-27 11:51:55.617286868 +0100
> @@ -247,6 +247,7 @@ extern unsigned long mem_cgroup_shrink_n
>  extern int __isolate_lru_page(struct page *page, int mode, int file);
>  extern unsigned long shrink_all_memory(unsigned long nr_pages);
>  extern int vm_swappiness;
> +extern int vm_discard_swapspace;
>  extern int remove_mapping(struct address_space *mapping, struct page *page);
>  extern long vm_total_pages;
>  
> Index: linux-2.6/kernel/sysctl.c
> ===================================================================
> --- linux-2.6.orig/kernel/sysctl.c	2009-11-27 11:49:02.935254088 +0100
> +++ linux-2.6/kernel/sysctl.c	2009-11-27 11:53:10.333006621 +0100
> @@ -1163,6 +1163,16 @@ static struct ctl_table vm_table[] = {
>  		.extra1		= &zero,
>  		.extra2		= &one_hundred,
>  	},
> +	{
> +		.ctl_name	= CTL_UNNUMBERED,
> +		.procname	= "discard_swapspace",
> +		.data		= &vm_discard_swapspace,
> +		.maxlen		= sizeof(vm_discard_swapspace),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_dointvec_minmax,
> +		.extra1		= &zero,
> +		.extra2		= &one,
> +	},
>  #ifdef CONFIG_HUGETLB_PAGE
>  	 {
>  		.procname	= "nr_hugepages",
> Index: linux-2.6/mm/swapfile.c
> ===================================================================
> --- linux-2.6.orig/mm/swapfile.c	2009-11-27 11:53:19.449254088 +0100
> +++ linux-2.6/mm/swapfile.c	2009-11-27 11:54:07.883255931 +0100
> @@ -41,6 +41,7 @@ long nr_swap_pages;
>  long total_swap_pages;
>  static int swap_overflow;
>  static int least_priority;
> +int vm_discard_swapspace;
>  
>  static const char Bad_file[] = "Bad swap file entry ";
>  static const char Unused_file[] = "Unused swap file entry ";
> @@ -1978,7 +1979,7 @@ SYSCALL_DEFINE2(swapon, const char __use
>  			p->flags |= SWP_SOLIDSTATE;
>  			p->cluster_next = 1 + (random32() % p->highest_bit);
>  		}
> -		if (discard_swap(p) == 0)
> +		if (discard_swap(p) == 0 && vm_discard_swapspace)
>  			p->flags |= SWP_DISCARDABLE;
>  	}
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
