Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 12F316B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 21:44:13 -0400 (EDT)
Received: by vws1 with SMTP id 1so7908366vws.14
        for <linux-mm@kvack.org>; Tue, 20 Jul 2010 18:44:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100721004407.GA14176@codeaurora.org>
References: <20100713121420.GB4263@codeaurora.org>
	<20100714104353B.fujita.tomonori@lab.ntt.co.jp>
	<20100714201149.GA14008@codeaurora.org>
	<20100714220536.GE18138@n2100.arm.linux.org.uk>
	<20100715012958.GB2239@codeaurora.org>
	<20100715085535.GC26212@n2100.arm.linux.org.uk>
	<AANLkTinVZeaZxt_lWKhjKa0dqhu3_j3BRNySO-2LvMdw@mail.gmail.com>
	<20100716075856.GC16124@n2100.arm.linux.org.uk>
	<20100717000108.GB21293@labbmf-linux.quicinc.com>
	<AANLkTinTQXbsD91JDHiSFrvDoUeHbaGUGSWA-5aT5ZCr@mail.gmail.com>
	<20100721004407.GA14176@codeaurora.org>
Date: Tue, 20 Jul 2010 21:44:12 -0400
Message-ID: <AANLkTinFCo8xTm2QM1kFWbv2xViGWt0bQz72U9YcQjv6@mail.gmail.com>
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
	memory management
From: Timothy Meade <zt.tmzt@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Zach Pfeffer <zpfeffer@codeaurora.org>
Cc: Larry Bassel <lbassel@codeaurora.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, ebiederm@xmission.com, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 20, 2010 at 8:44 PM, Zach Pfeffer <zpfeffer@codeaurora.org> wro=
te:
> On Mon, Jul 19, 2010 at 05:21:35AM -0400, Tim HRM wrote:
>> On Fri, Jul 16, 2010 at 8:01 PM, Larry Bassel <lbassel@codeaurora.org> w=
rote:
>> > On 16 Jul 10 08:58, Russell King - ARM Linux wrote:
>> >> On Thu, Jul 15, 2010 at 08:48:36PM -0400, Tim HRM wrote:
>> >> > Interesting, since I seem to remember the MSM devices mostly conduc=
t
>> >> > IO through regions of normal RAM, largely accomplished through
>> >> > ioremap() calls.
>> >> >
>> >> > Without more public domain documentation of the MSM chips and AMSS
>> >> > interfaces I wouldn't know how to avoid this, but I can imagine it
>> >> > creates a bit of urgency for Qualcomm developers as they attempt to
>> >> > upstream support for this most interesting SoC.
>> >>
>> >> As the patch has been out for RFC since early April on the linux-arm-=
kernel
>> >> mailing list (Subject: [RFC] Prohibit ioremap() on kernel managed RAM=
),
>> >> and no comments have come back from Qualcomm folk.
>> >
>> > We are investigating the impact of this change on us, and I
>> > will send out more detailed comments next week.
>> >
>> >>
>> >> The restriction on creation of multiple V:P mappings with differing
>> >> attributes is also fairly hard to miss in the ARM architecture
>> >> specification when reading the sections about caches.
>> >>
>> >
>> > Larry Bassel
>> >
>> > --
>> > Sent by an employee of the Qualcomm Innovation Center, Inc.
>> > The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Fo=
rum.
>> >
>>
>> Hi Larry and Qualcomm people.
>> I'm curious what your reason for introducing this new api (or adding
>> to dma) is. =A0Specifically how this would be used to make the memory
>> mapping of the MSM chip dynamic in contrast to the fixed _PHYS defines
>> in the Android and Codeaurora trees.
>
> The MSM has many integrated engines that allow offloading a variety of
> workloads. These engines have always addressed memory using physical
> addresses, because of this we had to reserve large (10's MB) buffers
> at boot. These buffers are never freed regardless of whether an engine
> is actually using them. As you can imagine, needing to reserve memory
> for all time on a device that doesn't have a lot of memory in the
> first place is not ideal because that memory could be used for other
> things, running apps, etc.
>
> To solve this problem we put IOMMUs in front of a lot of the
> engines. IOMMUs allow us to map physically discontiguous memory into a
> virtually contiguous address range. This means that we could ask the
> OS for 10 MB of pages and map all of these into our IOMMU space and
> the engine would still see a contiguous range.
>


I see. Much like I suspected, this is used to replace the static
regime of the earliest Android kernel.  You mention placing IOMMUs in
front of the A11 engines, you are involved in this architecture as an
engineer or similar?  Is there a reason a cooperative approach using
RPC or another mechanism is not used for memory reservation, this is
something that can be accomplished fully on APPS side?

> In reality, limitations in the hardware meant that we needed to map
> memory using larger mappings to minimize the number of TLB
> misses. This, plus the number of IOMMUs and the extreme use cases we
> needed to design for led us to a generic design.
>
> This generic design solved our problem and the general mapping
> problem. We thought other people, who had this same big-buffer
> interoperation problem would also appreciate a common API that was
> built with their needs in mind so we pushed our idea up.
>
>>
>> I'm also interested in how this ability to map memory regions as files
>> for devices like KGSL/DRI or PMEM might work and why this is better
>> suited to that purpose than existing methods, where this fits into
>> camera preview and other issues that have been dealt with in these
>> trees in novel ways (from my perspective).
>
> The file based approach was driven by Android's buffer passing scheme
> and the need to write userspace drivers for multimedia, etc...
>
>
So the Android file backed approach is obiviated by GEM and other mechanism=
s?

Thanks you for you help,
Timothy Meade
-tmzt #htc-linux (facebook.com/HTCLinux)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
