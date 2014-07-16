Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0096B0039
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 20:44:13 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so231957pdj.8
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 17:44:12 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id lf13si13021526pab.199.2014.07.15.17.44.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 17:44:12 -0700 (PDT)
In-Reply-To: <1405459404.28702.17.camel@misato.fc.hp.com>
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com> <53C58A69.3070207@zytor.com> <1405459404.28702.17.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [RFC PATCH 0/11] Support Write-Through mapping on x86
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Tue, 15 Jul 2014 20:40:28 -0400
Message-ID: <03d059f5-b564-4530-9184-f91ca9d5c016@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, airlied@gmail.com, bp@alien8.de

On July 15, 2014 5:23:24 PM EDT, Toshi Kani <toshi=2Ekani@hp=2Ecom> wrote:
>On Tue, 2014-07-15 at 13:09 -0700, H=2E Peter Anvin wrote:
>> On 07/15/2014 12:34 PM, Toshi Kani wrote:
>> > This RFC patchset is aimed to seek comments/suggestions for the
>design
>> > and changes to support of Write-Through (WT) mapping=2E  The study
>below
>> > shows that using WT mapping may be useful for non-volatile memory=2E
>> >=20
>> >   http://www=2Ehpl=2Ehp=2Ecom/techreports/2012/HPL-2012-236=2Epdf
>> >=20
>> > There were idea & patches to support WT in the past, which
>stimulated
>> > very valuable discussions on this topic=2E
>> >=20
>> >   https://lkml=2Eorg/lkml/2013/4/24/424
>> >   https://lkml=2Eorg/lkml/2013/10/27/70
>> >   https://lkml=2Eorg/lkml/2013/11/3/72
>> >=20
>> > This RFC patchset tries to address the issues raised by taking the
>> > following design approach:
>> >=20
>> >  - Keep the MTRR interface
>> >  - Keep the WB, WC, and UC- slots in the PAT MSR
>> >  - Keep the PAT bit unused
>> >  - Reassign the UC slot to WT in the PAT MSR
>> >=20
>> > There are 4 usable slots in the PAT MSR, which are currently
>assigned to:
>> >=20
>> >   PA0/4: WB, PA1/5: WC, PA2/6: UC-, PA3/7: UC
>> >=20
>> > The PAT bit is unused since it shares the same bit as the PSE bit
>and
>> > there was a bug in older processors=2E  Among the 4 slots, the
>uncached
>> > memory type consumes 2 slots, UC- and UC=2E  They are functionally
>> > equivalent, but UC- allows MTRRs to overwrite it with WC=2E  All
>interfaces
>> > that set the uncached memory type use UC- in order to work with
>MTRRs=2E
>> > The PA3/7 slot is effectively unused today=2E  Therefore, this
>patchset
>> > reassigns the PA3/7 slot to WT=2E  If MTRRs get deprecated in future,
>> > UC- can be reassigned to UC, and there is still no need to consume
>> > 2 slots for the uncached memory type=2E
>>=20
>> Not going to happen any time in the forseeable future=2E
>>=20
>> Furthermore, I don't think it is a big deal if on some old, buggy
>> processors we take the performance hit of cache type demotion, as
>long
>> as we don't actively lose data=2E
>>=20
>> > This patchset is consist of two parts=2E  The 1st part, patch [1/11]
>to
>> > [6/11], enables WT mapping and adds new interfaces for setting WT
>mapping=2E
>> > The 2nd part, patch [7/11] to [11/11], cleans up the code that has
>> > internal knowledge of the PAT slot assignment=2E  This keeps the
>kernel
>> > code independent from the PAT slot assignment=2E
>>=20
>> I have given this piece of feedback at least three times now,
>possibly
>> to different people, and I'm getting a bit grumpy about it:
>>=20
>> We already have an issue with Xen, because Xen assigned mappings
>> differently and it is incompatible with the use of PAT in Linux=2E  As
>a
>> result we get requests for hacks to work around this, which is
>something
>> I really don't want to see=2E  I would like to see a design involving a
>> "reverse PAT" table where the kernel can hold the mapping between
>memory
>> types and page table encodings (including the two different ones for
>> small and large pages=2E)
>
>Thanks for pointing this out! (And sorry for making you repeat it three
>time=2E=2E=2E)  I was not aware of the issue with Xen=2E  I will look int=
o the
>email archive to see what the Xen issue is, and how it can be
>addressed=2E

https://lkml=2Eorg/lkml/2011/11/8/406
>
>Thanks,
>-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
