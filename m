Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id BAB4B82F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 16:06:33 -0500 (EST)
Received: by pasz6 with SMTP id z6so137728592pas.2
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 13:06:33 -0800 (PST)
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com. [209.85.220.54])
        by mx.google.com with ESMTPS id pb9si2516894pbc.130.2015.11.06.13.06.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 13:06:32 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so109302813pac.3
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 13:06:32 -0800 (PST)
From: Kevin Hilman <khilman@kernel.org>
Subject: Re: [PATCH] arm: Use kernel mm when updating section permissions
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
	<CAGXu5j+U-Q2R1Hw4qSPpFUKz3xyYrASGc5buMJTSy0K-3mWHBA@mail.gmail.com>
Date: Fri, 06 Nov 2015 13:06:30 -0800
In-Reply-To: <CAGXu5j+U-Q2R1Hw4qSPpFUKz3xyYrASGc5buMJTSy0K-3mWHBA@mail.gmail.com>
	(Kees Cook's message of "Fri, 6 Nov 2015 12:28:58 -0800")
Message-ID: <7h8u6ahm7d.fsf@deeprootsystems.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: info@kernelci.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Laura Abbott <labbott@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Tyler Baker <tyler.baker@linaro.org>

Kees Cook <keescook@chromium.org> writes:

> On Fri, Nov 6, 2015 at 12:11 PM, Kevin Hilman <khilman@kernel.org> wrote:
>> On Fri, Nov 6, 2015 at 11:12 AM, Kees Cook <keescook@chromium.org> wrote:
>>
>> [...]
>>
>>> Hi Kevin and Kernel CI folks,
>>>
>>> Could lkdtm get added to the kernel-CI workflows? Extracting and
>>> validating Oops details when poking lkdtm would be extremely valuable
>>> for these cases. :)
>>
>> Yeah, we can add that.
>>
>> What arches should we expect this to be working on?  For starters
>
> This is a great question. ;) They're a mix of CONFIG and hardware
> feature specific, so probably they should be run on all architectures
> and we can figure out what's missing in each case.
>
> Everything built with CONFIG_DEBUG_RODATA should pass these:
>
> WRITE_RO
> WRITE_KERN
> EXEC_DATA
> EXEC_STACK
> EXEC_KMALLOC
> EXEC_VMALLOC
>
> But architectures without CONFIG_DEBUG_RODATA should be shamed. ;)
>
> Passing EXEC_USERSPACE requires SMEP on x86, and PXN on arm64.
> Passing ACCESS_USERSPACE rquires SMAP on x86, and PAN on arm64.
>
> The recent PAN emulation CONFIG_CPU_SW_DOMAIN_PAN on non-LPAE arm
> should cover ACCESS_USERSPACE too, and maybe EXEC_USERSPACE, but I
> haven't taken a close look.

A quick test on arm32 and both ACCESS_ and EXEC_USERSPACE tests pass
(meaning they trigger the WARNs).

> It might be useful, frankly, to test everything in lkdtm.

So I gave this a quick spin on an ARM board (qcom-apq8064-ifc6410)
using a dumb script[1] (for now avoiding the tests that cause a lockup
so I can test multiple features without a reboot.)  Seems like most of
them are producing a failure.  

However, this got me to thinking that one should probably write a
kselftest for this feature, and catch quite a few issues with the ones
that don't cause a hard lockup.  One would just need to be a bit smarter
than my script and do something to trap SIG* (or the parent catching
SIGCHLD) in order to be able to help determine failure, then grab the
dmesg and log it.

Having these test integrated into kselftest, and maintained along with
the the kernel features would be *way* better than trying to maintain a
set of tests in kernel CI for this feature, since right now we're
working just building/running all the selftests automatically.

What do you think about coming up with a kselftest for this stuff?  At
least the non-lockup stuff?

I'm not volunteering to write up the kselftest, but I will guarantee
that it get run on a broad range of boards once it exists. :)

Kevin

[1]
#!/bin/sh

crash_test_dummy() {
  echo $1> /sys/kernel/debug/provoke-crash/DIRECT
}

# Find all the tests that don't lockup
TESTS=$(cat /sys/kernel/debug/provoke-crash/DIRECT |grep -v types| grep -v LOCK |grep -v PANIC)

for test in $TESTS; do
  echo "Performing test: $test"
  crash_test_dummy $test &
  sleep 1
done

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
