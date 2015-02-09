Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0C8E66B006C
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 04:36:44 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id z2so4332114wiv.0
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 01:36:43 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sd8si7239757wjb.100.2015.02.09.01.36.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Feb 2015 01:36:42 -0800 (PST)
Message-ID: <54D87FA8.60408@suse.cz>
Date: Mon, 09 Feb 2015 10:36:40 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: BUG: stuck on mmap_sem in 3.18.6
References: <CALYGNiMhifrNm5jv499Y6BcM0mYkHUgPBP5a5p7-Gc7ue_jqjw@mail.gmail.com>
In-Reply-To: <CALYGNiMhifrNm5jv499Y6BcM0mYkHUgPBP5a5p7-Gc7ue_jqjw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 02/09/2015 08:14 AM, Konstantin Khlebnikov wrote:
> Python was running under ptrace-based sandbox "sydbox" used exherbo
> chroot. Kernel: 3.18.6 + my patch "mm: prevent endless growth of
> anon_vma hierarchy" (patch seems stable).
> 
> [ 4674.087780] INFO: task python:25873 blocked for more than 120 seconds.
> [ 4674.087793]       Tainted: G     U         3.18.6-zurg+ #158
> [ 4674.087797] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> disables this message.
> [ 4674.087801] python          D ffff88041e2d2000 14176 25873  25630 0x00000102
> [ 4674.087817]  ffff880286247b68 0000000000000086 ffff8803d5fe6b40
> 0000000000012000
> [ 4674.087824]  ffff880286247fd8 0000000000012000 ffff88040c16eb40
> ffff8803d5fe6b40
> [ 4674.087830]  0000000300000003 ffff8803d5fe6b40 ffff880362888e78
> ffff880362888e60
> [ 4674.087836] Call Trace:
> [ 4674.087854]  [<ffffffff81696be9>] schedule+0x29/0x70
> [ 4674.087865]  [<ffffffff81699815>] rwsem_down_write_failed+0x1d5/0x2f0
> [ 4674.087873]  [<ffffffff812d4c73>] call_rwsem_down_write_failed+0x13/0x20
> [ 4674.087881]  [<ffffffff816990c1>] ? down_write+0x31/0x50
> [ 4674.087891]  [<ffffffff811f3b44>] do_coredump+0x144/0xee0
> [ 4674.087900]  [<ffffffff810b66f7>] ? pick_next_task_fair+0x397/0x450
> [ 4674.087909]  [<ffffffff810026a6>] ? __switch_to+0x1d6/0x5f0
> [ 4674.087915]  [<ffffffff816966e6>] ? __schedule+0x3a6/0x880
> [ 4674.087924]  [<ffffffff81690000>] ? klist_remove+0x40/0xd0
> [ 4674.087932]  [<ffffffff81093988>] get_signal+0x298/0x6b0
> [ 4674.087940]  [<ffffffff81003588>] do_signal+0x28/0xbb0
> [ 4674.087946]  [<ffffffff8109276d>] ? do_send_sig_info+0x5d/0x80
> [ 4674.087955]  [<ffffffff81004179>] do_notify_resume+0x69/0xb0
> [ 4674.087963]  [<ffffffff8169b028>] int_signal+0x12/0x17
> 
> Maybe this guy did something wrong?

Well he has do_coredump on stack, so he did something wrong in userspace? But
here he's just waiting on down_write. Unless there's some bug in do_coredump
that would lock for read and then for write, without an unlock in between?

> Looks like mmap_sem is locked for read:

So we have the python waiting for write, blocking all new readers (that's how
read/write locks work, right?), but itself waiting for a prior reader to finish.
The question is, who is/was the reader? You could search the mmap_sem or mm
address in the rest of the processes' stacks, and maybe you'll find him?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
