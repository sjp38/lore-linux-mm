Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 658B182F64
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 17:15:14 -0400 (EDT)
Received: by qkas79 with SMTP id s79so23865385qka.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 14:15:14 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h64si2580193qgd.18.2015.09.30.14.15.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 14:15:13 -0700 (PDT)
Date: Wed, 30 Sep 2015 14:15:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: swap: Use swap_lock to prevent parallel swapon
 activations instead of i_mutex
Message-Id: <20150930141512.afaea9f25d85d80ba4fc5b84@linux-foundation.org>
In-Reply-To: <20150929142347.GK3068@techsingularity.net>
References: <20150929142347.GK3068@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Jerome Marchand <jmarchan@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Hugh Dickins <hughd@google.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Theodore Ts'o <tytso@mit.edu>

On Tue, 29 Sep 2015 15:23:47 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:

> Jerome Marchand reported a lockdep warning as follows
> 
>     [ 6819.501009] =================================
>     [ 6819.501009] [ INFO: inconsistent lock state ]
>     [ 6819.501009] 4.2.0-rc1-shmacct-babka-v2-next-20150709+ #255 Not tainted
>     [ 6819.501009] ---------------------------------
>     [ 6819.501009] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
>     [ 6819.501009] kswapd0/38 [HC0[0]:SC0[0]:HE1:SE1] takes:
>     [ 6819.501009]  (&sb->s_type->i_mutex_key#17){+.+.?.}, at: [<ffffffffa03772a5>] nfs_file_direct_write+0x85/0x3f0 [nfs]
>     [ 6819.501009] {RECLAIM_FS-ON-W} state was registered at:
>     [ 6819.501009]   [<ffffffff81107f51>] mark_held_locks+0x71/0x90
>     [ 6819.501009]   [<ffffffff8110b775>] lockdep_trace_alloc+0x75/0xe0
>     [ 6819.501009]   [<ffffffff81245529>] kmem_cache_alloc_node_trace+0x39/0x440
>     [ 6819.501009]   [<ffffffff81225b8f>] __get_vm_area_node+0x7f/0x160
>     [ 6819.501009]   [<ffffffff81226eb2>] __vmalloc_node_range+0x72/0x2c0
>     [ 6819.501009]   [<ffffffff81227424>] vzalloc+0x54/0x60
>     [ 6819.501009]   [<ffffffff8122c7c8>] SyS_swapon+0x628/0xfc0
>     [ 6819.501009]   [<ffffffff81867772>] entry_SYSCALL_64_fastpath+0x12/0x76
> 
> It's due to NFS acquiring i_mutex since a9ab5e840669 ("nfs: page
> cache invalidation for dio") to invalidate page cache before direct I/O.
> Filesystems may safely acquire i_mutex during direct writes but NFS is unique
> in its treatment of swap files. Ordinarily swap files are supported by the
> core VM looking up the physical block for a given offset in advance. There
> is no physical block for NFS and the direct write paths are used after
> calling mapping->swap_activate.
> 
> The lockdep warning is triggered by swapon(), which is not in reclaim
> context, acquiring the i_mutex to ensure a swapfile is not activated twice.
> 
> swapon does not need the i_mutex for this purpose.  There is a requirement
> that fallocate not be used on swapfiles but this is protected by the inode
> flag S_SWAPFILE and nothing to do with i_mutex. In fact, the current
> protection does nothing for block devices. This patch expands the role
> of swap_lock to protect against parallel activations of block devices and
> swapfiles and removes the use of i_mutex. This both improves the protection
> for swapon and avoids the lockdep warning.
> 
> ...
>
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1970,9 +1970,9 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  		set_blocksize(bdev, old_block_size);
>  		blkdev_put(bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL);
>  	} else {
> -		mutex_lock(&inode->i_mutex);
> +		spin_lock(&swap_lock);
>  		inode->i_flags &= ~S_SWAPFILE;
> -		mutex_unlock(&inode->i_mutex);
> +		spin_unlock(&swap_lock);

Grumble.  inode->i_flags is protected by inode->i_mutex, end of story.

Breaking this rule is somewhat of a big deal and if we really are going
to do this then we should add a good explanation of why it is a)
necessary, b) safe and c) maintainable to do so (if these things are
true!) and add an apologetic note to Ted's (useful) comment over
inode_set_flags().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
