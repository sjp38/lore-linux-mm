Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 4ABDB6B0037
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 14:13:45 -0400 (EDT)
Message-ID: <514CA182.7050906@sr71.net>
Date: Fri, 22 Mar 2013 11:22:58 -0700
From: Dave <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 17/30] thp: wait_split_huge_page(): serialize over
 i_mmap_mutex too
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-18-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -113,11 +113,20 @@ extern void __split_huge_page_pmd(struct vm_area_struct *vma,
>  			__split_huge_page_pmd(__vma, __address,		\
>  					____pmd);			\
>  	}  while (0)
> -#define wait_split_huge_page(__anon_vma, __pmd)				\
> +#define wait_split_huge_page(__vma, __pmd)				\
>  	do {								\
>  		pmd_t *____pmd = (__pmd);				\
> -		anon_vma_lock_write(__anon_vma);			\
> -		anon_vma_unlock_write(__anon_vma);			\
> +		struct address_space *__mapping =			\
> +					vma->vm_file->f_mapping;	\
> +		struct anon_vma *__anon_vma = (__vma)->anon_vma;	\
> +		if (__mapping)						\
> +			mutex_lock(&__mapping->i_mmap_mutex);		\
> +		if (__anon_vma) {					\
> +			anon_vma_lock_write(__anon_vma);		\
> +			anon_vma_unlock_write(__anon_vma);		\
> +		}							\
> +		if (__mapping)						\
> +			mutex_unlock(&__mapping->i_mmap_mutex);		\
>  		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
>  		       pmd_trans_huge(*____pmd));			\
>  	} while (0)

That thing was pretty ugly _before_. :)  Any chance this can get turned
in to a function?

What's the deal with the i_mmap_mutex operation getting split up?  I'm
blanking on what kind of pages would have both anon_vmas and a valid
mapping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
