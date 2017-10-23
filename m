Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id DB8976B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 16:35:09 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id s185so19464547oif.16
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 13:35:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y13si2488391otg.321.2017.10.23.13.35.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 13:35:07 -0700 (PDT)
Date: Mon, 23 Oct 2017 16:35:01 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm/mmu_notifier: avoid double notification when it
 is useless v2
Message-ID: <20171023203501.GA9371@redhat.com>
References: <20171017031003.7481-1-jglisse@redhat.com>
 <20171017031003.7481-2-jglisse@redhat.com>
 <20171019140426.21f51957@MiWiFi-R3-srv>
 <20171019032811.GC5246@redhat.com>
 <CAKTCnz=5GL_Bbu=kqywgW98uxpvYqCo2+KyzzGb67BmnKju3bw@mail.gmail.com>
 <20171019165823.GA3044@redhat.com>
 <1508565280.5662.6.camel@gmail.com>
 <20171021154703.GA30458@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171021154703.GA30458@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>, David Woodhouse <dwmw2@infradead.org>, Alistair Popple <alistair@popple.id.au>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Donnellan <andrew.donnellan@au1.ibm.com>, iommu@lists.linux-foundation.org, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-next <linux-next@vger.kernel.org>

On Sat, Oct 21, 2017 at 11:47:03AM -0400, Jerome Glisse wrote:
> On Sat, Oct 21, 2017 at 04:54:40PM +1100, Balbir Singh wrote:
> > On Thu, 2017-10-19 at 12:58 -0400, Jerome Glisse wrote:
> > > On Thu, Oct 19, 2017 at 09:53:11PM +1100, Balbir Singh wrote:
> > > > On Thu, Oct 19, 2017 at 2:28 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> > > > > On Thu, Oct 19, 2017 at 02:04:26PM +1100, Balbir Singh wrote:
> > > > > > On Mon, 16 Oct 2017 23:10:02 -0400
> > > > > > jglisse@redhat.com wrote:
> > > > > > > From: Jerome Glisse <jglisse@redhat.com>

[...]

> > > > > > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > > > > > index c037d3d34950..ff5bc647b51d 100644
> > > > > > > --- a/mm/huge_memory.c
> > > > > > > +++ b/mm/huge_memory.c
> > > > > > > @@ -1186,8 +1186,15 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
> > > > > > >             goto out_free_pages;
> > > > > > >     VM_BUG_ON_PAGE(!PageHead(page), page);
> > > > > > > 
> > > > > > > +   /*
> > > > > > > +    * Leave pmd empty until pte is filled note we must notify here as
> > > > > > > +    * concurrent CPU thread might write to new page before the call to
> > > > > > > +    * mmu_notifier_invalidate_range_end() happens which can lead to a
> > > > > > > +    * device seeing memory write in different order than CPU.
> > > > > > > +    *
> > > > > > > +    * See Documentation/vm/mmu_notifier.txt
> > > > > > > +    */
> > > > > > >     pmdp_huge_clear_flush_notify(vma, haddr, vmf->pmd);
> > > > > > > -   /* leave pmd empty until pte is filled */
> > > > > > > 
> > > > > > >     pgtable = pgtable_trans_huge_withdraw(vma->vm_mm, vmf->pmd);
> > > > > > >     pmd_populate(vma->vm_mm, &_pmd, pgtable);
> > > > > > > @@ -2026,8 +2033,15 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
> > > > > > >     pmd_t _pmd;
> > > > > > >     int i;
> > > > > > > 
> > > > > > > -   /* leave pmd empty until pte is filled */
> > > > > > > -   pmdp_huge_clear_flush_notify(vma, haddr, pmd);
> > > > > > > +   /*
> > > > > > > +    * Leave pmd empty until pte is filled note that it is fine to delay
> > > > > > > +    * notification until mmu_notifier_invalidate_range_end() as we are
> > > > > > > +    * replacing a zero pmd write protected page with a zero pte write
> > > > > > > +    * protected page.
> > > > > > > +    *
> > > > > > > +    * See Documentation/vm/mmu_notifier.txt
> > > > > > > +    */
> > > > > > > +   pmdp_huge_clear_flush(vma, haddr, pmd);
> > > > > > 
> > > > > > Shouldn't the secondary TLB know if the page size changed?
> > > > > 
> > > > > It should not matter, we are talking virtual to physical on behalf
> > > > > of a device against a process address space. So the hardware should
> > > > > not care about the page size.
> > > > > 
> > > > 
> > > > Does that not indicate how much the device can access? Could it try
> > > > to access more than what is mapped?
> > > 
> > > Assuming device has huge TLB and 2MB huge page with 4K small page.
> > > You are going from one 1 TLB covering a 2MB zero page to 512 TLB
> > > each covering 4K. Both case is read only and both case are pointing
> > > to same data (ie zero).
> > > 
> > > It is fine to delay the TLB invalidate on the device to the call of
> > > mmu_notifier_invalidate_range_end(). The device will keep using the
> > > huge TLB for a little longer but both CPU and device are looking at
> > > same data.
> > > 
> > > Now if there is a racing thread that replace one of the 512 zeor page
> > > after the split but before mmu_notifier_invalidate_range_end() that
> > > code path would call mmu_notifier_invalidate_range() before changing
> > > the pte to point to something else. Which should shoot down the device
> > > TLB (it would be a serious device bug if this did not work).
> > 
> > OK.. This seems reasonable, but I'd really like to see if it can be
> > tested
> 
> Well hard to test, many factors first each device might react differently.
> Device that only store TLB at 4k granularity are fine. Clever device that
> can store TLB for 4k, 2M, ... can ignore an invalidation that is smaller
> than their TLB entry ie getting a 4K invalidation would not invalidate a
> 2MB TLB entry in the device. I consider this as buggy. I will go look at
> the PCIE ATS specification one more time and see if there is any wording
> related that. I might bring up a question to the PCIE standard body if not.

So inside PCIE ATS there is the definition of "minimum translation or
invalidate size" which says 4096 bytes. So my understanding is that
hardware must support 4K invalidation in all the case and thus we shoud
be safe from possible hazard above.

But none the less i will repost without the optimization for huge page
to be more concervative as anyway we want to be correct before we care
about last bit of optimization.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
