Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 10CDE6B7588
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 12:42:17 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id v8so21243932ioh.11
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 09:42:17 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id m14si7205721itl.54.2018.12.05.09.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Dec 2018 09:42:15 -0800 (PST)
References: <20181204192221.GG2937@redhat.com>
 <f759cc28-309d-930c-da7d-34144a4d5517@deltatee.com>
 <20181204201347.GK2937@redhat.com>
 <2f146730-1bf9-db75-911d-67809fc7afef@deltatee.com>
 <20181204205902.GM2937@redhat.com>
 <e4d8bf6b-5b2c-58a5-577b-66d02f2342c1@deltatee.com>
 <20181204215146.GO2937@redhat.com>
 <c5cf87e8-9104-c2e6-9646-188f66fec581@deltatee.com>
 <20181204235630.GQ2937@redhat.com>
 <b77849e1-e05a-1071-7c48-ac93191e3134@deltatee.com>
 <20181205023116.GD3045@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <a5ae63ff-a913-25af-4648-4ebf91775412@deltatee.com>
Date: Wed, 5 Dec 2018 10:41:56 -0700
MIME-Version: 1.0
In-Reply-To: <20181205023116.GD3045@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com



On 2018-12-04 7:31 p.m., Jerome Glisse wrote:
> How can i express multiple link, or memory that is only accessible
> by a subset of the devices/CPUs. In today model they are back in
> assumption like everyone can access all the node which do not hold
> in what i am trying to do.

Well multiple links are easy when you have a 'link' bus. Just add
another link device under the bus.

Technically, the accessibility issue is already encoded in sysfs. For
example, through the PCI tree you can determine which ACS bits are set
and determine which devices are behind the same root bridge the same way
we do in the kernel p2pdma subsystem. This is all bus specific which is
fine, but if we want to change that, we should have a common way for
existing buses to describe these attributes in the existing tree. The
new 'link' bus devices would have to have some way to describe cases if
memory isn't accessible in some way across it.

But really, I would say the kernel is responsible for telling you when
memory is accessible to a list of initiators, so it should be part of
the checks in a theoretical hbind api. This is already the approach
p2pdma takes in-kernel: we have functions that tell you if two PCI
devices can talk to each other and we have functions to give you memory
accessible by a set of devices. What we don't have is a special tree
that p2pdma users have to walk through to determine accessibility.

In my eye's, you are just conflating a bunch of different issues that
are better solved independently in the existing frameworks we have. And
if they were tackled individually, you'd have a much easier time getting
them merged one by one.

Logan
