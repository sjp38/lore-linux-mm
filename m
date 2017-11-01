Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C394B6B026F
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 18:30:05 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e8so2000478wmc.2
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 15:30:05 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id q197si1592455wmb.236.2017.11.01.15.30.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 15:30:04 -0700 (PDT)
Date: Wed, 1 Nov 2017 23:30:01 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 04/23] x86, tlb: make CR4-based TLB flushes more robust
In-Reply-To: <d7db2bfd-e251-606f-a42f-55c9ef1aca55@linux.intel.com>
Message-ID: <alpine.DEB.2.20.1711012329240.1942@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223154.67F15B2A@viggo.jf.intel.com> <alpine.DEB.2.20.1711012222330.1942@nanos> <d7db2bfd-e251-606f-a42f-55c9ef1aca55@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


On Wed, 1 Nov 2017, Dave Hansen wrote:

> On 11/01/2017 02:25 PM, Thomas Gleixner wrote:
> >>  	cr4 = this_cpu_read(cpu_tlbstate.cr4);
> >> -	/* clear PGE */
> >> -	native_write_cr4(cr4 & ~X86_CR4_PGE);
> >> -	/* write old PGE again and flush TLBs */
> >> +	/*
> >> +	 * This function is only called on systems that support X86_CR4_PGE
> >> +	 * and where always set X86_CR4_PGE.  Warn if we are called without
> >> +	 * PGE set.
> >> +	 */
> >> +	WARN_ON_ONCE(!(cr4 & X86_CR4_PGE));
> > Because if CR4_PGE is not set, this warning triggers. So this defeats the
> > toggle mode you are implementing.
> 
> The warning is there because there is probably plenty of *other* stuff
> that breaks if we have X86_FEATURE_PGE=1, but CR4.PGE=0.
> 
> The point of this was to make this function do the right thing no matter
> what, but warn if it gets called in an unexpected way.

Fair enough. Can you please reflect that in the changelog ?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
