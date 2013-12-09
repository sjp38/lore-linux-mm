Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFC56B007D
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 04:34:06 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id hn9so3448678wib.0
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 01:34:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id 5si8704882eei.123.2013.12.09.01.34.05
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 01:34:05 -0800 (PST)
Message-ID: <52A58E8A.3050401@suse.cz>
Date: Mon, 09 Dec 2013 10:34:02 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: kernel BUG in munlock_vma_pages_range
References: <52A3D0C3.1080504@oracle.com>
In-Reply-To: <52A3D0C3.1080504@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: joern@logfs.org, mgorman@suse.de, Michel Lespinasse <walken@google.com>, riel@redhat.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12/08/2013 02:52 AM, Sasha Levin wrote:
> Hi all,
>
> While fuzzing with trinity inside a KVM tools guest running latest -next kernel,
> I've stumbled on the following spew.
>
> The code seems to be in munlock_vma_pages_range():
>
>           page = follow_page_mask(vma, start, FOLL_GET | FOLL_DUMP,
>                           &page_mask);
>
>           if (page && !IS_ERR(page)) {
>                   if (PageTransHuge(page)) {		<<==== HERE
>                           lock_page(page);
>
>
> This is new code added in "mm: munlock: batch non-THP page isolation and munlock+putback
> using pagevec". I've Cc'ed involved parties.

Hello, I will look at it, thanks.
Do you have specific reproduction instructions?

Vlastimil

> [  356.390309] kernel BUG at include/linux/page-flags.h:415!
> [  356.390309] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  356.395160] Dumping ftrace buffer:
> [  356.395160]    (ftrace buffer empty)
> [  356.395160] Modules linked in:
> [  356.395160] CPU: 36 PID: 10919 Comm: trinity-child74 Not tainted
> 3.13.0-rc2-next-20131206-sasha-00005-g8be2375-dirty #4045
> [  356.395160] task: ffff880f731e0000 ti: ffff880f731e8000 task.ti: ffff880f731e8000
> [  356.395160] RIP: 0010:[<ffffffff812636c9>]  [<ffffffff812636c9>] munlock_vma_pages_range+0x89/0x1b0
> [  356.395160] RSP: 0018:ffff880f731e9b58  EFLAGS: 00010286
> [  356.395160] RAX: 002fffff80008000 RBX: 00007f91cd801000 RCX: 0000000000000000
> [  356.395160] RDX: ffffea003ded0040 RSI: 00000000000013f1 RDI: 00000000ffffffff
> [  356.395160] RBP: ffff880f731e9c18 R08: 00000000e26e4584 R09: 0000000000000001
> [  356.395160] R10: 0000000000000001 R11: 0000000000000000 R12: ffffea003ded0040
> [  356.395160] R13: ffff880f733a8400 R14: 00007f91cdeea000 R15: ffff880f731e9be4
> [  356.395160] FS:  0000000000000000(0000) GS:ffff880fdba00000(0000) knlGS:0000000000000000
> [  356.395160] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  356.395160] CR2: 0000000000000000 CR3: 0000000f7314a000 CR4: 00000000000006e0
> [  356.395160] Stack:
> [  356.395160]  0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  356.395160]  0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  356.395160]  0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  356.395160] Call Trace:
> [  356.395160]  [<ffffffff81264c89>] exit_mmap+0x59/0x170
> [  356.395160]  [<ffffffff8129a4a0>] ? __khugepaged_exit+0xe0/0x150
> [  356.395160]  [<ffffffff81292d2b>] ? kmem_cache_free+0x24b/0x310
> [  356.395160]  [<ffffffff8129a4a0>] ? __khugepaged_exit+0xe0/0x150
> [  356.395160]  [<ffffffff81127eec>] mmput+0x7c/0xf0
> [  356.395160]  [<ffffffff8112c18d>] exit_mm+0x18d/0x1a0
> [  356.395160]  [<ffffffff811c8d85>] ? acct_collect+0x175/0x1b0
> [  356.395160]  [<ffffffff8112ceef>] do_exit+0x26f/0x4e0
> [  356.395160]  [<ffffffff8112d209>] do_group_exit+0xa9/0xe0
> [  356.395160]  [<ffffffff81311ff0>] get_signal_to_deliver+0x460/0x4b0
> [  356.395160]  [<ffffffff81067c3b>] do_signal+0x4b/0x120
> [  356.395160]  [<ffffffff842a4405>] ? _raw_spin_unlock+0x35/0x60
> [  356.395160]  [<ffffffff81168d36>] ? vtime_account_user+0x96/0xb0
> [  356.395160]  [<ffffffff8122ccbf>] ? context_tracking_user_exit+0xaf/0x160
> [  356.395160]  [<ffffffff81067f9a>] do_notify_resume+0x5a/0xe0
> [  356.395160]  [<ffffffff842ad0f0>] int_signal+0x12/0x17
> [  356.395160] Code: 48 89 de 4c 89 ef e8 17 7f ff ff 49 89 c4 48 85 c0 0f 84 eb 00 00 00 48 3d 00
> f0 ff ff 0f 87 df 00 00 00 48 8b 00 66 85 c0 79 0f <0f> 0b 0f 1f 44 00 00 eb fe 66 0f 1f 44 00 00 49
> 8b 04 24 f6 c4
> [  356.395160] RIP  [<ffffffff812636c9>] munlock_vma_pages_range+0x89/0x1b0
> [  356.395160]  RSP <ffff880f731e9b58>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
