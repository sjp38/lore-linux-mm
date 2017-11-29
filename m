Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AADEC6B0069
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 10:26:46 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id 207so3360732iti.5
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 07:26:46 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id c188si1750195ite.28.2017.11.29.07.26.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 07:26:45 -0800 (PST)
Date: Wed, 29 Nov 2017 16:26:31 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] x86/mm/kaiser: Flush the correct ASID in
 __native_flush_tlb_single()
Message-ID: <20171129152631.GQ3326@worktop>
References: <20171128095531.F32E1BC7@viggo.jf.intel.com>
 <20171129143526.GP3326@worktop>
 <27729551-ecd6-e4e9-d214-4ab03d8008da@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <27729551-ecd6-e4e9-d214-4ab03d8008da@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, bp@alien8.de, x86@kernel.org

On Wed, Nov 29, 2017 at 07:21:23AM -0800, Dave Hansen wrote:
> Yes, that works.  Also, as I think about it, INVLPG is a safer
> (bug-resistant) instruction to use too.  INVPCID _can_ get the current
> (kernel) ASID wrong, as we saw.  But INVLPG always uses the current one
> and can't be wrong about flushing the *current* ASID.
> 
> I think Andy measured it to be faster than INVPCID too.
> 
> So, maybe we should just remove INVPCID's use entirely.

With my patches the below invpcid_flush_one() is the only remaining user
(not counting flush_tlb_global).

I know Andy hates on INVPCID, but I could not convince myself that doing
a full user invalidate makes sense for flush_tlb_single(), then again
maybe it does, the patch is trivial after this.

> >  arch/x86/include/asm/tlbflush.h | 23 +++++++----------------
> >  1 file changed, 7 insertions(+), 16 deletions(-)
> > 
> > diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
> > index 481d5094559e..9587722162ee 100644
> > --- a/arch/x86/include/asm/tlbflush.h
> > +++ b/arch/x86/include/asm/tlbflush.h
> > @@ -438,29 +438,20 @@ static inline void __native_flush_tlb_single(unsigned long addr)
> >  {
> >  	u32 loaded_mm_asid = this_cpu_read(cpu_tlbstate.loaded_mm_asid);
> >  
> > +	asm volatile("invlpg (%0)" ::"r" (addr) : "memory");
> > +
> > +	if (!kaiser_enabled)
> > +		return;
> > +
> >  	/*
> >  	 * Some platforms #GP if we call invpcid(type=1/2) before
> >  	 * CR4.PCIDE=1.  Just call invpcid in the case we are called
> >  	 * early.
> >  	 */
> > +	if (!this_cpu_has(X86_FEATURE_INVPCID_SINGLE))
> >  		flush_user_asid(loaded_mm_asid);
> > +	else
> >  		invpcid_flush_one(user_asid(loaded_mm_asid), addr);
> >  }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
