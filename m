Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB8826B7CC3
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 17:39:43 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id c7so1768030qkg.16
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 14:39:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j90si1148456qtd.27.2018.12.06.14.39.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 14:39:42 -0800 (PST)
Date: Thu, 6 Dec 2018 17:39:35 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
Message-ID: <20181206223935.GG3544@redhat.com>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <f7eb9939-d550-706a-946d-acbb7383172e@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On Thu, Dec 06, 2018 at 02:04:46PM -0800, Dave Hansen wrote:
> On 12/6/18 12:11 PM, Logan Gunthorpe wrote:
> >> My concern with having folks do per-program parsing, *and* having a huge
> >> amount of data to parse makes it unusable.  The largest systems will
> >> literally have hundreds of thousands of objects in /sysfs, even in a
> >> single directory.  That makes readdir() basically impossible, and makes
> >> even open() (if you already know the path you want somehow) hard to do fast.
> > Is this actually realistic? I find it hard to imagine an actual hardware
> > bus that can have even thousands of devices under a single node, let
> > alone hundreds of thousands.
> 
> Jerome's proposal, as I understand it, would have generic "links".
> They're not an instance of bus, but characterize a class of "link".  For
> instance, a "link" might characterize the characteristics of the QPI bus
> between two CPU sockets. The link directory would enumerate the list of
> all *instances* of that link
> 
> So, a "link" directory for QPI would say Socket0<->Socket1,
> Socket1<->Socket2, Socket1<->Socket2, Socket2<->PCIe-1.2.3.4 etc...  It
> would have to enumerate the connections between every entity that shared
> those link properties.
> 
> While there might not be millions of buses, there could be millions of
> *paths* across all those buses, and that's what the HMAT describes, at
> least: the net result of all those paths.

Sorry if again i miss-explained thing. Link are arrows between nodes
(CPU or device or memory). An arrow/link has properties associated
with it: bandwidth, latency, cache-coherent, ...

So if in your system you 4 Sockets and that each socket is connected to
each other (mesh) and all inter-connect in the mesh have same property
then you only have 1 link directory with the 4 socket in it.

No if the 4 sockets are connect in a ring fashion ie:
        Socket0 - Socket1
           |         |
        Socket3 - Socket2

Then you have 4 links:
link0: socket0 socket1
link1: socket1 socket2
link3: socket2 socket3
link4: socket3 socket0

I do not see how their can be an explosion of link directory, worse
case is as many link directories as they are bus for a CPU/device/
target. So worse case if you have N devices and each devices is
connected two 2 bus (PCIE and QPI to go to other socket for instance)
then you have 2*N link directory (again this is a worst case).

They are lot of commonality that will remain so i expect that quite
a few link directory will have many symlink ie you won't get close
to the worst case.


In the end really it is easier to think from the physical topology
and there a link correspond to an inter-connect between two device
or CPU. In all the systems i have seen even in the craziest roadmap
i have only seen thing like 128/256 inter-connect (4 socket 32/64
devices per socket) and many of which can be grouped under a common
link directory. Here worse case is 4 connection per device/CPU/
target so worse case of 128/256 * 4  = 512/1024 link directory
and that's a lot. Given regularity i have seen described on slides
i expect that it would need something like 30 link directory and
20 bridges directory.

On today system 8GPU per socket with GPUlink between each GPU and
PCIE all this with 4 socket it comes down to 20 links directory.

In any cases each devices/CPU/target has a limit on the number of
bus/inter-connect it is connected too. I doubt there is anyone
designing device that will have much more than 4 external bus
connection.

So it is not a link per pair. It is a link for group of device/CPU/
target. Is it any clearer ?

Cheers,
J�r�me
