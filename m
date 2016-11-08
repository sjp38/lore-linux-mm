Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 58C496B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 09:31:46 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id h201so8009693lfg.5
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 06:31:46 -0800 (PST)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id d203si3468647lfd.193.2016.11.08.06.31.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 06:31:44 -0800 (PST)
Received: by mail-lf0-x242.google.com with SMTP id p100so11191961lfg.2
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 06:31:44 -0800 (PST)
Subject: Re: [PATCH 2/6] mm: mark all calls into the vmalloc subsystem as
 potentially sleeping
References: <1476773771-11470-1-git-send-email-hch@lst.de>
 <1476773771-11470-3-git-send-email-hch@lst.de>
 <20161019111541.GQ29358@nuc-i3427.alporthouse.com>
 <CAJWu+opLAwJ+OsT6DRx1qNEph8YRc5nCWp8uputAGcgMGs0oPg@mail.gmail.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <9461e467-17df-9abf-acbf-e6d5a8b493cc@gmail.com>
Date: Tue, 8 Nov 2016 17:32:04 +0300
MIME-Version: 1.0
In-Reply-To: <CAJWu+opLAwJ+OsT6DRx1qNEph8YRc5nCWp8uputAGcgMGs0oPg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>, Chris Wilson <chris@chris-wilson.co.uk>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Jisheng Zhang <jszhang@marvell.com>, John Dias <joaodias@google.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-rt-users@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>



On 11/08/2016 04:24 PM, Joel Fernandes wrote:
> On Wed, Oct 19, 2016 at 4:15 AM, Chris Wilson <chris@chris-wilson.co.uk> wrote:
>> On Tue, Oct 18, 2016 at 08:56:07AM +0200, Christoph Hellwig wrote:
>>> This is how everyone seems to already use them, but let's make that
>>> explicit.
>>
>> Ah, found an exception, vmapped stacks:
>>
>> [  696.928541] BUG: sleeping function called from invalid context at mm/vmalloc.c:615
>> [  696.928576] in_atomic(): 1, irqs_disabled(): 0, pid: 30521, name: bash
>> [  696.928590] 1 lock held by bash/30521:
>> [  696.928600]  #0: [  696.928606]  (vmap_area_lock[  696.928619] ){+.+...}, at: [  696.928640] [<ffffffff8115f0cf>] __purge_vmap_area_lazy+0x30f/0x370
>> [  696.928656] CPU: 0 PID: 30521 Comm: bash Tainted: G        W       4.9.0-rc1+ #124
>> [  696.928672] Hardware name:                  /        , BIOS PYBSWCEL.86A.0027.2015.0507.1758 05/07/2015
>> [  696.928690]  ffffc900070f7c70 ffffffff812be1f5 ffff8802750b6680 ffffffff819650a6
>> [  696.928717]  ffffc900070f7c98 ffffffff810a3216 0000000000004001 ffff8802726e16c0
>> [  696.928743]  ffff8802726e19a0 ffffc900070f7d08 ffffffff8115f0f3 ffff8802750b6680
>> [  696.928768] Call Trace:
>> [  696.928782]  [<ffffffff812be1f5>] dump_stack+0x68/0x93
>> [  696.928796]  [<ffffffff810a3216>] ___might_sleep+0x166/0x220
>> [  696.928809]  [<ffffffff8115f0f3>] __purge_vmap_area_lazy+0x333/0x370
>> [  696.928823]  [<ffffffff8115ea68>] ? vunmap_page_range+0x1e8/0x350
>> [  696.928837]  [<ffffffff8115f1b3>] free_vmap_area_noflush+0x83/0x90
>> [  696.928850]  [<ffffffff81160931>] remove_vm_area+0x71/0xb0
>> [  696.928863]  [<ffffffff81160999>] __vunmap+0x29/0xf0
>> [  696.928875]  [<ffffffff81160ab9>] vfree+0x29/0x70
>> [  696.928888]  [<ffffffff81071746>] put_task_stack+0x76/0x120
> 
> From this traceback, it looks like the lock causing the atomic context
> was actually acquired in the vfree path itself, and not by the vmapped
> stack user (as it says "vmap_area_lock" held). I am still wondering
> why vmap_area_lock was held during the might_sleep(), perhaps you may
> not have applied all patches from Chris H?
> 

I don't think that this splat is because we holding vmap_area_lock.
Look at cond_resched_lock:

#define cond_resched_lock(lock) ({				\
	___might_sleep(__FILE__, __LINE__, PREEMPT_LOCK_OFFSET);\
	__cond_resched_lock(lock);				\
})

It calls might_sleep() with spin lock still held.
AFAIU PREEMPT_LOCK_OFFSET supposed to tell might_sleep() to ignore spin locks
and complain iff something else changed preempt_count.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
