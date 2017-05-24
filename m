Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD98F6B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 11:13:54 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k15so19898198wmh.3
        for <linux-mm@kvack.org>; Wed, 24 May 2017 08:13:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q201si4954001wmg.49.2017.05.24.08.13.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 08:13:53 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4OFBflt102175
	for <linux-mm@kvack.org>; Wed, 24 May 2017 11:13:51 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2anc5whdt2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 May 2017 11:13:51 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 24 May 2017 16:13:47 +0100
Date: Wed, 24 May 2017 18:13:41 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <20170522133559.GE27382@rapoport-lnx>
 <20170522135548.GA8514@dhcp22.suse.cz>
 <20170522142927.GG27382@rapoport-lnx>
 <a9e74c22-1a07-f49a-42b5-497fee85e9c9@suse.cz>
 <20170524075043.GB3063@rapoport-lnx>
 <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
 <20170524103947.GC3063@rapoport-lnx>
 <aec1376e-34b3-56ce-448e-7fbddcda448b@suse.cz>
 <ab5bbeb6-0c61-f505-f365-37ca43415696@virtuozzo.com>
 <91778b6e-cb69-bfca-51da-f8c3256e630e@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <91778b6e-cb69-bfca-51da-f8c3256e630e@suse.cz>
Message-Id: <20170524151340.GG3063@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, May 24, 2017 at 04:54:38PM +0200, Vlastimil Babka wrote:
> On 05/24/2017 04:28 PM, Pavel Emelyanov wrote:
> > On 05/24/2017 02:31 PM, Vlastimil Babka wrote:
> >> On 05/24/2017 12:39 PM, Mike Rapoport wrote:
> >>>> Hm so the prctl does:
> >>>>
> >>>>                 if (arg2)
> >>>>                         me->mm->def_flags |= VM_NOHUGEPAGE;
> >>>>                 else
> >>>>                         me->mm->def_flags &= ~VM_NOHUGEPAGE;
> >>>>
> >>>> That's rather lazy implementation IMHO. Could we change it so the flag
> >>>> is stored elsewhere in the mm, and the code that decides to (not) use
> >>>> THP will check both the per-vma flag and the per-mm flag?
> >>>
> >>> I afraid I don't understand how that can help.
> >>> What we need is an ability to temporarily disable collapse of the pages in
> >>> VMAs that do not have VM_*HUGEPAGE flags set and that after we re-enable
> >>> THP, the vma->vm_flags for those VMAs will remain intact.
> >>
> >> That's what I'm saying - instead of implementing the prctl flag via
> >> mm->def_flags (which gets permanently propagated to newly created vma's
> >> but e.g. doesn't affect already existing ones), it would be setting a
> >> flag somewhere in mm, which khugepaged (and page faults) would check in
> >> addition to the per-vma flags.
> > 
> > I do not insist, but this would make existing paths (checking for flags) be 
> > 2 times slower -- from now on these would need to check two bits (vma flags
> > and mm flags) which are 100% in different cache lines.
> 
> I'd expect you already have mm struct cached during a page fault. And
> THP-eligible page fault is just one per pmd, the overhead should be
> practically zero.
> 
> > What Mike is proposing is the way to fine-tune the existing vma flags. This
> > would keep current paths as fast (or slow ;) ) as they are now. All the
> > complexity would go to rare cases when someone needs to turn thp off for a
> > while and then turn it back on.
> 
> Yeah but it's extending user-space API for a corner case. We should do
> that only when there's no other option.

With madvise() I'm suggesting we rather add "completeness" to the existing
API, IMHO. We do have API that sets VM_HUGEPAGE and clears VM_NOHUGEPAGE or
vise versa, but we do not have an API that can clear both flags...

And if we would use prctl(), we either change user visible behaviour or we
still need to extend the API and use, say, arg2 to distinguish between the
current behaviour and the new one.

--
Sincerely yours,
Mike. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
