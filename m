Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B18826B02B0
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 10:47:25 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id d140so10337710wmd.4
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 07:47:25 -0800 (PST)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id i2si6924086wma.140.2017.01.19.07.47.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 07:47:24 -0800 (PST)
Date: Thu, 19 Jan 2017 15:46:58 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v2] mm: add arch-independent testcases for RODATA
Message-ID: <20170119154658.GD27312@n2100.armlinux.org.uk>
References: <20170119153920.GA20363@pjb1027-Latitude-E5410>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170119153920.GA20363@pjb1027-Latitude-E5410>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jinbum Park <jinb.park7@gmail.com>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, keescook@chromium.org, arjan@linux.intel.com, akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, labbott@redhat.com, kernel-hardening@lists.openwall.com, mark.rutland@arm.com, kernel-janitors@vger.kernel.org

On Fri, Jan 20, 2017 at 12:39:20AM +0900, Jinbum Park wrote:
> diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
> index afcc550..e4f22ce 100644
> --- a/mm/Kconfig.debug
> +++ b/mm/Kconfig.debug
> @@ -90,3 +90,9 @@ config DEBUG_PAGE_REF
>  	  careful when enabling this feature because it adds about 30 KB to the
>  	  kernel code.  However the runtime performance overhead is virtually
>  	  nil until the tracepoints are actually enabled.
> +
> +config DEBUG_RODATA_TEST
> +	bool "Testcase for the marking rodata read-only"
> +	depends on DEBUG_RODATA
> +	---help---
> +	  This option enables a testcase for the setting rodata read-only.
> \ No newline at end of file

It's worth reviewing your own patches before sending them out for
things like this (please ensure that all files are not left without
a newline at the end.)

> diff --git a/mm/rodata_test.c b/mm/rodata_test.c
> new file mode 100644
> index 0000000..fb953c0
> --- /dev/null
> +++ b/mm/rodata_test.c
> @@ -0,0 +1,64 @@
> +/*
> + * rodata_test.c: functional test for mark_rodata_ro function
> + *
> + * (C) Copyright 2008 Intel Corporation
> + * Author: Arjan van de Ven <arjan@linux.intel.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; version 2
> + * of the License.
> + */
> +#include <asm/uaccess.h>
> +#include <asm/sections.h>
> +
> +const int rodata_test_data = 0xC3;
> +EXPORT_SYMBOL_GPL(rodata_test_data);
> +
> +void rodata_test(void)
> +{
> +	unsigned long start, end, rodata_addr;
> +	int zero = 0;
> +
> +	/* prepare test */
> +	rodata_addr = ((unsigned long)&rodata_test_data);
> +
> +	/* test 1: read the value */
> +	/* If this test fails, some previous testrun has clobbered the state */
> +	if (!rodata_test_data) {
> +		pr_err("rodata_test: test 1 fails (start data)\n");
> +		return;
> +	}
> +
> +	/* test 2: write to the variable; this should fault */
> +	/*
> +	 * This must be written in assembly to be able to catch the
> +	 * exception that is supposed to happen in the correct case.
> +	 *
> +	 * So that put_user macro is used to write arch-independent assembly.
> +	 */
> +	if (!put_user(zero, (int *)rodata_addr)) {
> +		pr_err("rodata_test: test data was not read only\n");
> +		return;
> +	}

I don't think this is going to do what you think - at least not on sane
architectures.  put_user() to kernel space is denied, even if the
location is writable to normal accesses within the kernel.

put_user() and get_user() are for accessing user supplied pointers,
which means it has built-in security to prevent userspace passing in
kernel-space pointers and using that as a way to read or modify kernel
space.

I think you want to use probe_kernel_write() here.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
