Date: Mon, 29 Mar 2004 12:50:20 -0500 (EST)
From: Rajesh Venkatasubramanian <vrajesh@umich.edu>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity
 fix
In-Reply-To: <20040329172248.GR3808@dualathlon.random>
Message-ID: <Pine.GSO.4.58.0403291240040.14450@eecs2340u20.engin.umich.edu>
References: <Pine.LNX.4.44.0403150527400.28579-100000@localhost.localdomain>
 <Pine.GSO.4.58.0403211634350.10248@azure.engin.umich.edu>
 <20040325225919.GL20019@dualathlon.random> <Pine.GSO.4.58.0403252258170.4298@azure.engin.umich.edu>
 <20040326075343.GB12484@dualathlon.random> <Pine.LNX.4.58.0403261013480.672@ruby.engin.umich.edu>
 <20040326175842.GC9604@dualathlon.random> <Pine.GSO.4.58.0403271448120.28539@sapphire.engin.umich.edu>
 <20040329172248.GR3808@dualathlon.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


>  #define VN_MAPPED(vp)	\
> -	(!list_empty(&(LINVFS_GET_IP(vp)->i_mapping->i_mmap)) || \
> -	(!list_empty(&(LINVFS_GET_IP(vp)->i_mapping->i_mmap_shared))))
> +	(!prio_tree_empty(&(LINVFS_GET_IP(vp)->i_mapping->i_mmap)) || \
> +	(!prio_tree_empty(&(LINVFS_GET_IP(vp)->i_mapping->i_mmap_shared))))

I think we will need the following too:
	(!list_empty(&(LINVFS_GET_IP(vp)->i_mmaping->i_mmap_nonlinear)


>  	down(&mapping->i_shared_sem);
> -	list_for_each_entry(vma, &mapping->i_mmap_shared, shared) {
> +	vma = __vma_prio_tree_first(&mapping->i_mmap_shared, &iter, 0, ULONG_MAX);
> +	while (vma) {
>  		if (!(vma->vm_flags & VM_DENYWRITE)) {
>  			prohibited |= (1 << DM_EVENT_WRITE);
>  			break;
>  		}
> +
> +		vma = __vma_prio_tree_next(vma, &mapping->i_mmap_shared, &iter, 0, ULONG_MAX);
>  	}

This part looks fine. But, I am not sure whether you have to handle
nonlinear maps here.

	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared) {
		...
	}

>  	up(&mapping->i_shared_sem);
>  #else

Hope that helps.

Rajesh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
