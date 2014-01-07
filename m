Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2406B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 23:26:22 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so19129293pde.28
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 20:26:22 -0800 (PST)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [122.248.162.5])
        by mx.google.com with ESMTPS id ot3si57029037pac.224.2014.01.06.20.26.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 20:26:21 -0800 (PST)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 7 Jan 2014 09:56:18 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id BCC06E0024
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 09:59:00 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s074Q95I52691178
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 09:56:09 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s074QEpP004555
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 09:56:15 +0530
Date: Tue, 7 Jan 2014 12:26:13 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: could you clarify mm/mempolicy: fix !vma in new_vma_page()
Message-ID: <52cb81ed.e3d8420a.72a1.ffffea65SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20140106112422.GA27602@dhcp22.suse.cz>
 <CAA_GA1dNdrG9aQ3UKDA0O=BY721rvseORVkc2+RxUpzysp3rYw@mail.gmail.com>
 <20140106141827.GB27602@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140106141827.GB27602@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Bob Liu <lliubbo@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bob Liu <bob.liu@oracle.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Michal,
On Mon, Jan 06, 2014 at 03:18:27PM +0100, Michal Hocko wrote:
>On Mon 06-01-14 20:45:54, Bob Liu wrote:
>[...]
>>  544         if (PageAnon(page)) {
>>  545                 struct anon_vma *page__anon_vma = page_anon_vma(page);
>>  546                 /*
>>  547                  * Note: swapoff's unuse_vma() is more efficient with this
>>  548                  * check, and needs it to match anon_vma when KSM is active.
>>  549                  */
>>  550                 if (!vma->anon_vma || !page__anon_vma ||
>>  551                     vma->anon_vma->root != page__anon_vma->root)
>>  552                         return -EFAULT;
>>  553         } else if (page->mapping && !(vma->vm_flags & VM_NONLINEAR)) {
>>  554                 if (!vma->vm_file ||
>>  555                     vma->vm_file->f_mapping != page->mapping)
>>  556                         return -EFAULT;
>>  557         } else
>>  558                 return -EFAULT;
>> 
>> That's the "other conditions" and the reason why we can't use
>> BUG_ON(!vma) in new_vma_page().
>
>Sorry, I wasn't clear with my question. I was interested in which of
>these triggered and why only for hugetlb pages?

Not just for hugetlb pages, sorry for do two things in one patch. The change 
for hugetlb pages is to fix the potential dereference NULL pointer reported 
by Dan. http://marc.info/?l=linux-mm&m=137689530323257&w=2 

If we should ask Sasha to add more debug information to dump which condition 
is failed in page_address_in_vma() for you?

Regards,
Wanpeng Li 
	

>
>-- 
>Michal Hocko
>SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
