Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1033D83293
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:55:57 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i71so6200739itf.2
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 10:55:57 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0047.outbound.protection.outlook.com. [104.47.34.47])
        by mx.google.com with ESMTPS id i1si2754099itg.127.2017.06.16.10.55.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 10:55:56 -0700 (PDT)
From: "Bridgman, John" <John.Bridgman@amd.com>
Subject: RE: [HMM 00/15] HMM (Heterogeneous Memory Management) v23
Date: Fri, 16 Jun 2017 17:55:52 +0000
Message-ID: <BN6PR12MB1348BFA811E8A5539EBD9056E8C10@BN6PR12MB1348.namprd12.prod.outlook.com>
References: <20170524172024.30810-1-jglisse@redhat.com>
 <BN6PR12MB134879159CFDA7B7C4F78E2CE8C10@BN6PR12MB1348.namprd12.prod.outlook.com>
 <20170616144737.GA2420@redhat.com>
In-Reply-To: <20170616144737.GA2420@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>, "Sander, Ben" <ben.sander@amd.com>, "Kuehling, Felix" <Felix.Kuehling@amd.com>

>-----Original Message-----
>From: Jerome Glisse [mailto:jglisse@redhat.com]
>Sent: Friday, June 16, 2017 10:48 AM
>To: Bridgman, John
>Cc: akpm@linux-foundation.org; linux-kernel@vger.kernel.org; linux-
>mm@kvack.org; Dan Williams; Kirill A . Shutemov; John Hubbard; Sander, Ben=
;
>Kuehling, Felix
>Subject: Re: [HMM 00/15] HMM (Heterogeneous Memory Management) v23
>
>On Fri, Jun 16, 2017 at 07:22:05AM +0000, Bridgman, John wrote:
>> Hi Jerome,
>>
>> I'm just getting back to this; sorry for the late responses.
>>
>> Your description of HMM talks about blocking CPU accesses when a page
>> has been migrated to device memory, and you treat that as a "given" in
>> the HMM design. Other than BAR limits, coherency between CPU and
>> device caches and performance on read-intensive CPU accesses to device
>> memory are there any other reasons for this ?
>
>Correct this is the list of reasons for it. Note that HMM is more of a too=
lboox
>that one monolithic thing. For instance you also have the HMM-CDM patchset
>that does allow to have GPU memory map to the CPU but this rely on CAPI or
>CCIX to keep same memory model garanty.
>
>
>> The reason I'm asking is that we make fairly heavy use of large BAR
>> support which allows the CPU to directly access all of the device
>> memory on each of the GPUs, albeit without cache coherency, and there
>> are some cases where it appears that allowing CPU access to the page
>> in device memory would be more efficient than constantly migrating
>> back and forth.
>
>The thing is we are designing toward random program and we can not make
>any assumption on what kind of instruction a program might run on such
>memory. So if program try to do atomic on it iirc it is un- define what is
>suppose to happen.

Thanks... thought I was missing something from the list. Agree that we need=
 to provide consistent behaviour, and we definitely care about atomics. If =
we could get consistent behaviour with the page still in device memory are =
you aware of any other problems related to HMM itself ?=20

>
>So if you want to keep such memory mapped to userspace i would suggest
>doing it through device specific vma and thus through API specific contrac=
t
>that is well understood by the developer.
>
>>
>> Migrating the page back and forth between device system memory appears
>> at first glance to provide three benefits (albeit at a
>> cost):
>>
>> 1. BAR limit - this is kind of a no-brainer, in the sense that if
>>    the CPU can not access the VRAM then you have to migrate it
>>
>> 2. coherency - having the CPU fault when page is in device memory
>>    or vice versa gives you an event which can be used to allow cache
>>    flushing on one device before handing ownership (from a cache
>>    perspective) to the other device - but at first glance you don't
>>    actually have to move the page to get that benefit
>>
>> 3. performance - CPU writes to device memory can be pretty fast
>>    since the transfers can be "fire and forget" but reads are always
>>    going to be slow because of the round-trip nature... but the
>>    tradeoff between access performance and migration overhead is
>>    more of a heuristic thing than a black-and-white thing
>
>You are missing CPU atomic operation AFAIK it is undefine how they behave
>on BAR/IO memory.
>
>
>> Do you see any HMM-related problems in principle with optionally
>> leaving a page in device memory while the CPU is accessing it assuming
>> that only one CPU/device "owns" the page from a cache POV at any given
>> time ?
>
>The problem i see is with breaking assumption in respect to the memory
>model the programmer have. So let say you have program A that use a librar=
y
>L and that library is clever enough to use the GPU and that GPU driver use
>HMM. Now if L migrate some memory behind the back of the program to
>perform some computation you do not want to break any of the assumption
>made by the programmer of A.
>
>So like i said above if you want to keep a live mapping of some memory i
>would do it through device specific API. The whole point of HMM is to make
>memory migration transparent without breaking any of the expectation you
>have about how memory access works from CPU point of view.
>
>Cheers,
>J=E9r=F4me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
