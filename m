Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CECFC6B05E8
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:01:05 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id h15-v6so7374348qkh.3
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:01:05 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k22-v6si2926091qvk.187.2018.05.18.09.01.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 09:01:04 -0700 (PDT)
Subject: Re: [PATCH] mm/kasan: Don't vfree() nonexistent vm_area.
From: David Hildenbrand <david@redhat.com>
References: <12c9e499-9c11-d248-6a3f-14ec8c4e07f1@molgen.mpg.de>
 <20180201163349.8700-1-aryabinin@virtuozzo.com>
 <784dfdf6-8fc3-be08-833b-a9097c3d1b96@redhat.com>
Message-ID: <6982f59e-c836-1064-c05c-a926446b6f48@redhat.com>
Date: Fri, 18 May 2018 18:01:02 +0200
MIME-Version: 1.0
In-Reply-To: <784dfdf6-8fc3-be08-833b-a9097c3d1b96@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On 18.05.2018 17:57, David Hildenbrand wrote:
> On 01.02.2018 17:33, Andrey Ryabinin wrote:
>> KASAN uses different routines to map shadow for hot added memory and memory
>> obtained in boot process. Attempt to offline memory onlined by normal boot
>> process leads to this:
>>
>>     Trying to vfree() nonexistent vm area (000000005d3b34b9)
>>     WARNING: CPU: 2 PID: 13215 at mm/vmalloc.c:1525 __vunmap+0x147/0x190
>>
>>     Call Trace:
>>      kasan_mem_notifier+0xad/0xb9
>>      notifier_call_chain+0x166/0x260
>>      __blocking_notifier_call_chain+0xdb/0x140
>>      __offline_pages+0x96a/0xb10
>>      memory_subsys_offline+0x76/0xc0
>>      device_offline+0xb8/0x120
>>      store_mem_state+0xfa/0x120
>>      kernfs_fop_write+0x1d5/0x320
>>      __vfs_write+0xd4/0x530
>>      vfs_write+0x105/0x340
>>      SyS_write+0xb0/0x140
>>
>> Obviously we can't call vfree() to free memory that wasn't allocated via
>> vmalloc(). Use find_vm_area() to see if we can call vfree().
>>
>> Unfortunately it's a bit tricky to properly unmap and free shadow allocated
>> during boot, so we'll have to keep it. If memory will come online again
>> that shadow will be reused.
>>
> 
> While debugging kasan memory hotplug problems I am having, stumbled over
> this patch.
> 
> Couldn't we handle that via VM_KASAN like in kasan_module_alloc/free
> instead?
> 

Just realized that this will most probably not work. So please ignore my
comment for now :)

-- 

Thanks,

David / dhildenb
