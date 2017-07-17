Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 37C976B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:44:12 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 79so18292958wmg.4
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 23:44:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j1si11912598wrb.194.2017.07.16.23.44.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 16 Jul 2017 23:44:11 -0700 (PDT)
Date: Mon, 17 Jul 2017 08:44:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/mremap: Fail map duplication attempts for private
 mappings
Message-ID: <20170717064407.GB7397@dhcp22.suse.cz>
References: <1499961495-8063-1-git-send-email-mike.kravetz@oracle.com>
 <4e921eb5-8741-3337-9a7d-5ec9473412da@suse.cz>
 <415625d2-1be9-71f0-ca11-a014cef98a3f@oracle.com>
 <20170714082629.GA2618@dhcp22.suse.cz>
 <146116f3-c318-efc0-de40-f67655cbbf94@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <146116f3-c318-efc0-de40-f67655cbbf94@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Linux API <linux-api@vger.kernel.org>

On Fri 14-07-17 10:29:01, Mike Kravetz wrote:
> On 07/14/2017 01:26 AM, Michal Hocko wrote:
> > On Thu 13-07-17 15:33:47, Mike Kravetz wrote:
> >> On 07/13/2017 12:11 PM, Vlastimil Babka wrote:
> >>> [+CC linux-api]
> >>>
> >>> On 07/13/2017 05:58 PM, Mike Kravetz wrote:
> >>>> mremap will create a 'duplicate' mapping if old_size == 0 is
> >>>> specified.  Such duplicate mappings make no sense for private
> >>>> mappings.  If duplication is attempted for a private mapping,
> >>>> mremap creates a separate private mapping unrelated to the
> >>>> original mapping and makes no modifications to the original.
> >>>> This is contrary to the purpose of mremap which should return
> >>>> a mapping which is in some way related to the original.
> >>>>
> >>>> Therefore, return EINVAL in the case where if an attempt is
> >>>> made to duplicate a private mapping.
> >>>>
> >>>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> >>>
> >>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> >>>
> >>
> >> In another e-mail thread, Andrea makes the case that mremap(old_size == 0)
> >> of private file backed mappings could possibly be used for something useful.
> >> For example to create a private COW mapping.
> > 
> > What does this mean exactly? I do not see it would force CoW so again
> > the new mapping could fail with the basic invariant that the content
> > of the new mapping should match the old one (e.g. old mapping already
> > CoWed some pages the new mapping would still contain the origin content
> > unless I am missing something).
> 
> I do not think you are missing anything.  You are correct in saying that
> the new mapping would be COW of the original file contents.  It is NOT
> based on any private pages of the old private mapping.  Sorry, my wording
> above was not quite clear.
> 
> As previously discussed, the more straight forward to way to accomplish
> the same thing would be a simple call to mmap with the fd.
> 
> After thinking about this some more, perhaps the original patch to return
> EINVAL for all private mappings makes more sense.  Even in the case of a
> file backed private mapping, the new mapping will be based on the file and
> not the old mapping.  The purpose of mremap is to create a new mapping
> based on the old mapping.  So, this is not strictly in line with the purpose
> of mremap.

Yes that is exactly my point. One would expect that the new mapping has
the same content as the previous mapping at the time when it was created
and the copy will be "atomic" (wrt. page faults). Otherwise you could
simply implement it in the userspace.

That being said, I do not think we should try to pretend this is a
correct behavior and the !old_len should be supported only for the
shared mappings which have at least reasonable semantic.

> Actually, the more I think about this, the more I wish there was some way
> to deprecate and eventually eliminate the old_size == 0 behavior.
> 
> > [...]
> >> +	/*
> >> +	 * !old_len  is a special case where a mapping is 'duplicated'.
> >> +	 * Do not allow this for private anon mappings.
> >> +	 */
> >> +	if (!old_len && vma_is_anonymous(vma) &&
> >> +	    !(vma->vm_flags & (VM_SHARED | VM_MAYSHARE)))
> >> +		return ERR_PTR(-EINVAL);
> > 
> > Why is vma_is_anonymous() without VM_*SHARE* check insufficient?
> 
> Are you asking,
> why is if (!old_len && vma_is_anonymous(vma)) insufficient?

yes

> If so, you are correct that the additional check for VM_*SHARE* is not
> necessary.  Shared mappings are technically not anonymous as they must
> contain a common backing object.

that is my understanding as well. But maybe there are some weird
mappings which do not have vm_ops and populate the whole range inside
the mmap callback. I remember we had a CVE for those but forgot all
details of course. Failing on those doesn't seem like a tragedy to me
and maybe it is even correct.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
