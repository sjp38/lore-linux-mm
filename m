Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD5A8800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 15:32:42 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id s75so2804680vke.23
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 12:32:42 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id b128si3179367vkh.53.2018.01.24.12.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 12:32:41 -0800 (PST)
Subject: Re: [PATCH v2] mm: Reduce memory bloat with THP
References: <1516318444-30868-1-git-send-email-nitingupta910@gmail.com>
 <20180119124957.GA6584@dhcp22.suse.cz>
From: Nitin Gupta <nitin.m.gupta@oracle.com>
Message-ID: <ce7c1498-9f28-2eb0-67b7-ade9b04b8e2b@oracle.com>
Date: Fri, 19 Jan 2018 12:59:17 -0800
MIME-Version: 1.0
In-Reply-To: <20180119124957.GA6584@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Nitin Gupta <nitingupta910@gmail.com>
Cc: steven.sistare@oracle.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Shaohua Li <shli@fb.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 1/19/18 4:49 AM, Michal Hocko wrote:
> On Thu 18-01-18 15:33:16, Nitin Gupta wrote:
>> From: Nitin Gupta <nitin.m.gupta@oracle.com>
>>
>> Currently, if the THP enabled policy is "always", or the mode
>> is "madvise" and a region is marked as MADV_HUGEPAGE, a hugepage
>> is allocated on a page fault if the pud or pmd is empty.  This
>> yields the best VA translation performance, but increases memory
>> consumption if some small page ranges within the huge page are
>> never accessed.
> 
> Yes, this is true but hardly unexpected for MADV_HUGEPAGE or THP always
> users.
>  

Yes, allocating hugepage on first touch is the current behavior for
above two cases. However, I see issues with this current behavior.
Firstly, THP=always mode is often too aggressive/wasteful to be useful
for any realistic workloads. For THP=madvise, users may want to back
active parts of memory region with hugepages while avoiding aggressive
hugepage allocation on first touch. Or, they may really want the current
behavior.

With this patch, users would have the option to pick what behavior they
want by passing hints to the kernel in the form of MADV_HUGEPAGE and
MADV_DONTNEED madvise calls.


>> An alternate behavior for such page faults is to install a
>> hugepage only when a region is actually found to be (almost)
>> fully mapped and active.  This is a compromise between
>> translation performance and memory consumption.  Currently there
>> is no way for an application to choose this compromise for the
>> page fault conditions above.
> 
> Is that really true? We have /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none
> This is not reflected during the PF of course but you can control the
> behavior there as well. Either by the global setting or a per proces
> prctl.
> 

I think this part of patch description needs some rewording. This patch
is to change *only* the page fault behavior.

Once pages are installed, khugepaged does its job as usual, using
max_ptes_none and other config values. I'm not trying to change any
khugepaged behavior here.


>> With this change, whenever an application issues MADV_DONTNEED on a
>> memory region, the region is marked as "space-efficient". For such
>> regions, a hugepage is not immediately allocated on first write.
> 
> Kirill didn't like it in the previous version and I do not like this
> either. You are adding a very subtle side effect which might completely
> unexpected. Consider userspace memory allocator which uses MADV_DONTNEED
> to free up unused memory. Now you have put it out of THP usage
> basically.
>

Userpsace may want a region to be considered by khugepaged while opting
out of hugepage allocation on first touch. Asking userspace memory
allocators to have to track and reclaim unused parts of a THP allocated
hugepage does not seems right, as the kernel can use simple userspace
hints to avoid allocating extra memory in the first place.

I agree that this patch is adding a subtle side-effect which may take
some applications by surprise. However, I often see the opposite too:
for many workloads, disabling THP is the first advise as this aggressive
allocation of hugepages on first touch is unexpected and is too
wasteful. For e.g.:

1) Disabling THP for TokuDB (Storage engine for MySQL, MariaDB)
http://www.chriscalender.com/disabling-transparent-hugepages-for-tokudb/

2) Disable THP on MongoDB
https://docs.mongodb.com/manual/tutorial/transparent-huge-pages/

3) Disable THP for Couchbase Server
https://blog.couchbase.com/often-overlooked-linux-os-tweaks/

4) Redis
http://antirez.com/news/84


> If the memory is used really scarce then we have MADV_NOHUGEPAGE.
> 

It's not really about memory scarcity but a more efficient use of it.
Applications may want hugepage benefits without requiring any changes to
app code which is what THP is supposed to provide, while still avoiding
memory bloat.

-Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
