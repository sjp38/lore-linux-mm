Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2CCA06B02C6
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 01:45:38 -0400 (EDT)
Date: Fri, 20 Aug 2010 13:45:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] VM: kswapd should not do blocking memory allocations
Message-ID: <20100820054533.GB11847@localhost>
References: <1282158241.8540.85.camel@heimdal.trondhjem.org>
 <AANLkTi=WkoxjwZbt6Vd0VhbuA7_k2WM-NUXZnrmzOOPy@mail.gmail.com>
 <1282159872.8540.96.camel@heimdal.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1282159872.8540.96.camel@heimdal.trondhjem.org>
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Ram Pai <ram.n.pai@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Hi Ram,
> 
> I was seeing it on NFS until I put in the following kswapd-specific hack
> into nfs_release_page():
> 
> 	/* Only do I/O if gfp is a superset of GFP_KERNEL */
> 	if (mapping && (gfp & GFP_KERNEL) == GFP_KERNEL) {
> 		int how = FLUSH_SYNC;
> 
> 		/* Don't let kswapd deadlock waiting for OOM RPC calls */
> 		if (current_is_kswapd())
> 			how = 0;

So the patch can remove the above workaround together, and add comment
that NFS exploits the gfp mask to avoid complex operations involving
recursive memory allocation and hence deadlock?

Thanks,
Fengguang

> 		nfs_commit_inode(mapping->host, how);
> 	}
> 
> Remove the 'if (current_is_kswapd())' line, and run an mmap() write
> intensive workload, and it should hang pretty much every time.
> 
> Cheers
>   Trond
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
