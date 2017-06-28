Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A06A7280300
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 18:14:37 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 62so10482416wmw.13
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 15:14:37 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id s198si6724653wme.147.2017.06.28.15.14.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 15:14:36 -0700 (PDT)
Date: Thu, 29 Jun 2017 00:13:44 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] futex: avoid undefined behaviour when shift exponent is
 negative
In-Reply-To: <595331FE.3090700@huawei.com>
Message-ID: <alpine.DEB.2.20.1706282353190.1890@nanos>
References: <1498045437-7675-1-git-send-email-zhongjiang@huawei.com> <20170621164036.4findvvz7jj4cvqo@gmail.com> <595331FE.3090700@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Ingo Molnar <mingo@kernel.org>, akpm@linux-foundation.org, mingo@redhat.com, minchan@kernel.org, mhocko@suse.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 28 Jun 2017, zhong jiang wrote:
> On 2017/6/22 0:40, Ingo Molnar wrote:
> > * zhong jiang <zhongjiang@huawei.com> wrote:
> >
> >> when shift expoment is negative, left shift alway zero. therefore, we
> >> modify the logic to avoid the warining.
> >>
> >> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> >> ---
> >>  arch/x86/include/asm/futex.h | 8 ++++++--
> >>  1 file changed, 6 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/arch/x86/include/asm/futex.h b/arch/x86/include/asm/futex.h
> >> index b4c1f54..2425fca 100644
> >> --- a/arch/x86/include/asm/futex.h
> >> +++ b/arch/x86/include/asm/futex.h
> >> @@ -49,8 +49,12 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
> >>  	int cmparg = (encoded_op << 20) >> 20;
> >>  	int oldval = 0, ret, tem;
> >>  
> >> -	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
> >> -		oparg = 1 << oparg;
> >> +	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28)) {
> >> +		if (oparg >= 0)
> >> +			oparg = 1 << oparg;
> >> +		else
> >> +			oparg = 0;
> >> +	}
> > Could we avoid all these complications by using an unsigned type?
>
>   I think it is not feasible.  a negative shift exponent is likely
>   existence and reasonable.

What is reasonable about a negative shift value?

> as the above case, oparg is a negative is common.

That's simply wrong. If oparg is negative and the SHIFT bit is set then the
result is undefined today and there is no way that this can be used at
all.

On x86:

   1 << -1	= 0x80000000
   1 << -2048	= 0x00000001
   1 << -2047	= 0x00000002

Anything using a shift value < 0 or > 31 will get crap as a
result. Rightfully so because it's just undefined.

Yes I know that the insanity of user space is unlimited, but anything
attempting this is so broken that we cannot break it further by making that
shift arg unsigned and actually limit it to 0-31

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
