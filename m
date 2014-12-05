Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0A56B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 12:53:03 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id gm9so1070589lab.26
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 09:53:02 -0800 (PST)
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com. [209.85.217.169])
        by mx.google.com with ESMTPS id ku5si29623903lac.26.2014.12.05.09.53.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 09:53:01 -0800 (PST)
Received: by mail-lb0-f169.google.com with SMTP id p9so945087lbv.14
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 09:53:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141205172701.GW11285@n2100.arm.linux.org.uk>
References: <35FD53F367049845BC99AC72306C23D103D6DB491609@CNBJMBX05.corpusers.net>
 <20140915113325.GD12361@n2100.arm.linux.org.uk> <20141204120305.GC17783@e104818-lin.cambridge.arm.com>
 <20141205120506.GH1630@arm.com> <20141205170745.GA31222@e104818-lin.cambridge.arm.com>
 <20141205172701.GW11285@n2100.arm.linux.org.uk>
From: Peter Maydell <peter.maydell@linaro.org>
Date: Fri, 5 Dec 2014 17:52:41 +0000
Message-ID: <CAFEAcA912Cgbs-zr+=YfBBQzK625bmbrgQwYCs4DMqPEF58e8Q@mail.gmail.com>
Subject: Re: [RFC v2] arm:extend the reserved mrmory for initrd to be page aligned
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Peter Maydell <Peter.Maydell@arm.com>, "Wang, Yalin" <Yalin.Wang@sonymobile.com>, "linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 5 December 2014 at 17:27, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Fri, Dec 05, 2014 at 05:07:45PM +0000, Catalin Marinas wrote:
>> On Fri, Dec 05, 2014 at 12:05:06PM +0000, Will Deacon wrote:
>> > Care to submit this as a proper patch? We should at least fix Peter's issue
>> > before doing things like extending headers, which won't work for older
>> > kernels anyway.
>>
>> Quick fix is the revert of the whole patch, together with removing
>> PAGE_ALIGN(end) in poison_init_mem() on arm32. If Russell is ok with
>> this patch, we can take it via the arm64 tree, otherwise I'll send you a
>> partial revert only for the arm64 part.
>
> Not really.  Let's look at the history.
>
> For years, we've been poisoning memory, page aligning the end pointer.
> This has never been an issue.

Depends what you mean by "never been an issue". I had to change
QEMU (commit 98ed805c, January 2013) for 32-bit ARM back when the
kernel started trashing the tail end of the page after the initrd
with the poisoning, to 4K-align the dtb so it didn't share a page
with the initrd-tail. That nobody else complained suggests that most
bootloaders don't in practice overlap the two, though (ie that
QEMU is an outlier in how it chooses to arrange things in memory).

I should probably have reported the breakage at the time, but
I took the pragmatic (lazy?) approach of just changing our
bootloader code.

thanks
-- PMM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
