Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CBDF06B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 05:11:14 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id l24so6613976pgu.17
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 02:11:14 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20068.outbound.protection.outlook.com. [40.107.2.68])
        by mx.google.com with ESMTPS id z23si764096pgc.1.2017.10.16.02.11.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Oct 2017 02:11:13 -0700 (PDT)
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
References: <20171012143756.p5bv4zx476qkmqhh@dhcp22.suse.cz>
 <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
 <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
 <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake>
 <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz>
 <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
 <20171016082456.no6ux63uy2rmj4fe@dhcp22.suse.cz>
From: Guy Shattah <sguy@mellanox.com>
Message-ID: <0e238c56-c59d-f648-95fc-c8cb56c3652e@mellanox.com>
Date: Mon, 16 Oct 2017 12:11:04 +0300
MIME-Version: 1.0
In-Reply-To: <20171016082456.no6ux63uy2rmj4fe@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>



On 16/10/2017 11:24, Michal Hocko wrote:
> On Sun 15-10-17 10:50:29, Guy Shattah wrote:
>>
>> On 13/10/2017 19:17, Michal Hocko wrote:
>>> On Fri 13-10-17 10:56:13, Cristopher Lameter wrote:
>>>> On Fri, 13 Oct 2017, Michal Hocko wrote:
>>>>
>>>>>> There is a generic posix interface that could we used for a variety of
>>>>>> specific hardware dependent use cases.
>>>>> Yes you wrote that already and my counter argument was that this generic
>>>>> posix interface shouldn't bypass virtual memory abstraction.
>>>> It does do that? In what way?
>>> availability of the virtual address space depends on the availability of
>>> the same sized contiguous physical memory range. That sounds like the
>>> abstraction is gone to large part to me.
>> In what way? userspace users will still be working with virtual memory.
> So you are saying that providing an API which fails randomly because of
> the physically fragmented memory is OK? Users shouldn't really care
> about the state of the physical memory. That is what we have the virtual
> memory for.

Users still see and work with virtual addresses, just as before.
Users using the suggested API are aware that API might fail since it 
involves current
system memory state. This won't be the first system call or the last one 
to fail due to
reasons beyond user control. For example: any user app might fail due to 
number of
open files, disk space, memory availability, network availability. All 
beyond user control.
A smart user always has their ways to handle exceptions.
A typical user failing to allocate contiguous memory and May fallback to 
allocating
non-contiguous memory. And by the way - even if each vendor implements 
their own
methods to allocate contiguous memory then this vendor specific API 
might fail too.
For the same reasons.




>   
>>>>>> There are numerous RDMA devices that would all need the mmap
>>>>>> implementation. And this covers only the needs of one subsystem. There are
>>>>>> other use cases.
>>>>> That doesn't prevent providing a library function which could be reused
>>>>> by all those drivers. Nothing really too much different from
>>>>> remap_pfn_range.
>>>> And then in all the other use cases as well. It would be much easier if
>>>> mmap could give you the memory you need instead of havig numerous drivers
>>>> improvise on their own. This is in particular also useful
>>>> for numerous embedded use cases where you need contiguous memory.
>>> But a generic implementation would have to deal with many issues as
>>> already mentioned. If you make this driver specific you can have access
>>> control based on fd etc... I really fail to see how this is any
>>> different from remap_pfn_range.
>> Why have several driver specific implementation if you can generalize the
>> idea and implement
>> an already existing POSIX standard?
> Because users shouldn't really care, really. We do have means to get
> large memory and having a guaranteed large memory is a PITA. Just look
> at hugetlb and all the issues it exposes. And that one is preallocated
> and it requires admin to do a conscious decision about the amount of the
> memory. You would like to establish something similar except without
> bounds to the size and no pre-allowed amount by an admin. This sounds
> just crazy to me.

Users do care about the performance they get using devices which benefit
from contiguous memory allocation.
Assuming that user requires 700Mb of contiguous memory. Then why allocate
giant (1GB) page when you can allocate 700Mb out of the 1GB and put the 
rest of the
300Mb back in the huge-pages/small-pages pool?


>
> On the other hand if you make this per-device mmap implementation you
> can have both admin defined policy on who is allowed this memory and
> moreover drivers can implement their fallback strategies which best suit
> their needs. I really fail to see how this is any different from using
> specialized mmap implementations.
We tried doing it in the past. but the maintainer gave us a very good 
argument:
" If you want to support anonymous mmaps to allocate large contiguous
pages work with the MM folks on providing that in a generic fashion."

After discussing it with people who have the same requirements as we do -
I totally agree with him

http://comments.gmane.org/gmane.linux.drivers.rdma/31467

> I might be really wrong but I consider such a general purpose flag quite
> dangerous and future maintenance burden. At least from the hugetlb/THP
> history I do not see why this should be any different.
Could you please elaborate why is it dangerous and future maintenance 
burden?

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
