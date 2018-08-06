Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 124506B0006
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 16:48:44 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g18-v6so9191274pfh.20
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 13:48:44 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id q16-v6si10615623pls.404.2018.08.06.13.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 13:48:42 -0700 (PDT)
Subject: Re: [RFC v6 PATCH 2/2] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1532628614-111702-1-git-send-email-yang.shi@linux.alibaba.com>
 <1532628614-111702-3-git-send-email-yang.shi@linux.alibaba.com>
 <20180803090759.GI27245@dhcp22.suse.cz>
 <aff7e86d-2e48-ff58-5d5d-9c67deb68674@linux.alibaba.com>
 <20180806094005.GG19540@dhcp22.suse.cz>
 <76c0fc2b-fca7-9f22-214a-920ee2537898@linux.alibaba.com>
 <20180806204119.GL10003@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <28de768b-c740-37b3-ea5a-8e2cb07d2bdc@linux.alibaba.com>
Date: Mon, 6 Aug 2018 13:48:35 -0700
MIME-Version: 1.0
In-Reply-To: <20180806204119.GL10003@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 8/6/18 1:41 PM, Michal Hocko wrote:
> On Mon 06-08-18 09:46:30, Yang Shi wrote:
>>
>> On 8/6/18 2:40 AM, Michal Hocko wrote:
>>> On Fri 03-08-18 14:01:58, Yang Shi wrote:
>>>> On 8/3/18 2:07 AM, Michal Hocko wrote:
>>>>> On Fri 27-07-18 02:10:14, Yang Shi wrote:
> [...]
>>>>>> If the vma has VM_LOCKED | VM_HUGETLB | VM_PFNMAP or uprobe, they are
>>>>>> considered as special mappings. They will be dealt with before zapping
>>>>>> pages with write mmap_sem held. Basically, just update vm_flags.
>>>>> Well, I think it would be safer to simply fallback to the current
>>>>> implementation with these mappings and deal with them on top. This would
>>>>> make potential issues easier to bisect and partial reverts as well.
>>>> Do you mean just call do_munmap()? It sounds ok. Although we may waste some
>>>> cycles to repeat what has done, it sounds not too bad since those special
>>>> mappings should be not very common.
>>> VM_HUGETLB is quite spread. Especially for DB workloads.
>> Wait a minute. In this way, it sounds we go back to my old implementation
>> with special handling for those mappings with write mmap_sem held, right?
> Yes, I would really start simple and add further enhacements on top.

If updating vm_flags with read lock is safe in this case, we don't have 
to do this. The only reason for this special handling is about vm_flags 
update.
