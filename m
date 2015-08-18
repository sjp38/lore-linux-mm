Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8EAE26B0255
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 18:57:10 -0400 (EDT)
Received: by igui7 with SMTP id i7so91778464igu.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 15:57:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id be5si613189igb.82.2015.08.18.15.57.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 15:57:09 -0700 (PDT)
Date: Tue, 18 Aug 2015 15:57:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: mmap: Simplify the failure return working flow
Message-Id: <20150818155708.8d10dac3736d547083c44500@linux-foundation.org>
In-Reply-To: <BLU436-SMTP37E3EE1A24E7A3EEEDBFA7B9780@phx.gbl>
References: <BLU436-SMTP37E3EE1A24E7A3EEEDBFA7B9780@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <xili_gchen_5257@hotmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, riel@redhat.com, Michal Hocko <mhocko@suse.cz>, sasha.levin@oracle.com, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 19 Aug 2015 06:27:58 +0800 Chen Gang <xili_gchen_5257@hotmail.com> wrote:

> From: Chen Gang <xili_gchen_5257@hotmail.com>

As sent, this patch is From:you@hotmail and Signed-off-by:you@gmail.

This is peculiar.  I'm assuming that it should have been From:you@gmail and
I have made that change to my copy of the patch.

You can do this yourself by putting an explicit From: line at the start
of the changelog.


> @@ -2958,23 +2957,23 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
>  		*need_rmap_locks = (new_vma->vm_pgoff <= vma->vm_pgoff);
>  	} else {
>  		new_vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
> -		if (new_vma) {
> -			*new_vma = *vma;
> -			new_vma->vm_start = addr;
> -			new_vma->vm_end = addr + len;
> -			new_vma->vm_pgoff = pgoff;
> -			if (vma_dup_policy(vma, new_vma))
> -				goto out_free_vma;
> -			INIT_LIST_HEAD(&new_vma->anon_vma_chain);
> -			if (anon_vma_clone(new_vma, vma))
> -				goto out_free_mempol;
> -			if (new_vma->vm_file)
> -				get_file(new_vma->vm_file);
> -			if (new_vma->vm_ops && new_vma->vm_ops->open)
> -				new_vma->vm_ops->open(new_vma);
> -			vma_link(mm, new_vma, prev, rb_link, rb_parent);
> -			*need_rmap_locks = false;
> -		}
> +		if (!new_vma)
> +			return NULL;
> +		*new_vma = *vma;
> +		new_vma->vm_start = addr;
> +		new_vma->vm_end = addr + len;
> +		new_vma->vm_pgoff = pgoff;
> +		if (vma_dup_policy(vma, new_vma))
> +			goto out_free_vma;
> +		INIT_LIST_HEAD(&new_vma->anon_vma_chain);
> +		if (anon_vma_clone(new_vma, vma))
> +			goto out_free_mempol;
> +		if (new_vma->vm_file)
> +			get_file(new_vma->vm_file);
> +		if (new_vma->vm_ops && new_vma->vm_ops->open)
> +			new_vma->vm_ops->open(new_vma);
> +		vma_link(mm, new_vma, prev, rb_link, rb_parent);
> +		*need_rmap_locks = false;
>  	}
>  	return new_vma;

Embedding a return deep inside the function isn't good.  It can lead to
resource leaks, locking leaks etc as the code evolves.  This is the
main reason why the kernel uses goto, IMO: single-entry, single-exit.

So,

--- a/mm/mmap.c~mm-mmap-simplify-the-failure-return-working-flow-fix
+++ a/mm/mmap.c
@@ -2952,7 +2952,7 @@ struct vm_area_struct *copy_vma(struct v
 	} else {
 		new_vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 		if (!new_vma)
-			return NULL;
+			goto out;
 		*new_vma = *vma;
 		new_vma->vm_start = addr;
 		new_vma->vm_end = addr + len;
@@ -2971,10 +2971,11 @@ struct vm_area_struct *copy_vma(struct v
 	}
 	return new_vma;
 
- out_free_mempol:
+out_free_mempol:
 	mpol_put(vma_policy(new_vma));
- out_free_vma:
+out_free_vma:
 	kmem_cache_free(vm_area_cachep, new_vma);
+out:
 	return NULL;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
