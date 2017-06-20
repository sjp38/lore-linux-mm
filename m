Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 830AA6B02C3
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 00:08:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c12so9085777pfk.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 21:08:37 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id n59si10470655plb.97.2017.06.19.21.08.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 21:08:36 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id y7so20692253pfd.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 21:08:36 -0700 (PDT)
Date: Mon, 19 Jun 2017 21:08:34 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [kernel-hardening] [PATCH 17/23] dcache: define usercopy region
 in dentry_cache slab cache
Message-ID: <20170620040834.GB610@zzz.localdomain>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
 <1497915397-93805-18-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497915397-93805-18-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: kernel-hardening@lists.openwall.com, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 19, 2017 at 04:36:31PM -0700, Kees Cook wrote:
> From: David Windsor <dave@nullcore.net>
> 
> When a dentry name is short enough, it can be stored directly in
> the dentry itself.  These dentry short names, stored in struct
> dentry.d_iname and therefore contained in the dentry_cache slab cache,
> need to be coped to/from userspace.
> 
> In support of usercopy hardening, this patch defines a region in
> the dentry_cache slab cache in which userspace copy operations
> are allowed.
> 
> This region is known as the slab cache's usercopy region.  Slab
> caches can now check that each copy operation involving cache-managed
> memory falls entirely within the slab's usercopy region.
> 
> This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
> whitelisting code in the last public patch of grsecurity/PaX based on my
> understanding of the code. Changes or omissions from the original code are
> mine and don't reflect the original grsecurity/PaX code.
> 

For all these patches please mention *where* the data is being copied to/from
userspace.

> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index a48f54238273..97f4a0117b3b 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -151,6 +151,11 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *);
>  		sizeof(struct __struct), __alignof__(struct __struct),\
>  		(__flags), NULL)
>  
> +#define KMEM_CACHE_USERCOPY(__struct, __flags, __field) kmem_cache_create_usercopy(#__struct,\
> +		sizeof(struct __struct), __alignof__(struct __struct),\
> +		(__flags), offsetof(struct __struct, __field),\
> +		sizeof_field(struct __struct, __field), NULL)
> +

This helper macro should be added in the patch which adds
kmem_cache_create_usercopy(), not in this one.

- Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
