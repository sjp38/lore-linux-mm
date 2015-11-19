Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f42.google.com (mail-vk0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0A36B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 04:43:33 -0500 (EST)
Received: by vkfr145 with SMTP id r145so13108612vkf.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 01:43:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a132si3322593vke.115.2015.11.19.01.43.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 01:43:32 -0800 (PST)
Date: Thu, 19 Nov 2015 09:43:26 +0000
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH] mm: Loosen MADV_NOHUGEPAGE to enable Qemu postcopy on
 s390
Message-ID: <20151119094326.GA2653@work-vm>
References: <1447341516-18076-1-git-send-email-jjherne@linux.vnet.ibm.com>
 <564C7DCA.8010400@suse.cz>
 <564D86AE.1010305@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <564D86AE.1010305@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, linux-api@vger.kernel.org, linux-man@vger.kernel.org, qemu-devel <qemu-devel@nongnu.org>, Juan Quintela <quintela@redhat.com>

* Christian Borntraeger (borntraeger@de.ibm.com) wrote:
> On 11/18/2015 02:31 PM, Vlastimil Babka wrote:
> > [CC += linux-api@vger.kernel.org]
> > 
> > Since this is a kernel-user-space API change, please CC linux-api@. The kernel
> > source file Documentation/SubmitChecklist notes that all Linux kernel patches
> > that change userspace interfaces should be CCed to linux-api@vger.kernel.org, so
> > that the various parties who are interested in API changes are informed. For
> > further information, see https://www.kernel.org/doc/man-pages/linux-api-ml.html
> > 
> > On 11/12/2015 04:18 PM, Jason J. Herne wrote:
> >> MADV_NOHUGEPAGE processing is too restrictive. kvm already disables
> >> hugepage but hugepage_madvise() takes the error path when we ask to turn
> >> on the MADV_NOHUGEPAGE bit and the bit is already on. This causes Qemu's
> >> new postcopy migration feature to fail on s390 because its first action is
> >> to madvise the guest address space as NOHUGEPAGE. This patch modifies the
> >> code so that the operation succeeds without error now.
> >>
> >> Signed-off-by: Jason J. Herne <jjherne@linux.vnet.ibm.com>
> >> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Looks like the manpage should be fine, as it wasn't very specific wrt these
> > madvise flags. The only thing that potentially applies is:
> > 
> > "EINVAL advice is not a valid."
> > 
> > which itself looks like it needs fixing. Valid what, value? As in completely
> > unknown flags, or flags not valid for the given vma?
> > 
> > Anyway, I agree that it doesn't make sense to fail madvise when the given flag
> > is already set. On the other hand, I don't think the userspace app should fail
> > just because of madvise failing? It should in general be an advice that the
> > kernel is also strictly speaking free to ignore as it shouldn't affect
> > correctnes, just performance. Yeah, there are exceptions today like
> > MADV_DONTNEED, but that shouldn't apply to hugepages?
> > So I think Qemu needs fixing too.
> 
> yes, I agree. David, Juan. I think The postcopy code should not fail if the madvise.
> Can you fix that? 

Yes, I can change that.

>  Also what happens if the kernel is build
> > without CONFIG_TRANSPARENT_HUGEPAGE? Then madvise also returns EINVAL,
> 
> Does it? To me it looks more like we would trigger a kernel bug.

Yes, it does return EINVAL; it's a shame - there's no way to distinguish between
a kernel that doesn't have hugepage and a screwup in the addresses passed;
everything gets squashed into EINVAL.

Dave

> mm/madvise.c:
>         case MADV_HUGEPAGE:
>         case MADV_NOHUGEPAGE:
>                 error = hugepage_madvise(vma, &new_flags, behavior);  <-----
>                 if (error)
>                         goto out;
>                 break;
>         }
> 
> 
> include/linux/huge_mm.h:
> static inline int hugepage_madvise(struct vm_area_struct *vma,
>                                    unsigned long *vm_flags, int advice)
> {
>         BUG();
>         return 0;
> }
> 
> If we just remove the BUG() statement the code would actually be correct
> in simply ignoring an MADVISE it cannot handle. If you agree, I can
> spin a patch.
> 
> 
> 
> 
> > how does Qemu handle that?
> 
> The normal qemu startup ignores the return value of the madvise. Only the
> recent post migration changes want to disable huge pages for userfaultd.
> And this code checks the return value. And yes, we should change that
> in QEMU.
> 
> 
> 
> 
> > 
> >> ---
> >>  mm/huge_memory.c | 4 ++--
> >>  1 file changed, 2 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> >> index c29ddeb..62fe06b 100644
> >> --- a/mm/huge_memory.c
> >> +++ b/mm/huge_memory.c
> >> @@ -2009,7 +2009,7 @@ int hugepage_madvise(struct vm_area_struct *vma,
> >>  		/*
> >>  		 * Be somewhat over-protective like KSM for now!
> >>  		 */
> >> -		if (*vm_flags & (VM_HUGEPAGE | VM_NO_THP))
> >> +		if (*vm_flags & VM_NO_THP)
> >>  			return -EINVAL;
> >>  		*vm_flags &= ~VM_NOHUGEPAGE;
> >>  		*vm_flags |= VM_HUGEPAGE;
> >> @@ -2025,7 +2025,7 @@ int hugepage_madvise(struct vm_area_struct *vma,
> >>  		/*
> >>  		 * Be somewhat over-protective like KSM for now!
> >>  		 */
> >> -		if (*vm_flags & (VM_NOHUGEPAGE | VM_NO_THP))
> >> +		if (*vm_flags & VM_NO_THP)
> >>  			return -EINVAL;
> >>  		*vm_flags &= ~VM_HUGEPAGE;
> >>  		*vm_flags |= VM_NOHUGEPAGE;
> >>
> > 
> 
--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
