Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id D12DA6B0034
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 16:31:01 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so6614338pdj.40
        for <linux-mm@kvack.org>; Mon, 09 Sep 2013 13:31:01 -0700 (PDT)
Date: Mon, 9 Sep 2013 13:30:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
In-Reply-To: <5227CF48.5080700@asianux.com>
Message-ID: <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com>
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 5 Sep 2013, Chen Gang wrote:

> diff --git a/mm/shmem.c b/mm/shmem.c
> index f00c1c1..b4d44db 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -883,16 +883,20 @@ redirty:
>  
>  #ifdef CONFIG_NUMA
>  #ifdef CONFIG_TMPFS
> -static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
> +static int shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
>  {
>  	char buffer[64];
> +	int ret;
>  
>  	if (!mpol || mpol->mode == MPOL_DEFAULT)
> -		return;		/* show nothing */
> +		return 0;		/* show nothing */
>  
> -	mpol_to_str(buffer, sizeof(buffer), mpol);
> +	ret = mpol_to_str(buffer, sizeof(buffer), mpol);

I was wondering how mpol_to_str() could fail given a pointer to a stack 
allocated buffer, so I checked and it happens if the mempolicy mode isn't 
known or the buffer isn't long enough.

I think it would be better to keep mpol_to_str() returning void, and hence 
avoiding the need for this patch, and make it so it cannot fail.  If the 
mode is invalid, just store a 0 to the buffer (or "unknown"); and if 
maxlen isn't large enough, make it a compile-time error (let's avoid 
trying to be fancy and allocating less than 64 bytes on the stack if a 
given context is known to have short mempolicy strings).

> +	if (ret < 0)
> +		return ret;
>  
>  	seq_printf(seq, ",mpol=%s", buffer);
> +	return 0;
>  }
>  
>  static struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
> @@ -951,8 +955,9 @@ static struct page *shmem_alloc_page(gfp_t gfp,
>  }
>  #else /* !CONFIG_NUMA */
>  #ifdef CONFIG_TMPFS
> -static inline void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
> +static inline int shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
>  {
> +	return 0;
>  }
>  #endif /* CONFIG_TMPFS */
>  
> @@ -2555,8 +2560,7 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
>  	if (!gid_eq(sbinfo->gid, GLOBAL_ROOT_GID))
>  		seq_printf(seq, ",gid=%u",
>  				from_kgid_munged(&init_user_ns, sbinfo->gid));
> -	shmem_show_mpol(seq, sbinfo->mpol);
> -	return 0;
> +	return shmem_show_mpol(seq, sbinfo->mpol);
>  }
>  #endif /* CONFIG_TMPFS */
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
