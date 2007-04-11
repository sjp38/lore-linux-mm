Date: Wed, 11 Apr 2007 15:30:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Why kmem_cache_free occupy CPU for more than 10 seconds?
Message-Id: <20070411153040.a7e6c3b8.akpm@linux-foundation.org>
In-Reply-To: <ac8af0be0704102317q50fe72b1m9e4825a769a63963@mail.gmail.com>
References: <ac8af0be0704102317q50fe72b1m9e4825a769a63963@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zhao Forrest <forrest.zhao@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Apr 2007 14:17:04 +0800
"Zhao Forrest" <forrest.zhao@gmail.com> wrote:

> We're using RHEL5 with kernel version 2.6.18-8.el5.
> When doing a stress test on raw device for about 3-4 hours, we found
> the soft lockup message in dmesg.
> I know we're not reporting the bug on the latest kernel, but does any
> expert know if this is the known issue in old kernel? Or why
> kmem_cache_free occupy CPU for more than 10 seconds?
> 
> Please let me know if you need any information.
> 
> Thanks,
> Forrest
> --------------------------------------------------------------
> BUG: soft lockup detected on CPU#1!
> 
> Call Trace:
>  <IRQ>  [<ffffffff800b2c93>] softlockup_tick+0xdb/0xed
>  [<ffffffff800933df>] update_process_times+0x42/0x68
>  [<ffffffff80073d97>] smp_local_timer_interrupt+0x23/0x47
>  [<ffffffff80074459>] smp_apic_timer_interrupt+0x41/0x47
>  [<ffffffff8005bcc2>] apic_timer_interrupt+0x66/0x6c
>  <EOI>  [<ffffffff80007660>] kmem_cache_free+0x1c0/0x1cb
>  [<ffffffff800262ee>] free_buffer_head+0x2a/0x43
>  [<ffffffff80027110>] try_to_free_buffers+0x89/0x9d
>  [<ffffffff80043041>] invalidate_mapping_pages+0x90/0x15f
>  [<ffffffff800d4a77>] kill_bdev+0xe/0x21
>  [<ffffffff800d4f9d>] __blkdev_put+0x4f/0x169
>  [<ffffffff80012281>] __fput+0xae/0x198
>  [<ffffffff80023647>] filp_close+0x5c/0x64
>  [<ffffffff800384f9>] put_files_struct+0x6c/0xc3
>  [<ffffffff80014f01>] do_exit+0x2d2/0x8b1
>  [<ffffffff80046eb6>] cpuset_exit+0x0/0x6c
>  [<ffffffff8002abd7>] get_signal_to_deliver+0x427/0x456
>  [<ffffffff80059122>] do_notify_resume+0x9c/0x7a9
>  [<ffffffff80086c6d>] default_wake_function+0x0/0xe
>  [<ffffffff800b1fd8>] audit_syscall_exit+0x2cd/0x2ec
>  [<ffffffff8005b362>] int_signal+0x12/0x17

I think there's nothing unusual happening here - you closed the device and
the kernel has to remove a tremendous number of pagecache pages, and that
simply takes a long time.

How much memory does the machine have?

There used to be a cond_resched() in invalidate_mapping_pages() which would
have prevented this, but I rudely removed it to support
/proc/sys/vm/drop_caches (which needs to call invalidate_inode_pages()
under spinlock).

We could resurrect that cond_resched() by passing in some flag, I guess. 
Or change the code to poke the softlockup detector.  The former would be
better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
