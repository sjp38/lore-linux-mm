Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 92A9C6B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 23:42:12 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b16so12080059pfi.5
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 20:42:12 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id y11si10985363pgq.435.2018.04.23.20.42.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 20:42:10 -0700 (PDT)
Subject: Re: [RFC v2 PATCH] mm: shmem: make stat.st_blksize return huge page
 size if THP is on
References: <1524242039-64997-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180423004748.GP17484@dhcp22.suse.cz>
 <3c59a1d1-dc66-ae5f-452c-dd0adb047433@linux.alibaba.com>
 <20180423150435.GS17484@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <aa4b8c48-781a-204c-246a-afa5a54dba99@linux.alibaba.com>
Date: Mon, 23 Apr 2018 21:41:50 -0600
MIME-Version: 1.0
In-Reply-To: <20180423150435.GS17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, kirill.shutemov@linux.intel.com
Cc: hughd@google.com, hch@infradead.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 4/23/18 9:04 AM, Michal Hocko wrote:
> On Sun 22-04-18 21:28:59, Yang Shi wrote:
>>
>> On 4/22/18 6:47 PM, Michal Hocko wrote:
> [...]
>>> will be used on the first aligned address even when the initial/last
>>> portion of the mapping is not THP aligned.
>> No, my test shows it is not. And, transhuge_vma_suitable() does check the
>> virtual address alignment. If it is not huge page size aligned, it will not
>> set PMD for huge page.
> It's been quite some time since I've looked at that code but I think you
> are wrong. It just doesn't make sense to make the THP decision on the
> VMA alignment much. Kirill, can you clarify please?

Thanks a lot Michal and Kirill to elaborate how tmpfs THP make pmd map.

I did a quick test, THP will be PMD mapped as long as :
* hint address is huge page aligned if MAP_FIXED
Or
* offset is huge page aligned
And
* The size is big enough (>= huge page size)

This test does verify what Kirill said. And, I dig into a little further 
qemu code and did strace, qemu does try to mmap the file to non huge 
page aligned address with MAP_FIXED.

I will correct the commit log then submit v4.

Yang

>
> Please note that I have no objections to actually export the huge page
> size as the max block size but your changelog just doesn't make any
> sense to me.
