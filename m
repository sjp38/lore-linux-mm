Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E8DB96B0033
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 13:01:21 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a13so7503315pgt.0
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 10:01:21 -0800 (PST)
Received: from out0-201.mail.aliyun.com (out0-201.mail.aliyun.com. [140.205.0.201])
        by mx.google.com with ESMTPS id c7si5310487plr.486.2017.12.15.10.01.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 10:01:20 -0800 (PST)
Subject: Re: [PATCH] mm: thp: avoid uninitialized variable use
References: <20171215125129.2948634-1-arnd@arndb.de>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <8d5476e2-5f87-1134-62d4-9f649c4e709a@alibaba-inc.com>
Date: Sat, 16 Dec 2017 02:01:08 +0800
MIME-Version: 1.0
In-Reply-To: <20171215125129.2948634-1-arnd@arndb.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 12/15/17 4:51 AM, Arnd Bergmann wrote:
> When the down_read_trylock() fails, 'vma' has not been initialized
> yet, which gcc now warns about:
> 
> mm/khugepaged.c: In function 'khugepaged':
> mm/khugepaged.c:1659:25: error: 'vma' may be used uninitialized in this function [-Werror=maybe-uninitialized]

Arnd,

Thanks for catching this. I'm wondering why my test didn't catch it. It 
might be because my gcc is old. I'm using gcc 4.8.5 on centos 7.

Regards,
Yang

> 
> Presumable we are not supposed to call find_vma() without the mmap_sem
> either, so setting it to NULL for this case seems appropriate.
> 
> Fixes: 0951b59acf3a ("mm: thp: use down_read_trylock() in khugepaged to avoid long block")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> I'm not completely sure this patch is sufficient, it gets rid of
> the warning, but it would be good to have the code reviewed better
> to see if other problems remain that result from down_read_trylock()
> patch.
> ---
>   mm/khugepaged.c | 5 ++---
>   1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 521b908f9600..b7e2268dfc9a 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1677,11 +1677,10 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
>   	 * Don't wait for semaphore (to avoid long wait times).  Just move to
>   	 * the next mm on the list.
>   	 */
> +	vma = NULL;
>   	if (unlikely(!down_read_trylock(&mm->mmap_sem)))
>   		goto breakouterloop_mmap_sem;
> -	if (unlikely(khugepaged_test_exit(mm)))
> -		vma = NULL;
> -	else
> +	if (likely(!khugepaged_test_exit(mm)))
>   		vma = find_vma(mm, khugepaged_scan.address);
>   
>   	progress++;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
