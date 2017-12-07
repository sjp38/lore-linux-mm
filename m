Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3DF6B025F
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 18:45:23 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id e70so179926wmc.6
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 15:45:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j3si4657073wrh.73.2017.12.07.15.45.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 15:45:22 -0800 (PST)
Date: Thu, 7 Dec 2017 15:45:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm, thp: introduce generic transparent huge page
 allocation interfaces
Message-Id: <20171207154519.df3f8218f8dbe05f95a2bc42@linux-foundation.org>
In-Reply-To: <1512644059-24329-1-git-send-email-changbin.du@intel.com>
References: <1512644059-24329-1-git-send-email-changbin.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: changbin.du@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu,  7 Dec 2017 18:54:19 +0800 changbin.du@intel.com wrote:

> From: Changbin Du <changbin.du@intel.com>
> 
> This patch introduced 4 new interfaces to allocate a prepared transparent
> huge page. These interfaces merge distributed two-step allocation as simple
> single step. And they can avoid issue like forget to call prep_transhuge_page()
> or call it on wrong page. A real fix:
> 40a899e ("mm: migrate: fix an incorrect call of prep_transhuge_page()")
> 
> Anyway, I just want to prove that expose direct allocation interfaces is
> better than a interface only do the second part of it.
> 
> These are similar to alloc_hugepage_xxx which are for hugetlbfs pages. New
> interfaces are:
>   - alloc_transhuge_page_vma
>   - alloc_transhuge_page_nodemask
>   - alloc_transhuge_page_node
>   - alloc_transhuge_page
> 
> These interfaces implicitly add __GFP_COMP gfp mask which is the minimum
> flags used for huge page allocation. More flags leave to the callers.
> 
> This patch does below changes:
>   - define alloc_transhuge_page_xxx interfaces
>   - apply them to all existing code
>   - declare prep_transhuge_page as static since no others use it
>   - remove alloc_hugepage_vma definition since it no longer has users
> 
> ...
>
> @@ -261,7 +272,10 @@ static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
>  	return false;
>  }
>  
> -static inline void prep_transhuge_page(struct page *page) {}
> +#define alloc_transhuge_page_vma(gfp_mask, vma, addr) NULL
> +#define alloc_transhuge_page_nodemask(gfp_mask, preferred_nid, nmask) NULL
> +#define alloc_transhuge_page_node(nid, gfp_maskg) NULL
> +#define alloc_transhuge_page(gfp_mask) NULL

Ugly.  And such things can cause unused-variable warnings in calling
code.  Whereas

static inline struct page *alloc_transhuge_page_vma(gfp_t gfp_mask,
			struct vm_area_struct *vma, unsigned long addr)
{
	return NULL;
}

will avoid such warnings.
  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
