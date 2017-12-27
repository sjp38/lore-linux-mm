Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D467C6B0033
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 04:10:37 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id q4so5446495wre.14
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 01:10:37 -0800 (PST)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id h4si7342118wrh.59.2017.12.27.01.10.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 01:10:36 -0800 (PST)
Subject: Re: [PATCH v3 0/3] create sysfs representation of ACPI HMAT
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
 <20171214130032.GK16951@dhcp22.suse.cz>
 <20171218203547.GA2366@linux.intel.com>
 <20171220181937.GB12236@bombadil.infradead.org>
 <2da89d31-27a3-34ab-2dbb-92403c8215ec@intel.com>
 <20171220211649.GA32200@bombadil.infradead.org>
 <20171220212408.GA8308@linux.intel.com>
 <CAPcyv4gTknp=0yQnVrrB5Ui+mJE_x-wdkV86UD4hsYnx3CAjfA@mail.gmail.com>
 <20171220224105.GA27258@linux.intel.com>
 <39cbe02a-d309-443d-54c9-678a0799342d@gmail.com>
 <CAPcyv4j9shdJFrvADa=qW4L-jPJJ4S_TJc_c=aRoW3EmSCCChQ@mail.gmail.com>
From: Brice Goglin <brice.goglin@gmail.com>
Message-ID: <71317994-af66-a1b2-4c7a-86a03253cf62@gmail.com>
Date: Wed, 27 Dec 2017 10:10:34 +0100
MIME-Version: 1.0
In-Reply-To: <CAPcyv4j9shdJFrvADa=qW4L-jPJJ4S_TJc_c=aRoW3EmSCCChQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

Le 22/12/2017 A  23:53, Dan Williams a A(C)critA :
> On Thu, Dec 21, 2017 at 12:31 PM, Brice Goglin <brice.goglin@gmail.com> wrote:
>> Le 20/12/2017 A  23:41, Ross Zwisler a A(C)crit :
> [..]
>> Hello
>>
>> I can confirm that HPC runtimes are going to use these patches (at least
>> all runtimes that use hwloc for topology discovery, but that's the vast
>> majority of HPC anyway).
>>
>> We really didn't like KNL exposing a hacky SLIT table [1]. We had to
>> explicitly detect that specific crazy table to find out which NUMA nodes
>> were local to which cores, and to find out which NUMA nodes were
>> HBM/MCDRAM or DDR. And then we had to hide the SLIT values to the
>> application because the reported latencies didn't match reality. Quite
>> annoying.
>>
>> With Ross' patches, we can easily get what we need:
>> * which NUMA nodes are local to which CPUs? /sys/devices/system/node/
>> can only report a single local node per CPU (doesn't work for KNL and
>> upcoming architectures with HBM+DDR+...)
>> * which NUMA nodes are slow/fast (for both bandwidth and latency)
>> And we can still look at SLIT under /sys/devices/system/node if really
>> needed.
>>
>> And of course having this in sysfs is much better than parsing ACPI
>> tables that are only accessible to root :)
> On this point, it's not clear to me that we should allow these sysfs
> entries to be world readable. Given /proc/iomem now hides physical
> address information from non-root we at least need to be careful not
> to undo that with new sysfs HMAT attributes. Once you need to be root
> for this info, is parsing binary HMAT vs sysfs a blocker for the HPC
> use case?

I don't think it would be a blocker.

> Perhaps we can enlist /proc/iomem or a similar enumeration interface
> to tell userspace the NUMA node and whether the kernel thinks it has
> better or worse performance characteristics relative to base
> system-RAM, i.e. new IORES_DESC_* values. I'm worried that if we start
> publishing absolute numbers in sysfs userspace will default to looking
> for specific magic numbers in sysfs vs asking the kernel for memory
> that has performance characteristics relative to base "System RAM". In
> other words the absolute performance information that the HMAT
> publishes is useful to the kernel, but it's not clear that userspace
> needs that vs a relative indicator for making NUMA node preference
> decisions.

Some HPC users will benchmark the machine to discovery actual
performance numbers anyway.
However, most users won't do this. They will want to know relative
performance of different nodes. If you normalize HMAT values by dividing
them with system-RAM values, that's likely OK. If you just say "that
node is faster than system RAM", it's not precise enough.

Brice

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
