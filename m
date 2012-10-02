Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id B51896B0068
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 12:13:32 -0400 (EDT)
Date: Tue, 2 Oct 2012 18:13:30 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v3 00/10] Introduce huge zero page
Message-ID: <20121002161330.GG4763@redhat.com>
References: <1349191172-28855-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1349191172-28855-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Tue, Oct 02, 2012 at 06:19:22PM +0300, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> During testing I noticed big (up to 2.5 times) memory consumption overhead
> on some workloads (e.g. ft.A from NPB) if THP is enabled.
> 
> The main reason for that big difference is lacking zero page in THP case.
> We have to allocate a real page on read page fault.
> 
> A program to demonstrate the issue:
> #include <assert.h>
> #include <stdlib.h>
> #include <unistd.h>
> 
> #define MB 1024*1024
> 
> int main(int argc, char **argv)
> {
>         char *p;
>         int i;
> 
>         posix_memalign((void **)&p, 2 * MB, 200 * MB);
>         for (i = 0; i < 200 * MB; i+= 4096)
>                 assert(p[i] == 0);
>         pause();
>         return 0;
> }
> 
> With thp-never RSS is about 400k, but with thp-always it's 200M.
> After the patcheset thp-always RSS is 400k too.
> 
> v3:
>  - fix potential deadlock in refcounting code on preemptive kernel.
>  - do not mark huge zero page as movable.
>  - fix typo in comment.
>  - Reviewed-by tag from Andrea Arcangeli.
> v2:
>  - Avoid find_vma() if we've already had vma on stack.
>    Suggested by Andrea Arcangeli.
>  - Implement refcounting for huge zero page.
> 
> Kirill A. Shutemov (10):
>   thp: huge zero page: basic preparation
>   thp: zap_huge_pmd(): zap huge zero pmd
>   thp: copy_huge_pmd(): copy huge zero page
>   thp: do_huge_pmd_wp_page(): handle huge zero page
>   thp: change_huge_pmd(): keep huge zero page write-protected
>   thp: change split_huge_page_pmd() interface
>   thp: implement splitting pmd for huge zero page
>   thp: setup huge zero page on non-write page fault
>   thp: lazy huge zero page allocation
>   thp: implement refcounting for huge zero page

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
