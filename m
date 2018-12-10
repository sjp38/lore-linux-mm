Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD7158E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 18:10:10 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b17so10987232pfc.11
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 15:10:10 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t64si10268418pgd.202.2018.12.10.15.10.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 15:10:09 -0800 (PST)
Date: Mon, 10 Dec 2018 18:10:07 -0500
From: Sasha Levin <sashal@kernel.org>
Subject: Re: x86: e820 regression
Message-ID: <20181210231007.GI97256@sasha-vm>
References: <20181210082837.hjduflu7ou642e2m@YUKI.localdomain>
 <20181210085421.GA30792@hori1.linux.bs1.fc.nec.co.jp>
 <20181210094909.GA27385@kroah.com>
 <20181210142151.xme3ncueelvi3xfa@YUKI.localdomain>
 <20181210165831.GA97256@sasha-vm>
 <20181210171555.pjbypquyg6bqjovh@YUKI.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181210171555.pjbypquyg6bqjovh@YUKI.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Erick Cafferata <erick@cafferata.me>
Cc: stable@vger.kernel.org, linux-mm@kvack.org

On Mon, Dec 10, 2018 at 12:15:56PM -0500, Erick Cafferata wrote:
>On 12/10 11:58, Sasha Levin wrote:
>> On Mon, Dec 10, 2018 at 09:21:52AM -0500, Erick Cafferata wrote:
>> > On 12/10 10:49, Greg KH wrote:
>> > > On Mon, Dec 10, 2018 at 08:54:21AM +0000, Naoya Horiguchi wrote:
>> > > > Hi Erick,
>> > > >
>> > > > On Mon, Dec 10, 2018 at 03:28:37AM -0500, Erick Cafferata wrote:
>> > > > > The following commit introduced a regression on my system.
>> > > > >
>> > > > > 124049decbb121ec32742c94fb5d9d6bed8f24d8
>> > > > > x86/e820: put !E820_TYPE_RAM regions into memblock.reserved
>> > > > >
>> > > > > and it was backported to stable, stopping the kernel to boot on my system since around 4.17.4.
>> > > > > It was reverted on upstream a couple months ago.
>> > > > > commit 2a5bda5a624d6471d25e953b9adba5182ab1b51f upstream
>> > > >
>> > > > This commit seems not a correct pointer.
>> > > > In mainline, commit 124049decbb was reverted by
>> > > >
>> > > >     commit 9fd61bc95130d4971568b89c9548b5e0a4e18e0e
>> > > >     Author: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
>> > > >     Date:   Fri Oct 26 15:10:24 2018 -0700
>> > > >
>> > > >         Revert "x86/e820: put !E820_TYPE_RAM regions into memblock.reserved"
>> > > >
>> > > > and, the original problem was finally fixed by
>> > > >
>> > > >     commit 907ec5fca3dc38d37737de826f06f25b063aa08e
>> > > >     Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> > > >     Date:   Fri Oct 26 15:10:15 2018 -0700
>> > > >
>> > > >         mm: zero remaining unavailable struct pages
>> > > >
>> > > >         Patch series "mm: Fix for movable_node boot option", v3.
>> > > >
>> > > > so I think both patches should be backported onto v4.17.z.
>> > >
>> > > 4.17.y and 4.18.y are long end-of-life, there's nothing I can do there.
>> > >
>> > > I can apply the above patches to the 4.19.y tree, is that sufficient?
>> > >
>> > > thanks,
>> > >
>> > > greg k-h
>> > If it were possible to backport it to 4.14 as well. It would be better,
>> > but 4.19 is already good.
>> > Also, would you port only the revert commit, or also the correct fix for
>> > the previous issue?
>> >
>> > PD: also, as it was pointed out previously, the correct commit is
>> > 9fd61bc95130d4971568b89c9548b5e0a4e18e0e.
>> > PD2: sorry about removing the context in the previous mail.
>>
>> 9fd61bc95130d4971568b89c9548b5e0a4e18e0e looks like the commit that
>> reverts the patch in question, not an additional fix.
>>
>> --
>> Thanks,
>> Sasha
>That's right, that commit is the revert. The commit I'm most interested
>in getting backported. However, I was referring to the other 3 commits
>affecting arch/x86/kernel/e820.c:
>
>7e1c4e27928e memblock: stop using implicit alignment to SMP_CACHE_BYTES
>57c8a661d95d mm: remove include/linux/bootmem.h
>2a5bda5a624d memblock: replace alloc_bootmem with memblock_alloc
>
>This 3 probably fixed the original issue, for which
>
>124049decbb1 x86/e820: put !E820_TYPE_RAM regions into memblock.reserved
>
>was pushed. I was asking if those 3(or more, if needed) would get
>backported as well.
>regards

+ linux-mm@

These commits touch quite a lot of code, and even though they look
simple they are quite invasive, so I wouldn't want to take them without
a proper backport someone tested and acked by the mm folks.

--
Thanks,
Sasha
