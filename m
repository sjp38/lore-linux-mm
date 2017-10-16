Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 695FF6B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 16:32:58 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id y15so13192281ita.22
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 13:32:58 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e18si6070733ioj.46.2017.10.16.13.32.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 13:32:56 -0700 (PDT)
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
References: <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
 <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
 <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake>
 <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz>
 <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
 <aff6b405-6a06-f84d-c9b1-c6fb166dff81@oracle.com>
 <20171016180749.2y2v4ucchb33xnde@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <e8cf6227-003d-8a82-8b4d-07176b43810c@oracle.com>
Date: Mon, 16 Oct 2017 13:32:45 -0700
MIME-Version: 1.0
In-Reply-To: <20171016180749.2y2v4ucchb33xnde@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Guy Shattah <sguy@mellanox.com>, Christopher Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On 10/16/2017 11:07 AM, Michal Hocko wrote:
> On Mon 16-10-17 10:43:38, Mike Kravetz wrote:
>> Just to be clear, the posix standard talks about a typed memory object.
>> The suggested implementation has one create a connection to the memory
>> object to receive a fd, then use mmap as usual to get a mapping backed
>> by contiguous pages/memory.  Of course, this type of implementation is
>> not a requirement.
> 
> I am not sure that POSIC standard for typed memory is easily
> implementable in Linux. Does any OS actually implement this API?

A quick search only reveals Blackberry QNX and PlayBook OS.

Also somewhat related.  In a earlier thread someone pointed out this
out of tree module used for contiguous allocations in SOC (and other?)
environments.  It even has the option of making use of CMA.
http://processors.wiki.ti.com/index.php/CMEM_Overview

>> However, this type of implementation looks quite a
>> bit like hugetlbfs today.
>> - Both require opening a special file/device, and then calling mmap on
>>   the returned fd.  You can technically use mmap(MAP_HUGETLB), but that
>>   still ends up using hugetbfs.  BTW, there was resistance to adding the
>>   MAP_HUGETLB flag to mmap.
> 
> And I think we shouldn't really shape any API based on hugetlb.

Agree.  I only wanted to point out the similarities.
But, it does make me wonder how much of a benefit hugetlb 1G pages would
make in the the RDMA performance comparison.  The table in the presentation
show a average speedup of something like 27% (or so) for contiguous allocation
which I assume are 2GB in size.  Certainly, using hugetlb is not the ideal
case, just wondering if it does help and how much.

>> - Allocation of contiguous memory is much like 'on demand' allocation of
>>   huge pages.  There are some (not many) users that use this model.  They
>>   attempt to allocate huge pages on demand, and if not available fall back
>>   to base pages.  This is how contiguous allocations would need to work.
>>   Of course, most hugetlbfs users pre-allocate pages for their use, and
>>   this 'might' be something useful for contiguous allocations as well.
> 
> But there is still admin configuration required to consume memory from
> the pool or overcommit that pool.
> 
>> I wonder if going down the path of a separate devide/filesystem/etc for
>> contiguous allocations might be a better option.  It would keep the
>> implementation somewhat separate.  However, I would then be afraid that
>> we end up with another 'separate/special vm' as in the case of hugetlbfs
>> today.
> 
> That depends on who is actually going to use the contiguous memory. If
> we are talking about drivers to communication to the userspace then
> using driver specific fd with its mmap implementation then we do not
> need any special fs nor a seperate infrastructure. Well except for a
> library function to handle the MM side of the thing.

If we embed this functionality into device specific mmap calls it will
closely tie the usage to the devices.  However, don't we still have to
worry about potential interaction with other parts of the mm as you mention
below?  I guess that would be the library function and how it is used
by drivers.

-- 
Mike Kravetz

> If we really need a general purpose physical contiguous memory allocator
> then I would agree that using MAP_ flag might be a way to go but that
> would require a very careful consideration of who is allowed to allocate
> and how much/large blocks. I do not see a good fit to conveying that
> information to the kernel right now. Moreover, and most importantly, I
> haven't heard any sound usecase for such a functionality in the first
> place. There is some hand waving about performance but there are no real
> numbers to back those claims AFAIK. Not to mention a serious
> consideration of potential consequences of the whole MM.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
