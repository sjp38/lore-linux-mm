Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE776B0003
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 21:03:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v10-v6so188918pfm.11
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 18:03:57 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id d24-v6si2668047plr.302.2018.06.26.18.03.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 18:03:56 -0700 (PDT)
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
 <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
 <3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com>
 <158a4e4c-d290-77c4-a595-71332ede392b@linux.alibaba.com>
 <BFD6A249-B1D7-43D5-8D7C-9FAED4A168A1@gmail.com>
 <20180620071817.GJ13685@dhcp22.suse.cz>
 <263935d9-d07c-ab3e-9e42-89f73f57be1e@linux.alibaba.com>
 <20180626074344.GZ2458@hirez.programming.kicks-ass.net>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <e54e298d-ef86-19a7-6f6b-07776f9a43e2@linux.alibaba.com>
Date: Tue, 26 Jun 2018 18:03:34 -0700
MIME-Version: 1.0
In-Reply-To: <20180626074344.GZ2458@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Matthew Wilcox <willy@infradead.org>, ldufour@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org



On 6/26/18 12:43 AM, Peter Zijlstra wrote:
> On Mon, Jun 25, 2018 at 05:06:23PM -0700, Yang Shi wrote:
>> By looking this deeper, we may not be able to cover all the unmapping range
>> for VM_DEAD, for example, if the start addr is in the middle of a vma. We
>> can't set VM_DEAD to that vma since that would trigger SIGSEGV for still
>> mapped area.
>>
>> splitting can't be done with read mmap_sem held, so maybe just set VM_DEAD
>> to non-overlapped vmas. Access to overlapped vmas (first and last) will
>> still have undefined behavior.
> Acquire mmap_sem for writing, split, mark VM_DEAD, drop mmap_sem. Acquire
> mmap_sem for reading, madv_free drop mmap_sem. Acquire mmap_sem for
> writing, free everything left, drop mmap_sem.
>
> ?
>
> Sure, you acquire the lock 3 times, but both write instances should be
> 'short', and I suppose you can do a demote between 1 and 2 if you care.

Thanks, Peter. Yes, by looking the code and trying two different 
approaches, it looks this approach is the most straight-forward one.

Splitting vma up-front can save a lot pain later. Holding write mmap_sem 
for this job before zapping mappings sounds worth the cost (very short 
write critical section).

And, VM_DEAD can be set exclusively with write mmap_sem without racing 
with page faults, this will give us consistent behavior for the race 
between PF and munmap. And, we don't need care about overlapped vma 
since it has been split before.

Yang
