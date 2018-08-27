Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 88C966B42B9
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 18:16:44 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v9-v6so323550pff.4
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 15:16:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d36-v6si386286pla.446.2018.08.27.15.16.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 15:16:43 -0700 (PDT)
Date: Mon, 27 Aug 2018 15:16:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2] kmemleak: Add option to print warnings to dmesg
Message-Id: <20180827151641.59bdca4e1ea2e532b10cd9fd@linux-foundation.org>
In-Reply-To: <20180827083821.7706-1-vincent.whitchurch@axis.com>
References: <20180827083821.7706-1-vincent.whitchurch@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vincent Whitchurch <vincent.whitchurch@axis.com>
Cc: catalin.marinas@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vincent Whitchurch <rabinv@axis.com>

On Mon, 27 Aug 2018 10:38:21 +0200 Vincent Whitchurch <vincent.whitchurch@axis.com> wrote:

> Currently, kmemleak only prints the number of suspected leaks to dmesg
> but requires the user to read a debugfs file to get the actual stack
> traces of the objects' allocation points.  Add an option to print the
> full object information to dmesg too.  This allows easier integration of
> kmemleak into automated test systems since those kind of systems
> presumably already save kernel logs.

"presumably" is a bit rubbery.  Are you sure this change is sufficienty
useful to justify including it?  Do you have use-cases for it?

> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -593,6 +593,15 @@ config DEBUG_KMEMLEAK_DEFAULT_OFF
>  	  Say Y here to disable kmemleak by default. It can then be enabled
>  	  on the command line via kmemleak=on.
>  
> +config DEBUG_KMEMLEAK_WARN
> +	bool "Print kmemleak object warnings to log buffer"
> +	depends on DEBUG_KMEMLEAK
> +	help
> +	  Say Y here to make kmemleak print information about unreferenced
> +	  objects (including stacktraces) as warnings to the kernel log buffer.
> +	  Otherwise this information is only available by reading the kmemleak
> +	  debugfs file.

Why add the config option?  Why not simply make the change for all
configs?

>  config DEBUG_STACK_USAGE
>  	bool "Stack utilization instrumentation"
>  	depends on DEBUG_KERNEL && !IA64
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 9a085d525bbc..22662715a3dc 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -181,6 +181,7 @@ struct kmemleak_object {
>  /* flag set to not scan the object */
>  #define OBJECT_NO_SCAN		(1 << 2)
>  
> +#define HEX_PREFIX		"    "
>  /* number of bytes to print per line; must be 16 or 32 */
>  #define HEX_ROW_SIZE		16
>  /* number of bytes to print at a time (1, 2, 4, 8) */
> @@ -299,6 +300,25 @@ static void kmemleak_disable(void);
>  	kmemleak_disable();		\
>  } while (0)
>  
> +#define warn_or_seq_printf(seq, fmt, ...)	do {	\
> +	if (seq)					\
> +		seq_printf(seq, fmt, ##__VA_ARGS__);	\
> +	else						\
> +		pr_warn(fmt, ##__VA_ARGS__);		\
> +} while (0)
> +
> +static void warn_or_seq_hex_dump(struct seq_file *seq, int prefix_type,
> +				 int rowsize, int groupsize, const void *buf,
> +				 size_t len, bool ascii)
> +{
> +	if (seq)
> +		seq_hex_dump(seq, HEX_PREFIX, prefix_type, rowsize, groupsize,
> +			     buf, len, ascii);
> +	else
> +		print_hex_dump(KERN_WARNING, pr_fmt(HEX_PREFIX), prefix_type,
> +			       rowsize, groupsize, buf, len, ascii);
> +}

This will print to the logs OR to the debugfs file, won't it?

If so, should we continue to print to the debugfs file when we're also
printing to the log?  That sounds potentially useful and will avoid
breaking things which expect the debugfs file to still be working.

>
> ...
>
