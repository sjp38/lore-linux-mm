Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id B57FC6B0062
	for <linux-mm@kvack.org>; Thu, 31 May 2012 16:09:20 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so945771qcs.14
        for <linux-mm@kvack.org>; Thu, 31 May 2012 13:09:19 -0700 (PDT)
Message-ID: <4FC7CFEB.5040009@gmail.com>
Date: Thu, 31 May 2012 16:09:15 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] tmpfs not interleaving properly
References: <20120531143916.GA16162@gulag1.americas.sgi.com>
In-Reply-To: <20120531143916.GA16162@gulag1.americas.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: hughd@google.com, npiggin@gmail.com, cl@linux.com, lee.schermerhorn@hp.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, riel@redhat.com, kosaki.motohiro@gmail.com

(5/31/12 10:39 AM), Nathan Zimmer wrote:
> When tmpfs has the memory policy interleaved it always starts allocating at each
> file at node 0.  When there are many small files the lower nodes fill up
> disproportionately.
> This patch attempts to spread out node usage by starting files at nodes other
> then 0.  I disturbed the addr parameter since alloc_pages_vma will only use it
> when the policy is MPOL_INTERLEAVE.  Random was picked over using another
> variable which would require some sort of contention management.
>
> Cc: Christoph Lameter<cl@linux.com>
> Cc: Nick Piggin<npiggin@gmail.com>
> Cc: Hugh Dickins<hughd@google.com>
> Cc: Lee Schermerhorn<lee.schermerhorn@hp.com>
> Acked-by: Rik van Riel<riel@redhat.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: Nathan T Zimmer<nzimmer@sgi.com>
> ---
>   include/linux/shmem_fs.h |    1 +
>   mm/shmem.c               |    3 ++-
>   2 files changed, 3 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
> index bef2cf0..cfe8a34 100644
> --- a/include/linux/shmem_fs.h
> +++ b/include/linux/shmem_fs.h
> @@ -17,6 +17,7 @@ struct shmem_inode_info {
>   		char		*symlink;	/* unswappable short symlink */
>   	};
>   	struct shared_policy	policy;		/* NUMA memory alloc policy */
> +	unsigned long           node_offset;	/* bias for interleaved nodes */
>   	struct list_head	swaplist;	/* chain of maybes on swap */
>   	struct list_head	xattr_list;	/* list of shmem_xattr */
>   	struct inode		vfs_inode;
> diff --git a/mm/shmem.c b/mm/shmem.c
> index d576b84..69a47fb 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -929,7 +929,7 @@ static struct page *shmem_alloc_page(gfp_t gfp,
>   	/*
>   	 * alloc_page_vma() will drop the shared policy reference
>   	 */
> -	return alloc_page_vma(gfp,&pvma, 0);
> +	return alloc_page_vma(gfp,&pvma, info->node_offset<<  PAGE_SHIFT );

3rd argument of alloc_page_vma() is an address. This is type error.



>   }
>   #else /* !CONFIG_NUMA */
>   #ifdef CONFIG_TMPFS
> @@ -1357,6 +1357,7 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
>   			inode->i_fop =&shmem_file_operations;
>   			mpol_shared_policy_init(&info->policy,
>   						 shmem_get_sbmpol(sbinfo));
> +			info->node_offset = node_random(&node_online_map);
>   			break;
>   		case S_IFDIR:
>   			inc_nlink(inode);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
