Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id F381E6B025F
	for <linux-mm@kvack.org>; Fri, 27 May 2016 13:46:52 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fg1so165404866pad.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 10:46:52 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r64si15620872pfj.240.2016.05.27.10.46.51
        for <linux-mm@kvack.org>;
        Fri, 27 May 2016 10:46:51 -0700 (PDT)
Date: Fri, 27 May 2016 18:46:36 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] arm64: kasan: instrument user memory access API
Message-ID: <20160527174635.GL24469@leverpostej>
References: <1464288231-11304-1-git-send-email-yang.shi@linaro.org>
 <57482930.6020608@virtuozzo.com>
 <cea39367-65b6-62df-7e4c-57ae1ce36dcc@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cea39367-65b6-62df-7e4c-57ae1ce36dcc@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, will.deacon@arm.com, catalin.marinas@arm.com, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Fri, May 27, 2016 at 09:34:03AM -0700, Shi, Yang wrote:
> On 5/27/2016 4:02 AM, Andrey Ryabinin wrote:
> >
> >
> >On 05/26/2016 09:43 PM, Yang Shi wrote:
> >>The upstream commit 1771c6e1a567ea0ba2cccc0a4ffe68a1419fd8ef
> >>("x86/kasan: instrument user memory access API") added KASAN instrument to
> >>x86 user memory access API, so added such instrument to ARM64 too.
> >>
> >>Tested by test_kasan module.
> >>
> >>Signed-off-by: Yang Shi <yang.shi@linaro.org>
> >>---
> >> arch/arm64/include/asm/uaccess.h | 18 ++++++++++++++++--
> >> 1 file changed, 16 insertions(+), 2 deletions(-)
> >
> >Please, cover __copy_from_user() and __copy_to_user() too.
> >Unlike x86, your patch doesn't instrument these two.

Argh, I missed those when reviewing. My bad.

> I should elaborated this in my review. Yes, I did think about it,
> but unlike x86, __copy_to/from_user are implemented by asm code on
> ARM64. If I add kasan_check_read/write into them, I have to move the
> registers around to prepare the parameters for kasan calls, then
> restore them after the call, for example the below code for
> __copy_to_user:
> 
>         mov     x9, x0
>         mov     x10, x1
>         mov     x11, x2
>         mov     x0, x10
>         mov     x1, x11
>         bl      kasan_check_read
>         mov     x0, x9
>         mov     x1, x10

There's no need to alter the assembly.

Rename the functions (e.g. have __arch_raw_copy_from_user), and add
static inline wrappers in uaccess.h that do the kasan calls before
calling the assembly functions.

That gives the compiler the freedom to do the right thing, and avoids
horrible ifdeffery in the assembly code.

> So, I'm wondering if it is worth or not since __copy_to/from_user
> are just called at a couple of places, i.e. sctp, a couple of
> drivers, etc and not used too much.

[mark@leverpostej:~/src/linux]% git grep -w __copy_to_user -- ^arch | wc -l
63
[mark@leverpostej:~/src/linux]% git grep -w __copy_from_user -- ^arch | wc -l
47

That's a reasonable number of callsites.

If we're going to bother adding this, it should be complete. So please
do update __copy_from_user and __copy_to_user.

> Actually, I think some of them
> could be replaced by __copy_to/from_user_inatomic.

Given the number of existing callers outside of arch code, I think we'll
get far more traction reworking the arm64 parts for now.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
