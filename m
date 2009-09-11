Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A26536B004D
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 02:01:17 -0400 (EDT)
Received: by yxe32 with SMTP id 32so1011672yxe.23
        for <linux-mm@kvack.org>; Thu, 10 Sep 2009 23:01:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090910225242.5c3f8ca1.akpm@linux-foundation.org>
References: <20090911013054.GA6567@sgi.com>
	 <20090910225242.5c3f8ca1.akpm@linux-foundation.org>
Date: Fri, 11 Sep 2009 15:01:16 +0900
Message-ID: <28c262360909102301v5d1c32b9lb3290a6a31f49d17@mail.gmail.com>
Subject: Re: [PATCH] Add memory mapped RTC driver for UV
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 11, 2009 at 2:52 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 10 Sep 2009 20:30:54 -0500 Dimitri Sivanich <sivanich@sgi.com> wr=
ote:
>
>> This driver memory maps the UV Hub RTC.
>>
>> ...
>>
>> +/**
>> + * uv_mmtimer_ioctl - ioctl interface for /dev/uv_mmtimer
>> + * @file: file structure for the device
>> + * @cmd: command to execute
>> + * @arg: optional argument to command
>> + *
>> + * Executes the command specified by @cmd. =A0Returns 0 for success, < =
0 for
>> + * failure.
>> + *
>> + * Valid commands:
>> + *
>> + * %MMTIMER_GETOFFSET - Should return the offset (relative to the start
>> + * of the page where the registers are mapped) for the counter in quest=
ion.
>> + *
>> + * %MMTIMER_GETRES - Returns the resolution of the clock in femto (10^-=
15)
>> + * seconds
>> + *
>> + * %MMTIMER_GETFREQ - Copies the frequency of the clock in Hz to the ad=
dress
>> + * specified by @arg
>> + *
>> + * %MMTIMER_GETBITS - Returns the number of bits in the clock's counter
>> + *
>> + * %MMTIMER_MMAPAVAIL - Returns 1 if registers can be mmap'd into users=
pace
>> + *
>> + * %MMTIMER_GETCOUNTER - Gets the current value in the counter and plac=
es it
>> + * in the address specified by @arg.
>
> Are these % thingies part of kerneldoc?
>
>> + */
>> +static long uv_mmtimer_ioctl(struct file *file, unsigned int cmd,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 unsigned long arg)
>> +{
>> + =A0 =A0 int ret =3D 0;
>> +
>> + =A0 =A0 switch (cmd) {
>> + =A0 =A0 case MMTIMER_GETOFFSET: /* offset of the counter */
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* UV RTC register is on it's own page
>
> "its" ;)
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (PAGE_SIZE <=3D (1 << 16))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D ((UV_LOCAL_MMR_BASE | =
UVH_RTC) & (PAGE_SIZE-1))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 / 8;
>> + =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOSYS;
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +
>> + =A0 =A0 case MMTIMER_GETRES: /* resolution of the clock in 10^-15 s */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (copy_to_user((unsigned long __user *)arg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &uv_mmtimer_fe=
mtoperiod, sizeof(unsigned long)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EFAULT;
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +
>> + =A0 =A0 case MMTIMER_GETFREQ: /* frequency in Hz */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (copy_to_user((unsigned long __user *)arg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &sn_rtc_cycles=
_per_second,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof(unsigne=
d long)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EFAULT;
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +
>> + =A0 =A0 case MMTIMER_GETBITS: /* number of bits in the clock */
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D hweight64(UVH_RTC_REAL_TIME_CLOCK_MASK=
);
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +
>> + =A0 =A0 case MMTIMER_MMAPAVAIL: /* can we mmap the clock into userspac=
e? */
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D (PAGE_SIZE <=3D (1 << 16)) ? 1 : 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +
>> + =A0 =A0 case MMTIMER_GETCOUNTER:
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (copy_to_user((unsigned long __user *)arg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsigned long=
 *)uv_local_mmr_address(UVH_RTC),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof(unsigne=
d long)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EFAULT;
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 default:
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOTTY;
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 }
>> + =A0 =A0 return ret;
>> +}
>> +
>> +/**
>> + * uv_mmtimer_mmap - maps the clock's registers into userspace
>> + * @file: file structure for the device
>> + * @vma: VMA to map the registers into
>> + *
>> + * Calls remap_pfn_range() to map the clock's registers into
>> + * the calling process' address space.
>> + */
>> +static int uv_mmtimer_mmap(struct file *file, struct vm_area_struct *vm=
a)
>> +{
>> + =A0 =A0 unsigned long uv_mmtimer_addr;
>> +
>> + =A0 =A0 if (vma->vm_end - vma->vm_start !=3D PAGE_SIZE)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>> +
>> + =A0 =A0 if (vma->vm_flags & VM_WRITE)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
>> +
>> + =A0 =A0 if (PAGE_SIZE > (1 << 16))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -ENOSYS;
>> +
>> + =A0 =A0 vma->vm_page_prot =3D pgprot_noncached(vma->vm_page_prot);
>> +
>> + =A0 =A0 uv_mmtimer_addr =3D UV_LOCAL_MMR_BASE | UVH_RTC;
>> + =A0 =A0 uv_mmtimer_addr &=3D ~(PAGE_SIZE - 1);
>> + =A0 =A0 uv_mmtimer_addr &=3D 0xfffffffffffffffUL;
>> +
>> + =A0 =A0 if (remap_pfn_range(vma, vma->vm_start, uv_mmtimer_addr >> PAG=
E_SHIFT,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 PAGE_SIZE, vma->vm_page_prot)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "remap_pfn_range failed in uv_=
mmtimer_mmap\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EAGAIN;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 return 0;
>> +}
>
> Methinks we should be setting vma->vm_flags's VM_IO here and perhaps
> also VM_RESERVED.

remap_pfn_range already does it. :)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
