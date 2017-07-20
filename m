Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E42716B0292
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 04:21:02 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k69so1969063wmc.14
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 01:21:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 59si1755733wrm.398.2017.07.20.01.21.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 01:21:01 -0700 (PDT)
Date: Thu, 20 Jul 2017 10:20:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/mremap: Fail map duplication attempts for private
 mappings
Message-ID: <20170720082058.GF9058@dhcp22.suse.cz>
References: <1499961495-8063-1-git-send-email-mike.kravetz@oracle.com>
 <4e921eb5-8741-3337-9a7d-5ec9473412da@suse.cz>
 <fad64378-02d7-32c3-50c5-8b444a07d274@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fad64378-02d7-32c3-50c5-8b444a07d274@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Linux API <linux-api@vger.kernel.org>

On Wed 19-07-17 09:39:50, Mike Kravetz wrote:
> On 07/13/2017 12:11 PM, Vlastimil Babka wrote:
> > [+CC linux-api]
> > 
> > On 07/13/2017 05:58 PM, Mike Kravetz wrote:
> >> mremap will create a 'duplicate' mapping if old_size == 0 is
> >> specified.  Such duplicate mappings make no sense for private
> >> mappings.  If duplication is attempted for a private mapping,
> >> mremap creates a separate private mapping unrelated to the
> >> original mapping and makes no modifications to the original.
> >> This is contrary to the purpose of mremap which should return
> >> a mapping which is in some way related to the original.
> >>
> >> Therefore, return EINVAL in the case where if an attempt is
> >> made to duplicate a private mapping.
> >>
> >> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> > 
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> After considering Michal's concerns with follow on patch, it appears
> this patch provides the most desired behavior.  Any other concerns
> or issues with this patch?

Maybe we should add a pr_warn_once to make users aware that this is no
longer supported.

> If this moves forward, I will create man page updates to describe the
> mremap(old_size == 0) behavior.
> 
> -- 
> Mike Kravetz
> 
> > 
> >> ---
> >>  mm/mremap.c | 7 +++++++
> >>  1 file changed, 7 insertions(+)
> >>
> >> diff --git a/mm/mremap.c b/mm/mremap.c
> >> index cd8a1b1..076f506 100644
> >> --- a/mm/mremap.c
> >> +++ b/mm/mremap.c
> >> @@ -383,6 +383,13 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
> >>  	if (!vma || vma->vm_start > addr)
> >>  		return ERR_PTR(-EFAULT);
> >>  
> >> +	/*
> >> +	 * !old_len  is a special case where a mapping is 'duplicated'.
> >> +	 * Do not allow this for private mappings.

Do not allow this for private mappings because we have never really
duplicated the range for those so the new VMA is a fresh one unrelated
to the original one which breaks mremap semantic. While we can do that
there doesn't seem to be any existing usecase currently.

> >> +	 */
> >> +	if (!old_len && !(vma->vm_flags & (VM_SHARED | VM_MAYSHARE)))
> >> +		return ERR_PTR(-EINVAL);
> >> +
> >>  	if (is_vm_hugetlb_page(vma))
> >>  		return ERR_PTR(-EINVAL);
> >>  
> >>
> > 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
