From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 1/2] mm, thp: introduce dedicated transparent huge
 page allocation interfaces
Date: Fri, 20 Oct 2017 06:35:44 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1710200634180.10736@nuc-kabylake>
References: <1508488588-23539-1-git-send-email-changbin.du@intel.com> <1508488588-23539-2-git-send-email-changbin.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508488588-23539-2-git-send-email-changbin.du@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Changbin Du <changbin.du@intel.com>
Cc: akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, khandual@linux.vnet.ibm.com, kirill@shutemov.name
List-Id: linux-mm.kvack.org

On Fri, 20 Oct 2017, changbin.du@intel.com wrote:

> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 269b5df..2a960fc 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -501,6 +501,43 @@ void prep_transhuge_page(struct page *page)
>  	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
>  }
>
> +struct page *alloc_transhuge_page_vma(gfp_t gfp_mask,
> +		struct vm_area_struct *vma, unsigned long addr)
> +{
> +	struct page *page;
> +
> +	page = alloc_pages_vma(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER,
> +			       vma, addr, numa_node_id(), true);
> +	if (unlikely(!page))
> +		return NULL;
> +	prep_transhuge_page(page);
> +	return page;
> +}
> +
> +struct page *alloc_transhuge_page_nodemask(gfp_t gfp_mask,
> +		int preferred_nid, nodemask_t *nmask)
> +{
> +	struct page *page;
> +
> +	page = __alloc_pages_nodemask(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER,
> +				      preferred_nid, nmask);
> +	if (unlikely(!page))
> +		return NULL;
> +	prep_transhuge_page(page);
> +	return page;
> +}
> +
> +struct page *alloc_transhuge_page(gfp_t gfp_mask)
> +{
> +	struct page *page;
> +
> +	page = alloc_pages(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER);
> +	if (unlikely(!page))
> +		return NULL;
> +	prep_transhuge_page(page);
> +	return page;
> +}
> +

These look pretty similar to the code used for huge pages (aside from the
call to prep_transhuge_page(). Maybe we can have common allocation
primitives for huge pages?
