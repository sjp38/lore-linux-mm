Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id A6FA56B0005
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 06:59:54 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id 128so59174675wmz.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 03:59:54 -0800 (PST)
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com. [195.75.94.105])
        by mx.google.com with ESMTPS id pi3si18762438wjb.134.2016.02.12.03.59.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 12 Feb 2016 03:59:53 -0800 (PST)
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Fri, 12 Feb 2016 11:59:52 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 46ADB1B08075
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 12:00:04 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1CBxnKA14549000
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 11:59:49 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1CBxluc028965
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 04:59:49 -0700
Date: Fri, 12 Feb 2016 12:59:43 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe
 also on PowerPC and ARM)
Message-ID: <20160212125943.1eb2ca9d@thinkpad>
In-Reply-To: <87a8n6shf2.fsf@linux.vnet.ibm.com>
References: <20160211192223.4b517057@thinkpad>
	<20160211190942.GA10244@node.shutemov.name>
	<20160211205702.24f0d17a@thinkpad>
	<87a8n6shf2.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Fri, 12 Feb 2016 09:34:33 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Gerald Schaefer <gerald.schaefer@de.ibm.com> writes:
> 
> > On Thu, 11 Feb 2016 21:09:42 +0200
> > "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> >
> >> On Thu, Feb 11, 2016 at 07:22:23PM +0100, Gerald Schaefer wrote:
> >> > Hi,
> >> > 
> >> > Sebastian Ott reported random kernel crashes beginning with v4.5-rc1 and
> >> > he also bisected this to commit 61f5d698 "mm: re-enable THP". Further
> >> > review of the THP rework patches, which cannot be bisected, revealed
> >> > commit fecffad "s390, thp: remove infrastructure for handling splitting PMDs"
> >> > (and also similar commits for other archs).
> >> > 
> >> > This commit removes the THP splitting bit and also the architecture
> >> > implementation of pmdp_splitting_flush(), which took care of the IPI for
> >> > fast_gup serialization. The commit message says
> >> > 
> >> >     pmdp_splitting_flush() is not needed too: on splitting PMD we will do
> >> >     pmdp_clear_flush() + set_pte_at().  pmdp_clear_flush() will do IPI as
> >> >     needed for fast_gup
> >> > 
> >> > The assumption that a TLB flush will also produce an IPI is wrong on s390,
> >> > and maybe also on other architectures, and I thought that this was actually
> >> > the main reason for having an arch-specific pmdp_splitting_flush().
> >> > 
> >> > At least PowerPC and ARM also had an individual implementation of
> >> > pmdp_splitting_flush() that used kick_all_cpus_sync() instead of a TLB
> >> > flush to send the IPI, and those were also removed. Putting the arch
> >> > maintainers and mailing lists on cc to verify.
> >> > 
> >> > On s390 this will break the IPI serialization against fast_gup, which
> >> > would certainly explain the random kernel crashes, please revert or fix
> >> > the pmdp_splitting_flush() removal.
> >> 
> >> Sorry for that.
> >> 
> >> I believe, the problem was already addressed for PowerPC:
> >> 
> >> http://lkml.kernel.org/g/454980831-16631-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com
> >> 
> >> I think kick_all_cpus_sync() in arch-specific pmdp_invalidate() would do
> >> the trick, right?
> >
> > Hmm, not sure about that. After pmdp_invalidate(), a pmd_none() check in
> > fast_gup will still return false, because the pmd is not empty (at least
> > on s390).
> 
> Why can't we do this ? I did this for ppc64.
> 
>  void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
>  		     pmd_t *pmdp)
>  {
> -	pmd_hugepage_update(vma->vm_mm, address, pmdp, _PAGE_PRESENT, 0);
> +	pmd_hugepage_update(vma->vm_mm, address, pmdp, ~0UL, 0);
> 

Wouldn't that semantically change what pmdp_invalidate() was supposed to
do? The comment before the call says "the pmd_trans_huge and
pmd_trans_splitting must remain set at all times on the pmd". So, after
removing pmd_trans_splitting, it seems to be necessary to at least keep
pmd_trans_huge set.

In your case, the pmd would be completely cleared, which may help to find
it in fast_gup with pmd_none(), but I'm not sure if this would open up
other problems, e.g. with concurrent page faults. But I must also admit that
my THP overview got a little rusty.

> >So I don't see spontaneously how it will help fast_gup to break
> > out to the slow path in case of THP splitting.
> >
> >> 
> >> If yes, I'll prepare patch tomorrow (some sleep required).
> >> 
> >
> > We'll check if adding kick_all_cpus_sync() to pmdp_invalidate() helps.
> > It would also be good if Martin has a look at this, he'll return on
> > Monday.
> 
> -aneesh
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
