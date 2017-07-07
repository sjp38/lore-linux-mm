Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9AFB6B0279
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 04:41:34 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u123so39426317itu.5
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 01:41:34 -0700 (PDT)
Received: from mail-it0-x22d.google.com (mail-it0-x22d.google.com. [2607:f8b0:4001:c0b::22d])
        by mx.google.com with ESMTPS id n199si3053654ita.61.2017.07.07.01.41.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 01:41:32 -0700 (PDT)
Received: by mail-it0-x22d.google.com with SMTP id m84so28921332ita.0
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 01:41:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170707023601.GA7478@jagdpanzerIV.localdomain>
References: <201707061928.IJI87020.FMQLFOOOHVFSJt@I-love.SAKURA.ne.jp> <20170707023601.GA7478@jagdpanzerIV.localdomain>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Fri, 7 Jul 2017 10:41:31 +0200
Message-ID: <CAKMK7uE_udhx0LtUmrDqbzDt2hSs6Qc7zDMiny5jKEzZUjS6RQ@mail.gmail.com>
Subject: Re: printk: Should console related code avoid __GFP_DIRECT_RECLAIM
 memory allocations?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, pmladek@suse.com, Michal Hocko <mhocko@kernel.org>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Andreas Mohr <andi@lisas.de>, Jan Kara <jack@suse.cz>, dri-devel <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>

On Fri, Jul 7, 2017 at 4:39 AM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> Hello,
>
> (Cc Daniel)

Oh the fun :-/

Imo it's complete misdesign of the console/printk stuff that it ends
up calling down into drm/kms drivers. There's no way this will ever
reliably work, and GFP_KERNEL is the least of your worries (there's an
endless amounts of locks we need to grab even for fairly simple
stuff). What we're doing now is trying to bail out when called from
any kind of suspicious context. That means much reduced chances
critical output shows up, but ime even when we managed to display
something it all died later on and only made sure the first oops
scrolled off the screen.

Here's our bag of tricks:
- We dropped the panic notifier.
- All drm/kms callbacks for fbdev/fbcon have an oops_in_progress
check, and bail out.
- Lots of work items for things because fbdev/fbcon assume you can
call gfx drivers from atomic context, which just isn't true anymore.

That's it for context, no idea what to do here, but no longer allowing
GFP_KERNEL in drm/kms drivers is definitely not an option. Like Sergey
said, untangling the console semaphore might be what we need - if we
can somehow get the console printing out from under the console lock,
that would help a lot. At least for fbcon on top of drm drivers,
simpler consoles probably don't want that.

A quick hack might be a PF_HOLDING_CONSOLE thread flag, and if that's
set we push all the fbdev operations into a worker thread which runs
entirely asynchronously. A real bad hack would be to do a
console_try_lock, but the console semaphore is highly contended, so
might result in too many false positives for practical use.

Cheers, Daniel

> On (07/06/17 19:28), Tetsuo Handa wrote:
>> (...snipped...)
>> [  912.892027] kworker/3:3     D12120  3217      2 0x00000080
>> [  912.892041] Workqueue: events console_callback
>> [  912.892042] Call Trace:
>> [  912.892047]  __schedule+0x23f/0x5d0
>> [  912.892051]  schedule+0x31/0x80
>> [  912.892056]  schedule_preempt_disabled+0x9/0x10
>> [  912.892061]  __mutex_lock.isra.2+0x2ac/0x4d0
>> [  912.892068]  __mutex_lock_slowpath+0xe/0x10
>> [  912.892072]  ? __mutex_lock_slowpath+0xe/0x10
>> [  912.892077]  mutex_lock+0x2a/0x30
>> [  912.892105]  vmw_fb_pan_display+0x35/0x90 [vmwgfx]
>> [  912.892114]  fb_pan_display+0xca/0x160
>> [  912.892118]  bit_update_start+0x1b/0x40
>> [  912.892123]  fbcon_switch+0x4a6/0x630
>> [  912.892128]  redraw_screen+0x15a/0x240
>> [  912.892132]  ? update_attr.isra.3+0x90/0x90
>> [  912.892139]  complete_change_console+0x3d/0xd0
>> [  912.892143]  change_console+0x57/0x90
>> [  912.892147]  console_callback+0x116/0x190
>> [  912.892153]  process_one_work+0x1f5/0x390
>> [  912.892156]  worker_thread+0x46/0x410
>> [  912.892161]  ? __schedule+0x247/0x5d0
>> [  912.892165]  kthread+0xff/0x140
>> [  912.892170]  ? process_one_work+0x390/0x390
>> [  912.892174]  ? kthread_create_on_node+0x60/0x60
>> [  912.892178]  ? do_syscall_64+0x13a/0x140
>> [  912.892181]  ret_from_fork+0x25/0x30
>> (...snipped...)
>> [  912.934633] kworker/0:0     D12824  4263      2 0x00000080
>> [  912.934643] Workqueue: events vmw_fb_dirty_flush [vmwgfx]
>> [  912.934643] Call Trace:
>> [  912.934645]  __schedule+0x23f/0x5d0
>> [  912.934646]  schedule+0x31/0x80
>> [  912.934647]  schedule_timeout+0x189/0x290
>> [  912.934649]  ? del_timer_sync+0x40/0x40
>> [  912.934650]  io_schedule_timeout+0x19/0x40
>> [  912.934651]  ? io_schedule_timeout+0x19/0x40
>> [  912.934653]  congestion_wait+0x7d/0xd0
>> [  912.934654]  ? wait_woken+0x80/0x80
>> [  912.934654]  shrink_inactive_list+0x3e3/0x4d0
>> [  912.934656]  shrink_node_memcg+0x360/0x780
>> [  912.934657]  ? list_lru_count_one+0x65/0x70
>> [  912.934658]  shrink_node+0xdc/0x310
>> [  912.934658]  ? shrink_node+0xdc/0x310
>> [  912.934659]  do_try_to_free_pages+0xea/0x370
>> [  912.934660]  try_to_free_pages+0xc3/0x100
>> [  912.934661]  __alloc_pages_slowpath+0x441/0xd50
>> [  912.934663]  ? ___slab_alloc+0x1b6/0x590
>> [  912.934664]  __alloc_pages_nodemask+0x20c/0x250
>> [  912.934665]  alloc_pages_current+0x65/0xd0
>> [  912.934666]  new_slab+0x472/0x600
>> [  912.934668]  ___slab_alloc+0x41b/0x590
>> [  912.934685]  ? drm_modeset_lock_all+0x1b/0xa0 [drm]
>> [  912.934691]  ? drm_modeset_lock_all+0x1b/0xa0 [drm]
>> [  912.934692]  __slab_alloc+0x1b/0x30
>> [  912.934693]  ? __slab_alloc+0x1b/0x30
>> [  912.934694]  kmem_cache_alloc+0x16b/0x1c0
>> [  912.934699]  drm_modeset_lock_all+0x1b/0xa0 [drm]
>> [  912.934702]  vmw_framebuffer_dmabuf_dirty+0x47/0x1d0 [vmwgfx]
>> [  912.934706]  vmw_fb_dirty_flush+0x229/0x270 [vmwgfx]
>> [  912.934708]  process_one_work+0x1f5/0x390
>> [  912.934709]  worker_thread+0x46/0x410
>> [  912.934710]  ? __schedule+0x247/0x5d0
>> [  912.934711]  kthread+0xff/0x140
>> [  912.934712]  ? process_one_work+0x390/0x390
>> [  912.934713]  ? kthread_create_on_node+0x60/0x60
>> [  912.934714]  ret_from_fork+0x25/0x30
>>
>> Pressing SysRq-c caused all locks to be released (doesn't it ?), and console
>
> hm, I think what happened is a bit different thing. sysrq-c didn't
> unlock any of the locks. I suspect that ->bo_mutex is never taken
> on the direct path vprintk_emit()->console_unlock()->call_console_drivers(),
> otherwise it would have made vprintk_emit() from atomic context impossible.
> so ->bo_mutex does not directly affect printk. it affects it indirectly.
> the root cause, however, I think, is actually console semaphore and
> console_lock() in change_console(). printk() depends on it a lot, so do
> drm/tty/etc. as long as the console semaphore is locked, printk can only
> add new messages to the logbuf. and this is what happened here, under
> console_sem we scheduled on ->bo_mutex, which was locked because of memory
> allocation on another CPU, yes. you see lost messages in your report
> because part of printk that is responsible for storing new messages was
> working just fine; it's the output to consoles that was blocked by
> console_sem -> bo_mutex chain.
>
> the reason why sysrq-c helped was because, sysrq-c did
>
>         panic_on_oops = 1
>         panic()
>
> and panic() called console_flush_on_panic(), which completely ignored the
> state of console semaphore and just flushed all the pending logbuf
> messages.
>
>         console_trylock();
>         console_unlock();
>
> so, I believe, console_semaphore remained locked just like it was before
> sysrq-c, and ->bo_mutex most likely remained locked as well. it's just we
> ignored the state of console_sem and this let us to print the messages
> (which also proves that ->bo_mutex is not taken by
> console_unlock()->call_console_drivers()).
>
> [..]
>> Since vmw_fb_dirty_flush was stalling for 130989 jiffies,
>> vmw_fb_dirty_flush started stalling at uptime = 782. And
>> drm_modeset_lock_all() from vmw_fb_dirty_flush work started
>> GFP_KERNEL memory allocation
>>
>> ----------
>> void drm_modeset_lock_all(struct drm_device *dev)
>> {
>>         struct drm_mode_config *config = &dev->mode_config;
>>         struct drm_modeset_acquire_ctx *ctx;
>>         int ret;
>>
>>         ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
>>         if (WARN_ON(!ctx))
>>                 return;
>
> hm, this allocation, per se, looks ok to me. can't really blame it.
> what you had is a combination of factors
>
>         CPU0                    CPU1                            CPU2
>                                                                 console_callback()
>                                                                  console_lock()
>                                                                  ^^^^^^^^^^^^^
>         vprintk_emit()          mutex_lock(&par->bo_mutex)
>                                  kzalloc(GFP_KERNEL)
>          console_trylock()        kmem_cache_alloc()              mutex_lock(&par->bo_mutex)
>          ^^^^^^^^^^^^^^^^          io_schedule_timeout
>
> // but I haven't seen the logs that you have provided, yet.
>
> [..]
>> As a result, console was not able to print SysRq-t output.
>>
>> So, how should we avoid this problem?
>
> from the top of my head -- console_sem must be replaced with something
> better. but that's a task for years.
>
> hm...
>
>> But should fbcon, drm, tty and so on stop using __GFP_DIRECT_RECLAIM
>> memory allocations because consoles should be as responsive as printk() ?
>
> may be, may be not. like I said, the allocation in question does not
> participate in console output. it's rather hard to imagine how we would
> enforce a !__GFP_DIRECT_RECLAIM requirement here. it's console semaphore
> to blame, I think.
>
> if we could unlock console for some of operations done under ->bo_mutex,
> then may be we could make some printing progress, at least. but I have
> zero knowledge of that part of the kernel.
>
>         -ss



-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
