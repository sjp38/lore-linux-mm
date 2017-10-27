Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C9B2B6B0033
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 10:30:40 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id c21so3368144wrg.16
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 07:30:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b5si5848836wrf.514.2017.10.27.07.30.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Oct 2017 07:30:38 -0700 (PDT)
Subject: Re: PROBLEM: Remapping hugepages mappings causes kernel to return
 EINVAL
References: <6b639da5-ad9a-158c-ad4a-7a4e44bd98fc@gmx.de>
 <5fb8955d-23af-ec85-a19f-3a5b26cc04d1@oracle.com>
 <20171023114210.j7ip75ewoy2tiqs4@dhcp22.suse.cz>
 <e2cc07b7-3c5e-a166-0bb2-eff92fc70cd1@gmx.de>
 <20171023124122.tjmrbcwo2btzk3li@dhcp22.suse.cz>
 <b6cbb960-d0f1-0630-a2a1-e00bab4af0a1@gmx.de>
 <20171023161316.ajrxgd2jzo3u52eu@dhcp22.suse.cz>
 <93ffc1c8-3401-2bea-732a-17d373d2f24c@gmx.de>
 <20171023165717.qx5qluryshz62zv5@dhcp22.suse.cz>
 <b138bcf8-0a66-a988-4040-520d767da266@gmx.de>
 <20171023180232.luayzqacnkepnm57@dhcp22.suse.cz>
 <0c934e18-5436-792f-2b2c-ebca3ae2d786@gmx.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b27c7b12-beb3-abdd-fde1-3d48fa73ea81@suse.cz>
Date: Fri, 27 Oct 2017 16:29:16 +0200
MIME-Version: 1.0
In-Reply-To: <0c934e18-5436-792f-2b2c-ebca3ae2d786@gmx.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>, Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 10/24/2017 09:41 AM, C.Wehrmeyer wrote:
> On 2017-10-23 20:02, Michal Hocko wrote:
>> On Mon 23-10-17 19:52:27, C.Wehrmeyer wrote:
>> [...]
>>>> or you can mmap a larger block and
>>>> munmap the initial unaligned part.
>>>
>>> And how is that supposed to be transparent? When I hear "transparent" I
>>> think of a mechanism which I can put under a system so that it benefits from
>>> it, while the system does not notice or at least does not need to be aware
>>> of it. The system also does not need to be changed for it.
>>
>> How do you expect to get a huge page when the mapping itself is not
>> properly aligned?
> 
> There are four ways that I can think of from the top of my head, but 
> only one of them would be actually transparent.
> 
> 1. Provide a flag to mmap, which might be something different from 
> MAP_HUGETLB. After all your question revolved merely around properly 
> aligned pages - we don't want to *force* the kernel to reserve 
> hugepages, we just want it to provide the proper alignment in this case. 
> That wouldn't be very transparent, but it would be the easiest route to 
> go (and mmap already kind-of supports such a thing).

Maybe just have mmap() detect that the requested size is a multiple of
huge page size, and then align it automatically? I.e. a heuristic that
should work in 99% of the cases?

> 2. Based on transparent_hugepage/enabled always churn out properly 
> aligned pages. In this case madvise(MADV_HUGEPAGE) becomes obsolete - 

madvise(MADV_HUGEPAGE) isn't about alignment. It controls whether the
mapping can get THP pages when the system global default is set to
"madvise" (thus other mappings don't get them at all), or whether the
system will try harder to defragment memory during page fault to
instantiate a THP page, when the "defrag" option is not set to "always"
but "madvise".

> after all it's mmap which decides what kind of addresses we get. First 
> getting *some* mapping that isn't properly aligned for hugepages and 
> *then* trying to mitigate the damage by another syscall not only defies 
> the meaning of "transparent", but might also be hard to implement 
> kernel-side. Let's say I map 8 MiBs of memory, without mmap knowing that 
> I'd prefer this to be allocated via THPs. I could either go with your 
> route (map 8 MiBs and then some more, trim at the beginning and the end, 
> and then tell madvise that all of that is now going to be hugepages - 
> which is something that could easily be done in the kernel, especially 
> with the internal knowledge about what the actual page size is and 
> without all those context switches that one takes in by mapping, 
> munmapping, munmapping *again* and then *madvising* the actual memory), 
> or I'd go with my third option.
> 
> 3. I map 8 MiBs, some some misaligned address from mmap, and then try to 
> mitigate the damage by telling madvise that all that is now supposed to 
> use hugepages. The dumb way of implementing this would be to split the 
> mapping - one section at the beginning has 256 4-KiB pages, the next one 
> utilises 3 2-MiB pages, and the last section has 256 4-KiB pages again 
> (or some such), effectively equalling 8 MiBs. I don't even know if Linux 
> supports variable-page-size mappings, and of course we're still carrying

Yes, Linux can combine THP huge pages and base pages in the same mapping.

> 512 4-KiBs pages with us that would have easily been mapped into one 
> 2-MiB page, which is why I call it the dumb way.
> 
> 4. Like three, but a wee bit smarter: introduce another system call that 
> works like madvise(MADV_HUGEPAGE), but let it return the address of a 
> properly aligned mapping, thus giving userspace 4 genuine 2-MiB pages. 
> Just like 3) that wouldn't be transparent, but at least it's only 4 
> context switches that don't give us half-baked hugepages. However, this 
> approach would effectively only be 1), just more complicated and 
> un-transparent.
> 
> tl; dr:
> 
> 1. Provide mmap with some sort of flag (which would be redundant IMHO) 
> in order to churn out properly aligned pages (not transparent, but the 
> current MAP_HUGETLB flag isn't either).
> 2. Based on THP enabling status always churn out properly aligned pages, 
> and just failsafe to smaller pages if hugepages couldn't be allocated 
> (truly transparent).
> 3. Map in memory, then tell madvise to make as many hugepages out of it 
> as possible while still keeping the initial mapping (not transparent, 
> and not sure Linux can actually do that).
> 4. Introduce a new system call (not transparent from the get-go) to give 
> out properly aligned pages, or make them properly aligned while the 
> mapping is transformed from not-properly-aligned to properly-aligned.
> 
> Your call.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
