Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A28486B0253
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 08:03:19 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id c3so5053978wrd.0
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 05:03:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si5323876wrf.298.2017.12.15.05.03.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Dec 2017 05:03:17 -0800 (PST)
Date: Fri, 15 Dec 2017 14:03:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: thp: avoid uninitialized variable use
Message-ID: <20171215130315.GZ16951@dhcp22.suse.cz>
References: <20171215125129.2948634-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171215125129.2948634-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 15-12-17 13:51:04, Arnd Bergmann wrote:
> When the down_read_trylock() fails, 'vma' has not been initialized
> yet, which gcc now warns about:
> 
> mm/khugepaged.c: In function 'khugepaged':
> mm/khugepaged.c:1659:25: error: 'vma' may be used uninitialized in this function [-Werror=maybe-uninitialized]

ups missed that

> 
> Presumable we are not supposed to call find_vma() without the mmap_sem
> either, so setting it to NULL for this case seems appropriate.

yes

> Fixes: 0951b59acf3a ("mm: thp: use down_read_trylock() in khugepaged to avoid long block")

This sha is not stable because this is a mmotm tree. I assume Andrew will fold
it to mm-thp-use-down_read_trylock-in-khugepaged-to-avoid-long-block.patch.
The patch looks good to me. I would initialize the vma in the
declaration, but that is a minor thing.

> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> I'm not completely sure this patch is sufficient, it gets rid of
> the warning, but it would be good to have the code reviewed better
> to see if other problems remain that result from down_read_trylock()
> patch.
> ---
>  mm/khugepaged.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 521b908f9600..b7e2268dfc9a 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1677,11 +1677,10 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
>  	 * Don't wait for semaphore (to avoid long wait times).  Just move to
>  	 * the next mm on the list.
>  	 */
> +	vma = NULL;
>  	if (unlikely(!down_read_trylock(&mm->mmap_sem)))
>  		goto breakouterloop_mmap_sem;
> -	if (unlikely(khugepaged_test_exit(mm)))
> -		vma = NULL;
> -	else
> +	if (likely(!khugepaged_test_exit(mm)))
>  		vma = find_vma(mm, khugepaged_scan.address);
>  
>  	progress++;
> -- 
> 2.9.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
