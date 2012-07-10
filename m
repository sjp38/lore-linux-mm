Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 08C836B0073
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 22:02:41 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so24395280pbb.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 19:02:41 -0700 (PDT)
Date: Mon, 9 Jul 2012 19:02:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/hugetlb: fix error code in hugetlbfs_alloc_inode
In-Reply-To: <1341882774-4772-1-git-send-email-liwp.linux@gmail.com>
Message-ID: <alpine.DEB.2.00.1207091901210.25143@chino.kir.corp.google.com>
References: <1341882774-4772-1-git-send-email-liwp.linux@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, William Irwin <wli@holomorphy.com>, linux-kernel@vger.kernel.org

On Tue, 10 Jul 2012, Wanpeng Li wrote:

> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index c4b85d0..79a0f33 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -696,7 +696,7 @@ static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
>  	p = kmem_cache_alloc(hugetlbfs_inode_cachep, GFP_KERNEL);
>  	if (unlikely(!p)) {
>  		hugetlbfs_inc_free_inodes(sbinfo);
> -		return NULL;
> +		return ERR_PTR(-ENOMEM);
>  	}
>  	return &p->vfs_inode;
>  }

So now you've removed Gavin Shan who already told you that it was correct 
as written and propose yet another bogus patch which will break.  This 
isn't professional.

alloc_inode() tests for a NULL return value, not for PTR_ERR(), so you 
would be introducing a bug if this patch were merged.  It's completely 
correct the way it's written.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
