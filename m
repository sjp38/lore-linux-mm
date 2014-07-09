Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 477796B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 11:08:30 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id z10so9148822pdj.15
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 08:08:29 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id nl15si7443330pdb.246.2014.07.09.08.08.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 08:08:28 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so9169911pde.34
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 08:08:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140709075252.GB31067@esperanza>
References: <cover.1404383187.git.vdavydov@parallels.com> <20140709075252.GB31067@esperanza>
From: Tim Hockin <thockin@hockin.org>
Date: Wed, 9 Jul 2014 08:08:07 -0700
Message-ID: <CAAAKZwsRDb6a062SFZYv-1SDYyD12uTzVMpdZt0CtdDjoddNVg@mail.gmail.com>
Subject: Re: [PATCH RFC 0/5] Virtual Memory Resource Controller for cgroups
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>

How is this different from RLIMIT_AS?  You specifically mentioned it
earlier but you don't explain how this is different.

>From my perspective, this is pointless.  There's plenty of perfectly
correct software that mmaps files without concern for VSIZE, because
they never fault most of those pages in.  From my observations it is
not generally possible to predict an average VSIZE limit that would
satisfy your concerns *and* not kill lots of valid apps.

It sounds like what you want is to limit or even disable swap usage.
Given your example, your hypothetical user would probably be better of
getting an OOM kill early so she can fix her job spec to request more
memory.

On Wed, Jul 9, 2014 at 12:52 AM, Vladimir Davydov
<vdavydov@parallels.com> wrote:
> On Thu, Jul 03, 2014 at 04:48:16PM +0400, Vladimir Davydov wrote:
>> Hi,
>>
>> Typically, when a process calls mmap, it isn't given all the memory pages it
>> requested immediately. Instead, only its address space is grown, while the
>> memory pages will be actually allocated on the first use. If the system fails
>> to allocate a page, it will have no choice except invoking the OOM killer,
>> which may kill this or any other process. Obviously, it isn't the best way of
>> telling the user that the system is unable to handle his request. It would be
>> much better to fail mmap with ENOMEM instead.
>>
>> That's why Linux has the memory overcommit control feature, which accounts and
>> limits VM size that may contribute to mem+swap, i.e. private writable mappings
>> and shared memory areas. However, currently it's only available system-wide,
>> and there's no way of avoiding OOM in cgroups.
>>
>> This patch set is an attempt to fill the gap. It implements the resource
>> controller for cgroups that accounts and limits address space allocations that
>> may contribute to mem+swap.
>>
>> The interface is similar to the one of the memory cgroup except it controls
>> virtual memory usage, not actual memory allocation:
>>
>>   vm.usage_in_bytes            current vm usage of processes inside cgroup
>>                                (read-only)
>>
>>   vm.max_usage_in_bytes        max vm.usage_in_bytes, can be reset by writing 0
>>
>>   vm.limit_in_bytes            vm.usage_in_bytes must be <= vm.limite_in_bytes;
>>                                allocations that hit the limit will be failed
>>                                with ENOMEM
>>
>>   vm.failcnt                   number of times the limit was hit, can be reset
>>                                by writing 0
>>
>> In future, the controller can be easily extended to account for locked pages
>> and shmem.
>
> Any thoughts on this?
>
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
