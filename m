Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1BBE6B042E
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 13:52:07 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v88so21626940wrb.1
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 10:52:07 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id k12si16281069wrc.386.2017.06.21.10.52.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 10:52:05 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id 77so28418341wrb.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 10:52:05 -0700 (PDT)
Date: Wed, 21 Jun 2017 20:52:03 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 1/3] x86/mm: Provide pmdp_establish() helper
Message-ID: <20170621175203.g2susfjihyqrf245@node.shutemov.name>
References: <20170619152228.GE3024@e104818-lin.cambridge.arm.com>
 <20170619160005.wgj4nymtj2nntfll@node.shutemov.name>
 <20170619170911.GF3024@e104818-lin.cambridge.arm.com>
 <20170619215210.2crwjou3sfdcj73d@node.shutemov.name>
 <20170620155438.GC21383@e104818-lin.cambridge.arm.com>
 <20170621095303.q5fqt5a3ao5smko6@node.shutemov.name>
 <20170621112702.GC10220@e104818-lin.cambridge.arm.com>
 <1af1738a-88a7-987c-eca7-2118d66514e1@synopsys.com>
 <20170621171558.7zrgzc7uk3kspcys@node.shutemov.name>
 <eeff42d2-fc4b-ea9c-81d2-145fb349f420@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <eeff42d2-fc4b-ea9c-81d2-145fb349f420@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Jun 21, 2017 at 10:20:47AM -0700, Vineet Gupta wrote:
> On 06/21/2017 10:16 AM, Kirill A. Shutemov wrote:
> > On Wed, Jun 21, 2017 at 08:49:03AM -0700, Vineet Gupta wrote:
> > > On 06/21/2017 04:27 AM, Catalin Marinas wrote:
> > > > On Wed, Jun 21, 2017 at 12:53:03PM +0300, Kirill A. Shutemov wrote:
> > > > > > > > > > On Thu, Jun 15, 2017 at 05:52:22PM +0300, Kirill A. Shutemov wrote:
> > > > > > > > > > > We need an atomic way to setup pmd page table entry, avoiding races with
> > > > > > > > > > > CPU setting dirty/accessed bits. This is required to implement
> > > > > > > > > > > pmdp_invalidate() that doesn't loose these bits.
> > > > [...]
> > > > > Any chance you could help me with arm too?
> > > > On arm (ARMv7 with LPAE) we don't have hardware updates of the
> > > > access/dirty bits, so a generic implementation would suffice. I didn't
> > > > find one in your patches, so here's an untested version:
> > > > 
> > > > static inline pmd_t pmdp_establish(struct mm_struct *mm, unsigned long address,
> > > > 				   pmd_t *pmdp, pmd_t pmd)
> > > > {
> > > > 	pmd_t old_pmd = *pmdp;
> > > > 	set_pmd_at(mm, address, pmdp, pmd);
> > > > 	return old_pmd;
> > > > }
> > > So it seems the discussions have settled down and pmdp_establish() can be
> > > implemented in generic way as above and it will suffice if arch doesn't have
> > > a special need. It would be nice to add the comment above generic version
> > > that it only needs to be implemented if hardware sets the accessed/dirty
> > > bits !
> > > 
> > > Then nothing special is needed for ARC - right ?
> > I will define generic version as Catalin proposed with a comment, but
> > under the name generic_pmdp_establish. An arch can make use of it by
> > 
> > #define pmdp_establish generic_pmdp_establish
> 
> Can you do that for ARC in your next posting - or want me to once you have
> posted that ?

I'll do this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
