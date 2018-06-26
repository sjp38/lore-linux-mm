Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 132716B0003
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 20:07:05 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b7-v6so5580205pgv.5
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 17:07:05 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id a4-v6si205091pfi.353.2018.06.25.17.07.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jun 2018 17:07:03 -0700 (PDT)
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
 <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
 <3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com>
 <158a4e4c-d290-77c4-a595-71332ede392b@linux.alibaba.com>
 <BFD6A249-B1D7-43D5-8D7C-9FAED4A168A1@gmail.com>
 <20180620071817.GJ13685@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <263935d9-d07c-ab3e-9e42-89f73f57be1e@linux.alibaba.com>
Date: Mon, 25 Jun 2018 17:06:23 -0700
MIME-Version: 1.0
In-Reply-To: <20180620071817.GJ13685@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Nadav Amit <nadav.amit@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, ldufour@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org



On 6/20/18 12:18 AM, Michal Hocko wrote:
> On Tue 19-06-18 17:31:27, Nadav Amit wrote:
>> at 4:08 PM, Yang Shi <yang.shi@linux.alibaba.com> wrote:
>>
>>>
>>> On 6/19/18 3:17 PM, Nadav Amit wrote:
>>>> at 4:34 PM, Yang Shi <yang.shi@linux.alibaba.com>
>>>>   wrote:
>>>>
>>>>
>>>>> When running some mmap/munmap scalability tests with large memory (i.e.
>>>>>
>>>>>> 300GB), the below hung task issue may happen occasionally.
>>>>>>
>>>>> INFO: task ps:14018 blocked for more than 120 seconds.
>>>>>        Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
>>>>> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>>>>> message.
>>>>> ps              D    0 14018      1 0x00000004
>>>>>
>>>>>
>>>> (snip)
>>>>
>>>>
>>>>> Zapping pages is the most time consuming part, according to the
>>>>> suggestion from Michal Hock [1], zapping pages can be done with holding
>>>>> read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
>>>>> mmap_sem to manipulate vmas.
>>>>>
>>>> Does munmap() == MADV_DONTNEED + munmap() ?
>>> Not exactly the same. So, I basically copied the page zapping used by munmap instead of calling MADV_DONTNEED.
>>>
>>>> For example, what happens with userfaultfd in this case? Can you get an
>>>> extra #PF, which would be visible to userspace, before the munmap is
>>>> finished?
>>>>
>>> userfaultfd is handled by regular munmap path. So, no change to userfaultfd part.
>> Right. I see it now.
>>
>>>> In addition, would it be ok for the user to potentially get a zeroed page in
>>>> the time window after the MADV_DONTNEED finished removing a PTE and before
>>>> the munmap() is done?
>>>>
>>> This should be undefined behavior according to Michal. This has been discussed in  https://lwn.net/Articles/753269/.
>> Thanks for the reference.
>>
>> Reading the man page I see: "All pages containing a part of the indicated
>> range are unmapped, and subsequent references to these pages will generate
>> SIGSEGV.a??
> Yes, this is true but I guess what Yang Shi meant was that an userspace
> access racing with munmap is not well defined. You never know whether
> you get your data, #PTF or SEGV because it depends on timing. The user
> visible change might be that you lose content and get zero page instead
> if you hit the race window while we are unmapping which was not possible
> before. But whouldn't such an access pattern be buggy anyway? You need
> some form of external synchronization AFAICS.
>
> But maybe some userspace depends on "getting right data or get SEGV"
> semantic. If we have to preserve that then we can come up with a VM_DEAD
> flag set before we tear it down and force the SEGV on the #PF path.
> Something similar we already do for MMF_UNSTABLE.

By looking this deeper, we may not be able to cover all the unmapping 
range for VM_DEAD, for example, if the start addr is in the middle of a 
vma. We can't set VM_DEAD to that vma since that would trigger SIGSEGV 
for still mapped area.

splitting can't be done with read mmap_sem held, so maybe just set 
VM_DEAD to non-overlapped vmas. Access to overlapped vmas (first and 
last) will still have undefined behavior.

Thanks,
Yang
