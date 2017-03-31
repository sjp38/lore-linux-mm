Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id E550D2806CB
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 03:12:50 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id c18so29950586vkd.21
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 00:12:50 -0700 (PDT)
Received: from mail-vk0-x22d.google.com (mail-vk0-x22d.google.com. [2607:f8b0:400c:c05::22d])
        by mx.google.com with ESMTPS id 94si51442uap.183.2017.03.31.00.12.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 00:12:49 -0700 (PDT)
Received: by mail-vk0-x22d.google.com with SMTP id s68so81102039vke.3
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 00:12:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170330152229.f2108e718114ed77acae7405@linux-foundation.org>
References: <20170330102719.13119-1-aryabinin@virtuozzo.com> <20170330152229.f2108e718114ed77acae7405@linux-foundation.org>
From: Joel Fernandes <joelaf@google.com>
Date: Fri, 31 Mar 2017 00:12:48 -0700
Message-ID: <CAJWu+oqQDPnSMvjdc_=EMPCEfubWJiRwTkwpmTfqavc2fmwxTA@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm/vmalloc: allow to call vfree() in atomic context
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, penguin-kernel@i-love.sakura.ne.jp, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, hpa@zytor.com, Chris Wilson <chris@chris-wilson.co.uk>, Christoph Hellwig <hch@lst.de>, mingo@elte.hu, Jisheng Zhang <jszhang@marvell.com>, John Dias <joaodias@google.com>, willy@infradead.org, Thomas Gleixner <tglx@linutronix.de>, thellstrom@vmware.com, stable@vger.kernel.org

Hi Andrew,

On Thu, Mar 30, 2017 at 3:22 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
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
>         if (unlikely(in_interrupt()))
>                 __vfree_deferred(addr);
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

Because it will make for a possibly time consuming critical section.
This was hurting real-time workloads which are sensitive to latencies
(commit f9e09977671b618a "mm: turn vmap_purge_lock into a mutex" fixed
it).

Thanks,
Joel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
