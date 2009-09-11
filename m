Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6203B6B004D
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 01:52:40 -0400 (EDT)
Date: Thu, 10 Sep 2009 22:52:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Add memory mapped RTC driver for UV
Message-Id: <20090910225242.5c3f8ca1.akpm@linux-foundation.org>
In-Reply-To: <20090911013054.GA6567@sgi.com>
References: <20090911013054.GA6567@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Sep 2009 20:30:54 -0500 Dimitri Sivanich <sivanich@sgi.com> wrote:

> This driver memory maps the UV Hub RTC.
>
> ...
>
> +/**
> + * uv_mmtimer_ioctl - ioctl interface for /dev/uv_mmtimer
> + * @file: file structure for the device
> + * @cmd: command to execute
> + * @arg: optional argument to command
> + *
> + * Executes the command specified by @cmd.  Returns 0 for success, < 0 for
> + * failure.
> + *
> + * Valid commands:
> + *
> + * %MMTIMER_GETOFFSET - Should return the offset (relative to the start
> + * of the page where the registers are mapped) for the counter in question.
> + *
> + * %MMTIMER_GETRES - Returns the resolution of the clock in femto (10^-15)
> + * seconds
> + *
> + * %MMTIMER_GETFREQ - Copies the frequency of the clock in Hz to the address
> + * specified by @arg
> + *
> + * %MMTIMER_GETBITS - Returns the number of bits in the clock's counter
> + *
> + * %MMTIMER_MMAPAVAIL - Returns 1 if registers can be mmap'd into userspace
> + *
> + * %MMTIMER_GETCOUNTER - Gets the current value in the counter and places it
> + * in the address specified by @arg.

Are these % thingies part of kerneldoc?

> + */
> +static long uv_mmtimer_ioctl(struct file *file, unsigned int cmd,
> +						unsigned long arg)
> +{
> +	int ret = 0;
> +
> +	switch (cmd) {
> +	case MMTIMER_GETOFFSET:	/* offset of the counter */
> +		/*
> +		 * UV RTC register is on it's own page

"its" ;)

> +		 */
> +		if (PAGE_SIZE <= (1 << 16))
> +			ret = ((UV_LOCAL_MMR_BASE | UVH_RTC) & (PAGE_SIZE-1))
> +				/ 8;
> +		else
> +			ret = -ENOSYS;
> +		break;
> +
> +	case MMTIMER_GETRES: /* resolution of the clock in 10^-15 s */
> +		if (copy_to_user((unsigned long __user *)arg,
> +				&uv_mmtimer_femtoperiod, sizeof(unsigned long)))
> +			ret = -EFAULT;
> +		break;
> +
> +	case MMTIMER_GETFREQ: /* frequency in Hz */
> +		if (copy_to_user((unsigned long __user *)arg,
> +				&sn_rtc_cycles_per_second,
> +				sizeof(unsigned long)))
> +			ret = -EFAULT;
> +		break;
> +
> +	case MMTIMER_GETBITS: /* number of bits in the clock */
> +		ret = hweight64(UVH_RTC_REAL_TIME_CLOCK_MASK);
> +		break;
> +
> +	case MMTIMER_MMAPAVAIL: /* can we mmap the clock into userspace? */
> +		ret = (PAGE_SIZE <= (1 << 16)) ? 1 : 0;
> +		break;
> +
> +	case MMTIMER_GETCOUNTER:
> +		if (copy_to_user((unsigned long __user *)arg,
> +				(unsigned long *)uv_local_mmr_address(UVH_RTC),
> +				sizeof(unsigned long)))
> +			ret = -EFAULT;
> +		break;
> +	default:
> +		ret = -ENOTTY;
> +		break;
> +	}
> +	return ret;
> +}
> +
> +/**
> + * uv_mmtimer_mmap - maps the clock's registers into userspace
> + * @file: file structure for the device
> + * @vma: VMA to map the registers into
> + *
> + * Calls remap_pfn_range() to map the clock's registers into
> + * the calling process' address space.
> + */
> +static int uv_mmtimer_mmap(struct file *file, struct vm_area_struct *vma)
> +{
> +	unsigned long uv_mmtimer_addr;
> +
> +	if (vma->vm_end - vma->vm_start != PAGE_SIZE)
> +		return -EINVAL;
> +
> +	if (vma->vm_flags & VM_WRITE)
> +		return -EPERM;
> +
> +	if (PAGE_SIZE > (1 << 16))
> +		return -ENOSYS;
> +
> +	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
> +
> +	uv_mmtimer_addr = UV_LOCAL_MMR_BASE | UVH_RTC;
> +	uv_mmtimer_addr &= ~(PAGE_SIZE - 1);
> +	uv_mmtimer_addr &= 0xfffffffffffffffUL;
> +
> +	if (remap_pfn_range(vma, vma->vm_start, uv_mmtimer_addr >> PAGE_SHIFT,
> +					PAGE_SIZE, vma->vm_page_prot)) {
> +		printk(KERN_ERR "remap_pfn_range failed in uv_mmtimer_mmap\n");
> +		return -EAGAIN;
> +	}
> +
> +	return 0;
> +}

Methinks we should be setting vma->vm_flags's VM_IO here and perhaps
also VM_RESERVED.

> +static struct miscdevice uv_mmtimer_miscdev = {
> +	MISC_DYNAMIC_MINOR,
> +	UV_MMTIMER_NAME,
> +	&uv_mmtimer_fops
> +};
> +
> +
> +/**
> + * uv_mmtimer_init - device initialization routine
> + *
> + * Does initial setup for the uv_mmtimer device.
> + */
> +static int __init uv_mmtimer_init(void)
> +{
> +	if (!is_uv_system())
> +		return 0;

This will leave the module loaded but inactive.  Would it make more
sense to return an error code in this case so that a) the user
discovers that he wasted his time and b) the module will get booted out
again?

> +	/*
> +	 * Sanity check the cycles/sec variable
> +	 */
> +	if (sn_rtc_cycles_per_second < 100000) {
> +		printk(KERN_ERR "%s: unable to determine clock frequency\n",
> +		       UV_MMTIMER_NAME);
> +		return -1;
> +	}
> +
> +	uv_mmtimer_femtoperiod = ((unsigned long)1E15 +
> +				sn_rtc_cycles_per_second / 2) /
> +				sn_rtc_cycles_per_second;
> +
> +	if (misc_register(&uv_mmtimer_miscdev)) {
> +		printk(KERN_ERR "%s: failed to register device\n",
> +		       UV_MMTIMER_NAME);
> +		return -1;
> +	}
> +
> +	printk(KERN_INFO "%s: v%s, %ld MHz\n", UV_MMTIMER_DESC,
> +		UV_MMTIMER_VERSION,
> +		sn_rtc_cycles_per_second/(unsigned long)1E6);
> +
> +	return 0;
> +}
> +
> +module_init(uv_mmtimer_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
