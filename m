Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE4582F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 15:29:00 -0500 (EST)
Received: by igpw7 with SMTP id w7so41228717igp.1
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 12:29:00 -0800 (PST)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id r134si2573686ior.36.2015.11.06.12.28.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 12:28:59 -0800 (PST)
Received: by igpw7 with SMTP id w7so45876678igp.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 12:28:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAMAWPa9XvdS+dF78c7Fgs4ekRy7wVnfFT=0A5NLpu0UYaqV7fA@mail.gmail.com>
References: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
	<20151105094615.GP8644@n2100.arm.linux.org.uk>
	<563B81DA.2080409@redhat.com>
	<20151105162719.GQ8644@n2100.arm.linux.org.uk>
	<563BFCC4.8050705@redhat.com>
	<CAGXu5jLS8GPxmMQwd9qw+w+fkMqU-GYyME5WUuKZZ4qTesVzCQ@mail.gmail.com>
	<563CF510.9080506@redhat.com>
	<CAGXu5jKLgL0Kt5xCWv-3ZUX94m1DNXLqsEDQKHoq7T=m6P7tvQ@mail.gmail.com>
	<CAGXu5j+Jeg-Cwc7Tr8UeY9vkJLudw07+b=m0h-d9GuSyKiO4QA@mail.gmail.com>
	<CAMAWPa9XvdS+dF78c7Fgs4ekRy7wVnfFT=0A5NLpu0UYaqV7fA@mail.gmail.com>
Date: Fri, 6 Nov 2015 12:28:58 -0800
Message-ID: <CAGXu5j+U-Q2R1Hw4qSPpFUKz3xyYrASGc5buMJTSy0K-3mWHBA@mail.gmail.com>
Subject: Re: [PATCH] arm: Use kernel mm when updating section permissions
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Hilman <khilman@kernel.org>
Cc: info@kernelci.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Laura Abbott <labbott@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Tyler Baker <tyler.baker@linaro.org>

On Fri, Nov 6, 2015 at 12:11 PM, Kevin Hilman <khilman@kernel.org> wrote:
> On Fri, Nov 6, 2015 at 11:12 AM, Kees Cook <keescook@chromium.org> wrote:
>
> [...]
>
>> Hi Kevin and Kernel CI folks,
>>
>> Could lkdtm get added to the kernel-CI workflows? Extracting and
>> validating Oops details when poking lkdtm would be extremely valuable
>> for these cases. :)
>
> Yeah, we can add that.
>
> What arches should we expect this to be working on?  For starters

This is a great question. ;) They're a mix of CONFIG and hardware
feature specific, so probably they should be run on all architectures
and we can figure out what's missing in each case.

Everything built with CONFIG_DEBUG_RODATA should pass these:

WRITE_RO
WRITE_KERN
EXEC_DATA
EXEC_STACK
EXEC_KMALLOC
EXEC_VMALLOC

But architectures without CONFIG_DEBUG_RODATA should be shamed. ;)

Passing EXEC_USERSPACE requires SMEP on x86, and PXN on arm64.
Passing ACCESS_USERSPACE rquires SMAP on x86, and PAN on arm64.

The recent PAN emulation CONFIG_CPU_SW_DOMAIN_PAN on non-LPAE arm
should cover ACCESS_USERSPACE too, and maybe EXEC_USERSPACE, but I
haven't taken a close look.

It might be useful, frankly, to test everything in lkdtm.

> we'll get builds going with CONFIG_LKDTM=y, and then start looking at
> adding the tests on arches that should work.
>
> Thes will be an interesting failure modes to catch because a kernel
> panic is actually a PASS, and a failure to panic is a FAIL.  :)

Yup! :) And extracting the Oops message can become important too. As
recently shown with CONFIG_CPU_SW_DOMAIN_PAN, the test was wrong, and
the Oops showed it:
http://www.gossamer-threads.com/lists/linux/kernel/2293320

Thanks for looking into it!

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
