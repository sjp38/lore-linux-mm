Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 224828E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 06:09:36 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id n64-v6so12384311qkd.10
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 03:09:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y35-v6si1128281qtk.314.2018.09.26.03.09.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 03:09:35 -0700 (PDT)
Subject: Re: [PATCH v2 5/6] powerpc/powernv: hold device_hotplug_lock when
 calling memtrace_offline_pages()
References: <20180925091457.28651-1-david@redhat.com>
 <20180925091457.28651-6-david@redhat.com> <20180925121504.GH8537@350D>
From: David Hildenbrand <david@redhat.com>
Message-ID: <19de0a52-2abd-6e79-1b8e-dcf17eff3fba@redhat.com>
Date: Wed, 26 Sep 2018 12:09:10 +0200
MIME-Version: 1.0
In-Reply-To: <20180925121504.GH8537@350D>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Rashmica Gupta <rashmica.g@gmail.com>, Michael Neuling <mikey@neuling.org>

On 25/09/2018 14:15, Balbir Singh wrote:
> On Tue, Sep 25, 2018 at 11:14:56AM +0200, David Hildenbrand wrote:
>> Let's perform all checking + offlining + removing under
>> device_hotplug_lock, so nobody can mess with these devices via
>> sysfs concurrently.
>>
>> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> Cc: Paul Mackerras <paulus@samba.org>
>> Cc: Michael Ellerman <mpe@ellerman.id.au>
>> Cc: Rashmica Gupta <rashmica.g@gmail.com>
>> Cc: Balbir Singh <bsingharora@gmail.com>
>> Cc: Michael Neuling <mikey@neuling.org>
>> Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
>> Reviewed-by: Rashmica Gupta <rashmica.g@gmail.com>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>>  arch/powerpc/platforms/powernv/memtrace.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/powerpc/platforms/powernv/memtrace.c b/arch/powerpc/platforms/powernv/memtrace.c
>> index fdd48f1a39f7..d84d09c56af9 100644
>> --- a/arch/powerpc/platforms/powernv/memtrace.c
>> +++ b/arch/powerpc/platforms/powernv/memtrace.c
>> @@ -70,6 +70,7 @@ static int change_memblock_state(struct memory_block *mem, void *arg)
>>  	return 0;
>>  }
>>  
>> +/* called with device_hotplug_lock held */
>>  static bool memtrace_offline_pages(u32 nid, u64 start_pfn, u64 nr_pages)
>>  {
>>  	u64 end_pfn = start_pfn + nr_pages - 1;
>> @@ -111,6 +112,7 @@ static u64 memtrace_alloc_node(u32 nid, u64 size)
>>  	end_pfn = round_down(end_pfn - nr_pages, nr_pages);
>>  
>>  	for (base_pfn = end_pfn; base_pfn > start_pfn; base_pfn -= nr_pages) {
>> +		lock_device_hotplug();
> 
> Why not grab the lock before the for loop? That way we can avoid bad cases like a
> large node being scanned for a small number of pages (nr_pages). Ideally we need
> a cond_resched() in the loop, but I guess offline_pages() has one.

Yes, it does.

I can move it out of the loop, thanks!

> 
> Acked-by: Balbir Singh <bsingharora@gmail.com>
> 


-- 

Thanks,

David / dhildenb
