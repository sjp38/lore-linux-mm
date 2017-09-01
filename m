Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C95266B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 21:33:58 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q16so6580078pgc.3
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 18:33:58 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 33si768821pll.647.2017.08.31.18.33.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 18:33:57 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] mm: kvfree the swap cluster info if the swap file is unsatisfactory
References: <20170831233515.GR3775@magnolia>
Date: Fri, 01 Sep 2017 09:33:54 +0800
In-Reply-To: <20170831233515.GR3775@magnolia> (Darrick J. Wong's message of
	"Thu, 31 Aug 2017 16:35:15 -0700")
Message-ID: <8760d3w6bh.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: akpm@linux-foundation.org, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Darrick J. Wong" <darrick.wong@oracle.com> writes:

> If initializing a small swap file fails because the swap file has a
> problem (holes, etc.) then we need to free the cluster info as part of
> cleanup.  Unfortunately a previous patch changed the code to use
> kvzalloc but did not change all the vfree calls to use kvfree.
>
> Found by running generic/357 from xfstests.
>
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

Thanks for fixing!

Reviewed-by: "Huang, Ying" <ying.huang@intel.com>

Best Regards,
Huang, Ying

> ---
>  mm/swapfile.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 6ba4aab..c1deb01 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -3052,7 +3052,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  	p->flags = 0;
>  	spin_unlock(&swap_lock);
>  	vfree(swap_map);
> -	vfree(cluster_info);
> +	kvfree(cluster_info);
>  	if (swap_file) {
>  		if (inode && S_ISREG(inode->i_mode)) {
>  			inode_unlock(inode);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
