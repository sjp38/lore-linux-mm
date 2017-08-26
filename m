Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4B32E6810D7
	for <linux-mm@kvack.org>; Sat, 26 Aug 2017 17:09:11 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 4so5470497oie.8
        for <linux-mm@kvack.org>; Sat, 26 Aug 2017 14:09:11 -0700 (PDT)
Received: from mail-io0-x234.google.com (mail-io0-x234.google.com. [2607:f8b0:4001:c06::234])
        by mx.google.com with ESMTPS id d142si8073019oib.184.2017.08.26.14.09.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Aug 2017 14:09:10 -0700 (PDT)
Received: by mail-io0-x234.google.com with SMTP id k22so6659145iod.2
        for <linux-mm@kvack.org>; Sat, 26 Aug 2017 14:09:09 -0700 (PDT)
Date: Sat, 26 Aug 2017 16:09:05 -0500
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: + mm-madvise-fix-freeing-of-locked-page-with-madv_free.patch
 added to -mm tree
Message-ID: <20170826210905.GA21712@zzz.localdomain>
References: <599df681.NreP1dR3/HGSfpCe%akpm@linux-foundation.org>
 <20170824060957.GA29811@dhcp22.suse.cz>
 <81C11D6F-653D-4B14-A3A6-E6BB6FB5436D@vmware.com>
 <3452db57-d847-ec8e-c9be-7710f4ddd5d4@oracle.com>
 <10E0D3D9-F7D4-4A0F-AD2F-9E40F3DE6CCC@vmware.com>
 <c51c78c4-8bac-c5e2-c740-3fc92d602436@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c51c78c4-8bac-c5e2-c740-3fc92d602436@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Nadav Amit <namit@vmware.com>, "ebiggers@google.com" <ebiggers@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, "nyc@holomorphy.com" <nyc@holomorphy.com>

On Fri, Aug 25, 2017 at 04:41:36PM -0700, Mike Kravetz wrote:
> >>>>>
> >>>>> If madvise(..., MADV_FREE) split a transparent hugepage, it called
> >>>>> put_page() before unlock_page().  This was wrong because put_page() can
> >>>>> free the page, e.g.  if a concurrent madvise(..., MADV_DONTNEED) has
> >>>>> removed it from the memory mapping.  put_page() then rightfully complained
> >>>>> about freeing a locked page.
> >>>>>
> >>>>> Fix this by moving the unlock_page() before put_page().
> >>>
> >>> Quick grep shows that a similar flow (put_page() followed by an
> >>> unlock_page() ) also happens in hugetlbfs_fallocate(). Isna??t it a problem as
> >>> well?
> >>
> >> I assume you are asking about this block of code?
> > 
> > Yes.
> > 
> >>
> >>                /*
> >>                 * page_put due to reference from alloc_huge_page()
> >>                 * unlock_page because locked by add_to_page_cache()
> >>                 */
> >>                put_page(page);
> >>                unlock_page(page);
> >>
> >> Well, there is a typo (page_put) in the comment. :(
> >>
> >> However, in this case we have just added the huge page to a hugetlbfs
> >> file.  The put_page() is there just to drop the reference count on the
> >> page (taken when allocated).  It will still be non-zero as we have
> >> successfully added it to the page cache.  So, we are not freeing the
> >> page here, just dropping the reference count.
> >>
> >> This should not cause a problem like that seen in madvise.
> > 
> > Thanks for the quick response.
> > 
> > I am not too familiar with this piece of code, so just for the matter of
> > understanding: what prevents the page from being removed from the page cache
> > shortly after it is added (even if it is highly unlikely)? The page lock? The
> > inode lock?
> 
> Someone would need to acquire the inode lock to remove the page.  This
> is held until we exit the routine.  Also note that put_page for this
> type of huge page almost always results in the page being put back
> on a free list within the hugetlb(fs) subsystem.  It is not returned
> to the 'normal' memory allocators for general use.
> 

I'm not sure about that.  What about sys_fadvise64(..., POSIX_FADV_DONTNEED)?
That removes pages from the page cache without taking the inode lock.  It won't
remove locked pages though, so presumably it is only the page lock that prevents
the race with hugetlbfs_fallocate().

But in any case, why not do the "obviously correct" thing --- unlock before put?

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
