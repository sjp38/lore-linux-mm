Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id F0EE26B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 23:06:27 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so1934084pde.25
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 20:06:27 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id mt5si4103044pbb.186.2014.03.13.20.06.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 20:06:26 -0700 (PDT)
Message-ID: <5322720F.1030706@huawei.com>
Date: Fri, 14 Mar 2014 11:05:51 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4] mm: per-thread vma caching
References: <1393537704.2899.3.camel@buesod1.americas.hpqcorp.net> <20140303164002.02df915e12d05bb98762407f@linux-foundation.org> <1393894778.30648.29.camel@buesod1.americas.hpqcorp.net> <20140303172348.3f00c9df.akpm@linux-foundation.org> <1393900953.30648.32.camel@buesod1.americas.hpqcorp.net> <20140303191224.96f93142.akpm@linux-foundation.org> <1393902810.30648.36.camel@buesod1.americas.hpqcorp.net> <CA+55aFwsjHPe4CF009p_L6PyYdP=F2bzi9-Wm5T+O6XPOCS6fg@mail.gmail.com>
In-Reply-To: <CA+55aFwsjHPe4CF009p_L6PyYdP=F2bzi9-Wm5T+O6XPOCS6fg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Davidlohr,

On 2014/3/4 11:26, Linus Torvalds wrote:
> On Mon, Mar 3, 2014 at 7:13 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>>
>> Yes, I shortly realized that was silly... but I can say for sure it can
>> happen and a quick qemu run confirms it. So I see your point as to
>> asking why we need it, so now I'm looking for an explanation in the
>> code.
> 
> We definitely *do* have users.
> 
> One example would be ptrace -> access_process_vm -> __access_remote_vm
> -> get_user_pages() -> find_extend_vma() -> find_vma_prev -> find_vma.
> 

I raw this oops on 3.14.0-rc5-next-20140307, which is possible caused by
your patch? Don't know how it was triggered.

[ 6072.026715] BUG: unable to handle kernel NULL pointer dereference at 00000000000007f8
[ 6072.026729] IP: [<ffffffff811a0189>] follow_page_mask+0x69/0x620
[ 6072.026742] PGD c1975f067 PUD c19479067 PMD 0
[ 6072.026749] Oops: 0000 [#1] SMP
[ 6072.026852] CPU: 2 PID: 13445 Comm: ps Not tainted 3.14.0-rc5-next-20140307-0.1-default+ #4
[ 6072.026863] Hardware name: Huawei Technologies Co., Ltd. Tecal RH2285          /BC11BTSA              , BIO
S CTSAV036 04/27/2011
[ 6072.026872] task: ffff88061d8848a0 ti: ffff880618854000 task.ti: ffff880618854000
[ 6072.026880] RIP: 0010:[<ffffffff811a0189>]  [<ffffffff811a0189>] follow_page_mask+0x69/0x620
[ 6072.026889] RSP: 0018:ffff880618855c18  EFLAGS: 00010206
[ 6072.026895] RAX: 00000000000000ff RBX: ffffffffffffffea RCX: ffff880618855d0c
[ 6072.026902] RDX: 0000000000000000 RSI: 00007fff0a474cc7 RDI: ffff88061aef8f00
[ 6072.026909] RBP: ffff880618855c88 R08: 0000000000000002 R09: 0000000000000000
[ 6072.026916] R10: 0000000000000000 R11: 0000000000003485 R12: 00007fff0a474cc7
[ 6072.026924] R13: 0000000000000016 R14: ffff88061aef8f00 R15: ffff880c1c842508
[ 6072.026932] FS:  00007f4687701700(0000) GS:ffff880c26a00000(0000) knlGS:0000000000000000
[ 6072.026940] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 6072.026947] CR2: 00000000000007f8 CR3: 0000000c184ee000 CR4: 00000000000007e0
[ 6072.026955] Stack:
[ 6072.026959]  ffff880618855c48 ffff880618855d0c 0000000018855c58 0000000000000246
[ 6072.026969]  0000000000000000 0000000000000752 ffffffff817c975c 0000000000000000
[ 6072.026980]  ffff880618855c88 0000000000000016 ffff880c1c842508 ffff88061d8848a0
[ 6072.026989] Call Trace:
[ 6072.026998]  [<ffffffff811a4b14>] __get_user_pages+0x204/0x5a0
[ 6072.027007]  [<ffffffff811a4f62>] get_user_pages+0x52/0x60
[ 6072.027015]  [<ffffffff811a5088>] __access_remote_vm+0x118/0x1f0
[ 6072.027023]  [<ffffffff811a51bb>] access_process_vm+0x5b/0x80
[ 6072.027033]  [<ffffffff812675a7>] proc_pid_cmdline+0x77/0x120
[ 6072.027041]  [<ffffffff81267da2>] proc_info_read+0xa2/0xe0
[ 6072.027050]  [<ffffffff811f439d>] vfs_read+0xad/0x1a0
[ 6072.027057]  [<ffffffff811f45b5>] SyS_read+0x65/0xb0
[ 6072.027066]  [<ffffffff8159ba12>] system_call_fastpath+0x16/0x1b
[ 6072.027072] Code: f4 4c 89 f7 89 45 a4 e8 36 0e eb ff 48 3d 00 f0 ff ff 48 89 c3 0f 86 d7 00 00 00 4c 89 e0
 49 8b 56 40 48 c1 e8 27 25 ff 01 00 00 <48> 8b 0c c2 48 85 c9 75 3e 41 83 e5 08 74 1b 49 8b 87 90 00 00
[ 6072.027134] RIP  [<ffffffff811a0189>] follow_page_mask+0x69/0x620
[ 6072.027142]  RSP <ffff880618855c18>
[ 6072.027146] CR2: 00000000000007f8
[ 6072.134516] ---[ end trace 8d006e01f05d1ba8 ]---


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
