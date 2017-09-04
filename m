Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6926C6B02F4
	for <linux-mm@kvack.org>; Sun,  3 Sep 2017 20:58:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n7so14588981pfi.7
        for <linux-mm@kvack.org>; Sun, 03 Sep 2017 17:58:16 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id m190si4032963pfc.400.2017.09.03.17.58.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Sep 2017 17:58:15 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] mm: kvfree the swap cluster info if the swap file is unsatisfactory
References: <20170831233515.GR3775@magnolia>
	<alpine.DEB.2.10.1709010123020.102682@chino.kir.corp.google.com>
Date: Mon, 04 Sep 2017 08:58:12 +0800
In-Reply-To: <alpine.DEB.2.10.1709010123020.102682@chino.kir.corp.google.com>
	(David Rientjes's message of "Fri, 1 Sep 2017 01:33:53 -0700")
Message-ID: <87o9qrqnyz.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

David Rientjes <rientjes@google.com> writes:

> On Thu, 31 Aug 2017, Darrick J. Wong wrote:
>
>> If initializing a small swap file fails because the swap file has a
>> problem (holes, etc.) then we need to free the cluster info as part of
>> cleanup.  Unfortunately a previous patch changed the code to use
>> kvzalloc but did not change all the vfree calls to use kvfree.
>> 
>
> Hopefully this can make it into 4.13.
>
> Fixes: 54f180d3c181 ("mm, swap: use kvzalloc to allocate some swap data structures")
> Cc: stable@vger.kernel.org [4.12]
>
>> Found by running generic/357 from xfstests.
>> 
>> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
>
> Acked-by: David Rientjes <rientjes@google.com>
>
> But I think there's also a memory leak and we need this on top of your 
> fix:
>
>
> mm, swapfile: fix swapon frontswap_map memory leak on error 
>
> Free frontswap_map if an error is encountered before enable_swap_info().
>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/swapfile.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -3053,6 +3053,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  	spin_unlock(&swap_lock);
>  	vfree(swap_map);
>  	kvfree(cluster_info);
> +	kvfree(frontswap_map);
>  	if (swap_file) {
>  		if (inode && S_ISREG(inode->i_mode)) {
>  			inode_unlock(inode);

Yes.  There is a memory leak.

Reviewed-by: "Huang, Ying" <ying.huang@intel.com>

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
