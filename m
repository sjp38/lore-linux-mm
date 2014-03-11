Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 291546B0037
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 15:26:17 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id wp18so8933759obc.23
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 12:26:16 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id sp3si25323577obb.17.2014.03.11.12.26.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 12:26:16 -0700 (PDT)
Message-ID: <531F616A.7060300@oracle.com>
Date: Tue, 11 Mar 2014 15:18:02 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mm,numa,mprotect: always continue after finding a
 stable thp page
References: <5318E4BC.50301@oracle.com> <20140306173137.6a23a0b2@cuia.bos.redhat.com> <5318FC3F.4080204@redhat.com> <20140307140650.GA1931@suse.de> <20140307150923.GB1931@suse.de> <20140307182745.GD1931@suse.de> <20140311162845.GA30604@suse.de> <531F3F15.8050206@oracle.com> <531F4128.8020109@redhat.com> <531F48CC.303@oracle.com> <20140311180652.GM10663@suse.de>
In-Reply-To: <20140311180652.GM10663@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, hhuang@redhat.com, knoel@redhat.com, aarcange@redhat.com

On 03/11/2014 02:06 PM, Mel Gorman wrote:
> On Tue, Mar 11, 2014 at 01:33:00PM -0400, Sasha Levin wrote:
>> Okay. So just this patch on top of the latest -next shows the following issues:
>>
>> 1. BUG in task_numa_work:
>>
>> [  439.417171] BUG: unable to handle kernel paging request at ffff880e17530c00
>> [  439.418216] IP: [<ffffffff81299385>] vmacache_find+0x75/0xa0
>> [  439.419073] PGD 8904067 PUD 1028fcb067 PMD 1028f10067 PTE 8000000e17530060
>> [  439.420340] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>> [  439.420340] Dumping ftrace buffer:
>> [  439.420340]    (ftrace buffer empty)
>> [  439.420340] Modules linked in:
>> [  439.420340] CPU: 12 PID: 9937 Comm: trinity-c212 Tainted: G        W    3.14.0-rc5-next-20140307-sasha-00009-g3b24300-dirty #137
>> [  439.420340] task: ffff880e1a45b000 ti: ffff880e1a490000 task.ti: ffff880e1a490000
>> [  439.420340] RIP: 0010:[<ffffffff81299385>]  [<ffffffff81299385>] vmacache_find+0x75/0xa0
>> [  439.420340] RSP: 0018:ffff880e1a491e68  EFLAGS: 00010286
>> [  439.420340] RAX: ffff880e17530c00 RBX: 0000000000000000 RCX: 0000000000000001
>> [  439.420340] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffff880e1a45b000
>> [  439.420340] RBP: ffff880e1a491e68 R08: 0000000000000000 R09: 0000000000000000
>> [  439.420340] R10: 0000000000000001 R11: 0000000000000000 R12: ffff880e1ab75000
>> [  439.420340] R13: ffff880e1ab75000 R14: 0000000000010000 R15: 0000000000000000
>> [  439.420340] FS:  00007f3458c05700(0000) GS:ffff880d2b800000(0000) knlGS:0000000000000000
>> [  439.420340] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [  439.420340] CR2: ffff880e17530c00 CR3: 0000000e1a472000 CR4: 00000000000006a0
>> [  439.420340] Stack:
>> [  439.420340]  ffff880e1a491e98 ffffffff812a7610 ffffffff8118de40 0000000000000117
>> [  439.420340]  00000001000036da ffff880e1a45b000 ffff880e1a491ef8 ffffffff8118de4b
>> [  439.420340]  ffff880e1a491ec8 ffffffff81269575 ffff880e1ab750a8 ffff880e1a45b000
>> [  439.420340] Call Trace:
>> [  439.420340]  [<ffffffff812a7610>] find_vma+0x20/0x90
>> [  439.420340]  [<ffffffff8118de40>] ? task_numa_work+0x130/0x360
>> [  439.420340]  [<ffffffff8118de4b>] task_numa_work+0x13b/0x360
>> [  439.420340]  [<ffffffff81269575>] ? context_tracking_user_exit+0x195/0x1d0
>> [  439.420340]  [<ffffffff8116c5be>] task_work_run+0xae/0xf0
>> [  439.420340]  [<ffffffff8106ffbe>] do_notify_resume+0x8e/0xe0
>> [  439.420340]  [<ffffffff844b17a2>] int_signal+0x12/0x17
>> [  439.420340] Code: 42 10 00 00 00 00 48 c7 42 18 00 00 00 00 eb 38 66 0f 1f 44 00 00 31 d2 48 89 c7 48 63 ca 48 8b 84 cf b8 07 00 00 48 85 c0 74 0b <48> 39 30 77 06 48 3b 70 08 72 12 ff c2 83 fa 04 75 de 66 0f 1f
>> [  439.420340] RIP  [<ffffffff81299385>] vmacache_find+0x75/0xa0
>> [  439.420340]  RSP <ffff880e1a491e68>
>> [  439.420340] CR2: ffff880e17530c00
>>
>
> Ok, this does not look related. It looks like damage from the VMA caching
> patches, possibly a use-after free. I'm skeptical that it's related to
> automatic NUMA balancing as such based on the second trace you posted.

It's a bit weird because right after applying the patch I've hit this trace twice while
never seeing it previously.

But it's very possible since there are quite a lot of different mm issues around right now.

> What does addr2line -e vmlinux ffffffff81299385 say? I want to be sure
> it looks like a vma dereference without risking making a mistake
> decoding it.

mm/vmacache.c:75

Or:

	if (vma && vma->vm_start <= addr && vma->vm_end > addr)

> 1. Does this bug trigger even if automatic NUMA balancing is disabled?

(assuming we're talking about kernel BUG at mm/mmap.c:439!)

Yes, same result with numa_balancing=disable.

> 2. Does this bug trigger if DEBUG_PAGEALLOC is disabled? If it's a
> 	use-after free then the bug would still be there.

Still there.

> 3. Can you test with the following patches reverted please?
>
> 	e15d25d9c827b4346a36a3a78dd566d5ad353402 mm-per-thread-vma-caching-fix-fix
> 	e440e20dc76803cdab616b4756c201d5c72857f2 mm-per-thread-vma-caching-fix
> 	0d9ad4220e6d73f63a9eeeaac031b92838f75bb3 mm: per-thread vma caching
>
> The last patch will not revert cleanly (least it didn't for me) but it
> was just a case of git rm the two affected files, remove any include of
> vmacache.h and commit the rest.

Don't see the issues I've reported before now.



Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
