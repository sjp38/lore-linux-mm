Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id ED85C829A8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 16:48:32 -0400 (EDT)
Received: by wichy4 with SMTP id hy4so58551660wic.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 13:48:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id km4si3470850wjc.108.2015.05.22.13.48.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 13:48:31 -0700 (PDT)
Date: Fri, 22 May 2015 22:48:09 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 22/23] userfaultfd: avoid mmap_sem read recursion in
 mcopy_atomic
Message-ID: <20150522204809.GB4251@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <1431624680-20153-23-git-send-email-aarcange@redhat.com>
 <20150522131822.74f374dd5a75a0285577c714@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150522131822.74f374dd5a75a0285577c714@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

On Fri, May 22, 2015 at 01:18:22PM -0700, Andrew Morton wrote:
> On Thu, 14 May 2015 19:31:19 +0200 Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > If the rwsem starves writers it wasn't strictly a bug but lockdep
> > doesn't like it and this avoids depending on lowlevel implementation
> > details of the lock.
> > 
> > ...
> >
> > @@ -229,13 +246,33 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
> >  
> >  		if (!zeropage)
> >  			err = mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
> > -					       dst_addr, src_addr);
> > +					       dst_addr, src_addr, &page);
> >  		else
> >  			err = mfill_zeropage_pte(dst_mm, dst_pmd, dst_vma,
> >  						 dst_addr);
> >  
> >  		cond_resched();
> >  
> > +		if (unlikely(err == -EFAULT)) {
> > +			void *page_kaddr;
> > +
> > +			BUILD_BUG_ON(zeropage);
> 
> I'm not sure what this is trying to do.  BUILD_BUG_ON(local_variable)?
> 
> It goes bang in my build.  I'll just delete it.

Yes, it has to be a false positive failure, so it's fine to drop
it. My gcc 4.8.4 can go inside the static called function and see that
only mcopy_atomic_pte can return -EFAULT. RHEL7 (4.8.3) gcc didn't
complain either. Perhaps to make the BUILD_BUG_ON work with older gcc,
it requrires a local variable set explicitly in the callee, but it's
not worth it.

It would be bad if we end up in the -EFAULT path in the zeropage case
(if somebody later adds an apparently innocent -EFAULT retval and
unexpectedly ends up in the mcopy_atomic_pte retry logic), but it's
not important, the caller should be reviewed before improvising new
retvals anyway.

The retry loop addition and the BUILD_BUG_ON is all about the
copy_from_user run while we already hold the mmap_sem (potentially of
a different process in the non-cooperative case but it's a problem if
it's the current task mmap_sem in case the rwlock implementation
changes to avoid write starvation and becomes non-reentrant). lockdep
definitely complains (even if I think in practice it'd be safe to
read-lock recurse, we just got lockdep complains never deadlocks in
fact). I didn't want to call gup_fast as copy_from_user is faster and
I got an usable user mapping with likely TLB entry hot too. The
lockdep warnings we hit I think were associated with NUMA hinting
faults or something infrequent like that, the fast path doesn't need
to retry.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
