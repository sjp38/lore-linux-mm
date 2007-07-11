Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6BIku1N024834
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 14:46:56 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6BIkifQ231956
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 12:46:49 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6BIkiMH028035
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 12:46:44 -0600
Date: Wed, 11 Jul 2007 11:46:43 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 10/12] Memoryless nodes: Update memory policy and page migration
Message-ID: <20070711184643.GA32035@us.ibm.com>
References: <20070711182219.234782227@sgi.com> <20070711182252.138829364@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070711182252.138829364@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 11.07.2007 [11:22:29 -0700], Christoph Lameter wrote:
> Online nodes now may have no memory. The checks and initialization must therefore
> be changed to no longer use the online functions.
> 
> This will correctly initialize the interleave on bootup to only target
> nodes with memory and will make sys_move_pages return an error when a page
> is to be moved to a memoryless node. Similarly we will get an error if
> MPOL_BIND and MPOL_INTERLEAVE is used on a memoryless node.
> 
> These are somewhat new semantics. So far one could specify memoryless nodes
> and we would maybe do the right thing and just ignore the node (or we'd do
> something strange like with MPOL_INTERLEAVE). If we want to allow the
> specification of memoryless nodes via memory policies then we need to keep
> checking for online nodes.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> ---
>  mm/mempolicy.c |   10 +++++-----
>  mm/migrate.c   |    2 +-
>  2 files changed, 6 insertions(+), 6 deletions(-)
> 
> Index: linux-2.6.22-rc6-mm1/mm/migrate.c
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/mm/migrate.c	2007-07-09 21:23:18.000000000 -0700
> +++ linux-2.6.22-rc6-mm1/mm/migrate.c	2007-07-11 10:37:03.000000000 -0700
> @@ -963,7 +963,7 @@ asmlinkage long sys_move_pages(pid_t pid
>  				goto out;
> 
>  			err = -ENODEV;
> -			if (!node_online(node))
> +			if (!node_memory(node))

			if (!node_state(node, N_MEMORY))

?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
