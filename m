Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 150096B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 09:26:46 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id d185so107669437pgc.2
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:26:46 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e7si844793pfa.53.2017.02.06.06.26.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 06:26:45 -0800 (PST)
Date: Mon, 6 Feb 2017 06:26:41 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/6] lockdep: allow to disable reclaim lockup detection
Message-ID: <20170206142641.GG2267@bombadil.infradead.org>
References: <20170206140718.16222-1-mhocko@kernel.org>
 <20170206140718.16222-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170206140718.16222-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, Feb 06, 2017 at 03:07:13PM +0100, Michal Hocko wrote:
> While we are at it also make sure that the radix tree doesn't
> accidentaly override tags stored in the upper part of the gfp_mask.

> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index 9dc093d5ef39..7550be09f9d6 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -2274,6 +2274,8 @@ static int radix_tree_cpu_dead(unsigned int cpu)
>  void __init radix_tree_init(void)
>  {
>  	int ret;
> +
> +	BUILD_BUG_ON(RADIX_TREE_MAX_TAGS + __GFP_BITS_SHIFT > 32);
>  	radix_tree_node_cachep = kmem_cache_create("radix_tree_node",
>  			sizeof(struct radix_tree_node), 0,
>  			SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,

That's going to have a conceptual conflict with some patches I have
in flight.  I'll take this part through my radix tree patch collection.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
