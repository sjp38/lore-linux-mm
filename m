Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 3DD8C6B007D
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 17:10:23 -0400 (EDT)
Date: Mon, 22 Oct 2012 14:10:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 1/2]swap: add a simple buddy allocator
Message-Id: <20121022141021.40cac432.akpm@linux-foundation.org>
In-Reply-To: <20121022023051.GA20255@kernel.org>
References: <20121022023051.GA20255@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com

On Mon, 22 Oct 2012 10:30:51 +0800
Shaohua Li <shli@kernel.org> wrote:

> I'm using a fast SSD to do swap. scan_swap_map() sometimes uses up to 20~30%
> CPU time (when cluster is hard to find), which becomes a bottleneck.
> scan_swap_map() scans a byte array to search a 256 page cluster, which is very
> slow.
> 
> Here I introduced a simple buddy allocator. Since we only care about 256 pages
> cluster, we can just use a counter to implement the buddy allocator. Every 256
> pages use one int to store the counter, so searching cluster is very efficient.
> With this, scap_swap_map() overhead disappears.
> 
> This might help low end SD card swap too. Because if the cluster is aligned, SD
> firmware can do flash erase more efficiently.
> 
> The downside is the cluster must be aligned to 256 pages, which will reduce the
> chance to find a cluster.
> 

hm.  How serious is this downside?

>
> ...
>
> @@ -2020,12 +2052,19 @@ SYSCALL_DEFINE2(swapon, const char __use
>  		goto bad_swap;
>  	}
>  
> +	swap_cluster_count = vzalloc(DIV_ROUND_UP(maxpages, SWAPFILE_CLUSTER) *
> +					sizeof(int));

[ Actually sizeof(unsigned int).  Or, probably safer, sizeof(*swap_cluster_count)]

How large is this allocation?  swap-size-in-bytes/256k, methinks.  So
64kbytes for a 16G swap partition?  That sounds acceptable.  Something
like lib/flex_array.c could be used here perhaps, although that would
involve memory allocations at awkward times.

> +	if (!swap_cluster_count) {
> +		error = -ENOMEM;
> +		goto bad_swap;
> +	}

I shall await Hugh review on this patchset ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
