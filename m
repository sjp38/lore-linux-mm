Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id DF8706B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 03:26:11 -0500 (EST)
Received: by labgd6 with SMTP id gd6so9637454lab.7
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 00:26:11 -0800 (PST)
Received: from mail-lb0-x22e.google.com (mail-lb0-x22e.google.com. [2a00:1450:4010:c04::22e])
        by mx.google.com with ESMTPS id wk7si11468742lbb.15.2015.02.10.00.26.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 00:26:10 -0800 (PST)
Received: by mail-lb0-f174.google.com with SMTP id z11so1052656lbi.5
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 00:26:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54D88D38.9010901@suse.cz>
References: <CALYGNiMhifrNm5jv499Y6BcM0mYkHUgPBP5a5p7-Gc7ue_jqjw@mail.gmail.com>
	<54D87FA8.60408@suse.cz>
	<CALYGNiOgSVgq+iaUs-f9MB4o8yOWb7jk6eEA=SMrqJh5K=6+hQ@mail.gmail.com>
	<54D88D38.9010901@suse.cz>
Date: Tue, 10 Feb 2015 12:26:09 +0400
Message-ID: <CALYGNiOKpDXHVu2fK5MNJpPcMLu7oGgLktcNP4m425mEH4RVqQ@mail.gmail.com>
Subject: Re: BUG: stuck on mmap_sem in 3.18.6
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

That was caused by backport of 33692f27597fcab536d7cbbcc8f52905133e4aa7
("vm: add VM_FAULT_SIGSEGV handling support") into v3.18.y without
commit 7fb08eca45270d0ae86e1ad9d39c40b7a55d0190
("x86: mm: move mmap_sem unlock from mm_fault_error() to caller")
which have moved mmap_sem around.

On Mon, Feb 9, 2015 at 1:34 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 02/09/2015 10:46 AM, Konstantin Khlebnikov wrote:
>> On Mon, Feb 9, 2015 at 12:36 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>> On 02/09/2015 08:14 AM, Konstantin Khlebnikov wrote:
>>>> Python was running under ptrace-based sandbox "sydbox" used exherbo
>>>> chroot. Kernel: 3.18.6 + my patch "mm: prevent endless growth of
>>>> anon_vma hierarchy" (patch seems stable).
>>>>
>>>> [ 4674.087780] INFO: task python:25873 blocked for more than 120 seconds.
>>>> [ 4674.087793]       Tainted: G     U         3.18.6-zurg+ #158
>>>> [ 4674.087797] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
>>>> disables this message.
>>>> [ 4674.087801] python          D ffff88041e2d2000 14176 25873  25630 0x00000102
>>>> [ 4674.087817]  ffff880286247b68 0000000000000086 ffff8803d5fe6b40
>>>> 0000000000012000
>>>> [ 4674.087824]  ffff880286247fd8 0000000000012000 ffff88040c16eb40
>>>> ffff8803d5fe6b40
>>>> [ 4674.087830]  0000000300000003 ffff8803d5fe6b40 ffff880362888e78
>>>> ffff880362888e60
>>>> [ 4674.087836] Call Trace:
>>>> [ 4674.087854]  [<ffffffff81696be9>] schedule+0x29/0x70
>>>> [ 4674.087865]  [<ffffffff81699815>] rwsem_down_write_failed+0x1d5/0x2f0
>>>> [ 4674.087873]  [<ffffffff812d4c73>] call_rwsem_down_write_failed+0x13/0x20
>>>> [ 4674.087881]  [<ffffffff816990c1>] ? down_write+0x31/0x50
>>>> [ 4674.087891]  [<ffffffff811f3b44>] do_coredump+0x144/0xee0
>>>> [ 4674.087900]  [<ffffffff810b66f7>] ? pick_next_task_fair+0x397/0x450
>>>> [ 4674.087909]  [<ffffffff810026a6>] ? __switch_to+0x1d6/0x5f0
>>>> [ 4674.087915]  [<ffffffff816966e6>] ? __schedule+0x3a6/0x880
>>>> [ 4674.087924]  [<ffffffff81690000>] ? klist_remove+0x40/0xd0
>>>> [ 4674.087932]  [<ffffffff81093988>] get_signal+0x298/0x6b0
>>>> [ 4674.087940]  [<ffffffff81003588>] do_signal+0x28/0xbb0
>>>> [ 4674.087946]  [<ffffffff8109276d>] ? do_send_sig_info+0x5d/0x80
>>>> [ 4674.087955]  [<ffffffff81004179>] do_notify_resume+0x69/0xb0
>>>> [ 4674.087963]  [<ffffffff8169b028>] int_signal+0x12/0x17
>>>>
>>>> Maybe this guy did something wrong?
>>>
>>> Well he has do_coredump on stack, so he did something wrong in userspace? But
>>> here he's just waiting on down_write. Unless there's some bug in do_coredump
>>> that would lock for read and then for write, without an unlock in between?
>>
>> I mean khugepaged. This code looks really messy. Maybe it already has
>> mmap_sem locked for read and tries to lock it again:
>
> Yeah it is messy, and incidentally I'm trying to change how it works. But I
> didn't find such double lock bug there.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
