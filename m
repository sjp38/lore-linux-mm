Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 82C876B00B1
	for <linux-mm@kvack.org>; Wed, 22 May 2013 08:47:04 -0400 (EDT)
Received: by mail-oa0-f49.google.com with SMTP id k14so2448306oag.8
        for <linux-mm@kvack.org>; Wed, 22 May 2013 05:47:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1368321816-17719-34-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1368321816-17719-34-git-send-email-kirill.shutemov@linux.intel.com>
Date: Wed, 22 May 2013 20:47:03 +0800
Message-ID: <CAJd=RBBogFk5F=yBtQ=TWTOND5HyUJN_XrdeRCqD6Y8skoquzw@mail.gmail.com>
Subject: Re: [PATCHv4 33/39] thp, mm: implement do_huge_linear_fault()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, May 12, 2013 at 9:23 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> @@ -3301,12 +3335,23 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  {
>         pte_t *page_table;
>         spinlock_t *ptl;
> +       pgtable_t pgtable = NULL;
>         struct page *page, *cow_page, *dirty_page = NULL;
> -       pte_t entry;
>         bool anon = false, page_mkwrite = false;
>         bool write = flags & FAULT_FLAG_WRITE;
> +       bool thp = flags & FAULT_FLAG_TRANSHUGE;
> +       unsigned long addr_aligned;
>         struct vm_fault vmf;
> -       int ret;
> +       int nr, ret;
> +
> +       if (thp) {
> +               if (!transhuge_vma_suitable(vma, address))
> +                       return VM_FAULT_FALLBACK;
> +               if (unlikely(khugepaged_enter(vma)))

vma->vm_mm now is under the care of khugepaged, why?

> +                       return VM_FAULT_OOM;
> +               addr_aligned = address & HPAGE_PMD_MASK;
> +       } else
> +               addr_aligned = address & PAGE_MASK;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
