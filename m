Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B7A956B02A7
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 19:33:24 -0400 (EDT)
Date: Thu, 5 Aug 2010 16:34:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 07/13] writeback: explicit low bound for vm.dirty_ratio
Message-Id: <20100805163401.e9754032.akpm@linux-foundation.org>
In-Reply-To: <20100805162433.673243074@intel.com>
References: <20100805161051.501816677@intel.com>
	<20100805162433.673243074@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 06 Aug 2010 00:10:58 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> Force a user visible low bound of 5% for the vm.dirty_ratio interface.
> 
> Currently global_dirty_limits() applies a low bound of 5% for
> vm_dirty_ratio.  This is not very user visible -- if the user sets
> vm.dirty_ratio=1, the operation seems to succeed but will be rounded up
> to 5% when used.
> 
> Another problem is inconsistency: calc_period_shift() uses the plain
> vm_dirty_ratio value, which may be a problem when vm.dirty_ratio is set
> to < 5 by the user.

The changelog describes the old behaviour but doesn't describe the
proposed new behaviour.

> --- linux-next.orig/kernel/sysctl.c	2010-08-05 22:48:34.000000000 +0800
> +++ linux-next/kernel/sysctl.c	2010-08-05 22:48:47.000000000 +0800
> @@ -126,6 +126,7 @@ static int ten_thousand = 10000;
>  
>  /* this is needed for the proc_doulongvec_minmax of vm_dirty_bytes */
>  static unsigned long dirty_bytes_min = 2 * PAGE_SIZE;
> +static int dirty_ratio_min = 5;
>  
>  /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
>  static int maxolduid = 65535;
> @@ -1031,7 +1032,7 @@ static struct ctl_table vm_table[] = {
>  		.maxlen		= sizeof(vm_dirty_ratio),
>  		.mode		= 0644,
>  		.proc_handler	= dirty_ratio_handler,
> -		.extra1		= &zero,
> +		.extra1		= &dirty_ratio_min,
>  		.extra2		= &one_hundred,
>  	},

I forget how the procfs core handles this.  Presumably the write will
now fail with -EINVAL or something?  So people's scripts will now
error out and their space shuttles will crash?

All of which illustrates why it's important to fully describe changes
in the changelog!  So people can consider and discuss the end-user
implications of a change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
