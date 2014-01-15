Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f53.google.com (mail-qe0-f53.google.com [209.85.128.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9DFBF6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 22:46:36 -0500 (EST)
Received: by mail-qe0-f53.google.com with SMTP id t7so580940qeb.12
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 19:46:36 -0800 (PST)
Received: from relais.videotron.ca (relais.videotron.ca. [24.201.245.36])
        by mx.google.com with ESMTP id ko6si3474464qeb.9.2014.01.14.19.46.35
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 19:46:35 -0800 (PST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN; CHARSET=US-ASCII
Received: from yoda.home ([66.130.143.177]) by VL-VM-MR003.ip.videotron.ca
 (Oracle Communications Messaging Exchange Server 7u4-22.01 64bit (built Apr 21
 2011)) with ESMTP id <0MZF00KZFBTN1W40@VL-VM-MR003.ip.videotron.ca> for
 linux-mm@kvack.org; Tue, 14 Jan 2014 22:46:35 -0500 (EST)
Date: Tue, 14 Jan 2014 22:46:34 -0500 (EST)
From: Nicolas Pitre <nico@fluxnic.net>
Subject: Re: [PATCH] mm: nobootmem: avoid type warning about alignment value
In-reply-to: <20140112105958.GA9791@n2100.arm.linux.org.uk>
Message-id: <alpine.LFD.2.10.1401142238110.28907@knanqh.ubzr>
References: <1385249326-9089-1-git-send-email-santosh.shilimkar@ti.com>
 <529217C7.6030304@cogentembedded.com> <52935762.1080409@ti.com>
 <20131209165044.cf7de2edb8f4205d5ac02ab0@linux-foundation.org>
 <20131210005454.GX4360@n2100.arm.linux.org.uk> <52A66826.7060204@ti.com>
 <20140112105958.GA9791@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Santosh Shilimkar <santosh.shilimkar@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, linux-arm-kernel@lists.infradead.org

On Sun, 12 Jan 2014, Russell King - ARM Linux wrote:

> This patch makes their types match exactly with x86's definitions of
> the same, which is the basic problem: on ARM, they all took "int" values
> and returned "int"s, which leads to min() in nobootmem.c complaining.
> 
>  arch/arm/include/asm/bitops.h | 54 +++++++++++++++++++++++++++++++++++--------
>  1 file changed, 44 insertions(+), 10 deletions(-)

For the record:

Acked-by: Nicolas Pitre <nico@linaro.org>

The reason why macros were used at the time this was originally written 
is because gcc used to have issues forwarding the constant nature of a 
variable down multiple levels of inline functions and 
__builtin_constant_p() always returned false.  But that was quite a long 
time ago.


> diff --git a/arch/arm/include/asm/bitops.h b/arch/arm/include/asm/bitops.h
> index e691ec91e4d3..b2e298a90d76 100644
> --- a/arch/arm/include/asm/bitops.h
> +++ b/arch/arm/include/asm/bitops.h
> @@ -254,25 +254,59 @@ static inline int constant_fls(int x)
>  }
>  
>  /*
> - * On ARMv5 and above those functions can be implemented around
> - * the clz instruction for much better code efficiency.
> + * On ARMv5 and above those functions can be implemented around the
> + * clz instruction for much better code efficiency.  __clz returns
> + * the number of leading zeros, zero input will return 32, and
> + * 0x80000000 will return 0.
>   */
> +static inline unsigned int __clz(unsigned int x)
> +{
> +	unsigned int ret;
> +
> +	asm("clz\t%0, %1" : "=r" (ret) : "r" (x));
>  
> +	return ret;
> +}
> +
> +/*
> + * fls() returns zero if the input is zero, otherwise returns the bit
> + * position of the last set bit, where the LSB is 1 and MSB is 32.
> + */
>  static inline int fls(int x)
>  {
> -	int ret;
> -
>  	if (__builtin_constant_p(x))
>  	       return constant_fls(x);
>  
> -	asm("clz\t%0, %1" : "=r" (ret) : "r" (x));
> -       	ret = 32 - ret;
> -	return ret;
> +	return 32 - __clz(x);
> +}
> +
> +/*
> + * __fls() returns the bit position of the last bit set, where the
> + * LSB is 0 and MSB is 31.  Zero input is undefined.
> + */
> +static inline unsigned long __fls(unsigned long x)
> +{
> +	return fls(x) - 1;
> +}
> +
> +/*
> + * ffs() returns zero if the input was zero, otherwise returns the bit
> + * position of the first set bit, where the LSB is 1 and MSB is 32.
> + */
> +static inline int ffs(int x)
> +{
> +	return fls(x & -x);
> +}
> +
> +/*
> + * __ffs() returns the bit position of the first bit set, where the
> + * LSB is 0 and MSB is 31.  Zero input is undefined.
> + */
> +static inline unsigned long __ffs(unsigned long x)
> +{
> +	return ffs(x) - 1;
>  }
>  
> -#define __fls(x) (fls(x) - 1)
> -#define ffs(x) ({ unsigned long __t = (x); fls(__t & -__t); })
> -#define __ffs(x) (ffs(x) - 1)
>  #define ffz(x) __ffs( ~(x) )
>  
>  #endif
> 
> 
> -- 
> FTTC broadband for 0.8mile line: 5.8Mbps down 500kbps up.  Estimation
> in database were 13.1 to 19Mbit for a good line, about 7.5+ for a bad.
> Estimate before purchase was "up to 13.2Mbit".
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
