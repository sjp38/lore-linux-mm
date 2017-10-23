Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2070E6B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 10:00:40 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t69so6785981wmt.7
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 07:00:40 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.18])
        by mx.google.com with ESMTPS id b45si5777183wrg.225.2017.10.23.07.00.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 07:00:34 -0700 (PDT)
Subject: Re: PROBLEM: Remapping hugepages mappings causes kernel to return
 EINVAL
References: <93684e4b-9e60-ef3a-ba62-5719fdf7cff9@gmx.de>
 <6b639da5-ad9a-158c-ad4a-7a4e44bd98fc@gmx.de>
 <5fb8955d-23af-ec85-a19f-3a5b26cc04d1@oracle.com>
 <20171023114210.j7ip75ewoy2tiqs4@dhcp22.suse.cz>
 <e2cc07b7-3c5e-a166-0bb2-eff92fc70cd1@gmx.de>
 <20171023124122.tjmrbcwo2btzk3li@dhcp22.suse.cz>
From: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>
Message-ID: <b6cbb960-d0f1-0630-a2a1-e00bab4af0a1@gmx.de>
Date: Mon, 23 Oct 2017 16:00:13 +0200
MIME-Version: 1.0
In-Reply-To: <20171023124122.tjmrbcwo2btzk3li@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On 2017-10-23 14:41, Michal Hocko wrote:
> On Mon 23-10-17 14:22:30, C.Wehrmeyer wrote:
>> On 2017-10-23 13:42, Michal Hocko wrote:
>>> I do not remember any such a request either. I can see some merit in the
>>> described use case. It is not specific on why hugetlb pages are used for
>>> the allocator memory because that comes with it own issues.
>>
>> That is yet for the user to specify. As of now hugepages still require a
>> special setup that not all people might have as of now - to my knowledge a
>> kernel being compiled with CONFIG_TRANSPARENT_HUGEPAGE=y and a number of
>> such pages being allocated either through the kernel boot line or through
> 
> CONFIG_TRANSPARENT_HUGEPAGE has nothing to do with hugetlb pages. These
> are THP which do not need any special configuration and mremap works on
> them.

I was not aware of the fact that HP != THP, so thank you for clarifying 
that.

> This is no longer true. GB pages can be allocated during runtime as
> well.

Didn't know that as well. I just knew the last time I tested this it was 
not possible.

>> 2-MiB pages, on the other hand,
>> shouldn't have those limitations anymore. User-space programs should be
>> capable of allocating such pages without the need for the user to fiddle
>> with nr_hugepages beforehand.
> 
> And that is what we have THP for...

Then I might have been using it incorrectly? I've been digging through 
Documentation/vm/transhuge.txt after your initial pointing out, and 
verified that the kernel uses THPs pretty much always, without the usage 
of madvise:

# cat /sys/kernel/mm/transparent_hugepage/enabled
[always] madvise never

And just to be very sure I've added:

if (madvise(buf1,ALLOC_SIZE_1,MADV_HUGEPAGE)) {
         errno_tmp = errno;
         fprintf(stderr,"madvise: %u\n",errno_tmp);
         goto out;
}

/*Make sure the mapping is actually used*/
memset(buf1,'!',ALLOC_SIZE_1);

/*Give me time for monitoring*/
sleep(2000);

right after the mmap call. I've also made sure that nothing is being 
optimised away by the compiler. With a 2MiB mapping being requested this 
should be a good opportunity for the kernel, and yet when I try to 
figure out how many THPs my processes uses:

$ cat /proc/21986/smaps  | grep 'AnonHuge'

I just end up with lots of:

AnonHugePages:         0 kB

And cat /proc/meminfo | grep 'Huge' doesn't change significantly as 
well. Am I just doing something wrong here, or shouldn't I trust the THP 
mechanisms to actually allocate hugepages for me?

> General purpose allocator playing with hugetlb
> pages is rather tricky and I would be really cautious there. I would
> rather play with THP to reduce the TLB footprint.

May one ask why you'd recommend to be cautious here? I understand that 
actual huge pages can slow down certain things - swapping comes to mind 
immediately, which is probably the reason why Linux (used to?) lock such 
pages in memory as well.

I once again want to emphasise that this is my first time writing to the 
mailing list. It might be redundant, but I'm not yet used to any 
conventions or technical details you're familiar with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
