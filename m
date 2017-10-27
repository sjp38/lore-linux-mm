Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E36286B0261
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 13:06:10 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 10so5031837qty.10
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 10:06:10 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i17si215010qtg.343.2017.10.27.10.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Oct 2017 10:06:09 -0700 (PDT)
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
 <b27c7b12-beb3-abdd-fde1-3d48fa73ea81@suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <2dad26cf-f37c-aada-053a-957c59c9858d@oracle.com>
Date: Fri, 27 Oct 2017 10:06:01 -0700
MIME-Version: 1.0
In-Reply-To: <b27c7b12-beb3-abdd-fde1-3d48fa73ea81@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, "C.Wehrmeyer" <c.wehrmeyer@gmx.de>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 10/27/2017 07:29 AM, Vlastimil Babka wrote:
> On 10/24/2017 09:41 AM, C.Wehrmeyer wrote:
>> On 2017-10-23 20:02, Michal Hocko wrote:
>>> On Mon 23-10-17 19:52:27, C.Wehrmeyer wrote:
>>> [...]
>>
>> 1. Provide a flag to mmap, which might be something different from 
>> MAP_HUGETLB. After all your question revolved merely around properly 
>> aligned pages - we don't want to *force* the kernel to reserve 
>> hugepages, we just want it to provide the proper alignment in this case. 
>> That wouldn't be very transparent, but it would be the easiest route to 
>> go (and mmap already kind-of supports such a thing).
> 
> Maybe just have mmap() detect that the requested size is a multiple of
> huge page size, and then align it automatically? I.e. a heuristic that
> should work in 99% of the cases?

We already do this for DAX (see thp_get_unmapped_area).  So, not much
code to write.  But could potentially fragment address spaces more.
We could also check to determine if the system/process/mapping is even
THP enabled before doing the alignment.

I like the idea, but still am concerned about fragmentation.  In addition,
even though applications shouldn't care where new mappings are placed it
would not surprise me that such a change will be noticeable to some.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
