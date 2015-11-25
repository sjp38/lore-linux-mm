Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id B81FA6B0255
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 19:40:04 -0500 (EST)
Received: by wmvv187 with SMTP id v187so234495919wmv.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:40:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 141si1922406wmg.56.2015.11.24.16.40.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 16:40:03 -0800 (PST)
Date: Tue, 24 Nov 2015 16:40:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 1/4] mm: mmap: Add new /proc tunable for mmap_base
 ASLR.
Message-Id: <20151124164001.71844bcfb4d7a500cd25d9c6@linux-foundation.org>
In-Reply-To: <1447888808-31571-2-git-send-email-dcashman@android.com>
References: <1447888808-31571-1-git-send-email-dcashman@android.com>
	<1447888808-31571-2-git-send-email-dcashman@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, will.deacon@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com

On Wed, 18 Nov 2015 15:20:05 -0800 Daniel Cashman <dcashman@android.com> wrote:

> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1568,6 +1568,28 @@ static struct ctl_table vm_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_doulongvec_minmax,
>  	},
> +#ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
> +	{
> +		.procname	= "mmap_rnd_bits",
> +		.data		= &mmap_rnd_bits,
> +		.maxlen		= sizeof(mmap_rnd_bits),
> +		.mode		= 0644,

Is there any harm in permitting the attacker to read these values?

And is there any benefit in permitting non-attackers to read them?

> +		.proc_handler	= proc_dointvec_minmax,
> +		.extra1		= &mmap_rnd_bits_min,
> +		.extra2		= &mmap_rnd_bits_max,
> +	},
> +#endif
> +#ifdef CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS
> +	{
> +		.procname	= "mmap_rnd_compat_bits",
> +		.data		= &mmap_rnd_compat_bits,
> +		.maxlen		= sizeof(mmap_rnd_compat_bits),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_minmax,
> +		.extra1		= &mmap_rnd_compat_bits_min,
> +		.extra2		= &mmap_rnd_compat_bits_max,
> +	},
> +#endif
>
> ...
>
> +#ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
> +int mmap_rnd_bits_min = CONFIG_ARCH_MMAP_RND_BITS_MIN;
> +int mmap_rnd_bits_max = CONFIG_ARCH_MMAP_RND_BITS_MAX;
> +int mmap_rnd_bits = CONFIG_ARCH_MMAP_RND_BITS;
> +#endif
> +#ifdef CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS
> +int mmap_rnd_compat_bits_min = CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN;
> +int mmap_rnd_compat_bits_max = CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX;
> +int mmap_rnd_compat_bits = CONFIG_ARCH_MMAP_RND_COMPAT_BITS;

These could be __read_mostly.

If one believes in such things.  One effect of __read_mostly is to
clump the write-often stuff into the same cachelines and I've never
been convinced that one outweighs the other...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
