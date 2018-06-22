Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 402686B026E
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 12:19:14 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p16-v6so3419746pfn.7
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 09:19:14 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b10-v6si6461025pga.51.2018.06.22.09.19.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 09:19:13 -0700 (PDT)
Date: Fri, 22 Jun 2018 19:19:12 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [v2 PATCH 1/2] mm: thp: register mm for khugepaged when merging
 vma for shmem
Message-ID: <20180622161912.sq32cnhfxo5ctgdp@black.fi.intel.com>
References: <1529622949-75504-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180622075958.mzagr2ayufiuokea@black.fi.intel.com>
 <cce4aa50-f8b7-8626-31ae-12464a30f884@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cce4aa50-f8b7-8626-31ae-12464a30f884@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yang.shi@linux.alibaba.com
Cc: hughd@google.com, vbabka@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 22, 2018 at 04:04:12PM +0000, yang.shi@linux.alibaba.com wrote:
> 
> 
> On 6/22/18 12:59 AM, Kirill A. Shutemov wrote:
> > On Thu, Jun 21, 2018 at 11:15:48PM +0000, yang.shi@linux.alibaba.com wrote:
> > > When merging anonymous page vma, if the size of vma can fit in at least
> > > one hugepage, the mm will be registered for khugepaged for collapsing
> > > THP in the future.
> > > 
> > > But, it skips shmem vma. Doing so for shmem too, but not file-private
> > > mapping, when merging vma in order to increase the odd to collapse
> > > hugepage by khugepaged.
> > > 
> > > Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> > > Cc: Hugh Dickins <hughd@google.com>
> > > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Cc: Vlastimil Babka <vbabka@suse.cz>
> > > ---
> > > v1 --> 2:
> > > * Exclude file-private mapping per Kirill's comment
> > > 
> > >   mm/khugepaged.c | 8 ++++++--
> > >   1 file changed, 6 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> > > index d7b2a4b..9b0ec30 100644
> > > --- a/mm/khugepaged.c
> > > +++ b/mm/khugepaged.c
> > > @@ -440,8 +440,12 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
> > >   		 * page fault if needed.
> > >   		 */
> > >   		return 0;
> > > -	if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
> > > -		/* khugepaged not yet working on file or special mappings */
> > > +	if ((vma->vm_ops && (!shmem_file(vma->vm_file) || vma->anon_vma)) ||
> > > +	    (vm_flags & VM_NO_KHUGEPAGED))
> > > +		/*
> > > +		 * khugepaged not yet working on non-shmem file or special
> > > +		 * mappings. And, file-private shmem THP is not supported.
> > > +		 */
> > >   		return 0;
> > My point was that vma->anon_vma check above this one should not prevent
> > collapse for shmem.
> > 
> > Looking into this more, I think we should just replace all these checks
> > with hugepage_vma_check() call.
> 
> I got a little bit confused here. I thought the condition to *not* collapse
> file-private shmem mapping should be:
> 
> shmem_file(vma->vm_file) && vma->anon_vma
> 
> Is this right?

No, if shmem_file(vma->vm_file) is true, vma->anon_vma doesn't matter.
We don't care about anon_vma in such VMA as we don't touch file-private
pages.

-- 
 Kirill A. Shutemov
