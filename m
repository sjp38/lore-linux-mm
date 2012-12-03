Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 1E4806B0068
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 22:14:40 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id hm11so815642wib.8
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 19:14:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1354287821-5925-2-git-send-email-kirill.shutemov@linux.intel.com>
References: <50B52E17.8020205@suse.cz>
	<1354287821-5925-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1354287821-5925-2-git-send-email-kirill.shutemov@linux.intel.com>
Date: Mon, 3 Dec 2012 11:14:38 +0800
Message-ID: <CAA_GA1ds_=50SrqvxsGrtM9UPg5w=2e5xpi5CrLbKmE4M6X0gw@mail.gmail.com>
Subject: Re: [PATCH 1/2] thp: fix anononymous page accounting in fallback path
 for COW of HZP
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Jiri Slaby <jslaby@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Nov 30, 2012 at 11:03 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> Don't forget to account newly allocated page in fallback path for
> copy-on-write of huge zero page.
>

What about fallback path in do_huge_pmd_wp_page_fallback()?
I think we should also account newly allocated page in it.

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/huge_memory.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 57f0024..9d6f521 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1164,6 +1164,7 @@ static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
>         pmd_populate(mm, pmd, pgtable);
>         spin_unlock(&mm->page_table_lock);
>         put_huge_zero_page();
> +       inc_mm_counter(mm, MM_ANONPAGES);
>
>         mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>
> --
> 1.7.11.7
>

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
