Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5350D6B04BA
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 16:43:07 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id x190so4436470oix.6
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 13:43:07 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q67sor1326320oib.131.2017.09.08.13.43.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Sep 2017 13:43:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <863afc77-ed84-fed5-ebb8-d88e636816a3@huawei.com>
References: <20170817000548.32038-1-jglisse@redhat.com> <20170904155123.GA3161@redhat.com>
 <7026dfda-9fd0-2661-5efc-66063dfdf6bc@huawei.com> <20170905023826.GA4836@redhat.com>
 <20170905185414.GB24073@linux.intel.com> <0bc5047d-d27c-65b6-acab-921263e715c8@huawei.com>
 <20170906021216.GA23436@redhat.com> <4f4a2196-228d-5d54-5386-72c3ffb1481b@huawei.com>
 <1726639990.10465990.1504805251676.JavaMail.zimbra@redhat.com> <863afc77-ed84-fed5-ebb8-d88e636816a3@huawei.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 8 Sep 2017 13:43:05 -0700
Message-ID: <CAPcyv4iWPG9wVqe1GW+Ewk4rqELZB6SRR=sF0G8NaabUu2jH_w@mail.gmail.com>
Subject: Re: [HMM-v25 19/19] mm/hmm: add new helper to hotplug CDM memory
 region v3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <liubo95@huawei.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, majiuyue <majiuyue@huawei.com>, "xieyisheng (A)" <xieyisheng1@huawei.com>

On Thu, Sep 7, 2017 at 6:59 PM, Bob Liu <liubo95@huawei.com> wrote:
> On 2017/9/8 1:27, Jerome Glisse wrote:
[..]
>> No this are 2 orthogonal thing, they do not conflict with each others qu=
ite
>> the contrary. HMM (the CDM part is no different) is a set of helpers, se=
e
>> it as a toolbox, for device driver.
>>
>> HMAT is a way for firmware to report memory resources with more informat=
ions
>> that just range of physical address. HMAT is specific to platform that r=
ely
>> on ACPI. HMAT does not provide any helpers to manage these memory.
>>
>> So a device driver can get informations about device memory from HMAT an=
d then
>> use HMM to help in managing and using this memory.
>>
>
> Yes, but as Balbir mentioned requires :
> 1. Don't online the memory as a NUMA node
> 2. Use the HMM-CDM API's to map the memory to ZONE DEVICE via the driver
>
> And I'm not sure whether Intel going to use this HMM-CDM based method for=
 their "target domain" memory ?
> Or they prefer to NUMA approach?   Ross=EF=BC=9F Dan?

The starting / strawman proposal for performance differentiated memory
ranges is to get platform firmware to mark them reserved by default.
Then, after we parse the HMAT, make them available via the device-dax
mechanism so that applications that need 100% guaranteed access to
these potentially high-value / limited-capacity ranges can be sure to
get them by default, i.e. before any random kernel objects are placed
in them. Otherwise, if there are no dedicated users for the memory
ranges via device-dax, or they don't need the total capacity, we want
to hotplug that memory into the general purpose memory allocator with
a numa node number so typical numactl and memory-management flows are
enabled.

Ideally this would not be specific to HMAT and any agent that knows
differentiated performance characteristics of a memory range could use
this scheme.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
