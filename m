Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 15DCC6B0038
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 05:25:36 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s63so23957730ioe.3
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 02:25:36 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0120.outbound.protection.outlook.com. [104.47.1.120])
        by mx.google.com with ESMTPS id r204si1985477itc.34.2017.03.31.02.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 31 Mar 2017 02:25:34 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm/vmalloc: allow to call vfree() in atomic context
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
 <20170330152229.f2108e718114ed77acae7405@linux-foundation.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <d7d8bbc9-9f46-8c84-dcf3-c564dcccc7d7@virtuozzo.com>
Date: Fri, 31 Mar 2017 12:26:53 +0300
MIME-Version: 1.0
In-Reply-To: <20170330152229.f2108e718114ed77acae7405@linux-foundation.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de, thellstrom@vmware.com, stable@vger.kernel.org



On 03/31/2017 01:22 AM, Andrew Morton wrote:
> On Thu, 30 Mar 2017 13:27:16 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> 
>> Commit 5803ed292e63 ("mm: mark all calls into the vmalloc subsystem
>> as potentially sleeping") added might_sleep() to remove_vm_area() from
>> vfree(), and commit 763b218ddfaf ("mm: add preempt points into
>> __purge_vmap_area_lazy()") actually made vfree() potentially sleeping.
>>
>> This broke vmwgfx driver which calls vfree() under spin_lock().
>>
>>     BUG: sleeping function called from invalid context at mm/vmalloc.c:1480
>>     in_atomic(): 1, irqs_disabled(): 0, pid: 341, name: plymouthd
>>     2 locks held by plymouthd/341:
>>      #0:  (drm_global_mutex){+.+.+.}, at: [<ffffffffc01c274b>] drm_release+0x3b/0x3b0 [drm]
>>      #1:  (&(&tfile->lock)->rlock){+.+...}, at: [<ffffffffc0173038>] ttm_object_file_release+0x28/0x90 [ttm]
>>
>>     Call Trace:
>>      dump_stack+0x86/0xc3
>>      ___might_sleep+0x17d/0x250
>>      __might_sleep+0x4a/0x80
>>      remove_vm_area+0x22/0x90
>>      __vunmap+0x2e/0x110
>>      vfree+0x42/0x90
>>      kvfree+0x2c/0x40
>>      drm_ht_remove+0x1a/0x30 [drm]
>>      ttm_object_file_release+0x50/0x90 [ttm]
>>      vmw_postclose+0x47/0x60 [vmwgfx]
>>      drm_release+0x290/0x3b0 [drm]
>>      __fput+0xf8/0x210
>>      ____fput+0xe/0x10
>>      task_work_run+0x85/0xc0
>>      exit_to_usermode_loop+0xb4/0xc0
>>      do_syscall_64+0x185/0x1f0
>>      entry_SYSCALL64_slow_path+0x25/0x25
>>
>> This can be fixed in vmgfx, but it would be better to make vfree()
>> non-sleeping again because we may have other bugs like this one.
> 
> I tend to disagree: adding yet another schedule_work() introduces
> additional overhead and adds some risk of ENOMEM errors which wouldn't
> occur with a synchronous free.
> 
>> __purge_vmap_area_lazy() is the only function in the vfree() path that
>> wants to be able to sleep. So it make sense to schedule
>> __purge_vmap_area_lazy() via schedule_work() so it runs only in sleepable
>> context.
> 
> vfree() already does
> 
> 	if (unlikely(in_interrupt()))
> 		__vfree_deferred(addr);
> 
> so it seems silly to introduce another defer-to-kernel-thread thing
> when we already have one.
> 
>> This will have a minimal effect on the regular vfree() path.
>> since __purge_vmap_area_lazy() is rarely called.
> 
> hum, OK, so perhaps the overhead isn't too bad.
> 
> Remind me: where does __purge_vmap_area_lazy() sleep?

It's cond_resched_lock(&vmap_area_lock);

> 
> Seems to me that a better fix would be to make vfree() atomic, if poss.
>
> Otherwise, to fix callers so they call vfree from sleepable context. 
> That will reduce kernel latencies as well.
> 

Currently we know only two such callers: ttm_object_file_release() and ttm_object_device_release().
Both of them call vfree() under spin_lock() for no reason, Thomas said that he
has patch to fix this: http://lkml.kernel.org/r/f1c0b9ec-c0c8-502c-c7f0-fe692c73ab04@vmware.com

So this patch is more like an attempt to address other similar bugs possibly introduced by
commit 5803ed292e63 ("mm: mark all calls into the vmalloc subsystem as potentially sleeping")
It's quite possible that we overlooked something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
