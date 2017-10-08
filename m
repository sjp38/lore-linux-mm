Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7CAFF6B025E
	for <linux-mm@kvack.org>; Sun,  8 Oct 2017 15:51:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j64so37369052pfj.6
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 12:51:21 -0700 (PDT)
Received: from out0-229.mail.aliyun.com (out0-229.mail.aliyun.com. [140.205.0.229])
        by mx.google.com with ESMTPS id y5si4812978pgs.580.2017.10.08.12.51.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Oct 2017 12:51:20 -0700 (PDT)
Subject: Re: [RFC PATCH] mm: shm: round up tmpfs size to huge page size when
 huge=always
References: <1507321330-22525-1-git-send-email-yang.s@alibaba-inc.com>
 <20171008125651.3mxiayuvuqi2hiku@node.shutemov.name>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <9357e3f2-6e49-b47a-20a6-ec7791c28fbd@alibaba-inc.com>
Date: Mon, 09 Oct 2017 03:51:06 +0800
MIME-Version: 1.0
In-Reply-To: <20171008125651.3mxiayuvuqi2hiku@node.shutemov.name>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: kirill.shutemov@linux.intel.com, hughd@google.com, mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/8/17 5:56 AM, Kirill A. Shutemov wrote:
> On Sat, Oct 07, 2017 at 04:22:10AM +0800, Yang Shi wrote:
>> When passing "huge=always" option for mounting tmpfs, THP is supposed to
>> be allocated all the time when it can fit, but when the available space is
>> smaller than the size of THP (2MB on x86), shmem fault handler still tries
>> to allocate huge page every time, then fallback to regular 4K page
>> allocation, i.e.:
>>
>> 	# mount -t tmpfs -o huge,size=3000k tmpfs /tmp
>> 	# dd if=/dev/zero of=/tmp/test bs=1k count=2048
>> 	# dd if=/dev/zero of=/tmp/test1 bs=1k count=2048
>>
>> The last dd command will handle 952 times page fault handler, then exit
>> with -ENOSPC.
>>
>> Rounding up tmpfs size to THP size in order to use THP with "always"
>> more efficiently. And, it will not wast too much memory (just allocate
>> 511 extra pages in worst case).
> 
> Hm. I don't think it's good idea to silently increase size of fs.

How about printing a warning to say the filesystem is resized?

> 
> Maybe better just refuse to mount with huge=always for too small fs?

It sounds fine too. When mounting tmpfs with "huge=always", if the size 
is not THP size aligned, it just can refuse to mount, then show warning 
about alignment restriction.

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
