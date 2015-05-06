Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id CD4276B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 11:42:42 -0400 (EDT)
Received: by oign205 with SMTP id n205so10665489oig.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 08:42:41 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id pz7si12185844oec.44.2015.05.06.08.42.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 08:42:40 -0700 (PDT)
Message-ID: <1430925811.23761.303.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 4/7] mtrr, x86: Fix MTRR state checks in
 mtrr_type_lookup()
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 06 May 2015 09:23:31 -0600
In-Reply-To: <20150506114705.GD22949@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
	 <1427234921-19737-5-git-send-email-toshi.kani@hp.com>
	 <20150506114705.GD22949@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Wed, 2015-05-06 at 13:47 +0200, Borislav Petkov wrote:
> On Tue, Mar 24, 2015 at 04:08:38PM -0600, Toshi Kani wrote:
> > 'mtrr_state.enabled' contains the FE (fixed MTRRs enabled)
> > and E (MTRRs enabled) flags in MSR_MTRRdefType.  Intel SDM,
> > section 11.11.2.1, defines these flags as follows:
> >  - All MTRRs are disabled when the E flag is clear.
> >    The FE flag has no affect when the E flag is clear.
> >  - The default type is enabled when the E flag is set.
> >  - MTRR variable ranges are enabled when the E flag is set.
> >  - MTRR fixed ranges are enabled when both E and FE flags
> >    are set.
> > 
> > MTRR state checks in __mtrr_type_lookup() do not match with
> > SDM.  Hence, this patch makes the following changes:
> >  - The current code detects MTRRs disabled when both E and
> >    FE flags are clear in mtrr_state.enabled.  Fix to detect
> >    MTRRs disabled when the E flag is clear.
> >  - The current code does not check if the FE bit is set in
> >    mtrr_state.enabled when looking into the fixed entries.
> >    Fix to check the FE flag.
> >  - The current code returns the default type when the E flag
> >    is clear in mtrr_state.enabled.  However, the default type
> >    is also disabled when the E flag is clear.  Fix to remove
> >    the code as this case is handled as MTRR disabled with
> >    the 1st change.
> > 
> > In addition, this patch defines the E and FE flags in
> > mtrr_state.enabled as follows.
> >  - FE flag: MTRR_STATE_MTRR_FIXED_ENABLED
> >  - E  flag: MTRR_STATE_MTRR_ENABLED
> > 
> > print_mtrr_state() is also updated accordingly.
> > 
> > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> > ---
> >  arch/x86/include/uapi/asm/mtrr.h   |    4 ++++
> >  arch/x86/kernel/cpu/mtrr/generic.c |   15 ++++++++-------
> >  2 files changed, 12 insertions(+), 7 deletions(-)
> 
> You missed a spot in the conversion in
> arch/x86/kernel/cpu/mtrr/cleanup.c::x86_get_mtrr_mem_range():
> 
> There we have
> 
> 	if (base < (1<<(20-PAGE_SHIFT)) && mtrr_state.have_fixed &&
> 	    (mtrr_state.enabled & 1)) {
> 
> which should be mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED.

Right.  I will also check both MTRR_STATE_MTRR_FIXED_ENABLED &
MTRR_STATE_MTRR_FIXED_ENABLED bits here.

> > diff --git a/arch/x86/include/uapi/asm/mtrr.h b/arch/x86/include/uapi/asm/mtrr.h
> > index d0acb65..66ba88d 100644
> > --- a/arch/x86/include/uapi/asm/mtrr.h
> > +++ b/arch/x86/include/uapi/asm/mtrr.h
> > @@ -88,6 +88,10 @@ struct mtrr_state_type {
> >         mtrr_type def_type;
> >  };
> > 
> > +/* Bit fields for enabled in struct mtrr_state_type */
> > +#define MTRR_STATE_MTRR_FIXED_ENABLED  0x01
> > +#define MTRR_STATE_MTRR_ENABLED                0x02
> > +
> >  #define MTRRphysBase_MSR(reg) (0x200 + 2 * (reg))
> >  #define MTRRphysMask_MSR(reg) (0x200 + 2 * (reg) + 1)
> 
> Please add those to arch/x86/include/asm/mtrr.h instead. They have no
> place in the uapi header.

I have a question.  Those bits define the bit field of enabled in struct
mtrr_state_type, which is defined in this header.  Is it OK to only move
those definitions to other header?

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
