Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 153366B0071
	for <linux-mm@kvack.org>; Sat, 12 Jan 2013 20:43:14 -0500 (EST)
Received: by mail-da0-f42.google.com with SMTP id z17so1310886dal.29
        for <linux-mm@kvack.org>; Sat, 12 Jan 2013 17:43:13 -0800 (PST)
Message-ID: <1358041388.31895.0.camel@kernel.cn.ibm.com>
Subject: Re: huge zero page vs FOLL_DUMP
From: Simon Jeons <simon.jeons@gmail.com>
Date: Sat, 12 Jan 2013 19:43:08 -0600
In-Reply-To: <20130112033659.GA26890@otc-wbsnb-06>
References: 
	<CANN689E5iw=UHfG1r82c91cZVqhX9xrxttKw3SCy=ZSgcAicNQ@mail.gmail.com>
	 <20130112033659.GA26890@otc-wbsnb-06>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>

On Sat, 2013-01-12 at 05:36 +0200, Kirill A. Shutemov wrote:
> On Fri, Jan 11, 2013 at 03:53:34PM -0800, Michel Lespinasse wrote:
> > Hi,
> > 
> > follow_page() has code to return ERR_PTR(-EFAULT) when it encounters
> > the zero page and FOLL_DUMP flag is passed - this is used to avoid
> > dumping the zero page to disk when doing core dumps, and also by
> > munlock to avoid having potentially large number of threads trying to
> > munlock the zero page at once, which we can't reclaim anyway.
> > 
> > We don't have the corresponding logic when follow_page() encounters a
> > huge zero page. I think we should, preferably before 3.8. However, I
> > am slightly confused as to what to do for the munlock case, as the
> > huge zero page actually does seem to be reclaimable. My guess is that
> > we could still skip the munlocks, until the zero page is actually
> > reclaimed at which point we should check if we can munlock it.
> > 
> > Kirill, is this something you would have time to look into ?
> 
> Nice catch! Thank you.
> 
> I don't think we should do anything about mlock(). Huge zero page cannot
> be mlocked -- it will not pass page->mapping check in

Hi Kirill,

What's store in page->mapping of huge zero page?

> follow_trans_huge_pmd(). And it's not reclaimable if it's mapped to
> anywhere.
> 
> Could you tese the patch?
> 
> From 062a9b670ede9fe5fca1d1947b42990b6b0642a4 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Sat, 12 Jan 2013 05:18:58 +0200
> Subject: [PATCH] thp: Avoid dumping huge zero page
> 
> No reason to preserve huge zero page in core dump.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Michel Lespinasse <walken@google.com>
> ---
>  mm/huge_memory.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 6001ee6..b5783d8 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1257,6 +1257,10 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>  	if (flags & FOLL_WRITE && !pmd_write(*pmd))
>  		goto out;
>  
> +	/* Avoid dumping huge zero page */
> +	if ((flags & FOLL_DUMP) && is_huge_zero_pmd(*pmd))
> +		return ERR_PTR(-EFAULT);
> +
>  	page = pmd_page(*pmd);
>  	VM_BUG_ON(!PageHead(page));
>  	if (flags & FOLL_TOUCH) {
> -- 
> 1.8.1
> 

-- 
Simon Jeons <simon.jeons@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
