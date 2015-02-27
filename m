Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 14E476B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 15:53:41 -0500 (EST)
Received: by igal13 with SMTP id l13so3661985iga.5
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 12:53:40 -0800 (PST)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id k6si1710323icl.32.2015.02.27.12.53.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 12:53:40 -0800 (PST)
Received: by igbhl2 with SMTP id hl2so3338466igb.0
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 12:53:40 -0800 (PST)
Date: Fri, 27 Feb 2015 12:53:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: set khugepaged_max_ptes_none by 1/8 of
 HPAGE_PMD_NR
In-Reply-To: <1425061608-15811-1-git-send-email-ebru.akagunduz@gmail.com>
Message-ID: <alpine.DEB.2.10.1502271248240.2122@chino.kir.corp.google.com>
References: <1425061608-15811-1-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, riel@redhat.com, aarcange@redhat.com

On Fri, 27 Feb 2015, Ebru Akagunduz wrote:

> Using THP, programs can access memory faster, by having the
> kernel collapse small pages into large pages. The parameter
> max_ptes_none specifies how many extra small pages (that are
> not already mapped) can be allocated when collapsing a group
> of small pages into one large page.
> 

Not exactly, khugepaged isn't "allocating" small pages to collapse into a 
hugepage, rather it is allocating a hugepage and then remapping the 
pageblock's mapped pages.

> A larger value of max_ptes_none can cause the kernel
> to collapse more incomplete areas into THPs, speeding
> up memory access at the cost of increased memory use.
> A smaller value of max_ptes_none will reduce memory
> waste, at the expense of collapsing fewer areas into
> THPs.
> 

This changelog only describes what max_ptes_none does, it doesn't state 
why you want to change it from HPAGE_PMD_NR-1, which is 511 on x86_64 
(largest value, more thp), to HPAGE_PMD_NR/8, which is 64 (smaller value, 
less thp, less rss as a result of collapsing).

This has particular performance implications on users who already have thp 
enabled, so it's difficult to change the default.  This is tuanble that 
you could easily set in an initscript, so I don't think we need to change 
the value for everybody.

> The problem was reported here:
> https://bugzilla.kernel.org/show_bug.cgi?id=93111
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> ---
>  mm/huge_memory.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index e08e37a..497fb5a 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -59,11 +59,10 @@ static DEFINE_MUTEX(khugepaged_mutex);
>  static DEFINE_SPINLOCK(khugepaged_mm_lock);
>  static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
>  /*
> - * default collapse hugepages if there is at least one pte mapped like
> - * it would have happened if the vma was large enough during page
> - * fault.
> + * The default value should be a compromise between memory use and THP speedup.
> + * To collapse hugepages, unmapped ptes should not exceed 1/8 of HPAGE_PMD_NR.
>   */
> -static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
> +static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR/8;
>  
>  static int khugepaged(void *none);
>  static int khugepaged_slab_init(void);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
