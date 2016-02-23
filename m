Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 43EEA6B0253
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:19:15 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id g62so212949871wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:19:15 -0800 (PST)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id 17si41254979wjv.159.2016.02.23.10.19.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 23 Feb 2016 10:19:14 -0800 (PST)
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Tue, 23 Feb 2016 18:19:13 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 0DE7317D8056
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 18:19:32 +0000 (GMT)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1NIJAtV6750536
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 18:19:10 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1NIJ9dd006031
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 11:19:10 -0700
Date: Tue, 23 Feb 2016 19:19:07 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe
 also on PowerPC and ARM)
Message-ID: <20160223191907.25719a4d@thinkpad>
In-Reply-To: <20160223103221.GA1418@node.shutemov.name>
References: <20160211192223.4b517057@thinkpad>
	<20160211190942.GA10244@node.shutemov.name>
	<20160211205702.24f0d17a@thinkpad>
	<20160212154116.GA15142@node.shutemov.name>
	<56BE00E7.1010303@de.ibm.com>
	<20160212181640.4eabb85f@thinkpad>
	<20160223103221.GA1418@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Tue, 23 Feb 2016 13:32:21 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Fri, Feb 12, 2016 at 06:16:40PM +0100, Gerald Schaefer wrote:
> > On Fri, 12 Feb 2016 16:57:27 +0100
> > Christian Borntraeger <borntraeger@de.ibm.com> wrote:
> > 
> > > > I'm also confused by pmd_none() is equal to !pmd_present() on s390. Hm?
> > > 
> > > Don't know, Gerald or Martin?
> > 
> > The implementation frequently changes depending on how many new bits Martin
> > needs to squeeze out :-)
> > We don't have a _PAGE_PRESENT bit for pmds, so pmd_present() just checks if the
> > entry is not empty. pmd_none() of course does the opposite, it checks if it is
> > empty.
> 
> I still worry about pmd_present(). It looks wrong to me. I wounder if
> patch below makes a difference.
> 
> The theory is that the splitting bit effetely masked bogus pmd_present():
> we had pmd_trans_splitting() in all code path and that prevented mm from
> touching the pmd. Once pmd_trans_splitting() has gone, mm proceed with the
> pmd where it shouldn't and here's a boom.

Well, I don't think pmd_present() == true is bogus for a trans_huge pmd under
splitting, after all there is a page behind the the pmd. Also, if it was
bogus, and it would need to be false, why should it be marked !pmd_present()
only at the pmdp_invalidate() step before the pmd_populate()? It clearly
is pmd_present() before that, on all architectures, and if there was any
problem/race with that, setting it to !pmd_present() at this stage would
only (marginally) reduce the race window.

BTW, PowerPC and Sparc seem to do the same thing in pmdp_invalidate(),
i.e. they do not set pmd_present() == false, only mark it so that it would
not generate a new TLB entry, just like on s390. After all, the function
is called pmdp_invalidate(), and I think the comment in mm/huge_memory.c
before that call is just a little ambiguous in its wording. When it says
"mark the pmd notpresent" it probably means "mark it so that it will not
generate a new TLB entry", which is also what the comment is really about:
prevent huge and small entries in the TLB for the same page at the same
time.

FWIW, and since the ARM arch-list is already on cc, I think there is
an issue with pmdp_invalidate() on ARM, since it also seems to clear
the trans_huge (and formerly trans_splitting) bit, which actually makes
the pmd !pmd_present(), but it violates the other requirement from the
comment:
"the pmd_trans_huge and pmd_trans_splitting must remain set at all times
on the pmd until the split is complete for this pmd"

> 
> I'm not sure that the patch is correct wrt yound/old pmds and I have no
> way to test it...
> 
> diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
> index 64ead8091248..2eeb17ab68ac 100644
> --- a/arch/s390/include/asm/pgtable.h
> +++ b/arch/s390/include/asm/pgtable.h
> @@ -490,7 +490,7 @@ static inline int pud_bad(pud_t pud)
> 
>  static inline int pmd_present(pmd_t pmd)
>  {
> -	return pmd_val(pmd) != _SEGMENT_ENTRY_INVALID;
> +	return !(pmd_val(pmd) & _SEGMENT_ENTRY_INVALID);
>  }
> 
>  static inline int pmd_none(pmd_t pmd)

No, that would not work well with young rw and ro pmds. We do now
have an extra free bit in the pmd on s390, after the removal of the
splitting bit, so we could try to implement pmd_present() with that
sw bit, but that would also require several not-so-trivial changes
to the other code in arch/s390/include/asm/pgtable.h.

I'll check with Martin, maybe it is actually trivial, then we can
do a quick test it to rule that one out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
