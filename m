Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5040D6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 12:23:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l2-v6so57406pff.3
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 09:23:55 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id d7-v6si2177210pgf.484.2018.06.20.09.23.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 09:23:52 -0700 (PDT)
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
 <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
 <20180619100218.GN2458@hirez.programming.kicks-ass.net>
 <f78924fc-ea81-9ddd-ebb2-28241d5721c8@linux.alibaba.com>
 <20180620071708.GI13685@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <41456a0f-0091-dfdb-952b-9bf08b323ba6@linux.alibaba.com>
Date: Wed, 20 Jun 2018 09:23:17 -0700
MIME-Version: 1.0
In-Reply-To: <20180620071708.GI13685@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 6/20/18 12:17 AM, Michal Hocko wrote:
> On Tue 19-06-18 14:13:05, Yang Shi wrote:
>>
>> On 6/19/18 3:02 AM, Peter Zijlstra wrote:
> [...]
>>> Hold up, two things: you having to copy most of do_munmap() didn't seem
>>> to suggest a helper function? And second, since when are we allowed to
>> Yes, they will be extracted into a helper function in the next version.
>>
>> May bad, I don't think it is allowed. We could reform this to:
>>
>> acquire write mmap_sem
>> vma lookup (split vmas)
>> release write mmap_sem
>>
>> acquire read mmap_sem
>> zap pages
>> release read mmap_sem
>>
>> I'm supposed this is safe as what Michal said before.
> I didn't get to read your patches carefully yet but I am wondering why
> do you need to split in the first place. Why cannot you simply unmap the
> range (madvise(DONTNEED)) under the read lock and then take the lock for
> write to finish the rest?

Yes, we can. I just thought splitting vma up-front sounds more straight 
forward. But, I neglected the write mmap_sem issue. Will move the vma 
split into later write mmap_sem in the next version.

Thanks,
Yang
