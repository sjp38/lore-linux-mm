Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8A06B0158
	for <linux-mm@kvack.org>; Tue, 26 May 2015 08:10:18 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so91442616pac.2
        for <linux-mm@kvack.org>; Tue, 26 May 2015 05:10:17 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id x3si17553918pbw.198.2015.05.26.05.10.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 05:10:17 -0700 (PDT)
Received: by paza2 with SMTP id a2so82303224paz.3
        for <linux-mm@kvack.org>; Tue, 26 May 2015 05:10:16 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] arm64: Implement vmalloc based thread_info allocator
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Jungseok Lee <jungseoklee85@gmail.com>
In-Reply-To: <20150525145857.GF14922@blaptop>
Date: Tue, 26 May 2015 21:10:11 +0900
Content-Transfer-Encoding: quoted-printable
Message-Id: <BA18E3D0-A487-4E74-8DCA-49F36A4F08E2@gmail.com>
References: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com> <5992243.NYDGjLH37z@wuerfel> <B873B881-4972-4524-B1D9-4BB05D7248A4@gmail.com> <20150525145857.GF14922@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, barami97@gmail.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On May 25, 2015, at 11:58 PM, Minchan Kim wrote:
> On Mon, May 25, 2015 at 07:01:33PM +0900, Jungseok Lee wrote:
>> On May 25, 2015, at 2:49 AM, Arnd Bergmann wrote:
>>> On Monday 25 May 2015 01:02:20 Jungseok Lee wrote:
>>>> Fork-routine sometimes fails to get a physically contiguous region =
for
>>>> thread_info on 4KB page system although free memory is enough. That =
is,
>>>> a physically contiguous region, which is currently 16KB, is not =
available
>>>> since system memory is fragmented.
>>>>=20
>>>> This patch tries to solve the problem as allocating thread_info =
memory
>>>> from vmalloc space, not 1:1 mapping one. The downside is one =
additional
>>>> page allocation in case of vmalloc. However, vmalloc space is large =
enough,
>>>> around 240GB, under a combination of 39-bit VA and 4KB page. Thus, =
it is
>>>> not a big tradeoff for fork-routine service.
>>>=20
>>> vmalloc has a rather large runtime cost. I'd argue that failing to =
allocate
>>> thread_info structures means something has gone very wrong.
>>=20
>> That is why the feature is marked "N" by default.
>> I focused on fork-routine stability rather than performance.
>=20
> If VM has trouble with order-2 allocation, your system would be
> trouble soon although fork at the moment manages to be successful
> because such small high-order(ex, order <=3D PAGE_ALLOC_COSTLY_ORDER)
> allocation is common in the kernel so VM should handle it smoothly.
> If VM didn't, it means we should fix VM itself, not a specific
> allocation site. Fork is one of victim by that.

A problem I observed is an user space, not a kernel side. As user =
applications
fail to create threads in order to distribute their jobs properly, they =
are getting
in trouble slowly and then gone.

Yes, fork is one of victim, but damages user applications seriously.
At this snapshot, free memory is enough.

>> Could you give me an idea how to evaluate performance degradation?
>> Running some benchmarks would be helpful, but I would like to try to
>> gather data based on meaningful methodology.
>>=20
>>> Can you describe the scenario that leads to fragmentation this bad?
>>=20
>> Android, but I could not describe an exact reproduction procedure =
step
>> by step since it's behaved and reproduced randomly. As reading the =
following
>> thread from mm mailing list, a similar symptom is observed on other =
systems.=20
>>=20
>> https://lkml.org/lkml/2015/4/28/59
>>=20
>> Although I do not know the details of a system mentioned in the =
thread,
>> even order-2 page allocation is not smoothly operated due to =
fragmentation on
>> low memory system.
>=20
> What Joonsoo have tackle is generic fragmentation problem, not *a* =
fork fail,
> which is more right approach to handle small high-order allocation =
problem.

I totally agree with that point. One of the best ways is to figure out a =
generic
anti-fragmentation with VM system improvement. Reducing the stack size =
to 8KB is also
a really great approach. My intention is not to overlook them or figure =
out a workaround.

IMHO, vmalloc would be a different option in case of ARM64 on low memory =
systems since
*fork failure from fragmentation* is a nontrivial issue.

Do you think the patch set doesn't need to be considered?

Best Regards
Jungseok Lee=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
