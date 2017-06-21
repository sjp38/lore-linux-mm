Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7526D6B03CB
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 05:53:10 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b65so35851289lfh.8
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 02:53:10 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id l74si8729347lfl.317.2017.06.21.02.53.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 02:53:08 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id u62so19801298lfg.0
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 02:53:08 -0700 (PDT)
Date: Wed, 21 Jun 2017 12:53:03 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 1/3] x86/mm: Provide pmdp_establish() helper
Message-ID: <20170621095303.q5fqt5a3ao5smko6@node.shutemov.name>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
 <20170615145224.66200-2-kirill.shutemov@linux.intel.com>
 <20170619152228.GE3024@e104818-lin.cambridge.arm.com>
 <20170619160005.wgj4nymtj2nntfll@node.shutemov.name>
 <20170619170911.GF3024@e104818-lin.cambridge.arm.com>
 <20170619215210.2crwjou3sfdcj73d@node.shutemov.name>
 <20170620155438.GC21383@e104818-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170620155438.GC21383@e104818-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Jun 20, 2017 at 04:54:38PM +0100, Catalin Marinas wrote:
> On Tue, Jun 20, 2017 at 12:52:10AM +0300, Kirill A. Shutemov wrote:
> > On Mon, Jun 19, 2017 at 06:09:12PM +0100, Catalin Marinas wrote:
> > > On Mon, Jun 19, 2017 at 07:00:05PM +0300, Kirill A. Shutemov wrote:
> > > > On Mon, Jun 19, 2017 at 04:22:29PM +0100, Catalin Marinas wrote:
> > > > > On Thu, Jun 15, 2017 at 05:52:22PM +0300, Kirill A. Shutemov wrote:
> > > > > > We need an atomic way to setup pmd page table entry, avoiding races with
> > > > > > CPU setting dirty/accessed bits. This is required to implement
> > > > > > pmdp_invalidate() that doesn't loose these bits.
> > > > > > 
> > > > > > On PAE we have to use cmpxchg8b as we cannot assume what is value of new pmd and
> > > > > > setting it up half-by-half can expose broken corrupted entry to CPU.
> > > > > > 
> > > > > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > > > > Cc: Ingo Molnar <mingo@kernel.org>
> > > > > > Cc: H. Peter Anvin <hpa@zytor.com>
> > > > > > Cc: Thomas Gleixner <tglx@linutronix.de>
> > > > > 
> > > > > I'll look at this from the arm64 perspective. It would be good if we can
> > > > > have a generic atomic implementation based on cmpxchg64 but I need to
> > > > > look at the details first.
> > > > 
> > > > Unfortunately, I'm not sure it's possbile.
> > > > 
> > > > The format of a page table is defined per-arch. We cannot assume much about
> > > > it in generic code.
> > > > 
> > > > I guess we could make it compile by casting to 'unsigned long', but is it
> > > > useful?
> > > > Every architecture manintainer still has to validate that this assumption
> > > > is valid for the architecture.
> > > 
> > > You are right, not much gained in doing this.
> > > 
> > > Maybe a stupid question but can we not implement pmdp_invalidate() with
> > > something like pmdp_get_and_clear() (usually reusing the ptep_*
> > > equivalent). Or pmdp_clear_flush() (again, reusing ptep_clear_flush())?
> > > 
> > > In my quick grep on pmdp_invalidate, it seems to be followed by
> > > set_pmd_at() or pmd_populate() already and the *pmd value after
> > > mknotpresent isn't any different from 0 to the hardware (at least on
> > > ARM). That's unless Linux expects to see some non-zero value here if
> > > walking the page tables on another CPU.
> > 
> > The whole reason to have pmdp_invalidate() in first place is to never make
> > pmd clear in the middle. Otherwise we will get race with MADV_DONTNEED.
> > See ced108037c2a for an example of such race.
> 
> Thanks for the explanation. So you basically just want to set a !present
> and !none pmd. I noticed that with your proposed pmdp_invalidate(),
> pmdp_establish(pmd_mknotpresent(*pmdp)) could set a stale *pmdp (with
> the present bit cleared) temporarily until updated with what
> pmdp_establish() returned. Is there a risk of racing with other parts of
> the kernel? I guess not since the pmd is !present.

I don't see such risk. Other parts of the kernel would see non-present pmd
and will have to take ptl to do anything meaningful with it.
pmdp_invalidate() caller has to hold ptl too, so the race is excluded.

> For arm64, I don't see the point of a cmpxchg, so something like below
> would do (it needs proper testing though):

Right. cmpxchg is required for x86 PAE, as it has sizeof(pmd_t) >
sizeof(long). We don't have 8-byte xchg() there.

Thanks, for the patch. I assume, I can use your signed-off-by, right?

Any chance you could help me with arm too?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
