Date: Sat, 3 Jan 2004 22:27:06 +0000
From: Matthew Wilcox <willy@debian.org>
Subject: Re: [Kernel-janitors] [PATCH] Check return code in mm/vmscan.c
Message-ID: <20040103222706.GM6982@parcelfarce.linux.theplanet.co.uk>
References: <20040103132524.GA21909@eugeneteo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040103132524.GA21909@eugeneteo.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eugene Teo <eugene.teo@eugeneteo.net>
Cc: kernel-janitors@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jan 03, 2004 at 09:25:24PM +0800, Eugene Teo wrote:
> http://www.anomalistic.org/patches/vmscan-check-ret-kernel_thread-fix-2.6.1-rc1-mm1.patch
> 
> diff -Naur -X /home/amnesia/w/dontdiff 2.6.1-rc1-mm1/mm/vmscan.c 2.6.1-rc1-mm1-fix/mm/vmscan.c
> --- 2.6.1-rc1-mm1/mm/vmscan.c	2004-01-03 20:33:39.000000000 +0800
> +++ 2.6.1-rc1-mm1-fix/mm/vmscan.c	2004-01-03 21:16:30.000000000 +0800
> @@ -1093,10 +1093,16 @@
>  
>  static int __init kswapd_init(void)
>  {
> +	int ret;
>  	pg_data_t *pgdat;
>  	swap_setup();
> -	for_each_pgdat(pgdat)
> -		kernel_thread(kswapd, pgdat, CLONE_KERNEL);
> +	for_each_pgdat(pgdat) {
> +		ret = kernel_thread(kswapd, pgdat, CLONE_KERNEL);
> +		if (ret < 0) {
> +			printk("%s: unable to start kernel thread\n", __FUNCTION__);
> +			return ret;
> +		}
> +	}
>  	total_memory = nr_free_pagecache_pages();
>  	return 0;
>  }

If your new code is triggered, we've just failed to set up total_memory.
I expect the system to behave very oddly after this ;-)

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
