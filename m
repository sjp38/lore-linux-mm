Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 226DE6B027F
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 20:35:22 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so1460974vcb.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 17:35:21 -0700 (PDT)
Message-ID: <4FE50F42.6010401@gmail.com>
Date: Fri, 22 Jun 2012 20:35:14 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] tmpfs not interleaving properly
References: <20120622143512.GA18468@gulag1.americas.sgi.com>
In-Reply-To: <20120622143512.GA18468@gulag1.americas.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, Hugh Dickins <hughd@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, kosaki.motohiro@gmail.com

(6/22/12 10:35 AM), Nathan Zimmer wrote:
> When tmpfs has the memory policy interleaved it always starts allocating at each
> file at node 0.  When there are many small files the lower nodes fill up
> disproportionately.
> This patch attempts to spread out node usage by starting files at nodes other
> then 0.  I disturbed the addr parameter since alloc_pages_vma will only use it
> when the policy is MPOL_INTERLEAVE.  A files preferred node is selected by 
> the cpu_mem_spread_node rotor.
> 
> v2: passed preferred node via addr
> v3: using current->cpuset_mem_spread_rotor instead of random_node
> 
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Nick Piggin <npiggin@gmail.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Nathan T Zimmer <nzimmer@sgi.com>
> ---
> 
>  include/linux/shmem_fs.h |    1 +
>  mm/shmem.c               |    9 +++++++--
>  2 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
> index bef2cf0..cfe8a34 100644
> --- a/include/linux/shmem_fs.h
> +++ b/include/linux/shmem_fs.h
> @@ -17,6 +17,7 @@ struct shmem_inode_info {
>  		char		*symlink;	/* unswappable short symlink */
>  	};
>  	struct shared_policy	policy;		/* NUMA memory alloc policy */
> +	unsigned long           node_offset;	/* bias for interleaved nodes */
>  	struct list_head	swaplist;	/* chain of maybes on swap */
>  	struct list_head	xattr_list;	/* list of shmem_xattr */
>  	struct inode		vfs_inode;
> diff --git a/mm/shmem.c b/mm/shmem.c
> index a15a466..93801b3 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -64,6 +64,7 @@ static struct vfsmount *shm_mnt;
>  #include <linux/highmem.h>
>  #include <linux/seq_file.h>
>  #include <linux/magic.h>
> +#include <linux/cpuset.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/pgtable.h>
> @@ -938,9 +939,12 @@ static struct page *shmem_alloc_page(gfp_t gfp,
>  	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
>  
>  	/*
> -	 * alloc_page_vma() will drop the shared policy reference
> +	 * alloc_page_vma() will drop the shared policy reference.
> +	 *
> +	 * To avoid allocating all tmpfs pages on node 0, we fake up a virtual
> +	 * address based on this file's predetermined preferred node.
>  	 */
> -	return alloc_page_vma(gfp, &pvma, 0);
> +	return alloc_page_vma(gfp, &pvma, info->node_offset << PAGE_SHIFT);

Still unacceptable. Please stop to pass hacky fake address.



>  }
>  #else /* !CONFIG_NUMA */
>  #ifdef CONFIG_TMPFS
> @@ -1374,6 +1378,7 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
>  			inode->i_fop = &shmem_file_operations;
>  			mpol_shared_policy_init(&info->policy,
>  						 shmem_get_sbmpol(sbinfo));
> +			info->node_offset = cpuset_mem_spread_node();

cpuset_mem_spread_node is designed for using allocation time.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
