Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 43AF26B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 19:17:07 -0400 (EDT)
Date: Mon, 26 Mar 2012 16:17:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm: hung task (handle_pte_fault)
Message-Id: <20120326161705.b96636db.akpm@linux-foundation.org>
In-Reply-To: <CA+1xoqczdjPD0OGEuZAu6f9Q8gxAQuhVL-ZhhUcELaz_B=Jfjg@mail.gmail.com>
References: <CA+1xoqczdjPD0OGEuZAu6f9Q8gxAQuhVL-ZhhUcELaz_B=Jfjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>

On Fri, 23 Mar 2012 12:45:03 +0200
Sasha Levin <levinsasha928@gmail.com> wrote:

> Hi guys,
> 
> During fuzzing using trinity inside a KVM tools guest with latest
> linux-next, I seem to be getting it hung once in a while, with the
> following spew:
> 
> [ 1441.420617] INFO: task trinity:2706 blocked for more than 120 seconds.
> [ 1441.421894] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> disables this message.
> [ 1441.424493] trinity         D 0000000000000000  3472  2706  16846 0x00000004
> [ 1441.426749]  ffff880029dbbb38 0000000000000086 ffff880029dbbae8
> ffff880029dbbfd8
> [ 1441.428582]  00000000001d45c0 ffff880029dba000 00000000001d45c0
> 00000000001d45c0
> [ 1441.430156]  00000000001d45c0 00000000001d45c0 ffff880029dbbfd8
> 00000000001d45c0
> [ 1441.432371] Call Trace:
> [ 1441.433042]  [<ffffffff81176dd0>] ? file_read_actor+0x1d0/0x1d0
> [ 1441.434251]  [<ffffffff827148d4>] schedule+0x24/0x70
> [ 1441.435314]  [<ffffffff82714e67>] io_schedule+0x87/0xd0
> [ 1441.436357]  [<ffffffff81176dd9>] sleep_on_page+0x9/0x10
> [ 1441.437442]  [<ffffffff82712cb7>] __wait_on_bit+0x57/0x80
> [ 1441.438584]  [<ffffffff81177bff>] ? __lock_page_or_retry+0x8f/0xd0
> [ 1441.439948]  [<ffffffff811775de>] wait_on_page_bit+0x6e/0x80
> [ 1441.440859]  [<ffffffff810d6d20>] ? autoremove_wake_function+0x40/0x40
> [ 1441.441700]  [<ffffffff810dbfbe>] ? up_read+0x1e/0x40
> [ 1441.442428]  [<ffffffff81177c36>] __lock_page_or_retry+0xc6/0xd0
> [ 1441.443270]  [<ffffffff81178490>] filemap_fault+0x440/0x4e0
> [ 1441.444072]  [<ffffffff811991cf>] __do_fault+0x7f/0x5f0
> [ 1441.444829]  [<ffffffff81112c00>] ?
> add_lock_to_list.clone.18.clone.27+0xd0/0xe0
> [ 1441.445886]  [<ffffffff8119cd27>] handle_pte_fault+0xf7/0x1e0
> [ 1441.446740]  [<ffffffff8119e1ce>] handle_mm_fault+0x1ce/0x330
> [ 1441.447537]  [<ffffffff8119e53c>] __get_user_pages+0x14c/0x640
> [ 1441.448399]  [<ffffffff811129ae>] ? put_lock_stats.clone.19+0xe/0x40
> [ 1441.449288]  [<ffffffff81117b1d>] ? __lock_acquired+0x19d/0x270
> [ 1441.450164]  [<ffffffff811a0087>] __mlock_vma_pages_range+0x87/0xa0
> [ 1441.451127]  [<ffffffff811a0129>] do_mlock_pages+0x89/0x160
> [ 1441.451932]  [<ffffffff811a0b71>] sys_mlockall+0x111/0x1a0
> [ 1441.452761]  [<ffffffff827176bd>] system_call_fastpath+0x1a/0x1f
> [ 1441.453659] no locks held by trinity/2706.
> [ 1441.454267] Kernel panic - not syncing: hung_task: blocked tasks
> 
> According to the logs, it's not the direct result of anything specific
> happening, so I can't give an exact scenario to reproduce it. It does
> happen rather often.

The task is waiting for IO to complete against a page, and it isn't
happening.

There are quite a lot of things which could cause this, alas.  VM,
readahead, scheduler, core wait/wakeup code, IO system, interrupt
system (if it happens outside KVM, I guess).

So....  ugh.  Hopefully someone will hit this in a situation where it
can be narrowed down or bisected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
