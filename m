Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68F4A440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 04:26:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id r7so376733wrb.0
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:26:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f184si1642164wma.85.2017.07.14.01.26.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 01:26:32 -0700 (PDT)
Date: Fri, 14 Jul 2017 10:26:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/mremap: Fail map duplication attempts for private
 mappings
Message-ID: <20170714082629.GA2618@dhcp22.suse.cz>
References: <1499961495-8063-1-git-send-email-mike.kravetz@oracle.com>
 <4e921eb5-8741-3337-9a7d-5ec9473412da@suse.cz>
 <415625d2-1be9-71f0-ca11-a014cef98a3f@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <415625d2-1be9-71f0-ca11-a014cef98a3f@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Linux API <linux-api@vger.kernel.org>

On Thu 13-07-17 15:33:47, Mike Kravetz wrote:
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
> > 
> 
> In another e-mail thread, Andrea makes the case that mremap(old_size == 0)
> of private file backed mappings could possibly be used for something useful.
> For example to create a private COW mapping.

What does this mean exactly? I do not see it would force CoW so again
the new mapping could fail with the basic invariant that the content
of the new mapping should match the old one (e.g. old mapping already
CoWed some pages the new mapping would still contain the origin content
unless I am missing something).

[...]
> +	/*
> +	 * !old_len  is a special case where a mapping is 'duplicated'.
> +	 * Do not allow this for private anon mappings.
> +	 */
> +	if (!old_len && vma_is_anonymous(vma) &&
> +	    !(vma->vm_flags & (VM_SHARED | VM_MAYSHARE)))
> +		return ERR_PTR(-EINVAL);

Why is vma_is_anonymous() without VM_*SHARE* check insufficient?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
