Received: from localhost.localdomain ([127.0.0.1]:1483 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S28576511AbXJaSgx (ORCPT <rfc822;linux-mm@kvack.org>);
	Wed, 31 Oct 2007 18:36:53 +0000
Date: Wed, 31 Oct 2007 18:36:24 +0000
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [patch 04/28] Add cmpxchg64 and cmpxchg64_local to mips
Message-ID: <20071031183624.GA31653@linux-mips.org>
References: <20071030191557.947156623@polymtl.ca> <20071030192102.677087409@polymtl.ca> <20071031124831.GA3982@linux-mips.org> <20071031131935.GA26625@Krystal>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071031131935.GA26625@Krystal>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, matthew@wil.cx, linux-arch@vger.kernel.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 31, 2007 at 09:19:35AM -0400, Mathieu Desnoyers wrote:

> * Ralf Baechle (ralf@linux-mips.org) wrote:
> > This implementation means cmpxchg64_local will also silently take 32-bit
> > arguments without making noises at compile time.  I think it should.
> > 
> 
> Something along those lines ? I've fixed the other architectures too.
> 
> 
> Add cmpxchg64 and cmpxchg64_local to mips
> 
> Make sure that at least cmpxchg64_local is available on all architectures to use
> for unsigned long long values.
> 
> Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
> CC: ralf@linux-mips.org
> CC linux-mips@linux-mips.org
> ---
>  include/asm-mips/cmpxchg.h |   17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> Index: linux-2.6-lttng/include/asm-mips/cmpxchg.h
> ===================================================================
> --- linux-2.6-lttng.orig/include/asm-mips/cmpxchg.h	2007-10-31 09:14:10.000000000 -0400
> +++ linux-2.6-lttng/include/asm-mips/cmpxchg.h	2007-10-31 09:15:35.000000000 -0400
> @@ -104,4 +104,21 @@ extern void __cmpxchg_called_with_bad_po
>  #define cmpxchg(ptr, old, new)		__cmpxchg(ptr, old, new, smp_llsc_mb())
>  #define cmpxchg_local(ptr, old, new)	__cmpxchg(ptr, old, new, )
>  
> +#define cmpxchg64(ptr,o,n)						\
> +  ({									\
> +  	BUILD_BUG_ON(sizeof(*(ptr)) != 8);				\
> +  	cmpxchg((ptr),(o),(n));						\
> +  })
> +
> +#ifdef CONFIG_64BIT
> +#define cmpxchg64_local(ptr,o,n)					\
> +  ({									\
> +  	BUILD_BUG_ON(sizeof(*(ptr)) != 8);				\
> +  	cmpxchg_local((ptr),(o),(n));					\
> +  })
> +#else
> +#include <asm-generic/cmpxchg-local.h>
> +#define cmpxchg64_local(ptr,o,n)	__cmpxchg64_local_generic((ptr),(o),(n))
> +#endif
> +
>  #endif /* __ASM_CMPXCHG_H */

That looks reasonable I think.

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
