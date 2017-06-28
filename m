Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B18252802FE
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 17:47:17 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z10so67455695pff.1
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 14:47:17 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id b3si2614835plb.145.2017.06.28.14.47.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 14:47:16 -0700 (PDT)
Date: Wed, 28 Jun 2017 14:43:46 -0700
In-Reply-To: <595331FE.3090700@huawei.com>
References: <1498045437-7675-1-git-send-email-zhongjiang@huawei.com> <20170621164036.4findvvz7jj4cvqo@gmail.com> <595331FE.3090700@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH] futex: avoid undefined behaviour when shift exponent is negative
From: hpa@zytor.com
Message-ID: <568AC6DF-7E6D-4F10-BD41-D43195629C13@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>, Ingo Molnar <mingo@kernel.org>
Cc: akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, minchan@kernel.org, mhocko@suse.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On June 27, 2017 9:35:10 PM PDT, zhong jiang <zhongjiang@huawei=2Ecom> wrot=
e:
>Hi,  Ingo
>
>Thank you for the comment=2E
>On 2017/6/22 0:40, Ingo Molnar wrote:
>> * zhong jiang <zhongjiang@huawei=2Ecom> wrote:
>>
>>> when shift expoment is negative, left shift alway zero=2E therefore,
>we
>>> modify the logic to avoid the warining=2E
>>>
>>> Signed-off-by: zhong jiang <zhongjiang@huawei=2Ecom>
>>> ---
>>>  arch/x86/include/asm/futex=2Eh | 8 ++++++--
>>>  1 file changed, 6 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/arch/x86/include/asm/futex=2Eh
>b/arch/x86/include/asm/futex=2Eh
>>> index b4c1f54=2E=2E2425fca 100644
>>> --- a/arch/x86/include/asm/futex=2Eh
>>> +++ b/arch/x86/include/asm/futex=2Eh
>>> @@ -49,8 +49,12 @@ static inline int futex_atomic_op_inuser(int
>encoded_op, u32 __user *uaddr)
>>>  	int cmparg =3D (encoded_op << 20) >> 20;
>>>  	int oldval =3D 0, ret, tem;
>>> =20
>>> -	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
>>> -		oparg =3D 1 << oparg;
>>> +	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28)) {
>>> +		if (oparg >=3D 0)
>>> +			oparg =3D 1 << oparg;
>>> +		else
>>> +			oparg =3D 0;
>>> +	}
>> Could we avoid all these complications by using an unsigned type?
>I think it is not feasible=2E  a negative shift exponent is likely
>existence and reasonable=2E
>  as the above case,  oparg is a negative is common=2E=20
>
> I think it can be avoided by following change=2E=20
>
>diff --git a/arch/x86/include/asm/futex=2Eh
>b/arch/x86/include/asm/futex=2Eh
>index b4c1f54=2E=2E3205e86 100644
>--- a/arch/x86/include/asm/futex=2Eh
>+++ b/arch/x86/include/asm/futex=2Eh
>@@ -50,7 +50,7 @@ static inline int futex_atomic_op_inuser(int
>encoded_op, u32 __user *uaddr)
>        int oldval =3D 0, ret, tem;
>
>        if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
>-               oparg =3D 1 << oparg;
>+               oparg =3D safe_shift(1, oparg);
>
>        if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
>                return -EFAULT;
>diff --git a/drivers/video/fbdev/core/fbmem=2Ec
>b/drivers/video/fbdev/core/fbmem=2Ec
>index 069fe79=2E=2Eb4edda3 100644
>--- a/drivers/video/fbdev/core/fbmem=2Ec
>+++ b/drivers/video/fbdev/core/fbmem=2Ec
>@@ -190,11 +190,6 @@ char* fb_get_buffer_offset(struct fb_info *info,
>struct fb_pixmap *buf, u32 size
>
> #ifdef CONFIG_LOGO
>
>-static inline unsigned safe_shift(unsigned d, int n)
>-{
>-       return n < 0 ? d >> -n : d << n;
>-}
>-
> static void fb_set_logocmap(struct fb_info *info,
>                                   const struct linux_logo *logo)
> {
>diff --git a/include/linux/kernel=2Eh b/include/linux/kernel=2Eh
>index d043ada=2E=2Ef3b8856 100644
>--- a/include/linux/kernel=2Eh
>+++ b/include/linux/kernel=2Eh
>@@ -841,6 +841,10 @@ static inline void ftrace_dump(enum
>ftrace_dump_mode oops_dump_mode) { }
>  */
> #define clamp_val(val, lo, hi) clamp_t(typeof(val), val, lo, hi)
>
>+static inline unsigned safe_shift(unsigned d, int n)
>+{
>+       return n < 0 ? d >> -n : d << n;
>+}
>
>Thansk
>zhongjiang
>
>> Thanks,
>>
>> 	Ingo
>>
>> =2E
>>

What makes it reasonable?  It is totally ill-defined and doesn't do anythi=
ng useful now?
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
