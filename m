Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id EA3E06B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 15:39:02 -0500 (EST)
Received: by wmww144 with SMTP id w144so45365867wmw.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 12:39:02 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id h62si7232396wmd.122.2015.12.08.12.39.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 12:39:01 -0800 (PST)
Date: Tue, 8 Dec 2015 21:38:12 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 28/34] x86: wire up mprotect_key() system call
In-Reply-To: <56672A50.4010801@sr71.net>
Message-ID: <alpine.DEB.2.11.1512082134470.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011503.2A095839@viggo.jf.intel.com> <alpine.DEB.2.11.1512081943270.3595@nanos> <56672A50.4010801@sr71.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, linux-api@vger.kernel.org

On Tue, 8 Dec 2015, Dave Hansen wrote:
> On 12/08/2015 10:44 AM, Thomas Gleixner wrote:
> > On Thu, 3 Dec 2015, Dave Hansen wrote:
> >>  #include <asm-generic/mman.h>
> >> diff -puN mm/Kconfig~pkeys-16-x86-mprotect_key mm/Kconfig
> >> --- a/mm/Kconfig~pkeys-16-x86-mprotect_key	2015-12-03 16:21:31.114920208 -0800
> >> +++ b/mm/Kconfig	2015-12-03 16:21:31.119920435 -0800
> >> @@ -679,4 +679,5 @@ config NR_PROTECTION_KEYS
> >>  	# Everything supports a _single_ key, so allow folks to
> >>  	# at least call APIs that take keys, but require that the
> >>  	# key be 0.
> >> +	default 16 if X86_INTEL_MEMORY_PROTECTION_KEYS
> >>  	default 1
> > 
> > What happens if I set that to 42?
> > 
> > I think we want to make this a runtime evaluated thingy. If pkeys are
> > compiled in, but the machine does not support it then we don't support
> > 16 keys, or do we?
> 
> We do have runtime evaluation:
> 
> #define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ?      \
>                              CONFIG_NR_PROTECTION_KEYS : 1)
> 
> The config option really just sets the architectural limit for how many
> are supported.  So it probably needs a better name at least.  Let me
> take a look at getting rid of this config option entirely.

Well, it does not set the architectural limit. It sets some random
value which the guy who configures the kernel choses.

The limit we have in the architecture is 16 because we only have 4
bits for it.
 
arch_max_pkey() is architecture specific, so we can make this:

#define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ? 16 : 1)

And when we magically get more bits in the next century, then '16' can
become a variable or whatever.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
