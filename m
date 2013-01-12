Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id A94D06B0068
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 23:27:32 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id l22so2112640vbn.28
        for <linux-mm@kvack.org>; Fri, 11 Jan 2013 20:27:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130112033659.GA26890@otc-wbsnb-06>
References: <CANN689E5iw=UHfG1r82c91cZVqhX9xrxttKw3SCy=ZSgcAicNQ@mail.gmail.com>
	<20130112033659.GA26890@otc-wbsnb-06>
Date: Fri, 11 Jan 2013 20:27:31 -0800
Message-ID: <CANN689HKD7t91e+-oZw6Nqq=cYQDk1eo+0JD7g=3AomfpcNSCw@mail.gmail.com>
Subject: Re: huge zero page vs FOLL_DUMP
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jan 11, 2013 at 7:36 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> On Fri, Jan 11, 2013 at 03:53:34PM -0800, Michel Lespinasse wrote:
>> Hi,
>>
>> follow_page() has code to return ERR_PTR(-EFAULT) when it encounters
>> the zero page and FOLL_DUMP flag is passed - this is used to avoid
>> dumping the zero page to disk when doing core dumps, and also by
>> munlock to avoid having potentially large number of threads trying to
>> munlock the zero page at once, which we can't reclaim anyway.
>>
>> We don't have the corresponding logic when follow_page() encounters a
>> huge zero page. I think we should, preferably before 3.8. However, I
>> am slightly confused as to what to do for the munlock case, as the
>> huge zero page actually does seem to be reclaimable. My guess is that
>> we could still skip the munlocks, until the zero page is actually
>> reclaimed at which point we should check if we can munlock it.
>>
>> Kirill, is this something you would have time to look into ?
>
> Nice catch! Thank you.
>
> I don't think we should do anything about mlock(). Huge zero page cannot
> be mlocked -- it will not pass page->mapping check in
> follow_trans_huge_pmd(). And it's not reclaimable if it's mapped to
> anywhere.

Ah, thanks for the explanation about mlock.

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
>         if (flags & FOLL_WRITE && !pmd_write(*pmd))
>                 goto out;
>
> +       /* Avoid dumping huge zero page */
> +       if ((flags & FOLL_DUMP) && is_huge_zero_pmd(*pmd))
> +               return ERR_PTR(-EFAULT);
> +
>         page = pmd_page(*pmd);
>         VM_BUG_ON(!PageHead(page));
>         if (flags & FOLL_TOUCH) {

Looks sane to me, and it also helps my munlock test (we were getting
and dropping references on the zero page which made it noticeably
slower). Thanks!

Reviewed-by: Michel Lespinasse <walken@google.com>

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
