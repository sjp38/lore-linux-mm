Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9629B6B0033
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 15:57:30 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f4so1296992wme.21
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 12:57:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i8si7520465wre.6.2017.10.17.12.57.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 12:57:29 -0700 (PDT)
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
References: <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
 <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake>
 <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz>
 <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
 <20171016082456.no6ux63uy2rmj4fe@dhcp22.suse.cz>
 <0e238c56-c59d-f648-95fc-c8cb56c3652e@mellanox.com>
 <20171016123248.csntl6luxgafst6q@dhcp22.suse.cz>
 <AM6PR0502MB378375AF8B569DBCCFE20D7DBD4C0@AM6PR0502MB3783.eurprd05.prod.outlook.com>
 <xa1tlgk9c3j4.fsf@mina86.com>
 <AM6PR0502MB3783280D15C96E5A3A831DCBBD4C0@AM6PR0502MB3783.eurprd05.prod.outlook.com>
 <5f48b8a3-f187-0645-4b7d-3643129daf41@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <09f9d3a1-a98f-dc0c-3b1b-ca60abe724cd@suse.cz>
Date: Tue, 17 Oct 2017 21:56:06 +0200
MIME-Version: 1.0
In-Reply-To: <5f48b8a3-f187-0645-4b7d-3643129daf41@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Guy Shattah <sguy@mellanox.com>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>
Cc: Christopher Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>

On 10/17/2017 08:23 PM, Mike Kravetz wrote:
> On 10/17/2017 07:20 AM, Guy Shattah wrote:
>> 1. CMA has to preconfigured. We're suggesting mechanism that works 'out of the box'
>> 2. Due to the pre-allocation techniques CMA imposes limitation on maximum 
>>    allocated memory. RDMA users often require 1Gb or more, sometimes more.
>> 3. CMA reserves memory in advance, our suggestion is using existing kernel memory
>>      mechanisms (THP for example) to allocate memory. 
> 
> I would not totally rule out the use of CMA.  I like the way that it reserves
> memory, but does not prohibit use by others.  In addition, there can be
> device (or purpose) specific reservations.

I think the use case are devices that *cannot* function without
contiguous memory, typical examples IIRC are smartphone cameras on with
Android where only single app is working with the device at given time,
so it's ok to reserve single area for the device, and allocation is done
by the driver. Here we are talking about allocations done by potentially
multiple userspace applications, so how do we reconcile that with the
reservations? How does a single flag identify which device's area to
use? How do we prevent one process depleting the area for other
processes? IMHO it's another indication that a generic interface is
infeasible and it should be driver-specific.

BTW, does RDMA need a specific NUMA node to work optimally? (one closest
to the device I presume?) Will it be the job of userspace to discover
and bind itself to that node, in addition to using MAP_CONTIG? Or would
that be another thing best handled by the driver?

> However, since reservations need to happen quite early it is often done on
> the kernel command line.  IMO, this should be avoided if possible.  There
> are interfaces for arch specific code to make reservations.  I do not know
> the system initialization sequence well enough to know if it would be
> possible for driver code to make CMA reservations.  But, it looks doubtful.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
