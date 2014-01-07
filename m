Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 28C636B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 05:22:18 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id q59so16695080wes.38
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 02:22:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si88181237eeg.51.2014.01.07.02.22.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 02:22:15 -0800 (PST)
Date: Tue, 7 Jan 2014 11:22:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: could you clarify mm/mempolicy: fix !vma in new_vma_page()
Message-ID: <20140107102212.GC8756@dhcp22.suse.cz>
References: <20140106112422.GA27602@dhcp22.suse.cz>
 <CAA_GA1dNdrG9aQ3UKDA0O=BY721rvseORVkc2+RxUpzysp3rYw@mail.gmail.com>
 <20140106141827.GB27602@dhcp22.suse.cz>
 <CAA_GA1csMEhSYmeS7qgDj7h=Xh2WrsYvirkS55W4Jj3LTHy87A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1csMEhSYmeS7qgDj7h=Xh2WrsYvirkS55W4Jj3LTHy87A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bob Liu <bob.liu@oracle.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 07-01-14 13:29:31, Bob Liu wrote:
> On Mon, Jan 6, 2014 at 10:18 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Mon 06-01-14 20:45:54, Bob Liu wrote:
> > [...]
> >>  544         if (PageAnon(page)) {
> >>  545                 struct anon_vma *page__anon_vma = page_anon_vma(page);
> >>  546                 /*
> >>  547                  * Note: swapoff's unuse_vma() is more efficient with this
> >>  548                  * check, and needs it to match anon_vma when KSM is active.
> >>  549                  */
> >>  550                 if (!vma->anon_vma || !page__anon_vma ||
> >>  551                     vma->anon_vma->root != page__anon_vma->root)
> >>  552                         return -EFAULT;
> >>  553         } else if (page->mapping && !(vma->vm_flags & VM_NONLINEAR)) {
> >>  554                 if (!vma->vm_file ||
> >>  555                     vma->vm_file->f_mapping != page->mapping)
> >>  556                         return -EFAULT;
> >>  557         } else
> >>  558                 return -EFAULT;
> >>
> >> That's the "other conditions" and the reason why we can't use
> >> BUG_ON(!vma) in new_vma_page().
> >
> > Sorry, I wasn't clear with my question. I was interested in which of
> > these triggered and why only for hugetlb pages?
> >
> 
> Sorry I didn't analyse the root cause. They are several checks in
> page_address_in_vma() so I think it might be not difficult to hit one
> of them.

I would be really curious when anon_vma or f_mapping would be out of
sync, that's why I've asked in the first place.

> For example, if the page was mapped to vma by nonlinear
> mapping?

Hmm, ok !private shmem/hugetlbfs might be remapped as non-linear. For
some reason I thought that migration for non-linear mappings is not
allowed. This is not the case and it would explain why the BUG_ON
triggered.

> Anyway, some debug code is needed to verify what really happened here.

That would be prefferable before the patch had been submitted and
merged...

> alloc_page_vma() can handle the vma=NULL case while
> alloc_huge_page_noerr() can't, so we return NULL instead of call down
> to alloc_huge_page().

OK, I see.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
