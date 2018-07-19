Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A28E86B0005
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:21:38 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id m2-v6so4306882plt.14
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 03:21:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j17-v6sor1537615pgn.416.2018.07.19.03.21.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 03:21:37 -0700 (PDT)
Date: Thu, 19 Jul 2018 13:21:30 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 08/19] x86/mm: Introduce variables to store number,
 shift and mask of KeyIDs
Message-ID: <20180719102130.b4f6b6v5wg3modtc@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-9-kirill.shutemov@linux.intel.com>
 <1edc05b0-8371-807e-7cfa-6e8f61ee9b70@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1edc05b0-8371-807e-7cfa-6e8f61ee9b70@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 18, 2018 at 04:19:10PM -0700, Dave Hansen wrote:
> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> > mktme_nr_keyids holds number of KeyIDs available for MKTME, excluding
> > KeyID zero which used by TME. MKTME KeyIDs start from 1.
> > 
> > mktme_keyid_shift holds shift of KeyID within physical address.
> 
> I know what all these words mean, but the combination of them makes no
> sense to me.  I still don't know what the variable does after reading this.
> 
> Is this the lowest bit in the physical address which is used for the
> KeyID?  How many bits you must shift up a KeyID to get to the location
> at which it can be masked into the physical address?

Right.

I'm not sure what is not clear from the description. It look fine to me.

> > mktme_keyid_mask holds mask to extract KeyID from physical address.
> 
> Good descriptions, wrong place.  Please put these in the code.

Okay.

> Also, the grammar constantly needs some work.  "holds mask" needs to be
> "holds the mask".

Right. Thanks

> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  arch/x86/include/asm/mktme.h | 16 ++++++++++++++++
> >  arch/x86/kernel/cpu/intel.c  | 12 ++++++++----
> >  arch/x86/mm/Makefile         |  2 ++
> >  arch/x86/mm/mktme.c          |  5 +++++
> >  4 files changed, 31 insertions(+), 4 deletions(-)
> >  create mode 100644 arch/x86/include/asm/mktme.h
> >  create mode 100644 arch/x86/mm/mktme.c
> > 
> > diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
> > new file mode 100644
> > index 000000000000..df31876ec48c
> > --- /dev/null
> > +++ b/arch/x86/include/asm/mktme.h
> > @@ -0,0 +1,16 @@
> > +#ifndef	_ASM_X86_MKTME_H
> > +#define	_ASM_X86_MKTME_H
> > +
> > +#include <linux/types.h>
> > +
> > +#ifdef CONFIG_X86_INTEL_MKTME
> > +extern phys_addr_t mktme_keyid_mask;
> > +extern int mktme_nr_keyids;
> > +extern int mktme_keyid_shift;
> > +#else
> > +#define mktme_keyid_mask	((phys_addr_t)0)
> > +#define mktme_nr_keyids		0
> > +#define mktme_keyid_shift	0
> > +#endif
> > +
> > +#endif
> > diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
> > index bf2caf9d52dd..efc9e9fc47d4 100644
> > --- a/arch/x86/kernel/cpu/intel.c
> > +++ b/arch/x86/kernel/cpu/intel.c
> > @@ -573,6 +573,9 @@ static void detect_tme(struct cpuinfo_x86 *c)
> >  
> >  #ifdef CONFIG_X86_INTEL_MKTME
> >  	if (mktme_status == MKTME_ENABLED && nr_keyids) {
> > +		mktme_nr_keyids = nr_keyids;
> > +		mktme_keyid_shift = c->x86_phys_bits - keyid_bits;
> > +
> >  		/*
> >  		 * Mask out bits claimed from KeyID from physical address mask.
> >  		 *
> > @@ -580,10 +583,8 @@ static void detect_tme(struct cpuinfo_x86 *c)
> >  		 * and number of bits claimed for KeyID is 6, bits 51:46 of
> >  		 * physical address is unusable.
> >  		 */
> > -		phys_addr_t keyid_mask;
> > -
> > -		keyid_mask = GENMASK_ULL(c->x86_phys_bits - 1, c->x86_phys_bits - keyid_bits);
> > -		physical_mask &= ~keyid_mask;
> > +		mktme_keyid_mask = GENMASK_ULL(c->x86_phys_bits - 1, mktme_keyid_shift);
> > +		physical_mask &= ~mktme_keyid_mask;
> 
> Seems a bit silly that we introduce keyid_mask only to make it global a
> few patches later.

Is it a big deal?

I found it easier to split changes into logical pieces this way.

> >  	} else {
> >  		/*
> >  		 * Reset __PHYSICAL_MASK.
> > @@ -591,6 +592,9 @@ static void detect_tme(struct cpuinfo_x86 *c)
> >  		 * between CPUs.
> >  		 */
> >  		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
> > +		mktme_keyid_mask = 0;
> > +		mktme_keyid_shift = 0;
> > +		mktme_nr_keyids = 0;
> >  	}
> 
> Should be unnecessary.  These are zeroed by the compiler.

No. detect_tme() called for each CPU in the system.

> > diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
> > index 4b101dd6e52f..4ebee899c363 100644
> > --- a/arch/x86/mm/Makefile
> > +++ b/arch/x86/mm/Makefile
> > @@ -53,3 +53,5 @@ obj-$(CONFIG_PAGE_TABLE_ISOLATION)		+= pti.o
> >  obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
> >  obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_identity.o
> >  obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
> > +
> > +obj-$(CONFIG_X86_INTEL_MKTME)	+= mktme.o
> > diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
> > new file mode 100644
> > index 000000000000..467f1b26c737
> > --- /dev/null
> > +++ b/arch/x86/mm/mktme.c
> > @@ -0,0 +1,5 @@
> > +#include <asm/mktme.h>
> > +
> > +phys_addr_t mktme_keyid_mask;
> > +int mktme_nr_keyids;
> > +int mktme_keyid_shift;
> 
> Descriptions should be here, please, not in the changelog.

Okay.

-- 
 Kirill A. Shutemov
