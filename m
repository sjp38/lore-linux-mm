Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9A96B2AE7
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 12:08:25 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id l65-v6so3180003pge.17
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:08:25 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id k5-v6si5362534pfk.2.2018.08.23.09.08.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 09:08:23 -0700 (PDT)
Subject: Re: [RFC v8 PATCH 2/5] uprobes: introduce has_uprobes helper
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
 <1534358990-85530-3-git-send-email-yang.shi@linux.alibaba.com>
 <e7147e14-bc38-03d0-90a4-5e0ca7e40050@suse.cz>
 <20180822150718.GB52756@linux.vnet.ibm.com>
 <20180823151554.GC10652@redhat.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <dc0d9e87-4f38-a6f9-8513-1c682bfaccc7@linux.alibaba.com>
Date: Thu, 23 Aug 2018 09:07:43 -0700
MIME-Version: 1.0
In-Reply-To: <20180823151554.GC10652@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, liu.song.a23@gmail.com, ravi.bangoria@linux.ibm.com, linux-kernel@vger.kernel.org



On 8/23/18 8:15 AM, Oleg Nesterov wrote:
> On 08/22, Srikar Dronamraju wrote:
>> * Vlastimil Babka <vbabka@suse.cz> [2018-08-22 12:55:59]:
>>
>>> On 08/15/2018 08:49 PM, Yang Shi wrote:
>>>> We need check if mm or vma has uprobes in the following patch to check
>>>> if a vma could be unmapped with holding read mmap_sem.
> Confused... why can't we call uprobe_munmap() under read_lock(mmap_sem) ?

I'm not sure if it is safe or not because it is not recommended and not 
safe to update vma's vm flags with read mmap_sem. uprobe_munmap() may 
update mm flags (MMF_RECALC_UPROBES). So, it sounds safer to not call it 
under read mmap_sem.

>
> OK, it can race with find_active_uprobe() but I do not see anything really
> wrong, and a false-positive MMF_RECALC_UPROBES is fine.

Thanks for confirming this. If it is ok to have such race, we don't have 
to have has_uprobes() helper anymore since it can be just called under 
read mmap_sem without any special handling.

Yang

>
> Again, I think we should simply kill uprobe_munmap(), but this needs another
> discussion.
>
> Oleg.
