Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB2C66B0033
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 13:46:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id q124so1167600wmb.23
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 10:46:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h143si7638985wma.123.2017.10.17.10.46.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 10:46:04 -0700 (PDT)
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
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <32726f82-e044-25e3-fdbf-ba3630da5053@suse.cz>
Date: Tue, 17 Oct 2017 19:44:44 +0200
MIME-Version: 1.0
In-Reply-To: <AM6PR0502MB3783280D15C96E5A3A831DCBBD4C0@AM6PR0502MB3783.eurprd05.prod.outlook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guy Shattah <sguy@mellanox.com>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>
Cc: Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>

On 10/17/2017 04:20 PM, Guy Shattah wrote:
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

You can already use THP, right? madvise(MADV_HUGEPAGE) increases your
chances to get the huge pages. Then you can mlock() them if you want.
And you get the TLB benefits. There's no guarantee of course, but you
shouldn't require a guarantee for MMAP_CONTIG anyway, because it's for
performance reasons, not functionality. So either MMAP_CONTIG would have
to fallback itself, or the userspace caller. Or would your scenario
rather fail than perform suboptimally?

> Guy
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
