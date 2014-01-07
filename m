Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6268E6B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 00:29:33 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id k4so236962qaq.36
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 21:29:33 -0800 (PST)
Received: from mail-ve0-x229.google.com (mail-ve0-x229.google.com [2607:f8b0:400c:c01::229])
        by mx.google.com with ESMTPS id t7si74686209qar.43.2014.01.06.21.29.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 21:29:32 -0800 (PST)
Received: by mail-ve0-f169.google.com with SMTP id c14so9918880vea.0
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 21:29:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140106141827.GB27602@dhcp22.suse.cz>
References: <20140106112422.GA27602@dhcp22.suse.cz>
	<CAA_GA1dNdrG9aQ3UKDA0O=BY721rvseORVkc2+RxUpzysp3rYw@mail.gmail.com>
	<20140106141827.GB27602@dhcp22.suse.cz>
Date: Tue, 7 Jan 2014 13:29:31 +0800
Message-ID: <CAA_GA1csMEhSYmeS7qgDj7h=Xh2WrsYvirkS55W4Jj3LTHy87A@mail.gmail.com>
Subject: Re: could you clarify mm/mempolicy: fix !vma in new_vma_page()
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bob Liu <bob.liu@oracle.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jan 6, 2014 at 10:18 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Mon 06-01-14 20:45:54, Bob Liu wrote:
> [...]
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
> Sorry, I wasn't clear with my question. I was interested in which of
> these triggered and why only for hugetlb pages?
>

Sorry I didn't analyse the root cause. They are several checks in
page_address_in_vma() so I think it might be not difficult to hit one
of them. For example, if the page was mapped to vma by nonlinear
mapping?
Anyway, some debug code is needed to verify what really happened here.

alloc_page_vma() can handle the vma=NULL case while
alloc_huge_page_noerr() can't, so we return NULL instead of call down
to alloc_huge_page().

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
