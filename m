Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CFE3F6B0268
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 15:22:57 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id 5so6993581wmk.8
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 12:22:57 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 189si8019638wmr.24.2017.11.20.12.22.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 12:22:56 -0800 (PST)
Date: Mon, 20 Nov 2017 21:22:53 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 12/30] x86, kaiser: map GDT into user page tables
In-Reply-To: <20171110193125.EBF58596@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1711202115190.2348@nanos>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193125.EBF58596@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Fri, 10 Nov 2017, Dave Hansen wrote:
>  	__set_fixmap(get_cpu_gdt_ro_index(cpu), get_cpu_gdt_paddr(cpu), prot);
> +
> +	/* CPU 0's mapping is done in kaiser_init() */
> +	if (cpu) {
> +		int ret;
> +
> +		ret = kaiser_add_mapping((unsigned long) get_cpu_gdt_ro(cpu),
> +					 PAGE_SIZE, __PAGE_KERNEL_RO);
> +		/*
> +		 * We do not have a good way to fail CPU bringup.
> +		 * Just WARN about it and hope we boot far enough
> +		 * to get a good log out.
> +		 */

The GDT fixmap can be set up before the CPU is started. There is no reason
to do that in cpu_init().

> +
> +	/*
> +	 * We could theoretically do this in setup_fixmap_gdt().
> +	 * But, we would need to rewrite the above page table
> +	 * allocation code to use the bootmem allocator.  The
> +	 * buddy allocator is not available at the time that we
> +	 * call setup_fixmap_gdt() for CPU 0.
> +	 */
> +	kaiser_add_user_map_early(get_cpu_gdt_ro(0), PAGE_SIZE,
> +				  __PAGE_KERNEL_RO | _PAGE_GLOBAL);

This one is needs to stay.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
