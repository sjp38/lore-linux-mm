Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4576E6B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 18:54:16 -0500 (EST)
Received: by wmww144 with SMTP id w144so151586396wmw.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 15:54:15 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u130si32377261wmb.100.2015.11.30.15.54.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 15:54:14 -0800 (PST)
Date: Mon, 30 Nov 2015 15:54:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 1/4] mm: mmap: Add new /proc tunable for mmap_base
 ASLR.
Message-Id: <20151130155412.b1a087f4f6f4d4180ab4472d@linux-foundation.org>
In-Reply-To: <1448578785-17656-2-git-send-email-dcashman@android.com>
References: <1448578785-17656-1-git-send-email-dcashman@android.com>
	<1448578785-17656-2-git-send-email-dcashman@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, will.deacon@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com

On Thu, 26 Nov 2015 14:59:42 -0800 Daniel Cashman <dcashman@android.com> wrote:

> ASLR  only uses as few as 8 bits to generate the random offset for the
> mmap base address on 32 bit architectures. This value was chosen to
> prevent a poorly chosen value from dividing the address space in such
> a way as to prevent large allocations. This may not be an issue on all
> platforms. Allow the specification of a minimum number of bits so that
> platforms desiring greater ASLR protection may determine where to place
> the trade-off.
> 
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
> +		.mode		= 0600,
> +		.proc_handler	= proc_dointvec_minmax,
> +		.extra1		= (void *) &mmap_rnd_bits_min,
> +		.extra2		= (void *) &mmap_rnd_bits_max,

hm, why the typecasts?  They're unneeded and are omitted everywhere(?)
else in kernel/sysctl.c.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
