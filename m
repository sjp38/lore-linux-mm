Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id A5631828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 13:27:54 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id b14so184095354wmb.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 10:27:54 -0800 (PST)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [146.101.78.143])
        by mx.google.com with ESMTPS id p3si176249676wjy.59.2016.01.08.10.27.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 08 Jan 2016 10:27:53 -0800 (PST)
Date: Fri, 8 Jan 2016 18:27:44 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] arm64: fix add kasan bug
Message-ID: <20160108182744.GQ16432@e104818-lin.cambridge.arm.com>
References: <1451556549-8962-1-git-send-email-zhongjiang@huawei.com>
 <20160105101017.GA14545@localhost.localdomain>
 <CAPAsAGwHyVDvaoNjVxZsjtVczWh7-+OQOxpFBLS+e961DBAzeQ@mail.gmail.com>
MIME-Version: 1.0
In-Reply-To: <CAPAsAGwHyVDvaoNjVxZsjtVczWh7-+OQOxpFBLS+e961DBAzeQ@mail.gmail.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: zhongjiang <zhongjiang@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "long.wanglong@huawei.com" <long.wanglong@huawei.com>, Will Deacon <will.deacon@arm.com>

On Wed, Jan 06, 2016 at 12:17:17AM +0300, Andrey Ryabinin wrote:
> 2016-01-05 13:10 GMT+03:00 Catalin Marinas <catalin.marinas@arm.com>:
> > On Thu, Dec 31, 2015 at 10:09:09AM +0000, zhongjiang wrote:
> >> From: zhong jiang <zhongjiang@huawei.com>
> >>
> >> In general, each process have 16kb stack space to use, but
> >> stack need extra space to store red_zone when kasan enable.
> >> the patch fix above question.
> >>
> >> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> >> ---
> >>  arch/arm64/include/asm/thread_info.h | 15 +++++++++++++--
> >>  1 file changed, 13 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/arch/arm64/include/asm/thread_info.h b/arch/arm64/include=
/asm/thread_info.h
> >> index 90c7ff2..45b5a7e 100644
> >> --- a/arch/arm64/include/asm/thread_info.h
> >> +++ b/arch/arm64/include/asm/thread_info.h
> > [...]
> >> +#ifdef CONFIG_KASAN
> >> +#define THREAD_SIZE          32768
> >> +#else
> >>  #define THREAD_SIZE          16384
> >> +#endif
> >
> > I'm not really keen on increasing the stack size to 32KB when KASan is
> > enabled (that's 8 4K pages). Have you actually seen a real problem with
> > the default size?
>
> > How large is the red_zone?
>
> Typical stack frame layout looks like this:
>     | 32-byte redzone | variable-1| padding-redzone to the next
> 32-byte boundary| variable-2|padding |.... | 32-byte redzone|
>
> AFAIK gcc creates redzones  only if it can't prove that all accesses
> to variable are valid (e.g. reference to variable passed to external
> function).
> Besides redzones, stack could be increased due to additional spilling.
> Although arm64 should be less affected by this since it has more
> registers than x86_64.
> On x86_64 I've seen few bad cases where stack frame of a single
> function was bloated up to 6K.

I think on arm64 we shouldn't be affected that badly. I did some tests
(well, running LTP and checking the maximum stack usage). Without KASan,
I get about 5-6KB usage maximum. Once KASan is enabled, the maximum
stack utilisation is around 8KB.

I also changed FRAME_WARN to be 2048 with KASAN but it didn't trigger
any warning on arm64 (defconfig + KASAN).

Of course, there is a risk of IRQ followed by softirq which is what led
us to increase the stack size to 16KB. However, in 4.5 we'll have
separate IRQ stacks while still keeping THREAD_SIZE to 16KB. In 4.6, the
plan is to try to reduce default THREAD_SIZE to 8KB.

So it's only in 4.6 (if we go for 8KB THREAD_SIZE) that we should
increase the stack when KASAN is enabled (though to 16KB rather than
32KB).

I don't think 4.5 needs any adjustments and for 4.4 I would only do this
*if* there is actually a regression. However, I haven't seen any such
report yet, in which case I NAK this patch (at least until further
information emerges).

--
Catalin
IMPORTANT NOTICE: The contents of this email and any attachments are confid=
ential and may also be privileged. If you are not the intended recipient, p=
lease notify the sender immediately and do not disclose the contents to any=
 other person, use it for any purpose, or store or copy the information in =
any medium. Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
