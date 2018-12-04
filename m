Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C18806B713B
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 18:54:24 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id a18so9990369pga.16
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 15:54:24 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id f81si19503876pfh.33.2018.12.04.15.54.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 15:54:23 -0800 (PST)
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
References: <20181203233509.20671-1-jglisse@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <6e2a1dba-80a8-42bf-127c-2f5c2441c248@intel.com>
Date: Tue, 4 Dec 2018 15:54:22 -0800
MIME-Version: 1.0
In-Reply-To: <20181203233509.20671-1-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On 12/3/18 3:34 PM, jglisse@redhat.com wrote:
> This patchset use the above scheme to expose system topology through
> sysfs under /sys/bus/hms/ with:
>     - /sys/bus/hms/devices/v%version-%id-target/ : a target memory,
>       each has a UID and you can usual value in that folder (node id,
>       size, ...)
> 
>     - /sys/bus/hms/devices/v%version-%id-initiator/ : an initiator
>       (CPU or device), each has a HMS UID but also a CPU id for CPU
>       (which match CPU id in (/sys/bus/cpu/). For device you have a
>       path that can be PCIE BUS ID for instance)
> 
>     - /sys/bus/hms/devices/v%version-%id-link : an link, each has a
>       UID and a file per property (bandwidth, latency, ...) you also
>       find a symlink to every target and initiator connected to that
>       link.
> 
>     - /sys/bus/hms/devices/v%version-%id-bridge : a bridge, each has
>       a UID and a file per property (bandwidth, latency, ...) you
>       also find a symlink to all initiators that can use that bridge.

We support 1024 NUMA nodes on x86.  The ACPI HMAT expresses the
connections between each node.  Let's suppose that each node has some
CPUs and some memory.

That means we'll have 1024 target directories in sysfs, 1024 initiator
directories in sysfs, and 1024*1024 link directories.  Or, would the
kernel be responsible for "compiling" the firmware-provided information
down into a more manageable number of links?

Some idiot made the mistake of having one sysfs directory per 128MB of
memory way back when, and now we have hundreds of thousands of
/sys/devices/system/memory/memoryX directories.  That sucks to manage.
Isn't this potentially repeating that mistake?

Basically, is sysfs the right place to even expose this much data?
