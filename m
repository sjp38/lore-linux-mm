Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1AB876B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 06:30:03 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f8so12507883pgs.9
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 03:30:03 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z11si10775102plo.291.2017.12.19.03.30.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 03:30:00 -0800 (PST)
Subject: Re: [PATCH] mm: thp: use down_read_trylock in khugepaged to avoid
 long block
References: <1513281203-54878-1-git-send-email-yang.s@alibaba-inc.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <fb89021a-a6f6-8bdb-4c9d-b66686589530@I-love.SAKURA.ne.jp>
Date: Tue, 19 Dec 2017 20:29:56 +0900
MIME-Version: 1.0
In-Reply-To: <1513281203-54878-1-git-send-email-yang.s@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: kirill.shutemov@linux.intel.com, mhocko@suse.com, hughd@google.com, aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org

On 2017/12/15 4:53, Yang Shi wrote:
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index ea4ff25..ecc2b68 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1674,7 +1674,12 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
>  	spin_unlock(&khugepaged_mm_lock);
>  
>  	mm = mm_slot->mm;
> -	down_read(&mm->mmap_sem);
> +	/*
> + 	 * Not wait for semaphore to avoid long time waiting, just move
> + 	 * to the next mm on the list.
> + 	 */
> +	if (unlikely(!down_read_trylock(&mm->mmap_sem)))
> +		goto breakouterloop_mmap_sem;
>  	if (unlikely(khugepaged_test_exit(mm)))
>  		vma = NULL;
>  	else
> 

You are jumping before initializing vma.

mm/khugepaged.c: In function a??khugepageda??:
mm/khugepaged.c:1757:31: warning: a??vmaa?? may be used uninitialized in this function [-Wmaybe-uninitialized]
  if (khugepaged_test_exit(mm) || !vma) {
      ~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~
mm/khugepaged.c:1659:25: note: a??vmaa?? was declared here
  struct vm_area_struct *vma;
                         ^~~ 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
