Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 6CCD76B009C
	for <linux-mm@kvack.org>; Tue, 21 May 2013 19:38:30 -0400 (EDT)
Message-ID: <519C0573.4030808@sr71.net>
Date: Tue, 21 May 2013 16:38:27 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 31/39] thp: consolidate code between handle_mm_fault()
 and do_huge_pmd_anonymous_page()
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-32-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-32-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> do_huge_pmd_anonymous_page() has copy-pasted piece of handle_mm_fault()
> to handle fallback path.
> 
> Let's consolidate code back by introducing VM_FAULT_FALLBACK return
> code.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/huge_mm.h |    3 ---
>  include/linux/mm.h      |    3 ++-
>  mm/huge_memory.c        |   31 +++++--------------------------
>  mm/memory.c             |    9 ++++++---
>  4 files changed, 13 insertions(+), 33 deletions

Wow, nice diffstat!

This and the previous patch can go in the cleanups pile, no?

> @@ -3788,9 +3788,12 @@ retry:
>  	if (!pmd)
>  		return VM_FAULT_OOM;
>  	if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) {
> +		int ret = 0;
>  		if (!vma->vm_ops)
> -			return do_huge_pmd_anonymous_page(mm, vma, address,
> -							  pmd, flags);
> +			ret = do_huge_pmd_anonymous_page(mm, vma, address,
> +					pmd, flags);
> +		if ((ret & VM_FAULT_FALLBACK) == 0)
> +			return ret;

This could use a small comment about where the code flow is going, when
and why.  FWIW, I vastly prefer the '!' form in these:

	if (!(ret & VM_FAULT_FALLBACK))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
