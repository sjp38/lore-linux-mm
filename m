Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2926B0276
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 08:45:57 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id m83so14168169wmc.1
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 05:45:57 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ue16si2245855wjb.134.2016.10.26.05.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 05:45:55 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id 79so3512975wmy.4
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 05:45:55 -0700 (PDT)
Date: Wed, 26 Oct 2016 14:45:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH stable 4.4 2/4] mm: filemap: don't plant shadow entries
 without radix tree node
Message-ID: <20161026124553.GA25683@dhcp22.suse.cz>
References: <20161025075148.31661-1-mhocko@kernel.org>
 <20161025075148.31661-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161025075148.31661-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable tree <stable@vger.kernel.org>, Greg KH <gregkh@linuxfoundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>

Greg,
I do not see this one in the 4.4 queue you have just sent today.

On Tue 25-10-16 09:51:46, Michal Hocko wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
> 
> commit d3798ae8c6f3767c726403c2ca6ecc317752c9dd upstream.
> 
> When the underflow checks were added to workingset_node_shadow_dec(),
> they triggered immediately:
> 
>   kernel BUG at ./include/linux/swap.h:276!
>   invalid opcode: 0000 [#1] SMP
>   Modules linked in: isofs usb_storage fuse xt_CHECKSUM ipt_MASQUERADE nf_nat_masquerade_ipv4 tun nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_REJECT nf_reject_ipv6
>    soundcore wmi acpi_als pinctrl_sunrisepoint kfifo_buf tpm_tis industrialio acpi_pad pinctrl_intel tpm_tis_core tpm nfsd auth_rpcgss nfs_acl lockd grace sunrpc dm_crypt
>   CPU: 0 PID: 20929 Comm: blkid Not tainted 4.8.0-rc8-00087-gbe67d60ba944 #1
>   Hardware name: System manufacturer System Product Name/Z170-K, BIOS 1803 05/06/2016
>   task: ffff8faa93ecd940 task.stack: ffff8faa7f478000
>   RIP: page_cache_tree_insert+0xf1/0x100
>   Call Trace:
>     __add_to_page_cache_locked+0x12e/0x270
>     add_to_page_cache_lru+0x4e/0xe0
>     mpage_readpages+0x112/0x1d0
>     blkdev_readpages+0x1d/0x20
>     __do_page_cache_readahead+0x1ad/0x290
>     force_page_cache_readahead+0xaa/0x100
>     page_cache_sync_readahead+0x3f/0x50
>     generic_file_read_iter+0x5af/0x740
>     blkdev_read_iter+0x35/0x40
>     __vfs_read+0xe1/0x130
>     vfs_read+0x96/0x130
>     SyS_read+0x55/0xc0
>     entry_SYSCALL_64_fastpath+0x13/0x8f
>   Code: 03 00 48 8b 5d d8 65 48 33 1c 25 28 00 00 00 44 89 e8 75 19 48 83 c4 18 5b 41 5c 41 5d 41 5e 5d c3 0f 0b 41 bd ef ff ff ff eb d7 <0f> 0b e8 88 68 ef ff 0f 1f 84 00
>   RIP  page_cache_tree_insert+0xf1/0x100
> 
> This is a long-standing bug in the way shadow entries are accounted in
> the radix tree nodes. The shrinker needs to know when radix tree nodes
> contain only shadow entries, no pages, so node->count is split in half
> to count shadows in the upper bits and pages in the lower bits.
> 
> Unfortunately, the radix tree implementation doesn't know of this and
> assumes all entries are in node->count. When there is a shadow entry
> directly in root->rnode and the tree is later extended, the radix tree
> implementation will copy that entry into the new node and and bump its
> node->count, i.e. increases the page count bits. Once the shadow gets
> removed and we subtract from the upper counter, node->count underflows
> and triggers the warning. Afterwards, without node->count reaching 0
> again, the radix tree node is leaked.
> 
> Limit shadow entries to when we have actual radix tree nodes and can
> count them properly. That means we lose the ability to detect refaults
> from files that had only the first page faulted in at eviction time.
> 
> [hannes@cmpxchg.org: backport for 4.4 stable]
> Fixes: 449dd6984d0e ("mm: keep page cache radix tree nodes in check")
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reported-and-tested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/filemap.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 4cfe423d3e8a..7ad648c9780c 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -164,6 +164,14 @@ static void page_cache_tree_delete(struct address_space *mapping,
>  
>  	__radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
>  
> +	if (!node) {
> +		/*
> +		 * We need a node to properly account shadow
> +		 * entries. Don't plant any without. XXX
> +		 */
> +		shadow = NULL;
> +	}
> +
>  	if (shadow) {
>  		mapping->nrshadows++;
>  		/*
> -- 
> 2.9.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
