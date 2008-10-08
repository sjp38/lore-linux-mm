Received: by mu-out-0910.google.com with SMTP id i2so3599926mue.6
        for <linux-mm@kvack.org>; Wed, 08 Oct 2008 14:35:49 -0700 (PDT)
Date: Thu, 9 Oct 2008 01:38:31 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in
	/proc/pid/smaps
Message-ID: <20081008213831.GA23729@x200.localdomain>
References: <1223052415-18956-1-git-send-email-mel@csn.ul.ie> <1223052415-18956-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1223052415-18956-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, dave@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 03, 2008 at 05:46:54PM +0100, Mel Gorman wrote:
> It is useful to verify a hugepage-aware application is using the expected
> pagesizes for its memory regions. This patch creates an entry called
> KernelPageSize in /proc/pid/smaps that is the size of page used by the
> kernel to back a VMA. The entry is not called PageSize as it is possible
> the MMU uses a different size. This extension should not break any sensible
> parser that skips lines containing unrecognised information.

> +		   "KernelPageSize: %8lu kB\n",

> +unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
> +{
> +	struct hstate *hstate;
> +
> +	if (!is_vm_hugetlb_page(vma))
> +		return PAGE_SIZE;
> +
> +	hstate = hstate_vma(vma);
> +	VM_BUG_ON(!hstate);
> +
> +	return 1UL << (hstate->order + PAGE_SHIFT);
			    ^^^^
VM_BUG_ON is unneeded because kernel will oops here if hstate is NULL.

Also, in /proc/*/maps it's printed only for hugetlb vmas and called
hpagesize, in smaps it's printed for every vma and called
KernelPageSize. All of this is inconsistent.

And app will verify once that hugepages are of right size, so Pss cost
argument for changing /proc/*/maps seems weak to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
