Date: Wed, 7 Feb 2007 23:27:42 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Define the shmem_inode_info flags directly
In-Reply-To: <20070207204030.30615.77294.stgit@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0702072320410.3025@blonde.wat.veritas.com>
References: <20070207204030.30615.77294.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Feb 2007, Adam Litke wrote:
> 
> Andrew: This is a pretty basic and obvious cleanup IMO.  How about a ride in
> -mm?
> 
> Defining flags in terms of other flags is always confusing.  Give them literal
> values instead of defining them in terms of VM_flags.  While we're at it, move
> them to a header file in preparation for the introduction of a
> SHMEM_HUGETLB flag.

NAK.  Look further and you'll find at least VM_LOCKED and VM_ACCOUNT
also used straight in shmem info->flags: it's trying to ensure there
won't be a clash when applying VM_flags there.  So you've a choice of
three ways forward, I don't mind which: (a) leave it alone, (b) add
comments, (c) define a separate set of flags for SHMEM and convert
where necessary.  But NAK to this patch.

(Sorry, I'm way behind and haven't checked your earlier mails yet.)

Hugh

> 
> Signed-off-by: Adam Litke <agl@us.ibm.com>
> ---
> 
>  include/linux/shmem_fs.h |    4 ++++
>  mm/shmem.c               |    4 ----
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
> index f3c5189..3ea0b6e 100644
> --- a/include/linux/shmem_fs.h
> +++ b/include/linux/shmem_fs.h
> @@ -8,6 +8,10 @@
>  
>  #define SHMEM_NR_DIRECT 16
>  
> +/* These info->flags are used to handle pagein/truncate races efficiently */
> +#define SHMEM_PAGEIN	0x00000001
> +#define SHMEM_TRUNCATE	0x00000002
> +
>  struct shmem_inode_info {
>  	spinlock_t		lock;
>  	unsigned long		flags;
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 70da7a0..a9bdb0d 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -66,10 +66,6 @@
>  
>  #define VM_ACCT(size)    (PAGE_CACHE_ALIGN(size) >> PAGE_SHIFT)
>  
> -/* info->flags needs VM_flags to handle pagein/truncate races efficiently */
> -#define SHMEM_PAGEIN	 VM_READ
> -#define SHMEM_TRUNCATE	 VM_WRITE
> -
>  /* Definition to limit shmem_truncate's steps between cond_rescheds */
>  #define LATENCY_LIMIT	 64

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
