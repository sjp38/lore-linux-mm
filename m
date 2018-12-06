Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE4336B7BF0
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 15:12:15 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id p4so1403854iod.17
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 12:12:15 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id n63si691936jab.15.2018.12.06.12.12.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Dec 2018 12:12:14 -0800 (PST)
References: <20181203233509.20671-1-jglisse@redhat.com>
 <6e2a1dba-80a8-42bf-127c-2f5c2441c248@intel.com>
 <20181205001544.GR2937@redhat.com>
 <42006749-7912-1e97-8ccd-945e82cebdde@intel.com>
 <20181205021334.GB3045@redhat.com>
 <b3122fdf-02c3-2e9c-1da6-fb873b824d59@intel.com>
 <20181205175357.GG3536@redhat.com>
 <b8fab9a7-62ed-5d8d-3cb1-aea6aacf77fe@intel.com>
 <20181206192050.GC3544@redhat.com>
 <d6508932-377c-a4d1-d4d8-01d0f55b9190@intel.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <c583be1b-17db-1ed3-0f5a-bd119edc8bfe@deltatee.com>
Date: Thu, 6 Dec 2018 13:11:28 -0700
MIME-Version: 1.0
In-Reply-To: <d6508932-377c-a4d1-d4d8-01d0f55b9190@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org



On 2018-12-06 12:31 p.m., Dave Hansen wrote:
> On 12/6/18 11:20 AM, Jerome Glisse wrote:
>>>> For case 1 you can pre-parse stuff but this can be done by helper library
>>> How would that work?  Would each user/container/whatever do this once?
>>> Where would they keep the pre-parsed stuff?  How do they manage their
>>> cache if the topology changes?
>> Short answer i don't expect a cache, i expect that each program will have
>> a init function that query the topology and update the application codes
>> accordingly.
> 
> My concern with having folks do per-program parsing, *and* having a huge
> amount of data to parse makes it unusable.  The largest systems will
> literally have hundreds of thousands of objects in /sysfs, even in a
> single directory.  That makes readdir() basically impossible, and makes
> even open() (if you already know the path you want somehow) hard to do fast.

Is this actually realistic? I find it hard to imagine an actual hardware
bus that can have even thousands of devices under a single node, let
alone hundreds of thousands. At some point the laws of physics apply.
For example, in present hardware, the most ports a single PCI switch can
have these days is under one hundred. I'd imagine any such large systems
would have a hierarchy of devices (ie. layers of switch-like devices)
which implies the existing sysfs bus/devices  should have a path through
it without navigating a directory with that unreasonable a number of
objects in it. HMS, on the other hand, has all possible initiators
(,etc) under a single directory.

The caveat to this is, that to find an initial starting point in the bus
hierarchy you might have to go through /sys/dev/{block|char} or
/sys/class which may have directories with a large number of objects.
Though, such a system would necessarily have a similarly large number of
objects in /dev which means means you will probably never get around the
readdir/open bottleneck you mention... and, thus, this doesn't seem
overly realistic to me.

Logan
