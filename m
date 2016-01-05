Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE2F6B0006
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 08:10:43 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id f206so22344894wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 05:10:43 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id u3si64916016wju.201.2016.01.05.05.10.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 05:10:42 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id b14so28275717wmb.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 05:10:42 -0800 (PST)
Date: Tue, 5 Jan 2016 15:10:39 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] mm, oom: skip mlocked VMAs in __oom_reap_vmas()
Message-ID: <20160105131039.GA19907@node.shutemov.name>
References: <1451421990-32297-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1451421990-32297-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20160105124735.GA15324@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160105124735.GA15324@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On Tue, Jan 05, 2016 at 01:47:35PM +0100, Michal Hocko wrote:
> On Tue 29-12-15 23:46:29, Kirill A. Shutemov wrote:
> > As far as I can see we explicitly munlock pages everywhere before unmap
> > them. The only case when we don't to that is OOM-reaper.
> 
> Very well spotted!
> 
> > I don't think we should bother with munlocking in this case, we can just
> > skip the locked VMA.
> 
> Why cannot we simply munlock them here for the private mappings?

It's probably right think to do, but I wanted to fix the bug first.
And I wasn't ready to investigate context the reaper working in to check
if it's safe to munlock there. For instance, munlock would take page lock
and I'm not sure at the moment if it can or cannot lead to deadlock in
some scenario. So I choose safer fix.

If calling munlock is always safe where unmap happens, why not move inside
unmap?

> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 4b0a5d8b92e1..25dd7cd6fb5e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -456,9 +456,12 @@ static bool __oom_reap_vmas(struct mm_struct *mm)
>  		 * we do not want to block exit_mmap by keeping mm ref
>  		 * count elevated without a good reason.
>  		 */
> -		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
> +		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
> +			if (vma->vm_flags & VM_LOCKED)
> +				munlock_vma_pages_all(vma);
>  			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
>  					 &details);
> +		}
>  	}
>  	tlb_finish_mmu(&tlb, 0, -1);
>  	up_read(&mm->mmap_sem);
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
