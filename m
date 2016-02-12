Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1EAD96B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 12:16:52 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id p63so30196974wmp.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 09:16:52 -0800 (PST)
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com. [195.75.94.102])
        by mx.google.com with ESMTPS id ll4si20459753wjb.130.2016.02.12.09.16.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 12 Feb 2016 09:16:50 -0800 (PST)
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Fri, 12 Feb 2016 17:16:48 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2222B17D8068
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 17:17:02 +0000 (GMT)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1CHGkrx57999486
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 17:16:46 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1CHGhdo004304
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 10:16:45 -0700
Date: Fri, 12 Feb 2016 18:16:40 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe
 also on PowerPC and ARM)
Message-ID: <20160212181640.4eabb85f@thinkpad>
In-Reply-To: <56BE00E7.1010303@de.ibm.com>
References: <20160211192223.4b517057@thinkpad>
	<20160211190942.GA10244@node.shutemov.name>
	<20160211205702.24f0d17a@thinkpad>
	<20160212154116.GA15142@node.shutemov.name>
	<56BE00E7.1010303@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Fri, 12 Feb 2016 16:57:27 +0100
Christian Borntraeger <borntraeger@de.ibm.com> wrote:

> On 02/12/2016 04:41 PM, Kirill A. Shutemov wrote:
> > On Thu, Feb 11, 2016 at 08:57:02PM +0100, Gerald Schaefer wrote:
> >> On Thu, 11 Feb 2016 21:09:42 +0200
> >> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> >>
> >>> On Thu, Feb 11, 2016 at 07:22:23PM +0100, Gerald Schaefer wrote:
> >>>> Hi,
> >>>>
> >>>> Sebastian Ott reported random kernel crashes beginning with v4.5-rc1 and
> >>>> he also bisected this to commit 61f5d698 "mm: re-enable THP". Further
> >>>> review of the THP rework patches, which cannot be bisected, revealed
> >>>> commit fecffad "s390, thp: remove infrastructure for handling splitting PMDs"
> >>>> (and also similar commits for other archs).
> >>>>
> >>>> This commit removes the THP splitting bit and also the architecture
> >>>> implementation of pmdp_splitting_flush(), which took care of the IPI for
> >>>> fast_gup serialization. The commit message says
> >>>>
> >>>>     pmdp_splitting_flush() is not needed too: on splitting PMD we will do
> >>>>     pmdp_clear_flush() + set_pte_at().  pmdp_clear_flush() will do IPI as
> >>>>     needed for fast_gup
> >>>>
> >>>> The assumption that a TLB flush will also produce an IPI is wrong on s390,
> >>>> and maybe also on other architectures, and I thought that this was actually
> >>>> the main reason for having an arch-specific pmdp_splitting_flush().
> >>>>
> >>>> At least PowerPC and ARM also had an individual implementation of
> >>>> pmdp_splitting_flush() that used kick_all_cpus_sync() instead of a TLB
> >>>> flush to send the IPI, and those were also removed. Putting the arch
> >>>> maintainers and mailing lists on cc to verify.
> >>>>
> >>>> On s390 this will break the IPI serialization against fast_gup, which
> >>>> would certainly explain the random kernel crashes, please revert or fix
> >>>> the pmdp_splitting_flush() removal.
> >>>
> >>> Sorry for that.
> >>>
> >>> I believe, the problem was already addressed for PowerPC:
> >>>
> >>> http://lkml.kernel.org/g/454980831-16631-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com
> >>>
> >>> I think kick_all_cpus_sync() in arch-specific pmdp_invalidate() would do
> >>> the trick, right?
> >>
> >> Hmm, not sure about that. After pmdp_invalidate(), a pmd_none() check in
> >> fast_gup will still return false, because the pmd is not empty (at least
> >> on s390). So I don't see spontaneously how it will help fast_gup to break
> >> out to the slow path in case of THP splitting.
> > 
> > What pmdp_flush_direct() does in pmdp_invalidate()? It's hard to unwrap for me :-/
> > Does it make the pmd !pmd_present()?
> 
> It uses the idte instruction, which in an atomic fashion flushes the associated
> TLB entry and changes the value of the pmd entry to invalid. This comes from the
> HW requirement to not  change a PTE/PMD that might be still in use, other than 
> with special instructions that does the tlb handling and the invalidation together.

Correct, and it does _not_ make the pmd !pmd_present(), that would only be the
case after a _clear_flush(). It only marks the pmd as invalid and flushes,
so that it cannot generate a new TLB entry before the following pmd_populate(),
but it keeps its other content. This is to fulfill the requirements outlined in
the comment in mm/huge_memory.c before the call to pmdp_invalidate(). And
independent from that comment, we would need such an _invalidate() or
_clear_flush() on s390 before the pmd_populate() because of the HW details
that Christian described.

Reading the comment again, I do now notice that it also says "mark the current
pmd notpresent", which we cannot do w/o losing the huge and (formerly) splitting
bits, but it also shouldn't be needed to provide the "single TLB guarantee" that
is required from the comment. So, a pmd_present() check on s390 in this state
would still return true. Not sure yet if this is a problem, need more thinking,
this behavior was already present before the THP rework but maybe it was OK
before and is not OK now.

At least for fast_gup this should not be a problem though.

> (It also does some some other magic to the attach_count, which might hold off
> finish_arch_post_lock_switch while some flushing is happening, but this should
> be unrelated here)
> 
> 
> > I'm also confused by pmd_none() is equal to !pmd_present() on s390. Hm?
> 
> Don't know, Gerald or Martin?

The implementation frequently changes depending on how many new bits Martin
needs to squeeze out :-)
We don't have a _PAGE_PRESENT bit for pmds, so pmd_present() just checks if the
entry is not empty. pmd_none() of course does the opposite, it checks if it is
empty.

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-s390" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
