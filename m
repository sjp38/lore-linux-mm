Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 74FC96B025E
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 09:18:54 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w95so2200719wrc.20
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 06:18:54 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id x7si3045120edl.469.2017.12.06.06.18.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 06:18:53 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v3 0/7] ktask: multithread CPU-intensive kernel work
References: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
 <20171205142300.67489b1a90605e1089c5aaa9@linux-foundation.org>
Message-ID: <03c1726f-5e6b-f879-5518-c77376adece4@oracle.com>
Date: Wed, 6 Dec 2017 09:21:49 -0500
MIME-Version: 1.0
In-Reply-To: <20171205142300.67489b1a90605e1089c5aaa9@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aaron.lu@intel.com, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

On 12/05/2017 05:23 PM, Andrew Morton wrote:
> On Tue,  5 Dec 2017 14:52:13 -0500 Daniel Jordan <daniel.m.jordan@oracle.com> wrote:
> 
>> This patchset is based on 4.15-rc2 plus one mmots fix[*] and contains three
>> ktask users:
>>   - deferred struct page initialization at boot time
>>   - clearing gigantic pages
>>   - fallocate for HugeTLB pages
> 
> Performance improvements are nice.  How much overall impact is there in
> real-world worklaods?

All of the users so far are mainly for initialization/startup, so the 
impact depends on how often users are rebooting (deferred struct page 
init) and starting applications such as RDBMS'es (hugetlbfs_fallocate).

ktask saves 5 seconds of boot time on the two-socket machine I tested on 
with deferred init, which is half the time it takes for the kernel to 
get to systemd, so for big machines that are frequently updated, the 
savings would add up.

> 
>> Work in progress:
>>   - Parallelizing page freeing in the exit/munmap paths
> 
> Also sounds interesting.

Parallelizing this efficiently depends on scaling lru_lock and 
zone->lock, which I've been working on separately.

Have you identified any other parallelizable
> operations?  vfs object teardown at umount time may be one...

By vfs object teardown, are you referring to evict_inodes/dispose_list?

If so, I actually have tried parallelizing that and there were good 
speedups during unmount with many cached pages.  It's just a matter of 
parallelizing well across inodes with different amounts of pages in cache.

I've also gotten good results with __get_user_pages.  If we want to keep 
the return value of __get_user_pages consistent on error (and I'm 
assuming that's a given), there needs to be logic that undoes the work 
past the first non-pinned page in the range so we continue to return the 
number of pages pinned from the start.  That seems ok since it's a slow 
path.

The shmem page free path (shmem_undo_range), struct page initialization 
on memory hotplug, and huge page copying are others I've considered but 
haven't implemented yet.

>>   - CPU hotplug support
> 
> Of what?  The ktask infrastructure itself?

Yes, ktask itself.  When CPUs come up or down, ktask's resource limits 
and preallocated data (the struct ktask_work's passed to the workqueue 
code) need to be adjusted for the new CPU count, at least as it's 
written now.

Thanks for the comments,
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
