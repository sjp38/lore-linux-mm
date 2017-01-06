Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 687866B0260
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 07:23:00 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id x2so17148862itf.6
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 04:23:00 -0800 (PST)
Received: from mail-it0-x232.google.com (mail-it0-x232.google.com. [2607:f8b0:4001:c0b::232])
        by mx.google.com with ESMTPS id 126si55505567iof.209.2017.01.06.04.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 04:22:59 -0800 (PST)
Received: by mail-it0-x232.google.com with SMTP id c20so12034888itb.0
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 04:22:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170106120339.GA20726@arm.com>
References: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
 <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org>
 <20170104132831.GD18193@arm.com> <CAKv+Gu8MdpVDCSjfum7AMtbgR6cTP5H+67svhDSu6bkaijvvyg@mail.gmail.com>
 <20170104140223.GF18193@arm.com> <20170105112407.GU4930@rric.localdomain>
 <20170105120819.GH679@arm.com> <20170105122200.GV4930@rric.localdomain>
 <20170105194944.GY4930@rric.localdomain> <20170106120339.GA20726@arm.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 6 Jan 2017 12:22:58 +0000
Message-ID: <CAKv+Gu_RGjW8AxjefhW5dFVVGSt+0+RXLZd1S32d37NpLchTvw@mail.gmail.com>
Subject: Re: [PATCH 2/2] arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Robert Richter <robert.richter@cavium.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Hanjun Guo <hanjun.guo@linaro.org>, Yisheng Xie <xieyisheng1@huawei.com>, James Morse <james.morse@arm.com>

On 6 January 2017 at 12:03, Will Deacon <will.deacon@arm.com> wrote:
> On Thu, Jan 05, 2017 at 08:49:44PM +0100, Robert Richter wrote:
>> On 05.01.17 13:22:00, Robert Richter wrote:
>> > On 05.01.17 12:08:20, Will Deacon wrote:
>> > > I really can't see how the fix causes a crash, and I couldn't reproduce
>> > > it on any of my boards, nor could any of the Linaro folk afaik. Are you
>> > > definitely running mainline with just these two patches from Ard?
>> >
>> > Yes, just both patches applied. Various other solutions were working.
>>
>> I have retested the same kernel (v4.9 based) as before and now it
>> boots fine including rtc-efi device registration (it was crashing
>> there):
>>
>>  rtc-efi rtc-efi: rtc core: registered rtc-efi as rtc0
>>
>> There could be a difference in firmware and mem setup, though I also
>> downgraded the firmware to test it, but can't reproduce it anymore. I
>> could reliable trigger the crash the first time.
>>
>> FTR the oops.
>
> Hmm, I just can't help but think you were accidentally running with
> additional patches when you saw this oops previously. For example,
> your log looks very similar to this one:
>
>   http://lists.infradead.org/pipermail/linux-arm-kernel/2016-December/473666.html
>
> but then again, these crashes probably often look alike.
>

These are quite different, in fact. In James's case, the UEFI memory
map was missing some entries, so not all memory regions that the
firmware expected to be there were actually mapped, hence the all-zero
*pte. In Robert's case, it looks like the UEFI runtime services page
tables are corrupted, i.e., *pte has RES0 bits set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
