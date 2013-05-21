Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 7C3336B0098
	for <linux-mm@kvack.org>; Tue, 21 May 2013 19:23:06 -0400 (EDT)
Message-ID: <519C01D8.4040301@sr71.net>
Date: Tue, 21 May 2013 16:23:04 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 29/39] thp: move maybe_pmd_mkwrite() out of mk_huge_pmd()
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-30-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-30-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> It's confusing that mk_huge_pmd() has sematics different from mk_pte()
> or mk_pmd().
> 
> Let's move maybe_pmd_mkwrite() out of mk_huge_pmd() and adjust
> prototype to match mk_pte().

Was there a motivation to do this beyond adding consistency?  Do you use
this later or something?

> @@ -746,7 +745,8 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
>  		pte_free(mm, pgtable);
>  	} else {
>  		pmd_t entry;
> -		entry = mk_huge_pmd(page, vma);
> +		entry = mk_huge_pmd(page, vma->vm_page_prot);
> +		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
>  		page_add_new_anon_rmap(page, vma, haddr);
>  		set_pmd_at(mm, haddr, pmd, entry);

I'm not the biggest fan since this does add lines of code, but I do
appreciate the consistency it adds, so:

Acked-by: Dave Hansen <dave.hansen@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
