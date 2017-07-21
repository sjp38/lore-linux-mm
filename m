Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 41B7C6B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 23:48:22 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id f135so40161176yba.1
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 20:48:22 -0700 (PDT)
Received: from mail-yb0-x22d.google.com (mail-yb0-x22d.google.com. [2607:f8b0:4002:c09::22d])
        by mx.google.com with ESMTPS id u127si866353ybf.620.2017.07.20.20.48.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 20:48:21 -0700 (PDT)
Received: by mail-yb0-x22d.google.com with SMTP id 74so10199059ybf.3
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 20:48:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170721014106.GB25991@redhat.com>
References: <20170713211532.970-1-jglisse@redhat.com> <2d534afc-28c5-4c81-c452-7e4c013ab4d0@huawei.com>
 <20170718153816.GA3135@redhat.com> <b6f9d812-a1f5-d647-0a6a-39a08023c3b4@huawei.com>
 <20170719022537.GA6911@redhat.com> <f571a0a5-69ff-10b7-d612-353e53ba16fd@huawei.com>
 <20170720150305.GA2767@redhat.com> <ab3e67d5-5ed5-816f-6f8e-3228866be1fe@huawei.com>
 <20170721014106.GB25991@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 20 Jul 2017 20:48:20 -0700
Message-ID: <CAPcyv4jJraGPW214xJ+wU3G=88UUP45YiA6hV5_NvNZSNB4qGA@mail.gmail.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Bob Liu <liubo95@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>

On Thu, Jul 20, 2017 at 6:41 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Fri, Jul 21, 2017 at 09:15:29AM +0800, Bob Liu wrote:
>> On 2017/7/20 23:03, Jerome Glisse wrote:
>> > On Wed, Jul 19, 2017 at 05:09:04PM +0800, Bob Liu wrote:
>> >> On 2017/7/19 10:25, Jerome Glisse wrote:
>> >>> On Wed, Jul 19, 2017 at 09:46:10AM +0800, Bob Liu wrote:
>> >>>> On 2017/7/18 23:38, Jerome Glisse wrote:
>> >>>>> On Tue, Jul 18, 2017 at 11:26:51AM +0800, Bob Liu wrote:
>> >>>>>> On 2017/7/14 5:15, J=C3=A9r=C3=B4me Glisse wrote:
>
> [...]
>
>> >> Then it's more like replace the numa node solution(CDM) with ZONE_DEV=
ICE
>> >> (type MEMORY_DEVICE_PUBLIC). But the problem is the same, e.g how to =
make
>> >> sure the device memory say HBM won't be occupied by normal CPU alloca=
tion.
>> >> Things will be more complex if there are multi GPU connected by nvlin=
k
>> >> (also cache coherent) in a system, each GPU has their own HBM.
>> >>
>> >> How to decide allocate physical memory from local HBM/DDR or remote H=
BM/
>> >> DDR?
>> >>
>> >> If using numa(CDM) approach there are NUMA mempolicy and autonuma mec=
hanism
>> >> at least.
>> >
>> > NUMA is not as easy as you think. First like i said we want the device
>> > memory to be isolated from most existing mm mechanism. Because memory
>> > is unreliable and also because device might need to be able to evict
>> > memory to make contiguous physical memory allocation for graphics.
>> >
>>
>> Right, but we need isolation any way.
>> For hmm-cdm, the isolation is not adding device memory to lru list, and =
many
>> if (is_device_public_page(page)) ...
>>
>> But how to evict device memory?
>
> What you mean by evict ? Device driver can evict whenever they see the ne=
ed
> to do so. CPU page fault will evict too. Process exit or munmap() will fr=
ee
> the device memory.
>
> Are you refering to evict in the sense of memory reclaim under pressure ?
>
> So the way it flows for memory pressure is that if device driver want to
> make room it can evict stuff to system memory and if there is not enough
> system memory than thing get reclaim as usual before device driver can
> make progress on device memory reclaim.
>
>
>> > Second device driver are not integrated that closely within mm and the
>> > scheduler kernel code to allow to efficiently plug in device access
>> > notification to page (ie to update struct page so that numa worker
>> > thread can migrate memory base on accurate informations).
>> >
>> > Third it can be hard to decide who win between CPU and device access
>> > when it comes to updating thing like last CPU id.
>> >
>> > Fourth there is no such thing like device id ie equivalent of CPU id.
>> > If we were to add something the CPU id field in flags of struct page
>> > would not be big enough so this can have repercusion on struct page
>> > size. This is not an easy sell.
>> >
>> > They are other issues i can't think of right now. I think for now it
>>
>> My opinion is most of the issues are the same no matter use CDM or HMM-C=
DM.
>> I just care about a more complete solution no matter CDM,HMM-CDM or othe=
r ways.
>> HMM or HMM-CDM depends on device driver, but haven't see a public/full d=
river to
>> demonstrate the whole solution works fine.
>
> I am working with NVidia close source driver team to make sure that it wo=
rks
> well for them. I am also working on nouveau open source driver for same N=
Vidia
> hardware thought it will be of less use as what is missing there is a sol=
id
> open source userspace to leverage this. Nonetheless open source driver ar=
e in
> the work.

Can you point to the nouveau patches? I still find these HMM patches
un-reviewable without an upstream consumer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
