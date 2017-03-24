Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 72BD16B0343
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 11:04:33 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q126so8167231pga.0
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 08:04:33 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0136.outbound.protection.outlook.com. [104.47.0.136])
        by mx.google.com with ESMTPS id d11si3173544pln.319.2017.03.24.08.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 24 Mar 2017 08:04:32 -0700 (PDT)
Subject: Re: [PATCH] mm: Remove pointless might_sleep() in remove_vm_area().
References: <1490352808-7187-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <59149d48-2a8e-d7c0-8009-1d0b3ea8290b@virtuozzo.com>
 <201703242140.CHJ64587.LFSFQOJOOMtFHV@I-love.SAKURA.ne.jp>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <fe511b26-f2e5-0a0e-09cc-303d38d2ad05@virtuozzo.com>
Date: Fri, 24 Mar 2017 18:05:45 +0300
MIME-Version: 1.0
In-Reply-To: <201703242140.CHJ64587.LFSFQOJOOMtFHV@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org
Cc: willy@infradead.org, hch@lst.de, jszhang@marvell.com, joelaf@google.com, chris@chris-wilson.co.uk, joaodias@google.com, tglx@linutronix.de, hpa@zytor.com, mingo@elte.hu



On 03/24/2017 03:40 PM, Tetsuo Handa wrote:
> Andrey Ryabinin wrote:
>> On 03/24/2017 01:53 PM, Tetsuo Handa wrote:
>>> Commit 5803ed292e63a1bf ("mm: mark all calls into the vmalloc subsystem
>>> as potentially sleeping") added might_sleep() to remove_vm_area() from
>>> vfree(), and is causing
>>>
>>> [    2.616064] BUG: sleeping function called from invalid context at mm/vmalloc.c:1480
>>> [    2.616125] in_atomic(): 1, irqs_disabled(): 0, pid: 341, name: plymouthd
>>> [    2.616156] 2 locks held by plymouthd/341:
>>> [    2.616158]  #0:  (drm_global_mutex){+.+.+.}, at: [<ffffffffc01c274b>] drm_release+0x3b/0x3b0 [drm]
>>> [    2.616256]  #1:  (&(&tfile->lock)->rlock){+.+...}, at: [<ffffffffc0173038>] ttm_object_file_release+0x28/0x90 [ttm]
>>> [    2.616270] CPU: 2 PID: 341 Comm: plymouthd Not tainted 4.11.0-0.rc3.git0.1.kmallocwd.fc25.x86_64+debug #1
>>> [    2.616271] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
>>> [    2.616273] Call Trace:
>>> [    2.616281]  dump_stack+0x86/0xc3
>>> [    2.616285]  ___might_sleep+0x17d/0x250
>>> [    2.616289]  __might_sleep+0x4a/0x80
>>> [    2.616293]  remove_vm_area+0x22/0x90
>>> [    2.616296]  __vunmap+0x2e/0x110
>>> [    2.616299]  vfree+0x42/0x90
>>> [    2.616304]  kvfree+0x2c/0x40
>>> [    2.616312]  drm_ht_remove+0x1a/0x30 [drm]
>>> [    2.616317]  ttm_object_file_release+0x50/0x90 [ttm]
>>> [    2.616324]  vmw_postclose+0x47/0x60 [vmwgfx]
>>> [    2.616331]  drm_release+0x290/0x3b0 [drm]
>>> [    2.616338]  __fput+0xf8/0x210
>>> [    2.616342]  ____fput+0xe/0x10
>>> [    2.616345]  task_work_run+0x85/0xc0
>>> [    2.616351]  exit_to_usermode_loop+0xb4/0xc0
>>> [    2.616355]  do_syscall_64+0x185/0x1f0
>>> [    2.616359]  entry_SYSCALL64_slow_path+0x25/0x25
>>>
>>> warning.
>>>
>>> But commit f9e09977671b618a ("mm: turn vmap_purge_lock into a mutex") did
>>> not make vfree() potentially sleeping because try_purge_vmap_area_lazy()
>>> is still using mutex_trylock(). Thus, this is a false positive warning.
>>>
>>
>> Commit f9e09977671b618a did not made vfree() sleeping.
>> Commit 763b218ddfa "mm: add preempt points into __purge_vmap_area_lazy()"
>> did this, thus it's not a false positive.
>>
>>
>>> ___might_sleep() via cond_resched_lock() in __purge_vmap_area_lazy() from
>>> try_purge_vmap_area_lazy() from free_vmap_area_noflush() from
>>> free_unmap_vmap_area() from remove_vm_area() which might trigger same
>>> false positive warning is remaining. But so far we haven't heard about
>>> warning from that path.
>>
>> And why that would be a false positive?
>>
> 
> #define cond_resched_lock(lock) ({                              \
> 	___might_sleep(__FILE__, __LINE__, PREEMPT_LOCK_OFFSET);\
> 	__cond_resched_lock(lock);                              \
> 	})
> 
> cond_resched_lock() calls ___might_sleep() even when
> __cond_resched_lock() will not call preempt_schedule_common()
> because should_resched() returns false due to preemption counter
> being already elevated by holding &(&tfile->lock)->rlock spinlock.
 
That is true only for preemptible kernel. On non-preempt kernel should_resched()
might return true under spin_lock.

Just fix the drm code. There is zero point in releasing memory under spinlock.



> If should_resched() is known to return false, calling
> ___might_sleep() from cond_resched_lock() is a false positive.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
