Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 844D66B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 15:29:30 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i17so11696649wmb.7
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:29:30 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id h136si12311890wmd.120.2017.11.27.12.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 12:29:28 -0800 (PST)
Date: Mon, 27 Nov 2017 21:28:49 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch V2 2/5] x86/kaiser: Simplify disabling of global pages
In-Reply-To: <0b5a64f1-9979-ae56-99f8-72c3802a9c60@linux.intel.com>
Message-ID: <alpine.DEB.2.20.1711272128360.2333@nanos>
References: <20171126231403.657575796@linutronix.de> <20171126232414.393912629@linutronix.de> <0b5a64f1-9979-ae56-99f8-72c3802a9c60@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, 27 Nov 2017, Dave Hansen wrote:

> On 11/26/2017 03:14 PM, Thomas Gleixner wrote:
> > +static void enable_global_pages(void)
> > +{
> > +#ifndef CONFIG_KAISER
> > +	__supported_pte_mask |= _PAGE_GLOBAL;
> > +#endif
> > +}
> > +
> >  static void __init probe_page_size_mask(void)
> >  {
> >  	/*
> > @@ -179,11 +186,11 @@ static void __init probe_page_size_mask(
> >  		cr4_set_bits_and_update_boot(X86_CR4_PSE);
> >  
> >  	/* Enable PGE if available */
> > +	__supported_pte_mask |= _PAGE_GLOBAL;
> >  	if (boot_cpu_has(X86_FEATURE_PGE)) {
> >  		cr4_set_bits_and_update_boot(X86_CR4_PGE);
> > -		__supported_pte_mask |= _PAGE_GLOBAL;
> > -	} else
> > -		__supported_pte_mask &= ~_PAGE_GLOBAL;
> > +		enable_global_pages();
> > +	}
> 
> This looks a little funky.  Doesn't this or _PAGE_GLOBAL into
> __supported_pte_mask twice?  Once before the if(), and then a second
> time via enable_global_pages() inside the if?
> 
> Did you intend for it to be masked *out* in the first one and then or'd
> back in via enable_global_pages()?

It's fixed already ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
