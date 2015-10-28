Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9B04A82F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 19:43:13 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so20757284pad.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 16:43:13 -0700 (PDT)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id kd3si44933680pbc.173.2015.10.28.16.43.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 28 Oct 2015 16:43:12 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1446067520-31806-1-git-send-email-dcashman@android.com>
Date: Wed, 28 Oct 2015 18:34:15 -0500
In-Reply-To: <1446067520-31806-1-git-send-email-dcashman@android.com> (Daniel
	Cashman's message of "Wed, 28 Oct 2015 14:25:19 -0700")
Message-ID: <871tcewoso.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH 1/2] mm: mmap: Add new /proc tunable for mmap_base ASLR.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, dcashman <dcashman@google.com>

Daniel Cashman <dcashman@android.com> writes:

> From: dcashman <dcashman@google.com>
>
> ASLR currently only uses 8 bits to generate the random offset for the
> mmap base address on 32 bit architectures. This value was chosen to
> prevent a poorly chosen value from dividing the address space in such
> a way as to prevent large allocations. This may not be an issue on all
> platforms. Allow the specification of a minimum number of bits so that
> platforms desiring greater ASLR protection may determine where to place
> the trade-off.

This all would be much cleaner if the arm architecture code were just to
register the sysctl itself.

As it sits this looks like a patchset that does not meaninfully bisect,
and would result in code that is hard to trace and understand.

Eric

> Signed-off-by: Daniel Cashman <dcashman@google.com>
> ---
>  Documentation/sysctl/kernel.txt | 14 ++++++++++++++
>  include/linux/mm.h              |  6 ++++++
>  kernel/sysctl.c                 | 11 +++++++++++
>  3 files changed, 31 insertions(+)
>
> diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
> index 6fccb69..0d4ca53 100644
> --- a/Documentation/sysctl/kernel.txt
> +++ b/Documentation/sysctl/kernel.txt
> @@ -41,6 +41,7 @@ show up in /proc/sys/kernel:
>  - kptr_restrict
>  - kstack_depth_to_print       [ X86 only ]
>  - l2cr                        [ PPC only ]
> +- mmap_rnd_bits
>  - modprobe                    ==> Documentation/debugging-modules.txt
>  - modules_disabled
>  - msg_next_id		      [ sysv ipc ]
> @@ -391,6 +392,19 @@ This flag controls the L2 cache of G3 processor boards. If
>  
>  ==============================================================
>  
> +mmap_rnd_bits:
> +
> +This value can be used to select the number of bits to use to
> +determine the random offset to the base address of vma regions
> +resulting from mmap allocations on architectures which support
> +tuning address space randomization.  This value will be bounded
> +by the architecture's minimum and maximum supported values.
> +
> +This value can be changed after boot using the
> +/proc/sys/kernel/mmap_rnd_bits tunable
> +
> +==============================================================
> +
>  modules_disabled:
>  
>  A toggle value indicating if modules are allowed to be loaded
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 80001de..15b083a 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -51,6 +51,12 @@ extern int sysctl_legacy_va_layout;
>  #define sysctl_legacy_va_layout 0
>  #endif
>  
> +#ifdef CONFIG_ARCH_MMAP_RND_BITS
> +extern int mmap_rnd_bits_min;
> +extern int mmap_rnd_bits_max;
> +extern int mmap_rnd_bits;
> +#endif
> +
>  #include <asm/page.h>
>  #include <asm/pgtable.h>
>  #include <asm/processor.h>
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index e69201d..37e657a 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1139,6 +1139,17 @@ static struct ctl_table kern_table[] = {
>  		.proc_handler	= timer_migration_handler,
>  	},
>  #endif
> +#ifdef CONFIG_ARCH_MMAP_RND_BITS
> +	{
> +		.procname	= "mmap_rnd_bits",
> +		.data		= &mmap_rnd_bits,
> +		.maxlen		= sizeof(mmap_rnd_bits),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_minmax,
> +		.extra1		= &mmap_rnd_bits_min,
> +		.extra2		= &mmap_rnd_bits_max,
> +	},
> +#endif
>  	{ }
>  };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
