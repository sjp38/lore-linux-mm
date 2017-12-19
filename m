Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE7C46B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 06:39:23 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id a45so11255440wra.14
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 03:39:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z3si5221982wrz.517.2017.12.19.03.39.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 03:39:22 -0800 (PST)
Date: Tue, 19 Dec 2017 12:39:17 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: thp: use down_read_trylock in khugepaged to avoid
 long block
Message-ID: <20171219113917.GJ2787@dhcp22.suse.cz>
References: <1513281203-54878-1-git-send-email-yang.s@alibaba-inc.com>
 <fb89021a-a6f6-8bdb-4c9d-b66686589530@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <fb89021a-a6f6-8bdb-4c9d-b66686589530@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Yang Shi <yang.s@alibaba-inc.com>, kirill.shutemov@linux.intel.com, hughd@google.com, aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue 19-12-17 20:29:56, Tetsuo Handa wrote:
> On 2017/12/15 4:53, Yang Shi wrote:
> > diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> > index ea4ff25..ecc2b68 100644
> > --- a/mm/khugepaged.c
> > +++ b/mm/khugepaged.c
> > @@ -1674,7 +1674,12 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
> >  	spin_unlock(&khugepaged_mm_lock);
> >  
> >  	mm = mm_slot->mm;
> > -	down_read(&mm->mmap_sem);
> > +	/*
> > + 	 * Not wait for semaphore to avoid long time waiting, just move
> > + 	 * to the next mm on the list.
> > + 	 */
> > +	if (unlikely(!down_read_trylock(&mm->mmap_sem)))
> > +		goto breakouterloop_mmap_sem;
> >  	if (unlikely(khugepaged_test_exit(mm)))
> >  		vma = NULL;
> >  	else
> > 
> 
> You are jumping before initializing vma.
> 
> mm/khugepaged.c: In function a??khugepageda??:
> mm/khugepaged.c:1757:31: warning: a??vmaa?? may be used uninitialized in this function [-Wmaybe-uninitialized]
>   if (khugepaged_test_exit(mm) || !vma) {
>       ~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~
> mm/khugepaged.c:1659:25: note: a??vmaa?? was declared here
>   struct vm_area_struct *vma;
>                          ^~~ 

http://lkml.kernel.org/r/20171215125129.2948634-1-arnd@arndb.de

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
