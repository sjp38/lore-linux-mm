Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 212436B02B4
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 04:48:55 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id i1so1906915lfh.1
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 01:48:55 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id a14si546835ljb.99.2017.06.15.01.48.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 01:48:53 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id v20so722051lfa.2
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 01:48:53 -0700 (PDT)
Date: Thu, 15 Jun 2017 11:48:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [HELP-NEEDED, PATCH 0/3] Do not loose dirty bit on THP pages
Message-ID: <20170615084851.if6sntxo5tswhlk5@node.shutemov.name>
References: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
 <eed279c6-bf61-f2f3-c9f2-d9a94568e2e3@linux.vnet.ibm.com>
 <20170614165513.GD17632@arm.com>
 <548e33cb-e737-bb39-91a3-f66ee9211262@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <548e33cb-e737-bb39-91a3-f66ee9211262@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Will Deacon <will.deacon@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com

On Thu, Jun 15, 2017 at 06:35:21AM +0530, Aneesh Kumar K.V wrote:
> 
> 
> On Wednesday 14 June 2017 10:25 PM, Will Deacon wrote:
> > Hi Aneesh,
> > 
> > On Wed, Jun 14, 2017 at 08:55:26PM +0530, Aneesh Kumar K.V wrote:
> > > On Wednesday 14 June 2017 07:21 PM, Kirill A. Shutemov wrote:
> > > > Vlastimil noted that pmdp_invalidate() is not atomic and we can loose
> > > > dirty and access bits if CPU sets them after pmdp dereference, but
> > > > before set_pmd_at().
> > > > 
> > > > The bug doesn't lead to user-visible misbehaviour in current kernel, but
> > > > fixing this would be critical for future work on THP: both huge-ext4 and THP
> > > > swap out rely on proper dirty tracking.
> > > > 
> > > > Unfortunately, there's no way to address the issue in a generic way. We need to
> > > > fix all architectures that support THP one-by-one.
> > > > 
> > > > All architectures that have THP supported have to provide atomic
> > > > pmdp_invalidate(). If generic implementation of pmdp_invalidate() is used,
> > > > architecture needs to provide atomic pmdp_mknonpresent().
> > > > 
> > > > I've fixed the issue for x86, but I need help with the rest.
> > > > 
> > > > So far THP is supported on 8 architectures. Power and S390 already provides
> > > > atomic pmdp_invalidate(). x86 is fixed by this patches, so 5 architectures
> > > > left:
> > > > 
> > > >   - arc;
> > > >   - arm;
> > > >   - arm64;
> > > >   - mips;
> > > >   - sparc -- it has custom pmdp_invalidate(), but it's racy too;
> > > > 
> > > > Please, help me with them.
> > > > 
> > > > Kirill A. Shutemov (3):
> > > >    x86/mm: Provide pmdp_mknotpresent() helper
> > > >    mm: Do not loose dirty and access bits in pmdp_invalidate()
> > > >    mm, thp: Do not loose dirty bit in __split_huge_pmd_locked()
> > > > 
> > > 
> > > 
> > > But in __split_huge_pmd_locked() we collected the dirty bit early. So even
> > > if we made pmdp_invalidate() atomic, if we had marked the pmd pte entry
> > > dirty after we collected the dirty bit, we still loose it right ?
> > > 
> > > 
> > > May be we should relook at pmd PTE udpate interface. We really need an
> > > interface that can update pmd entries such that we don't clear it in
> > > between. IMHO, we can avoid the pmdp_invalidate() completely, if we can
> > > switch from a pmd PTE entry to a pointer to PTE page (pgtable_t). We also
> > > need this interface to avoid the madvise race fixed by
> > 
> > There's a good chance I'm not following your suggestion here, but it's
> > probably worth me pointing out that swizzling a page table entry from a
> > block mapping (e.g. a huge page mapped at the PMD level) to a table entry
> > (e.g. a pointer to a page of PTEs) can lead to all sorts of horrible
> > problems on ARM, including amalgamation of TLB entries and fatal aborts.
> > 
> > So we really need to go via an invalid entry, with appropriate TLB
> > invalidation before installing the new entry.
> > 
> 
> I am not suggesting we don't do the invalidate (the need for that is
> documented in __split_huge_pmd_locked(). I am suggesting we need a new
> interface, something like Andrea suggested.
> 
> old_pmd = pmdp_establish(pmd_mknotpresent());
> 
> instead of pmdp_invalidate(). We can then use this in scenarios where we
> want to update pmd PTE entries, where right now we go through a pmdp_clear
> and set_pmd path. We should really not do that for THP entries.

Which cases are you talking about? When do we need to clear pmd and set
later?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
