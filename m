Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 96D5F6B00B7
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 17:09:52 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so745084pbc.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 14:09:51 -0800 (PST)
Date: Wed, 14 Nov 2012 14:09:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 01/11] thp: huge zero page: basic preparation
In-Reply-To: <1352300463-12627-2-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1211141407120.13515@chino.kir.corp.google.com>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <1352300463-12627-2-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:

> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> Huge zero page (hzp) is a non-movable huge page (2M on x86-64) filled
> with zeros.
> 
> For now let's allocate the page on hugepage_init(). We'll switch to lazy
> allocation later.
> 
> We are not going to map the huge zero page until we can handle it
> properly on all code paths.
> 
> is_huge_zero_{pfn,pmd}() functions will be used by following patches to
> check whether the pfn/pmd is huge zero page.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: David Rientjes <rientjes@google.com>

> ---
>  mm/huge_memory.c |   30 ++++++++++++++++++++++++++++++
>  1 files changed, 30 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 40f17c3..e5ce979 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -47,6 +47,7 @@ static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
>  /* during fragmentation poll the hugepage allocator once every minute */
>  static unsigned int khugepaged_alloc_sleep_millisecs __read_mostly = 60000;
>  static struct task_struct *khugepaged_thread __read_mostly;
> +static unsigned long huge_zero_pfn __read_mostly;
>  static DEFINE_MUTEX(khugepaged_mutex);
>  static DEFINE_SPINLOCK(khugepaged_mm_lock);
>  static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
> @@ -159,6 +160,29 @@ static int start_khugepaged(void)
>  	return err;
>  }
>  
> +static int init_huge_zero_page(void)

Could be __init, but this gets switched over to lazy allocation later in 
the series so probably not worth it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
