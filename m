Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A954A6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 03:45:42 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g18so5959646lfg.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 00:45:42 -0700 (PDT)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id v139si2020186wmv.78.2016.07.07.00.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 00:45:41 -0700 (PDT)
Date: Thu, 7 Jul 2016 09:42:17 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/9] mm: Hardened usercopy
In-Reply-To: <1467843928-29351-2-git-send-email-keescook@chromium.org>
Message-ID: <alpine.DEB.2.11.1607070938430.4083@nanos>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org> <1467843928-29351-2-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Wed, 6 Jul 2016, Kees Cook wrote:
> +
> +#if defined(CONFIG_FRAME_POINTER) && defined(CONFIG_X86)
> +	const void *frame = NULL;
> +	const void *oldframe;
> +#endif

That's ugly

> +
> +	/* Object is not on the stack at all. */
> +	if (obj + len <= stack || stackend <= obj)
> +		return 0;
> +
> +	/*
> +	 * Reject: object partially overlaps the stack (passing the
> +	 * the check above means at least one end is within the stack,
> +	 * so if this check fails, the other end is outside the stack).
> +	 */
> +	if (obj < stack || stackend < obj + len)
> +		return -1;
> +
> +#if defined(CONFIG_FRAME_POINTER) && defined(CONFIG_X86)
> +	oldframe = __builtin_frame_address(1);
> +	if (oldframe)
> +		frame = __builtin_frame_address(2);
> +	/*
> +	 * low ----------------------------------------------> high
> +	 * [saved bp][saved ip][args][local vars][saved bp][saved ip]
> +	 *		     ^----------------^
> +	 *             allow copies only within here
> +	 */
> +	while (stack <= frame && frame < stackend) {
> +		/*
> +		 * If obj + len extends past the last frame, this
> +		 * check won't pass and the next frame will be 0,
> +		 * causing us to bail out and correctly report
> +		 * the copy as invalid.
> +		 */
> +		if (obj + len <= frame)
> +			return obj >= oldframe + 2 * sizeof(void *) ? 2 : -1;
> +		oldframe = frame;
> +		frame = *(const void * const *)frame;
> +	}
> +	return -1;
> +#else
> +	return 1;
> +#endif

I'd rather make that a weak function returning 1 which can be replaced by
x86 for CONFIG_FRAME_POINTER=y. That also allows other architectures to
implement their specific frame checks.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
