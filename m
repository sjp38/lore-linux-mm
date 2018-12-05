Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA2C6B757A
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 12:27:11 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v11so15371685ply.4
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 09:27:11 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id v6si21121540pfv.181.2018.12.05.09.27.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 09:27:10 -0800 (PST)
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
References: <20181203233509.20671-1-jglisse@redhat.com>
 <6e2a1dba-80a8-42bf-127c-2f5c2441c248@intel.com>
 <20181205001544.GR2937@redhat.com>
 <42006749-7912-1e97-8ccd-945e82cebdde@intel.com>
 <20181205021334.GB3045@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b3122fdf-02c3-2e9c-1da6-fb873b824d59@intel.com>
Date: Wed, 5 Dec 2018 09:27:09 -0800
MIME-Version: 1.0
In-Reply-To: <20181205021334.GB3045@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On 12/4/18 6:13 PM, Jerome Glisse wrote:
> On Tue, Dec 04, 2018 at 05:06:49PM -0800, Dave Hansen wrote:
>> OK, but there are 1024*1024 matrix cells on a systems with 1024
>> proximity domains (ACPI term for NUMA node).  So it sounds like you are
>> proposing a million-directory approach.
> 
> No, pseudo code:
>     struct list links;
> 
>     for (unsigned r = 0; r < nrows; r++) {
>         for (unsigned c = 0; c < ncolumns; c++) {
>             if (!link_find(links, hmat[r][c].bandwidth,
>                            hmat[r][c].latency)) {
>                 link = link_new(hmat[r][c].bandwidth,
>                                 hmat[r][c].latency);
>                 // add initiator and target correspond to that row
>                 // and columns to this new link
>                 list_add(&link, links);
>             }
>         }
>     }
> 
> So all cells that have same property are under the same link. 

OK, so the "link" here is like a cable.  It's like saying, "we have a
network and everything is connected with an ethernet cable that can do
1gbit/sec".

But, what actually connects an initiator to a target?  I assume we still
need to know which link is used for each target/initiator pair.  Where
is that enumerated?

I think this just means we need a million symlinks to a "link" instead
of a million link directories.  Still not great.

> Note that userspace can parse all this once during its initialization
> and create pools of target to use.

It sounds like you're agreeing that there is too much data in this
interface for applications to _regularly_ parse it.  We need some
central thing that parses it all and caches the results.
