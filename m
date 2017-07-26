Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC0BF6B02F4
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 05:53:42 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p43so26655784wrb.6
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 02:53:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n6si9071322wmi.32.2017.07.26.02.53.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 02:53:41 -0700 (PDT)
Date: Wed, 26 Jul 2017 11:53:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm: shm: Use new hugetlb size encoding
 definitions
Message-ID: <20170726095338.GF2981@dhcp22.suse.cz>
References: <20170328175408.GD7838@bombadil.infradead.org>
 <1500330481-28476-1-git-send-email-mike.kravetz@oracle.com>
 <1500330481-28476-4-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500330481-28476-4-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org, ak@linux.intel.com, mtk.manpages@gmail.com, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com

On Mon 17-07-17 15:28:01, Mike Kravetz wrote:
> Use the common definitions from hugetlb_encode.h header file for
> encoding hugetlb size definitions in shmget system call flags.  In
> addition, move these definitions to the from the internal to user
> (uapi) header file.

s@to the from@from@

> 
> Suggested-by: Matthew Wilcox <willy@infradead.org>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

with s@HUGETLB_FLAG_ENCODE__16GB@HUGETLB_FLAG_ENCODE_16GB@

Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/shm.h      | 17 -----------------
>  include/uapi/linux/shm.h | 23 +++++++++++++++++++++--
>  2 files changed, 21 insertions(+), 19 deletions(-)
> 
> diff --git a/include/linux/shm.h b/include/linux/shm.h
> index 04e8818..d56285a 100644
> --- a/include/linux/shm.h
> +++ b/include/linux/shm.h
> @@ -27,23 +27,6 @@ struct shmid_kernel /* private to the kernel */
>  /* shm_mode upper byte flags */
>  #define	SHM_DEST	01000	/* segment will be destroyed on last detach */
>  #define SHM_LOCKED      02000   /* segment will not be swapped */
> -#define SHM_HUGETLB     04000   /* segment will use huge TLB pages */
> -#define SHM_NORESERVE   010000  /* don't check for reservations */
> -
> -/* Bits [26:31] are reserved */
> -
> -/*
> - * When SHM_HUGETLB is set bits [26:31] encode the log2 of the huge page size.
> - * This gives us 6 bits, which is enough until someone invents 128 bit address
> - * spaces.
> - *
> - * Assume these are all power of twos.
> - * When 0 use the default page size.
> - */
> -#define SHM_HUGE_SHIFT  26
> -#define SHM_HUGE_MASK   0x3f
> -#define SHM_HUGE_2MB    (21 << SHM_HUGE_SHIFT)
> -#define SHM_HUGE_1GB    (30 << SHM_HUGE_SHIFT)
>  
>  #ifdef CONFIG_SYSVIPC
>  struct sysv_shm {
> diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
> index 1fbf24e..329bc17 100644
> --- a/include/uapi/linux/shm.h
> +++ b/include/uapi/linux/shm.h
> @@ -3,6 +3,7 @@
>  
>  #include <linux/ipc.h>
>  #include <linux/errno.h>
> +#include <asm-generic/hugetlb_encode.h>
>  #ifndef __KERNEL__
>  #include <unistd.h>
>  #endif
> @@ -40,11 +41,29 @@ struct shmid_ds {
>  /* Include the definition of shmid64_ds and shminfo64 */
>  #include <asm/shmbuf.h>
>  
> -/* permission flag for shmget */
> +/* shmget() shmflg values. */
> +/* The bottom nine bits are the same as open(2) mode flags */
>  #define SHM_R		0400	/* or S_IRUGO from <linux/stat.h> */
>  #define SHM_W		0200	/* or S_IWUGO from <linux/stat.h> */
> +/* Bits 9 & 10 are IPC_CREAT and IPC_EXCL */
> +#define SHM_HUGETLB	04000	/* segment will use huge TLB pages */
> +#define	SHM_NORESERVE	010000	/* don't check for reservations */
>  
> -/* mode for attach */
> +/*
> + * Huge page size encoding when SHM_HUGETLB is specified, and a huge page
> + * size other than the default is desired.  See hugetlb_encode.h
> + */
> +#define SHM_HUGE_SHIFT	HUGETLB_FLAG_ENCODE_SHIFT
> +#define SHM_HUGE_MASK	HUGETLB_FLAG_ENCODE_MASK
> +#define MAP_HUGE_512KB	HUGETLB_FLAG_ENCODE_512KB
> +#define MAP_HUGE_1MB	HUGETLB_FLAG_ENCODE_1MB
> +#define MAP_HUGE_2MB	HUGETLB_FLAG_ENCODE_2MB
> +#define MAP_HUGE_8MB	HUGETLB_FLAG_ENCODE_8MB
> +#define MAP_HUGE_16MB	HUGETLB_FLAG_ENCODE_16MB
> +#define MAP_HUGE_1GB	HUGETLB_FLAG_ENCODE_1GB
> +#define MAP_HUGE_16GB	HUGETLB_FLAG_ENCODE__16GB
> +
> +/* shmat() shmflg values */
>  #define	SHM_RDONLY	010000	/* read-only access */
>  #define	SHM_RND		020000	/* round attach address to SHMLBA boundary */
>  #define	SHM_REMAP	040000	/* take-over region on attach */
> -- 
> 2.7.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
