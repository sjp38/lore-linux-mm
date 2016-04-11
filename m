Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 263BF6B025F
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:05:49 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id f198so140526051wme.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:05:49 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id 3si17803235wmk.45.2016.04.11.04.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 04:05:47 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id l6so140774766wml.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:05:47 -0700 (PDT)
Date: Mon, 11 Apr 2016 14:05:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 01/31] huge tmpfs: prepare counts in meminfo, vmstat and
 SysRq-m
Message-ID: <20160411110545.GD22996@node.shutemov.name>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051410260.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1604051410260.5965@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 05, 2016 at 02:12:26PM -0700, Hugh Dickins wrote:
> ShmemFreeHoles will show the wastage from using huge pages for small, or
> sparsely occupied, or unrounded files: wastage not included in Shmem or
> MemFree, but will be freed under memory pressure.  (But no count for the
> partially occupied portions of huge pages: seems less important, but
> could be added.)

And here first difference in interfaces comes: I don't have an
equivalent in my implementation, as I don't track such information.
It looks like an implementation detail for team-pages based huge tmpfs.

We don't track anything similar for anon-THP.

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3830,6 +3830,11 @@ out:
>  }
>  
>  #define K(x) ((x) << (PAGE_SHIFT-10))
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +#define THPAGE_PMD_NR	HPAGE_PMD_NR
> +#else
> +#define THPAGE_PMD_NR	0	/* Avoid BUILD_BUG() */
> +#endif

I've just put THP-related counters on separate line and wrap it into
#ifdef.


-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
