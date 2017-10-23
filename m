Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 034886B0069
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 13:52:50 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u78so7186696wmd.13
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 10:52:49 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.15])
        by mx.google.com with ESMTPS id v23si420426wmh.18.2017.10.23.10.52.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 10:52:48 -0700 (PDT)
Subject: Re: PROBLEM: Remapping hugepages mappings causes kernel to return
 EINVAL
References: <93684e4b-9e60-ef3a-ba62-5719fdf7cff9@gmx.de>
 <6b639da5-ad9a-158c-ad4a-7a4e44bd98fc@gmx.de>
 <5fb8955d-23af-ec85-a19f-3a5b26cc04d1@oracle.com>
 <20171023114210.j7ip75ewoy2tiqs4@dhcp22.suse.cz>
 <e2cc07b7-3c5e-a166-0bb2-eff92fc70cd1@gmx.de>
 <20171023124122.tjmrbcwo2btzk3li@dhcp22.suse.cz>
 <b6cbb960-d0f1-0630-a2a1-e00bab4af0a1@gmx.de>
 <20171023161316.ajrxgd2jzo3u52eu@dhcp22.suse.cz>
 <93ffc1c8-3401-2bea-732a-17d373d2f24c@gmx.de>
 <20171023165717.qx5qluryshz62zv5@dhcp22.suse.cz>
From: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>
Message-ID: <b138bcf8-0a66-a988-4040-520d767da266@gmx.de>
Date: Mon, 23 Oct 2017 19:52:27 +0200
MIME-Version: 1.0
In-Reply-To: <20171023165717.qx5qluryshz62zv5@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On 2017-10-23 18:57, Michal Hocko wrote:
> On Mon 23-10-17 18:46:59, C.Wehrmeyer wrote:
>> On 23-10-17 18:13, Michal Hocko wrote:
>>> On Mon 23-10-17 16:00:13, C.Wehrmeyer wrote:
>>>> And just to be very sure I've added:
>>>>
>>>> if (madvise(buf1,ALLOC_SIZE_1,MADV_HUGEPAGE)) {
>>>>           errno_tmp = errno;
>>>>           fprintf(stderr,"madvise: %u\n",errno_tmp);
>>>>           goto out;
>>>> }
>>>>
>>>> /*Make sure the mapping is actually used*/
>>>> memset(buf1,'!',ALLOC_SIZE_1);
>>>
>>> Is the buffer aligned to 2MB?
>>
>> When I omit MAP_HUGETLB for the flags that mmap receives - no.
>>
>> #define ALLOC_SIZE_1 (2 * 1024 * 1024)
>> [...]
>> buf1 = mmap (
>>          NULL,
>>          ALLOC_SIZE_1,
>>          prot, /*PROT_READ | PROT_WRITE*/
>>          flags /*MAP_PRIVATE | MAP_ANONYMOUS*/,
>>          -1,
>>          0
>> );
>>
>> In such a case buf1 usually contains addresses which are aligned to 4 KiBs,
>> such as 0x7f07d76e9000. 2-MiB-aligned addresses, such as 0x7f89f5e00000, are
>> only produced with MAP_HUGETLB - which, if I understood the documentation
>> correctly, is not the point of THPs as they are supposed to be transparent.
> 
> yes. You can use posix_memalign

Useless. We don't use the memory allocation structures of malloc/free, 
and yet that's exactly what this function requires us to do. The reason 
why we use mmap and mremap is to get rid of userspace-crap in the first 
place.

> or you can mmap a larger block and
> munmap the initial unaligned part.

And how is that supposed to be transparent? When I hear "transparent" I 
think of a mechanism which I can put under a system so that it benefits 
from it, while the system does not notice or at least does not need to 
be aware of it. The system also does not need to be changed for it.

This approach is even more un-transparent than providing a flag to mmap 
in order to make hugepages work correctly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
