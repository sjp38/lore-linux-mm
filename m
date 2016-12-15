Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12DAD6B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 14:02:48 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id t7so83836505yba.2
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 11:02:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k77si1247229vki.233.2016.12.15.11.02.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 11:02:47 -0800 (PST)
Date: Thu, 15 Dec 2016 20:02:42 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 15/33] userfaultfd: hugetlbfs: add __mcopy_atomic_hugetlb
 for huge page UFFDIO_COPY
Message-ID: <20161215190242.GC4909@redhat.com>
References: <20161104193626.GU4611@redhat.com>
 <1805f956-1777-471c-1401-46c984189c88@oracle.com>
 <20161116182809.GC26185@redhat.com>
 <8ee2c6db-7ee4-285f-4c68-75fd6e799c0d@oracle.com>
 <20161117154031.GA10229@redhat.com>
 <718434af-d279-445d-e210-201bf02f434f@oracle.com>
 <20161118000527.GB10229@redhat.com>
 <c9350efa-ca79-c514-0305-22c90fdbb0df@oracle.com>
 <1b60f0b3-835f-92d6-33e2-e7aaab3209cc@oracle.com>
 <019d01d24554$38e7f220$aab7d660$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <019d01d24554$38e7f220$aab7d660$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Mike Kravetz' <mike.kravetz@oracle.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

On Wed, Nov 23, 2016 at 02:38:37PM +0800, Hillf Danton wrote:
> On Tuesday, November 22, 2016 9:17 AM Mike Kravetz wrote:
> > I am not sure if you are convinced ClearPagePrivate is an acceptable
> > solution to this issue.  If you do, here is the simple patch to add
> > it and an appropriate comment.
> > 
> Hi Mike and Andrea
> 
> Sorry for my jumping in.
> 
> In commit 07443a85ad
> ("mm, hugetlb: return a reserved page to a reserved pool if failed")
> newly allocated huge page gets cleared for a successful COW.
> 
> I'm wondering if we can handle our error path along that way?
> 
> Obvious I could miss the points you are concerning.

The hugepage allocation toggles the region covering the page in the
vma reservations, so when the vma is virtually unmapped, those regions
that got toggled, are considered not reserved and the global
reservation is not decreased.

Because the global reservation is decreased by the same page
allocation that sets the page private flag after toggling the virtual
regions, the page private flag shall be cleared when the page is
finally mapped in userland, as it's not reserved anymore. This way
when the page is freed, the global reservation will not be increased
(and when the vma is unmapped the reservation will not be decreased
either, because of the region toggling above).

hugetlb_mcopy_atomic_pte is already correctly doing:

	ClearPagePrivate(page);
	hugepage_add_new_anon_rmap(page, dst_vma, dst_addr);

while mapping the hugepage in userland.

The issue is that if we can't reach hugetlb_mcopy_atomic_pte because
userland screws with the vmas while the UFFDIO_COPY releases the
mmap_sem, the point where we error out, has the vma out of sync
because we had to drop the mmap_sem in the first place. So we can't
toggle the vma virtual region covering the page back to its original
state (i.e. reserved). That's what restore_reserve_on_error would try
to achieve, but we can't run it as the vma we got in the error path is
stale.

All we know is that one more page will be considered not reserved when
the vma is unmapped, so the global reservation will be decreased of
one less page when the vma is unmapped. In turn when freeing such
hugepage in the error path, we've to prevent the global reserve to be
increased once again and to do so we've to clear the page private flag
before freeing the hugepage.

I already applied Mark's patch that clears the page private flag in
the error path. If anything is incorrect in the explanation above let
me know.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
