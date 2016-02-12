Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id A6C1A6B0255
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 18:15:14 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id p63so38385923wmp.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 15:15:14 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id bm5si22471373wjb.92.2016.02.12.15.15.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Feb 2016 15:15:13 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id c200so40951336wme.0
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 15:15:13 -0800 (PST)
Date: Sat, 13 Feb 2016 01:15:10 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
Message-ID: <20160212231510.GB15142@node.shutemov.name>
References: <20160211192223.4b517057@thinkpad>
 <20160211190942.GA10244@node.shutemov.name>
 <20160211205702.24f0d17a@thinkpad>
 <20160212154116.GA15142@node.shutemov.name>
 <56BE00E7.1010303@de.ibm.com>
 <20160212181640.4eabb85f@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160212181640.4eabb85f@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Fri, Feb 12, 2016 at 06:16:40PM +0100, Gerald Schaefer wrote:
> On Fri, 12 Feb 2016 16:57:27 +0100
> Christian Borntraeger <borntraeger@de.ibm.com> wrote:
> 
> > On 02/12/2016 04:41 PM, Kirill A. Shutemov wrote:
> > > On Thu, Feb 11, 2016 at 08:57:02PM +0100, Gerald Schaefer wrote:
> > >> On Thu, 11 Feb 2016 21:09:42 +0200
> > >> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> > >>
> > >>> On Thu, Feb 11, 2016 at 07:22:23PM +0100, Gerald Schaefer wrote:
> > >>>> Hi,
> > >>>>
> > >>>> Sebastian Ott reported random kernel crashes beginning with v4.5-rc1 and
> > >>>> he also bisected this to commit 61f5d698 "mm: re-enable THP". Further
> > >>>> review of the THP rework patches, which cannot be bisected, revealed
> > >>>> commit fecffad "s390, thp: remove infrastructure for handling splitting PMDs"
> > >>>> (and also similar commits for other archs).
> > >>>>
> > >>>> This commit removes the THP splitting bit and also the architecture
> > >>>> implementation of pmdp_splitting_flush(), which took care of the IPI for
> > >>>> fast_gup serialization. The commit message says
> > >>>>
> > >>>>     pmdp_splitting_flush() is not needed too: on splitting PMD we will do
> > >>>>     pmdp_clear_flush() + set_pte_at().  pmdp_clear_flush() will do IPI as
> > >>>>     needed for fast_gup
> > >>>>
> > >>>> The assumption that a TLB flush will also produce an IPI is wrong on s390,
> > >>>> and maybe also on other architectures, and I thought that this was actually
> > >>>> the main reason for having an arch-specific pmdp_splitting_flush().
> > >>>>
> > >>>> At least PowerPC and ARM also had an individual implementation of
> > >>>> pmdp_splitting_flush() that used kick_all_cpus_sync() instead of a TLB
> > >>>> flush to send the IPI, and those were also removed. Putting the arch
> > >>>> maintainers and mailing lists on cc to verify.
> > >>>>
> > >>>> On s390 this will break the IPI serialization against fast_gup, which
> > >>>> would certainly explain the random kernel crashes, please revert or fix
> > >>>> the pmdp_splitting_flush() removal.
> > >>>
> > >>> Sorry for that.
> > >>>
> > >>> I believe, the problem was already addressed for PowerPC:
> > >>>
> > >>> http://lkml.kernel.org/g/454980831-16631-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com
> > >>>
> > >>> I think kick_all_cpus_sync() in arch-specific pmdp_invalidate() would do
> > >>> the trick, right?
> > >>
> > >> Hmm, not sure about that. After pmdp_invalidate(), a pmd_none() check in
> > >> fast_gup will still return false, because the pmd is not empty (at least
> > >> on s390). So I don't see spontaneously how it will help fast_gup to break
> > >> out to the slow path in case of THP splitting.
> > > 
> > > What pmdp_flush_direct() does in pmdp_invalidate()? It's hard to unwrap for me :-/
> > > Does it make the pmd !pmd_present()?
> > 
> > It uses the idte instruction, which in an atomic fashion flushes the associated
> > TLB entry and changes the value of the pmd entry to invalid. This comes from the
> > HW requirement to not  change a PTE/PMD that might be still in use, other than 
> > with special instructions that does the tlb handling and the invalidation together.
> 
> Correct, and it does _not_ make the pmd !pmd_present(), that would only be the
> case after a _clear_flush(). It only marks the pmd as invalid and flushes,
> so that it cannot generate a new TLB entry before the following pmd_populate(),
> but it keeps its other content. This is to fulfill the requirements outlined in
> the comment in mm/huge_memory.c before the call to pmdp_invalidate(). And
> independent from that comment, we would need such an _invalidate() or
> _clear_flush() on s390 before the pmd_populate() because of the HW details
> that Christian described.
> 
> Reading the comment again, I do now notice that it also says "mark the current
> pmd notpresent", which we cannot do w/o losing the huge and (formerly) splitting
> bits, but it also shouldn't be needed to provide the "single TLB guarantee" that
> is required from the comment. So, a pmd_present() check on s390 in this state
> would still return true. Not sure yet if this is a problem, need more thinking,
> this behavior was already present before the THP rework but maybe it was OK
> before and is not OK now.
> 
> At least for fast_gup this should not be a problem though.

I'm trying to wrap my head around the issue and I don't think missing
serialization with gup_fast is the cause -- we just don't need it
anymore.

Previously, __split_huge_page_splitting() required serialization against
gup_fast to make sure nobody can obtain new reference to the page after
__split_huge_page_splitting() returns. This was a way to stabilize page
references before starting to distribute them from head page to tail
pages.

With new refcounting, we don't care about this. Splitting PMD is now
decoupled from splitting underlying compound page. It's okay to get new
pins after split_huge_pmd(). To stabilize page references during
split_huge_page() we rely on setting up migration entries once all
pmds are split into page table entries.

The theory that serialization against gup_fast is not a root cause of the
crashes is consistent no crashes on arm64. Problem is somewhere else.
 
> > (It also does some some other magic to the attach_count, which might hold off
> > finish_arch_post_lock_switch while some flushing is happening, but this should
> > be unrelated here)
> > 
> > 
> > > I'm also confused by pmd_none() is equal to !pmd_present() on s390. Hm?
> > 
> > Don't know, Gerald or Martin?
> 
> The implementation frequently changes depending on how many new bits Martin
> needs to squeeze out :-)

One bit was freed up by the commit you've pointed to as a cause.
I wounder If it's possible that screw up something while removing it? I
don't see it, but who knows.

Could you check if revert of fecffad25458 helps?

And could you share how crashes looks like? I haven't seen backtraces yet.

> We don't have a _PAGE_PRESENT bit for pmds, so pmd_present() just checks if the
> entry is not empty. pmd_none() of course does the opposite, it checks if it is
> empty.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
