Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A1AC6B0261
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 12:47:24 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o44so10370096wrf.0
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 09:47:24 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.19])
        by mx.google.com with ESMTPS id c10si2029176wrg.554.2017.10.23.09.47.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 09:47:22 -0700 (PDT)
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
From: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>
Message-ID: <93ffc1c8-3401-2bea-732a-17d373d2f24c@gmx.de>
Date: Mon, 23 Oct 2017 18:46:59 +0200
MIME-Version: 1.0
In-Reply-To: <20171023161316.ajrxgd2jzo3u52eu@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On 23-10-17 18:13, Michal Hocko wrote:
> On Mon 23-10-17 16:00:13, C.Wehrmeyer wrote:
>> And just to be very sure I've added:
>>
>> if (madvise(buf1,ALLOC_SIZE_1,MADV_HUGEPAGE)) {
>>          errno_tmp = errno;
>>          fprintf(stderr,"madvise: %u\n",errno_tmp);
>>          goto out;
>> }
>>
>> /*Make sure the mapping is actually used*/
>> memset(buf1,'!',ALLOC_SIZE_1);
> 
> Is the buffer aligned to 2MB?

When I omit MAP_HUGETLB for the flags that mmap receives - no.

#define ALLOC_SIZE_1 (2 * 1024 * 1024)
[...]
buf1 = mmap (
         NULL,
         ALLOC_SIZE_1,
         prot, /*PROT_READ | PROT_WRITE*/
         flags /*MAP_PRIVATE | MAP_ANONYMOUS*/,
         -1,
         0
);

In such a case buf1 usually contains addresses which are aligned to 4 
KiBs, such as 0x7f07d76e9000. 2-MiB-aligned addresses, such as 
0x7f89f5e00000, are only produced with MAP_HUGETLB - which, if I 
understood the documentation correctly, is not the point of THPs as they 
are supposed to be transparent.

I'm not exactly sure how I'm supposed to force mmap to give me any other 
kind of address, if that is going to be your suggestion - unless I'd 
read the mapping configuration for the current process and find myself a 
spot where I can tell mmap to create a mapping for me using MAP_FIXED. 
But that wouldn't be transparent, either.

>> /*Give me time for monitoring*/
>> sleep(2000);
>>
>> right after the mmap call. I've also made sure that nothing is being
>> optimised away by the compiler. With a 2MiB mapping being requested this
>> should be a good opportunity for the kernel, and yet when I try to figure
>> out how many THPs my processes uses:
>>
>> $ cat /proc/21986/smaps  | grep 'AnonHuge'
>>
>> I just end up with lots of:
>>
>> AnonHugePages:         0 kB
>>
>> And cat /proc/meminfo | grep 'Huge' doesn't change significantly as well. Am
>> I just doing something wrong here, or shouldn't I trust the THP mechanisms
>> to actually allocate hugepages for me?
> 
> If the mapping is aligned properly then the rest is up to system and
> availability of large physically contiguous memory blocks.

I have about 5 GiBs of free memory right now, and while I can not 
guarantee that memory fragmentation prevents the kernel from using THP, 
manually reserving 256 2-MiB pages through nr_hugepages and then freeing 
them works just fine. Yes, after allocating them I checked if 
nr_hugepages actually was 256. And yet, after immediately running my 
program, there would be no change any of the AnonHugePages elements that 
smaps exports. Also (while omitting MAP_HUGETLB) buf1 remains to be 
aligned to 4 KiB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
