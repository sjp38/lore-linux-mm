Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 533D46B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 08:03:39 -0400 (EDT)
Received: by mail-yh0-f47.google.com with SMTP id 29so2074878yhl.34
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 05:03:39 -0700 (PDT)
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
        by mx.google.com with ESMTPS id n70si4678294yhn.65.2014.04.24.05.03.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 05:03:38 -0700 (PDT)
Received: by mail-yh0-f53.google.com with SMTP id i57so2069744yha.40
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 05:03:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140424110321.GN26756@n2100.arm.linux.org.uk>
References: <1397648803-15961-1-git-send-email-steve.capper@linaro.org>
	<20140424102229.GA28014@linaro.org>
	<20140424103639.GC19564@arm.com>
	<20140424104232.GK26756@n2100.arm.linux.org.uk>
	<CAPvkgC3P8iZp5nECiGHdeGzRwmdh=ouiAREqKwk1tYzZxHTWvg@mail.gmail.com>
	<20140424110321.GN26756@n2100.arm.linux.org.uk>
Date: Thu, 24 Apr 2014 13:03:38 +0100
Message-ID: <CAPvkgC36fLVJJtZumFO=f4eMEQvh_SjN7QDRpxT=ThfnGa1rog@mail.gmail.com>
Subject: Re: [PATCH V2 0/5] Huge pages for short descriptors on ARM
From: Steve Capper <steve.capper@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Will Deacon <will.deacon@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "robherring2@gmail.com" <robherring2@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>

On 24 April 2014 12:03, Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
> On Thu, Apr 24, 2014 at 11:55:56AM +0100, Steve Capper wrote:
>> On 24 April 2014 11:42, Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
>> > On Thu, Apr 24, 2014 at 11:36:39AM +0100, Will Deacon wrote:
>> >> I guess I'm after some commitment that this is (a) useful to somebody and
>> >> (b) going to be tested regularly, otherwise it will go the way of things
>> >> like big-endian, where we end up carrying around code which is broken more
>> >> often than not (although big-endian is more self-contained).
>> >
>> > It may be something worth considering adding to my nightly builder/boot
>> > testing, but I suspect that's impractical as it probably requires a BE
>> > userspace, which would then mean that the platform can't boot LE.
>> >
>> > I suspect that we will just have to rely on BE users staying around and
>> > reporting problems when they occur.
>>
>> The huge page support is for standard LE, I think Will was saying that
>> this will be like BE if no-one uses it.
>
> We're not saying that.
>

Apologies, I was talking at cross-purposes.

> What we're asking is this: *Who* is using hugepages today?

I've asked the people who have been in touch with me to jump in to
this discussion.
People working on phones and servers have expressed an interest.

>
> What we're then doing is comparing it to the situation we have today with
> BE, where BE support is *always* getting broken because no one in the main
> community tests it - not even a build test, nor a boot test which would
> be required to find the problems that (for example) cropped up in the
> last merge window.

I can appreciate that concern.

>
>> It's somewhat unfair to compare huge pages on short descriptors with
>> BE. For a start, the userspace that works with LPAE will work on the
>> short-descriptor kernel too.
>
> That sounds good, but the question is how does this get tested by
> facilities such as my build/boot system, or Olof/Kevin's system?
> Without that, it will find itself in exactly the same situation that
> BE is in, where problems aren't found until after updates are merged
> into Linus' tree.
>

For minimal build/boot testing, I would recommend enabling:
CONFIG_HUGETLBFS=y
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y

That should not have any significant effect on the running system (one
has to opt-in to use HugeTLB or THP in this case), so could be put in
a defconfig.

For actual usage testing, typically one would use the upstream
libhugelbfs test suite as it is very good at finding problems, is kept
up to date, and is easy to automate and interpret the results. For
THP, I usually run a kernel build repeatedly with
/sys/kernel/mm/transparent_hugepage/enabled set to always along with
LTP's mm tests.

We also run continuous integration tests within Linaro against Linaro
kernels, and the libhugetlbfs test suite is one of our tests. If it
helps things, I can set up automated huge page tests within Linaro and
pull in another branch?

Cheers,
--
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
