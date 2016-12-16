Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06FDF6B0260
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:02:17 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y68so132187288pfb.6
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:02:16 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id m6si8757893pgg.171.2016.12.16.10.02.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:02:15 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id b1so349866pgc.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:02:15 -0800 (PST)
Date: Fri, 16 Dec 2016 10:02:10 -0800
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 1/2] bpf: do not use KMALLOC_SHIFT_MAX
Message-ID: <20161216180209.GA77597@ast-mbp.thefacebook.com>
References: <20161215164722.21586-1-mhocko@kernel.org>
 <20161215164722.21586-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161215164722.21586-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Cristopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>

On Thu, Dec 15, 2016 at 05:47:21PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> 01b3f52157ff ("bpf: fix allocation warnings in bpf maps and integer
> overflow") has added checks for the maximum allocateable size. It
> (ab)used KMALLOC_SHIFT_MAX for that purpose. While this is not incorrect
> it is not very clean because we already have KMALLOC_MAX_SIZE for this
> very reason so let's change both checks to use KMALLOC_MAX_SIZE instead.
> 
> Cc: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Nack until the patches 1 and 2 are reversed.

The bug that patch 2 fixes was the reason we used KMALLOC_SHIFT_MAX - 1 here
instead of KMALLOC_MAX_SIZE,
so you have to fix the kmalloc vs __alloc_pages_slowpath discrepancy first.

> ---
>  kernel/bpf/arraymap.c | 2 +-
>  kernel/bpf/hashtab.c  | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
> index a2ac051c342f..229a5d5df977 100644
> --- a/kernel/bpf/arraymap.c
> +++ b/kernel/bpf/arraymap.c
> @@ -56,7 +56,7 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
>  	    attr->value_size == 0 || attr->map_flags)
>  		return ERR_PTR(-EINVAL);
>  
> -	if (attr->value_size >= 1 << (KMALLOC_SHIFT_MAX - 1))
> +	if (attr->value_size > KMALLOC_MAX_SIZE)
>  		/* if value_size is bigger, the user space won't be able to
>  		 * access the elements.
>  		 */
> diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
> index ad1bc67aff1b..c5ec7dc71c84 100644
> --- a/kernel/bpf/hashtab.c
> +++ b/kernel/bpf/hashtab.c
> @@ -181,7 +181,7 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
>  		 */
>  		goto free_htab;
>  
> -	if (htab->map.value_size >= (1 << (KMALLOC_SHIFT_MAX - 1)) -
> +	if (htab->map.value_size >= KMALLOC_MAX_SIZE -
>  	    MAX_BPF_STACK - sizeof(struct htab_elem))
>  		/* if value_size is bigger, the user space won't be able to
>  		 * access the elements via bpf syscall. This check also makes
> -- 
> 2.10.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
