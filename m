Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id AB7896B0044
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 18:35:21 -0400 (EDT)
Date: Fri, 30 Mar 2012 15:35:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm: migrate_pages hang
Message-Id: <20120330153519.1e80735b.akpm@linux-foundation.org>
In-Reply-To: <CA+1xoqfxZ8cji9SZFg0NZN-riFO7c8tKjtH7W1H9q-ES=J+ybw@mail.gmail.com>
References: <CA+1xoqfxZ8cji9SZFg0NZN-riFO7c8tKjtH7W1H9q-ES=J+ybw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Sat, 31 Mar 2012 00:23:30 +0200
Sasha Levin <levinsasha928@gmail.com> wrote:

> Hi all,
> 
> I saw the following inside a KVM guest, this is the first time I
> observed this hang and it seems to have started with today's
> (20120330) -next.
> 
> [ 3122.093136] INFO: task trinity:17328 blocked for more than 120 seconds.
> [ 3122.093807] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> disables this message.
> [ 3122.095237] trinity         D ffff8800703284d8  5648 17328   3101 0x00000004
> [ 3122.096543]  ffff8800064cfb08 0000000000000082 ffff8800064cfab8
> ffffffff8107d346
> [ 3122.098087]  ffff8800064cffd8 00000000001d4580 ffff8800064ce010
> 00000000001d4580
> [ 3122.099447]  00000000001d4580 00000000001d4580 ffff8800064cffd8
> 00000000001d4580
> [ 3122.100607] Call Trace:
> [ 3122.100983]  [<ffffffff8107d346>] ? kvm_clock_read+0x46/0x80
> [ 3122.101950]  [<ffffffff81176260>] ? __lock_page+0x70/0x70
> [ 3122.102761]  [<ffffffff827063d4>] schedule+0x24/0x70
> [ 3122.103576]  [<ffffffff827064a7>] io_schedule+0x87/0xd0
> [ 3122.104371]  [<ffffffff81176269>] sleep_on_page+0x9/0x10
> [ 3122.105179]  [<ffffffff82704152>] __wait_on_bit_lock+0x52/0xb0
> [ 3122.106042]  [<ffffffff81176252>] __lock_page+0x62/0x70
> [ 3122.106811]  [<ffffffff810d78f0>] ? autoremove_wake_function+0x40/0x40
> [ 3122.107450]  [<ffffffff811cc2f9>] lock_page+0x39/0x40
> [ 3122.107976]  [<ffffffff811cd294>] __unmap_and_move+0x274/0x280
> [ 3122.108848]  [<ffffffff81899061>] ? list_del+0x11/0x40
> [ 3122.109385]  [<ffffffff811cd32d>] unmap_and_move+0x8d/0x130
> [ 3122.109957]  [<ffffffff811cd47b>] migrate_pages+0xab/0x150
> [ 3122.110788]  [<ffffffff811bc440>] ? isolate_freepages+0x390/0x390
> [ 3122.111399]  [<ffffffff811bcc51>] compact_zone+0x1e1/0x2a0
> [ 3122.111935]  [<ffffffff82707e15>] ? _raw_spin_unlock_irqrestore+0x75/0xa0
> [ 3122.112579]  [<ffffffff811bcec3>] __compact_pgdat+0x1b3/0x200
> [ 3122.113199]  [<ffffffff811bcf47>] compact_node+0x37/0x40
> [ 3122.113631]  [<ffffffff81185080>] ? lru_add_drain_all+0x10/0x20
> [ 3122.114266]  [<ffffffff811bcf98>] sysfs_compact_node+0x48/0x60
> [ 3122.114768]  [<ffffffff8125c3d2>] ? sysfs_write_file+0x82/0xf0
> [ 3122.115368]  [<ffffffff81b0dc3b>] dev_attr_store+0x1b/0x20
> [ 3122.115877]  [<ffffffff8125c3ee>] sysfs_write_file+0x9e/0xf0
> [ 3122.116423]  [<ffffffff811e3258>] vfs_write+0xc8/0x190
> [ 3122.116934]  [<ffffffff811e340f>] sys_write+0x4f/0x90
> [ 3122.117697]  [<ffffffff82708cf9>] system_call_fastpath+0x16/0x1b
> [ 3122.118354] 2 locks held by trinity/17328:
> [ 3122.118694]  #0:  (&buffer->mutex){+.+.+.}, at:
> [<ffffffff8125c394>] sysfs_write_file+0x44/0xf0
> [ 3122.119498]  #1:  (s_active#57){.+.+.+}, at: [<ffffffff8125c3d2>]
> sysfs_write_file+0x82/0xf0

You reported what I suppose is the same bug a week ago ("mm: hung task
(handle_pte_fault)"): the kernel is waiting for a page to come
unlocked, thinking that there is I/O outstanding against it.

And my ugh still applies: "There are quite a lot of things which could
cause this, alas.  VM, readahead, scheduler, core wait/wakeup code, IO
system, interrupt system (if it happens outside KVM, I guess).  So.... 
ugh.  Hopefully someone will hit this in a situation where it can be
narrowed down or bisected."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
