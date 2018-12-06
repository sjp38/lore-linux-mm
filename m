Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 621196B7CF7
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 18:09:24 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q64so1590742pfa.18
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 15:09:24 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id g69si1394306pfg.225.2018.12.06.15.09.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 15:09:23 -0800 (PST)
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
References: <20181205001544.GR2937@redhat.com>
 <42006749-7912-1e97-8ccd-945e82cebdde@intel.com>
 <20181205021334.GB3045@redhat.com>
 <b3122fdf-02c3-2e9c-1da6-fb873b824d59@intel.com>
 <20181205175357.GG3536@redhat.com>
 <b8fab9a7-62ed-5d8d-3cb1-aea6aacf77fe@intel.com>
 <20181206192050.GC3544@redhat.com>
 <d6508932-377c-a4d1-d4d8-01d0f55b9190@intel.com>
 <c583be1b-17db-1ed3-0f5a-bd119edc8bfe@deltatee.com>
 <f7eb9939-d550-706a-946d-acbb7383172e@intel.com>
 <20181206223935.GG3544@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <c1126d60-95c0-ed34-6314-fcec17ac1c29@intel.com>
Date: Thu, 6 Dec 2018 15:09:21 -0800
MIME-Version: 1.0
In-Reply-To: <20181206223935.GG3544@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On 12/6/18 2:39 PM, Jerome Glisse wrote:
> No if the 4 sockets are connect in a ring fashion ie:
>         Socket0 - Socket1
>            |         |
>         Socket3 - Socket2
> 
> Then you have 4 links:
> link0: socket0 socket1
> link1: socket1 socket2
> link3: socket2 socket3
> link4: socket3 socket0
> 
> I do not see how their can be an explosion of link directory, worse
> case is as many link directories as they are bus for a CPU/device/
> target.

This looks great.  But, we don't _have_ this kind of information for any
system that I know about or any system available in the near future.

We basically have two different world views:
1. The system is described point-to-point.  A connects to B @
   100GB/s.  B connects to C at 50GB/s.  Thus, C->A should be
   50GB/s.
   * Less information to convey
   * Potentially less precise if the properties are not perfectly
     additive.  If A->B=10ns and B->C=20ns, A->C might be >30ns.
   * Costs must be calculated instead of being explicitly specified
2. The system is described endpoint-to-endpoint.  A->B @ 100GB/s
   B->C @ 50GB/s, A->C @ 50GB/s.
   * A *lot* more information to convey O(N^2)?
   * Potentially more precise.
   * Costs are explicitly specified, not calculated

These patches are really tied to world view #1.  But, the HMAT is really
tied to world view #1.

I know you're not a fan of the HMAT.  But it is the firmware reality
that we are stuck with, until something better shows up.  I just don't
see a way to convert it into what you have described here.

I'm starting to think that, no matter if the HMAT or some other approach
gets adopted, we shouldn't be exposing this level of gunk to userspace
at *all* since it requires adopting one of the world views.
