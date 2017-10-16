Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 10A806B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 13:43:47 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d67so16260727qkg.3
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 10:43:47 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 28si789848qtn.62.2017.10.16.10.43.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 10:43:46 -0700 (PDT)
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
References: <20171012014611.18725-1-mike.kravetz@oracle.com>
 <20171012014611.18725-4-mike.kravetz@oracle.com>
 <20171012143756.p5bv4zx476qkmqhh@dhcp22.suse.cz>
 <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
 <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
 <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake>
 <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz>
 <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <aff6b405-6a06-f84d-c9b1-c6fb166dff81@oracle.com>
Date: Mon, 16 Oct 2017 10:43:38 -0700
MIME-Version: 1.0
In-Reply-To: <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guy Shattah <sguy@mellanox.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On 10/15/2017 12:50 AM, Guy Shattah wrote:
> On 13/10/2017 19:17, Michal Hocko wrote:
>> On Fri 13-10-17 10:56:13, Cristopher Lameter wrote:
>>> On Fri, 13 Oct 2017, Michal Hocko wrote:
>>>
>>>>> There is a generic posix interface that could we used for a variety of
>>>>> specific hardware dependent use cases.
>>>> Yes you wrote that already and my counter argument was that this generic
>>>> posix interface shouldn't bypass virtual memory abstraction.
>>> It does do that? In what way?
>> availability of the virtual address space depends on the availability of
>> the same sized contiguous physical memory range. That sounds like the
>> abstraction is gone to large part to me.
> In what way? userspace users will still be working with virtual memory.
> 
>>
>>>>> There are numerous RDMA devices that would all need the mmap
>>>>> implementation. And this covers only the needs of one subsystem. There are
>>>>> other use cases.
>>>> That doesn't prevent providing a library function which could be reused
>>>> by all those drivers. Nothing really too much different from
>>>> remap_pfn_range.
>>> And then in all the other use cases as well. It would be much easier if
>>> mmap could give you the memory you need instead of havig numerous drivers
>>> improvise on their own. This is in particular also useful
>>> for numerous embedded use cases where you need contiguous memory.
>> But a generic implementation would have to deal with many issues as
>> already mentioned. If you make this driver specific you can have access
>> control based on fd etc... I really fail to see how this is any
>> different from remap_pfn_range.
> Why have several driver specific implementation if you can generalize the idea and implement
> an already existing POSIX standard?

Just to be clear, the posix standard talks about a typed memory object.
The suggested implementation has one create a connection to the memory
object to receive a fd, then use mmap as usual to get a mapping backed
by contiguous pages/memory.  Of course, this type of implementation is
not a requirement.  However, this type of implementation looks quite a
bit like hugetlbfs today.
- Both require opening a special file/device, and then calling mmap on
  the returned fd.  You can technically use mmap(MAP_HUGETLB), but that
  still ends up using hugetbfs.  BTW, there was resistance to adding the
  MAP_HUGETLB flag to mmap.
- Allocation of contiguous memory is much like 'on demand' allocation of
  huge pages.  There are some (not many) users that use this model.  They
  attempt to allocate huge pages on demand, and if not available fall back
  to base pages.  This is how contiguous allocations would need to work.
  Of course, most hugetlbfs users pre-allocate pages for their use, and
  this 'might' be something useful for contiguous allocations as well.

I wonder if going down the path of a separate devide/filesystem/etc for
contiguous allocations might be a better option.  It would keep the
implementation somewhat separate.  However, I would then be afraid that
we end up with another 'separate/special vm' as in the case of hugetlbfs
today.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
