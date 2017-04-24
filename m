Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id EAB0A6B0038
	for <linux-mm@kvack.org>; Sun, 23 Apr 2017 20:39:14 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id c26so52884772itd.16
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 17:39:14 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id y206si17087189pfb.368.2017.04.23.17.39.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Apr 2017 17:39:14 -0700 (PDT)
Subject: Re: [HMM 03/15] mm/unaddressable-memory: new type of ZONE_DEVICE for
 unaddressable memory
References: <20170422033037.3028-1-jglisse@redhat.com>
 <20170422033037.3028-4-jglisse@redhat.com>
 <CAPcyv4jq0+FptsqUY14PA7WfgjYOt-kA5r084c8vvmkAU8WqaQ@mail.gmail.com>
 <20170422181151.GA2360@redhat.com>
 <CAPcyv4jr=CNuaGQt80SwR5dpiXy_pDr8aD-w0EtLNE4oGC8WcQ@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <f88de491-1cd2-75e1-4304-dc11c96b5d2a@nvidia.com>
Date: Sun, 23 Apr 2017 17:39:12 -0700
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jr=CNuaGQt80SwR5dpiXy_pDr8aD-w0EtLNE4oGC8WcQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 4/23/17 6:13 AM, Dan Williams wrote:
> On Sat, Apr 22, 2017 at 11:11 AM, Jerome Glisse <jglisse@redhat.com> wrot=
e:
>> On Fri, Apr 21, 2017 at 10:30:01PM -0700, Dan Williams wrote:
>>> On Fri, Apr 21, 2017 at 8:30 PM, J=C3=A9r=C3=B4me Glisse <jglisse@redha=
t.com> wrote:
>>
>> [...]
>>
>>>> +/*
>>>> + * Specialize ZONE_DEVICE memory into multiple types each having diff=
erents
>>>> + * usage.
>>>> + *
>>>> + * MEMORY_DEVICE_PERSISTENT:
>>>> + * Persistent device memory (pmem): struct page might be allocated in=
 different
>>>> + * memory and architecture might want to perform special actions. It =
is similar
>>>> + * to regular memory, in that the CPU can access it transparently. Ho=
wever,
>>>> + * it is likely to have different bandwidth and latency than regular =
memory.
>>>> + * See Documentation/nvdimm/nvdimm.txt for more information.
>>>> + *
>>>> + * MEMORY_DEVICE_UNADDRESSABLE:
>>>> + * Device memory that is not directly addressable by the CPU: CPU can=
 neither
>>>> + * read nor write _UNADDRESSABLE memory. In this case, we do still ha=
ve struct
>>>> + * pages backing the device memory. Doing so simplifies the implement=
ation, but
>>>> + * it is important to remember that there are certain points at which=
 the struct
>>>> + * page must be treated as an opaque object, rather than a "normal" s=
truct page.
>>>> + * A more complete discussion of unaddressable memory may be found in
>>>> + * include/linux/hmm.h and Documentation/vm/hmm.txt.
>>>> + */
>>>> +enum memory_type {
>>>> +       MEMORY_DEVICE_PERSISTENT =3D 0,
>>>> +       MEMORY_DEVICE_UNADDRESSABLE,
>>>> +};
>>>
>>> Ok, this is a bikeshed, but I think it is important. I think these
>>> should be called MEMORY_DEVICE_PUBLIC and MEMORY_DEVICE_PRIVATE. The
>>> reason is that persistence has nothing to do with the code paths that
>>> deal with the pmem use case of ZONE_DEVICE. The only property the mm
>>> cares about is that the address range behaves the same as host memory
>>> for dma and cpu accesses. The "unaddressable" designation always
>>> confuses me because a memory range isn't memory if it's
>>> "unaddressable". It is addressable, it's just "private" to the device.
>>
>> I can change the name but the memory is truely unaddressable, the CPU
>> can not access it whatsoever (well it can access a small window but
>> even that is not guaranteed).
>>
>
> Understood, but that's still "addressable only by certain agents or
> through a proxy" which seems closer to "private" to me.
>

Actually, MEMORY_DEVICE_PRIVATE / _PUBLIC seems like a good choice to=20
me, because the memory may not remain CPU-unaddressable in the future.=20
By that, I mean that I know of at least one company (ours) that is=20
working on products that will support hardware-based memory coherence=20
(and access counters to go along with that). If someone were to enable=20
HMM on such a system, then the device memory would be, in fact, directly=20
addressable by a CPU--thus exactly contradicting the "unaddressable" name.

Yes, it is true that we would have to modify HMM anyway, in order to=20
work in that situation, partly because HMM today relies on CPU and=20
device page faults in order to work. And it's also true that we might=20
want to take a different approach than HMM, to support that kind of=20
device: for example, making it a NUMA node has been debated here, recently.

But even so, I think the potential for the "unaddressable" memory=20
actually becoming "addressable" someday, is a good argument for using a=20
different name.

thanks,

--
John Hubbard
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
