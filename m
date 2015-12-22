Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id B507E6B0005
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 04:33:31 -0500 (EST)
Received: by mail-yk0-f171.google.com with SMTP id p130so158017215yka.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 01:33:31 -0800 (PST)
Received: from mail-yk0-x22a.google.com (mail-yk0-x22a.google.com. [2607:f8b0:4002:c07::22a])
        by mx.google.com with ESMTPS id s206si4608357yws.203.2015.12.22.01.33.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 01:33:30 -0800 (PST)
Received: by mail-yk0-x22a.google.com with SMTP id 140so158050172ykp.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 01:33:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1450755641-7856-7-git-send-email-laura@labbott.name>
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
	<1450755641-7856-7-git-send-email-laura@labbott.name>
Date: Tue, 22 Dec 2015 10:33:30 +0100
Message-ID: <CA+rthh-X2jvGpptE72CCbOx2MdkukJSCu621+9ymMJ_pCQ9t+w@mail.gmail.com>
Subject: Re: [kernel-hardening] [RFC][PATCH 6/7] mm: Add Kconfig option for
 slab sanitization
From: Mathias Krause <minipli@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <laura@labbott.name>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kees Cook <keescook@chromium.org>

On 22 December 2015 at 04:40, Laura Abbott <laura@labbott.name> wrote:
>
> The SL[AOU]B allocators all behave differently w.r.t. to what happen
> an object is freed. CONFIG_SLAB_SANITIZATION introduces a common
> mechanism to control what happens on free. When this option is
> enabled, objects may be poisoned according to a combination of
> slab_sanitization command line option and whether SLAB_NO_SANITIZE
> is set on a cache.
>
> All credit for the original work should be given to Brad Spengler and
> the PaX Team.
>
> Signed-off-by: Laura Abbott <laura@labbott.name>
> ---
>  init/Kconfig | 36 ++++++++++++++++++++++++++++++++++++
>  1 file changed, 36 insertions(+)
>
> diff --git a/init/Kconfig b/init/Kconfig
> index 235c7a2..37857f3 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1755,6 +1755,42 @@ config SLUB_CPU_PARTIAL
>           which requires the taking of locks that may cause latency spikes.
>           Typically one would choose no for a realtime system.
>
> +config SLAB_MEMORY_SANITIZE
> +       bool "Sanitize all freed memory"
> +       help
> +         By saying Y here the kernel will erase slab objects as soon as they
> +         are freed.  This in turn reduces the lifetime of data
> +         stored in them, making it less likely that sensitive information such
> +         as passwords, cryptographic secrets, etc stay in memory for too long.
> +

> +         This is especially useful for programs whose runtime is short, long
> +         lived processes and the kernel itself benefit from this as long as
> +         they ensure timely freeing of memory that may hold sensitive
> +         information.

This part is not true. The code is handling SLAB objects only, so
talking about processes in this context is misleading. Freeing memory
in userland containing secrets cannot be covered by this feature as
is. It needs a counter-part in the userland memory allocator as well
as handling page sanitization in the buddy allocator.

I guess you've just copy+pasted that Kconfig description from the PaX
feature PAX_MEMORY_SANITIZE that also covers the buddy allocator,
therefore fits that description while this patch set does not. So
please adapt the text or implement the fully featured version.

> +
> +         A nice side effect of the sanitization of slab objects is the
> +         reduction of possible info leaks caused by padding bytes within the
> +         leaky structures.  Use-after-free bugs for structures containing
> +         pointers can also be detected as dereferencing the sanitized pointer
> +         will generate an access violation.
> +
> +         The tradeoff is performance impact. The noticible impact can vary
> +         and you are advised to test this feature on your expected workload
> +         before deploying it
> +

> +         The slab sanitization feature excludes a few slab caches per default
> +         for performance reasons. The level of sanitization can be adjusted
> +         with the sanitize_slab commandline option:
> +               sanitize_slab=off: No sanitization will occur
> +               santiize_slab=slow: Sanitization occurs only on the slow path
> +               for all but the excluded slabs
> +               (relevant for SLUB allocator only)
> +               sanitize_slab=partial: Sanitization occurs on all path for all
> +               but the excluded slabs
> +               sanitize_slab=full: All slabs are sanitize

This should probably be moved to Documentation/kernel-parameters.txt,
as can be found in the PaX patch[1]?

> +
> +         If unsure, say Y here.

Really? It has an unknown performance impact, depending on the
workload, which might make "unsure users" preferably say No, if they
don't care about info leaks.

Related to this, have you checked that the sanitization doesn't
interfere with the various slab handling schemes, namely RCU related
specialties? Not all caches are marked SLAB_DESTROY_BY_RCU, some use
call_rcu() instead, implicitly relying on the semantics RCU'ed slabs
permit, namely allowing a "use-after-free" access to be legitimate
within the RCU grace period. Scrubbing the object during that period
would break that assumption.

Speaking of RCU, do you have a plan to support RCU'ed slabs as well?

> +
>  config MMAP_ALLOW_UNINITIALIZED
>         bool "Allow mmapped anonymous memory to be uninitialized"
>         depends on EXPERT && !MMU
> --
> 2.5.0
>

Regards,
Mathias

[1] https://github.com/minipli/linux-grsec/blob/v4.3.3-pax/Documentation/kernel-parameters.txt#L2689-L2696

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
