Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C42CF6B000A
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 06:49:16 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id az8-v6so11912066plb.15
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 03:49:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d31-v6sor5416381pld.59.2018.07.10.03.49.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Jul 2018 03:49:15 -0700 (PDT)
Date: Tue, 10 Jul 2018 13:49:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 13/18] x86/mm: Allow to disable MKTME after enumeration
Message-ID: <20180710104910.3xpiniksptpby4fo@kshutemo-mobl1>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
 <20180626142245.82850-14-kirill.shutemov@linux.intel.com>
 <20180709182055.GI6873@char.US.ORACLE.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180709182055.GI6873@char.US.ORACLE.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 09, 2018 at 02:20:55PM -0400, Konrad Rzeszutek Wilk wrote:
> On Tue, Jun 26, 2018 at 05:22:40PM +0300, Kirill A. Shutemov wrote:
> > The new helper mktme_disable() allows to disable MKTME even if it's
> > enumerated successfully. MKTME initialization may fail and this
> > functionality allows system to boot regardless of the failure.
> > 
> > MKTME needs per-KeyID direct mapping. It requires a lot more virtual
> > address space which may be a problem in 4-level paging mode. If the
> > system has more physical memory than we can handle with MKTME.
> 
> .. then what should happen?

We fail MKTME initialization and boot the system. See next sentence.

> > The feature allows to fail MKTME, but boot the system successfully.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  arch/x86/include/asm/mktme.h | 2 ++
> >  arch/x86/kernel/cpu/intel.c  | 5 +----
> >  arch/x86/mm/mktme.c          | 9 +++++++++
> >  3 files changed, 12 insertions(+), 4 deletions(-)
> > 
> > diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
> > index 44409b8bbaca..ebbee6a0c495 100644
> > --- a/arch/x86/include/asm/mktme.h
> > +++ b/arch/x86/include/asm/mktme.h
> > @@ -6,6 +6,8 @@
> >  
> >  struct vm_area_struct;
> >  
> > +void mktme_disable(void);
> > +
> >  #ifdef CONFIG_X86_INTEL_MKTME
> >  extern phys_addr_t mktme_keyid_mask;
> >  extern int mktme_nr_keyids;
> > diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
> > index efc9e9fc47d4..75e3b2602b4a 100644
> > --- a/arch/x86/kernel/cpu/intel.c
> > +++ b/arch/x86/kernel/cpu/intel.c
> > @@ -591,10 +591,7 @@ static void detect_tme(struct cpuinfo_x86 *c)
> >  		 * Maybe needed if there's inconsistent configuation
> >  		 * between CPUs.
> >  		 */
> > -		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
> > -		mktme_keyid_mask = 0;
> > -		mktme_keyid_shift = 0;
> > -		mktme_nr_keyids = 0;
> > +		mktme_disable();
> >  	}
> >  #endif
> >  
> > diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
> > index 1194496633ce..bb6210dbcf0e 100644
> > --- a/arch/x86/mm/mktme.c
> > +++ b/arch/x86/mm/mktme.c
> > @@ -13,6 +13,15 @@ static inline bool mktme_enabled(void)
> >  	return static_branch_unlikely(&mktme_enabled_key);
> >  }
> >  
> > +void mktme_disable(void)
> > +{
> > +	physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
> > +	mktme_keyid_mask = 0;
> > +	mktme_keyid_shift = 0;
> > +	mktme_nr_keyids = 0;
> > +	static_branch_disable(&mktme_enabled_key);
> > +}
> > +
> >  int page_keyid(const struct page *page)
> >  {
> >  	if (!mktme_enabled())
> > -- 
> > 2.18.0
> > 
> 

-- 
 Kirill A. Shutemov
