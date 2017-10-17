Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 657A16B0033
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 14:24:00 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id l194so3225293qke.22
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 11:24:00 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 4si483916qtg.30.2017.10.17.11.23.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 11:23:59 -0700 (PDT)
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
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5f48b8a3-f187-0645-4b7d-3643129daf41@oracle.com>
Date: Tue, 17 Oct 2017 11:23:50 -0700
MIME-Version: 1.0
In-Reply-To: <AM6PR0502MB3783280D15C96E5A3A831DCBBD4C0@AM6PR0502MB3783.eurprd05.prod.outlook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guy Shattah <sguy@mellanox.com>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>
Cc: Christopher Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On 10/17/2017 07:20 AM, Guy Shattah wrote:
> 
> 
>> On Tue, Oct 17 2017, Guy Shattah wrote:
>>> Are you going to be OK with kernel API which implements contiguous
>>> memory allocation?  Possibly with mmap style?  Many drivers could
>>> utilize it instead of having their own weird and possibly non-standard
>>> way to allocate contiguous memory.  Such API won't be available for
>>> user space.
>>
>> What you describe sounds like CMA.  It may be far from perfect but ita??s there
>> already and drivers which need contiguous memory can allocate it.
>>
> 
> 1. CMA has to preconfigured. We're suggesting mechanism that works 'out of the box'
> 2. Due to the pre-allocation techniques CMA imposes limitation on maximum 
>    allocated memory. RDMA users often require 1Gb or more, sometimes more.
> 3. CMA reserves memory in advance, our suggestion is using existing kernel memory
>      mechanisms (THP for example) to allocate memory. 

I would not totally rule out the use of CMA.  I like the way that it reserves
memory, but does not prohibit use by others.  In addition, there can be
device (or purpose) specific reservations.

However, since reservations need to happen quite early it is often done on
the kernel command line.  IMO, this should be avoided if possible.  There
are interfaces for arch specific code to make reservations.  I do not know
the system initialization sequence well enough to know if it would be
possible for driver code to make CMA reservations.  But, it looks doubtful.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
