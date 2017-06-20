Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 700006B0292
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 00:24:46 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v9so118332351pfk.5
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 21:24:46 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id i10si9998080pgc.553.2017.06.19.21.24.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 21:24:45 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id y7so20745669pfd.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 21:24:45 -0700 (PDT)
Date: Mon, 19 Jun 2017 21:24:42 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [kernel-hardening] [PATCH 22/23] usercopy: split user-controlled
 slabs to separate caches
Message-ID: <20170620042442.GC610@zzz.localdomain>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
 <1497915397-93805-23-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497915397-93805-23-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: kernel-hardening@lists.openwall.com, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 19, 2017 at 04:36:36PM -0700, Kees Cook wrote:
> From: David Windsor <dave@nullcore.net>
> 
> Some userspace APIs (e.g. ipc, seq_file) provide precise control over
> the size of kernel kmallocs, which provides a trivial way to perform
> heap overflow attacks where the attacker must control neighboring
> allocations of a specific size. Instead, move these APIs into their own
> cache so they cannot interfere with standard kmallocs. This is enabled
> with CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC.
> 

This is a logically separate change which IMO should be its own patch, not just
patch 22/23.

Also, is this really just about heap overflows?  I thought the main purpose of
separate heaps is to make it more difficult to exploit use-after-frees, since
anything allocating an object from heap A cannot overwrite freed memory in heap
B.  (At least, not at the SLAB level; it may still be done at the page level.)

> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index a89d37e8b387..ff4f4a698ad0 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -45,6 +45,7 @@ struct vm_area_struct;
>  #else
>  #define ___GFP_NOLOCKDEP	0
>  #endif
> +#define ___GFP_USERCOPY		0x4000000u
>  /* If the above are modified, __GFP_BITS_SHIFT may need updating */
>  
>  /*
> @@ -83,12 +84,17 @@ struct vm_area_struct;
>   *   node with no fallbacks or placement policy enforcements.
>   *
>   * __GFP_ACCOUNT causes the allocation to be accounted to kmemcg.
> + *
> + * __GFP_USERCOPY indicates that the page will be explicitly copied to/from
> + *   userspace, and may be allocated from a separate kmalloc pool.
> + *
>   */

The "page", or the allocation?  It's only for slab objects, is it not?  More
importantly, the purpose of this needs to be clearly documented; otherwise
people won't know what this is and whether they should/need to use it or not.

- Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
