Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9296B0069
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 17:25:31 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k15so1904325wrc.1
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 14:25:31 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id q3si1384965wrd.153.2017.11.01.14.25.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 14:25:30 -0700 (PDT)
Date: Wed, 1 Nov 2017 22:25:26 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 04/23] x86, tlb: make CR4-based TLB flushes more robust
In-Reply-To: <20171031223154.67F15B2A@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1711012222330.1942@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223154.67F15B2A@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Tue, 31 Oct 2017, Dave Hansen wrote:
> Our CR4-based TLB flush currently requries global pages to be
> supported *and* enabled.  But, we really only need for them to be
> supported.  Make the code more robust by alllowing X86_CR4_PGE to
> clear as well as set.

That's not what the patch is actually doing.

>  	cr4 = this_cpu_read(cpu_tlbstate.cr4);
> -	/* clear PGE */
> -	native_write_cr4(cr4 & ~X86_CR4_PGE);
> -	/* write old PGE again and flush TLBs */
> +	/*
> +	 * This function is only called on systems that support X86_CR4_PGE
> +	 * and where always set X86_CR4_PGE.  Warn if we are called without
> +	 * PGE set.
> +	 */
> +	WARN_ON_ONCE(!(cr4 & X86_CR4_PGE));

Because if CR4_PGE is not set, this warning triggers. So this defeats the
toggle mode you are implementing.

> +	/*
> +	 * Architecturally, any _change_ to X86_CR4_PGE will fully flush the
> +	 * TLB of all entries including all entries in all PCIDs and all
> +	 * global pages.  Make sure that we _change_ the bit, regardless of
> +	 * whether we had X86_CR4_PGE set in the first place.
> +	 */
> +	native_write_cr4(cr4 ^ X86_CR4_PGE);
> +	/* Put original CR3 value back: */

That want's to be CR4. Restoring CR3 to CR4 might be suboptimal.

>  	native_write_cr4(cr4);

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
