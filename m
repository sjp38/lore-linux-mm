Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3EE7C6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 03:58:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r190so12325509wmr.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 00:58:46 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.133])
        by mx.google.com with ESMTPS id hm9si2050361wjb.247.2016.07.07.00.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 00:58:44 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/9] mm: Hardened usercopy
Date: Thu, 07 Jul 2016 10:01:36 +0200
Message-ID: <3418914.byvl8Wuxlf@wuerfel>
In-Reply-To: <1467843928-29351-2-git-send-email-keescook@chromium.org>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org> <1467843928-29351-2-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, kernel-hardening@lists.openwall.com, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, x86@kernel.org, Russell King <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Pekka Enberg <penberg@kernel.org>, Casey Schaufler <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>

On Wednesday, July 6, 2016 3:25:20 PM CEST Kees Cook wrote:
> This is the start of porting PAX_USERCOPY into the mainline kernel. This
> is the first set of features, controlled by CONFIG_HARDENED_USERCOPY. The
> work is based on code by PaX Team and Brad Spengler, and an earlier port
> from Casey Schaufler. Additional non-slab page tests are from Rik van Riel.
> 
> This patch contains the logic for validating several conditions when
> performing copy_to_user() and copy_from_user() on the kernel object
> being copied to/from:
> - address range doesn't wrap around
> - address range isn't NULL or zero-allocated (with a non-zero copy size)
> - if on the slab allocator:
>   - object size must be less than or equal to copy size (when check is
>     implemented in the allocator, which appear in subsequent patches)
> - otherwise, object must not span page allocations
> - if on the stack
>   - object must not extend before/after the current process task
>   - object must be contained by the current stack frame (when there is
>     arch/build support for identifying stack frames)
> - object must not overlap with kernel text
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>

Nice!

I have a few further thoughts, most of which have probably been
considered before:

> +static inline const char *check_bogus_address(const void *ptr, unsigned long n)
> +{
> +	/* Reject if object wraps past end of memory. */
> +	if (ptr + n < ptr)
> +		return "<wrapped address>";
> +
> +	/* Reject if NULL or ZERO-allocation. */
> +	if (ZERO_OR_NULL_PTR(ptr))
> +		return "<null>";
> +
> +	return NULL;
> +}

This checks against address (void*)16, but I guess on most architectures the
lowest possible kernel address is much higher. While there may not be much
that to exploit if the expected kernel address points to userland, forbidding
any obviously incorrect address that is outside of the kernel may be easier.

Even on architectures like s390 that start the kernel memory at (void *)0x0,
the lowest address to which we may want to do a copy_to_user would be much
higher than (void*)0x16.

> +
> +	/* Allow kernel rodata region (if not marked as Reserved). */
> +	if (ptr >= (const void *)__start_rodata &&
> +	    end <= (const void *)__end_rodata)
> +		return NULL;

Should we explicitly forbid writing to rodata, or is it enough to
rely on page protection here?

> +	/* Allow kernel bss region (if not marked as Reserved). */
> +	if (ptr >= (const void *)__bss_start &&
> +	    end <= (const void *)__bss_stop)
> +		return NULL;

accesses to .data/.rodata/.bss are probably not performance critical,
so we could go further here and check the kallsyms table to ensure
that we are not spanning multiple symbols here.

For stuff that is performance critical, should there be a way to
opt out of the checks, or do we assume it already uses functions
that avoid the checks? I looked at the file and network I/O path
briefly and they seem to use kmap_atomic() to get to the user pages
at least in some of the common cases (but I may well be missing
important ones).

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
