Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 51AA76B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 14:43:42 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id b184so8248122iof.21
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 11:43:42 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id l17si1372293itl.160.2018.01.25.11.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 11:43:36 -0800 (PST)
Subject: Re: [PATCH v2] mm: Reduce memory bloat with THP
References: <1516318444-30868-1-git-send-email-nitingupta910@gmail.com>
 <20180119124957.GA6584@dhcp22.suse.cz>
 <ce7c1498-9f28-2eb0-67b7-ade9b04b8e2b@oracle.com>
 <59F98618-C49F-48A8-BCA1-A8F717888BAA@cs.rutgers.edu>
From: Nitin Gupta <nitin.m.gupta@oracle.com>
Message-ID: <4d7ce874-9771-ad5f-c064-52a46fc37689@oracle.com>
Date: Thu, 25 Jan 2018 11:41:03 -0800
MIME-Version: 1.0
In-Reply-To: <59F98618-C49F-48A8-BCA1-A8F717888BAA@cs.rutgers.edu>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Michal Hocko <mhocko@kernel.org>, Nitin Gupta <nitingupta910@gmail.com>, steven.sistare@oracle.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander" <alexander.levin@verizon.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Shaohua Li <shli@fb.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 01/24/2018 04:47 PM, Zi Yan wrote:
>>>> With this change, whenever an application issues MADV_DONTNEED on a
>>>> memory region, the region is marked as "space-efficient". For such
>>>> regions, a hugepage is not immediately allocated on first write.
>>> Kirill didn't like it in the previous version and I do not like this
>>> either. You are adding a very subtle side effect which might completely
>>> unexpected. Consider userspace memory allocator which uses MADV_DONTNEED
>>> to free up unused memory. Now you have put it out of THP usage
>>> basically.
>>>
>> Userpsace may want a region to be considered by khugepaged while opting
>> out of hugepage allocation on first touch. Asking userspace memory
>> allocators to have to track and reclaim unused parts of a THP allocated
>> hugepage does not seems right, as the kernel can use simple userspace
>> hints to avoid allocating extra memory in the first place.
>>
>> I agree that this patch is adding a subtle side-effect which may take
>> some applications by surprise. However, I often see the opposite too:
>> for many workloads, disabling THP is the first advise as this aggressive
>> allocation of hugepages on first touch is unexpected and is too
>> wasteful. For e.g.:
>>
>> 1) Disabling THP for TokuDB (Storage engine for MySQL, MariaDB)
>> http://www.chriscalender.com/disabling-transparent-hugepages-for-tokudb/
>>
>> 2) Disable THP on MongoDB
>> https://docs.mongodb.com/manual/tutorial/transparent-huge-pages/
>>
>> 3) Disable THP for Couchbase Server
>> https://blog.couchbase.com/often-overlooked-linux-os-tweaks/
>>
>> 4) Redis
>> http://antirez.com/news/84
>>
>>
>>> If the memory is used really scarce then we have MADV_NOHUGEPAGE.
>>>
>> It's not really about memory scarcity but a more efficient use of it.
>> Applications may want hugepage benefits without requiring any changes to
>> app code which is what THP is supposed to provide, while still avoiding
>> memory bloat.
>>
> I read these links and find that there are mainly two complains:
> 1. THP causes latency spikes, because direction compaction slows down THP allocation,
> 2. THP bloats memory footprint when jemalloc uses MADV_DONTNEED to return memory ranges smaller than
>    THP size and fails because of THP.
>
> The first complain is not related to this patch.

I'm trying to address many different THP issues and memory bloat is
first among them.
> For second one, at least with recent kernels, MADV_DONTNEED splits THPs and returns the memory range you
> specified in madvise(). Am I missing anything?
>

Yes, MADV_DONTNEED splits THPs and releases the requested range but
this is not
solving the issue of aggressive alloc-hugepage-on-first-touch policy
of THP=madvise
on MADV_HUGEPAGE regions. Sure, some workloads may prefer that policy
but for
application that don't, this patch give them an option to give hints
to the kernel to
go for gradual hugepage promotion via khugepaged only (and not on
first touch).

It's not good if an application has to track which parts of their
(implicitly allocated)
hugepage are in use and which sub-parts are free so they can issue
MADV_DONTNEED
calls on them. This approach really does not make THP "transparent"
and requires
lot of mm tracking code in userpace.

Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
