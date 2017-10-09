Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9FE366B025F
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 12:43:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a7so61451972pfj.3
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 09:43:48 -0700 (PDT)
Received: from out0-225.mail.aliyun.com (out0-225.mail.aliyun.com. [140.205.0.225])
        by mx.google.com with ESMTPS id l10si7374321pff.527.2017.10.09.09.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 09:43:47 -0700 (PDT)
Subject: Re: [RFC PATCH] mm: shm: round up tmpfs size to huge page size when
 huge=always
References: <1507321330-22525-1-git-send-email-yang.s@alibaba-inc.com>
 <20171008125651.3mxiayuvuqi2hiku@node.shutemov.name>
 <20171009064811.lmotdeuewfbznhzq@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <20e565eb-9cef-4203-4182-14e2b8e704bf@alibaba-inc.com>
Date: Tue, 10 Oct 2017 00:43:31 +0800
MIME-Version: 1.0
In-Reply-To: <20171009064811.lmotdeuewfbznhzq@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: kirill.shutemov@linux.intel.com, hughd@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/8/17 11:48 PM, Michal Hocko wrote:
> On Sun 08-10-17 15:56:51, Kirill A. Shutemov wrote:
>> On Sat, Oct 07, 2017 at 04:22:10AM +0800, Yang Shi wrote:
>>> When passing "huge=always" option for mounting tmpfs, THP is supposed to
>>> be allocated all the time when it can fit, but when the available space is
>>> smaller than the size of THP (2MB on x86), shmem fault handler still tries
>>> to allocate huge page every time, then fallback to regular 4K page
>>> allocation, i.e.:
>>>
>>> 	# mount -t tmpfs -o huge,size=3000k tmpfs /tmp
>>> 	# dd if=/dev/zero of=/tmp/test bs=1k count=2048
>>> 	# dd if=/dev/zero of=/tmp/test1 bs=1k count=2048
>>>
>>> The last dd command will handle 952 times page fault handler, then exit
>>> with -ENOSPC.
>>>
>>> Rounding up tmpfs size to THP size in order to use THP with "always"
>>> more efficiently. And, it will not wast too much memory (just allocate
>>> 511 extra pages in worst case).
>>
>> Hm. I don't think it's good idea to silently increase size of fs.
> 
> Agreed!
> 
>> Maybe better just refuse to mount with huge=always for too small fs?
> 
> We cannot we simply have the remaining page !THP? What is the actual
> problem?

The remaining pages can be !THP, it will fall back to regular 4k pages 
when the available space is less than THP size.

I just wonder it sounds not make sense to *not* mount tmpfs with THP 
size alignment when "huge=always" is passed.

I guess someone would like to assume all allocation in tmpfs with 
"huge=always" should be THP. But, they might not be fully aware of in 
some corner cases THP might be not used, for example, the remaining 
space is less then THP size, then some unexpected performance degrade 
might be perceived.

So, why not we do the mount correctly at the first place. It could be 
delegated to the administrator, but it should be better to give some 
hint from kernel side.

Thanks,
Yang


> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
