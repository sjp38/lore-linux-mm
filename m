Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D4FEF6B000E
	for <linux-mm@kvack.org>; Tue, 22 May 2018 12:42:57 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z16-v6so5630575pgv.16
        for <linux-mm@kvack.org>; Tue, 22 May 2018 09:42:57 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20118.outbound.protection.outlook.com. [40.107.2.118])
        by mx.google.com with ESMTPS id m27-v6si16441720pfj.192.2018.05.22.09.42.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 May 2018 09:42:55 -0700 (PDT)
Subject: Re: [PATCH] mm/kasan: Don't vfree() nonexistent vm_area.
References: <12c9e499-9c11-d248-6a3f-14ec8c4e07f1@molgen.mpg.de>
 <20180201163349.8700-1-aryabinin@virtuozzo.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <4fc394ae-65e8-7c51-112a-81bee0fb8429@virtuozzo.com>
Date: Tue, 22 May 2018 19:44:06 +0300
MIME-Version: 1.0
In-Reply-To: <20180201163349.8700-1-aryabinin@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org



On 02/01/2018 07:33 PM, Andrey Ryabinin wrote:
> KASAN uses different routines to map shadow for hot added memory and memory
> obtained in boot process. Attempt to offline memory onlined by normal boot
> process leads to this:
> 
>     Trying to vfree() nonexistent vm area (000000005d3b34b9)
>     WARNING: CPU: 2 PID: 13215 at mm/vmalloc.c:1525 __vunmap+0x147/0x190
> 
>     Call Trace:
>      kasan_mem_notifier+0xad/0xb9
>      notifier_call_chain+0x166/0x260
>      __blocking_notifier_call_chain+0xdb/0x140
>      __offline_pages+0x96a/0xb10
>      memory_subsys_offline+0x76/0xc0
>      device_offline+0xb8/0x120
>      store_mem_state+0xfa/0x120
>      kernfs_fop_write+0x1d5/0x320
>      __vfs_write+0xd4/0x530
>      vfs_write+0x105/0x340
>      SyS_write+0xb0/0x140
> 
> Obviously we can't call vfree() to free memory that wasn't allocated via
> vmalloc(). Use find_vm_area() to see if we can call vfree().
> 
> Unfortunately it's a bit tricky to properly unmap and free shadow allocated
> during boot, so we'll have to keep it. If memory will come online again
> that shadow will be reused.
> 
> Fixes: fa69b5989bb0 ("mm/kasan: add support for memory hotplug")
> Reported-by: Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: <stable@vger.kernel.org>
> ---

This seems stuck in -mm. Andrew, can we proceed?
