Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id EF8CB6B00B3
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 13:36:16 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id gq1so8762210obb.18
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 10:36:16 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d7si13960825oeh.95.2014.03.11.10.36.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 10:36:16 -0700 (PDT)
Message-ID: <531F48CC.303@oracle.com>
Date: Tue, 11 Mar 2014 13:33:00 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mm,numa,mprotect: always continue after finding a
 stable thp page
References: <5318E4BC.50301@oracle.com> <20140306173137.6a23a0b2@cuia.bos.redhat.com> <5318FC3F.4080204@redhat.com> <20140307140650.GA1931@suse.de> <20140307150923.GB1931@suse.de> <20140307182745.GD1931@suse.de> <20140311162845.GA30604@suse.de> <531F3F15.8050206@oracle.com> <531F4128.8020109@redhat.com>
In-Reply-To: <531F4128.8020109@redhat.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, hhuang@redhat.com, knoel@redhat.com, aarcange@redhat.com

On 03/11/2014 01:00 PM, Rik van Riel wrote:
> On 03/11/2014 12:51 PM, Sasha Levin wrote:
>> On 03/11/2014 12:28 PM, Mel Gorman wrote:
>>> On Fri, Mar 07, 2014 at 06:27:45PM +0000, Mel Gorman wrote:
>>>>> This is a completely untested prototype. It rechecks pmd_trans_huge
>>>>> under the lock and falls through if it hit a parallel split. It's not
>>>>> perfect because it could decide to fall through just because there was
>>>>> no prot_numa work to do but it's for illustration purposes. Secondly,
>>>>> I noted that you are calling invalidate for every pmd range. Is that
>>>>> not
>>>>> a lot of invalidations? We could do the same by just tracking the
>>>>> address
>>>>> of the first invalidation.
>>>>>
>>>>
>>>> And there were other minor issues. This is still untested but Sasha,
>>>> can you try it out please? I discussed this with Rik on IRC for a bit
>>>> and
>>>> reckon this should be sufficient if the correct race has been
>>>> identified.
>>>>
>>>
>>> Any luck with this patch Sasha? It passed basic tests here but I had not
>>> seen the issue trigger either.
>>>
>>
>> Sorry, I've been stuck in my weekend project of getting lockdep to work
>> with page locks :)
>>
>> It takes a moment to test, so just to be sure - I should have only this
>> last patch applied?
>> Without the one in the original mail?
>
> Indeed, only this patch should do it.

Okay. So just this patch on top of the latest -next shows the following issues:

1. BUG in task_numa_work:

[  439.417171] BUG: unable to handle kernel paging request at ffff880e17530c00
[  439.418216] IP: [<ffffffff81299385>] vmacache_find+0x75/0xa0
[  439.419073] PGD 8904067 PUD 1028fcb067 PMD 1028f10067 PTE 8000000e17530060
[  439.420340] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  439.420340] Dumping ftrace buffer:
[  439.420340]    (ftrace buffer empty)
[  439.420340] Modules linked in:
[  439.420340] CPU: 12 PID: 9937 Comm: trinity-c212 Tainted: G        W    3.14.0-rc5-next-20140307-sasha-00009-g3b24300-dirty #137
[  439.420340] task: ffff880e1a45b000 ti: ffff880e1a490000 task.ti: ffff880e1a490000
[  439.420340] RIP: 0010:[<ffffffff81299385>]  [<ffffffff81299385>] vmacache_find+0x75/0xa0
[  439.420340] RSP: 0018:ffff880e1a491e68  EFLAGS: 00010286
[  439.420340] RAX: ffff880e17530c00 RBX: 0000000000000000 RCX: 0000000000000001
[  439.420340] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffff880e1a45b000
[  439.420340] RBP: ffff880e1a491e68 R08: 0000000000000000 R09: 0000000000000000
[  439.420340] R10: 0000000000000001 R11: 0000000000000000 R12: ffff880e1ab75000
[  439.420340] R13: ffff880e1ab75000 R14: 0000000000010000 R15: 0000000000000000
[  439.420340] FS:  00007f3458c05700(0000) GS:ffff880d2b800000(0000) knlGS:0000000000000000
[  439.420340] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  439.420340] CR2: ffff880e17530c00 CR3: 0000000e1a472000 CR4: 00000000000006a0
[  439.420340] Stack:
[  439.420340]  ffff880e1a491e98 ffffffff812a7610 ffffffff8118de40 0000000000000117
[  439.420340]  00000001000036da ffff880e1a45b000 ffff880e1a491ef8 ffffffff8118de4b
[  439.420340]  ffff880e1a491ec8 ffffffff81269575 ffff880e1ab750a8 ffff880e1a45b000
[  439.420340] Call Trace:
[  439.420340]  [<ffffffff812a7610>] find_vma+0x20/0x90
[  439.420340]  [<ffffffff8118de40>] ? task_numa_work+0x130/0x360
[  439.420340]  [<ffffffff8118de4b>] task_numa_work+0x13b/0x360
[  439.420340]  [<ffffffff81269575>] ? context_tracking_user_exit+0x195/0x1d0
[  439.420340]  [<ffffffff8116c5be>] task_work_run+0xae/0xf0
[  439.420340]  [<ffffffff8106ffbe>] do_notify_resume+0x8e/0xe0
[  439.420340]  [<ffffffff844b17a2>] int_signal+0x12/0x17
[  439.420340] Code: 42 10 00 00 00 00 48 c7 42 18 00 00 00 00 eb 38 66 0f 1f 44 00 00 31 d2 48 89 c7 48 63 ca 48 8b 84 cf b8 07 00 00 48 85 c0 74 0b <48> 39 30 77 06 48 3b 70 08 72 12 ff c2 83 fa 04 75 de 66 0f 1f
[  439.420340] RIP  [<ffffffff81299385>] vmacache_find+0x75/0xa0
[  439.420340]  RSP <ffff880e1a491e68>
[  439.420340] CR2: ffff880e17530c00

2. Similar to the above, but with a different trace:

[  304.212158] BUG: unable to handle kernel paging request at ffff88020d37f800
[  304.220420] IP: [<ffffffff81299385>] vmacache_find+0x75/0xa0
[  304.220420] PGD 8904067 PUD 102effb067 PMD 102ef91067 PTE 800000020d37f060
[  304.220420] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  304.220420] Dumping ftrace buffer:
[  304.220420]    (ftrace buffer empty)
[  304.220420] Modules linked in:
[  304.220420] CPU: 30 PID: 11157 Comm: trinity-c393 Tainted: G    B   W    3.14.0-rc5-next-20140307-sasha-00009-g3b24300-dirty #137
[  304.220420] task: ffff881020a90000 ti: ffff88101fda2000 task.ti: ffff88101fda2000
[  304.260466] RIP: 0010:[<ffffffff81299385>]  [<ffffffff81299385>] vmacache_find+0x75/0xa0
[  304.260466] RSP: 0000:ffff88101fda3da8  EFLAGS: 00010286
[  304.260466] RAX: ffff88020d37f800 RBX: 00007f7f92f680fc RCX: 0000000000000000
[  304.260466] RDX: 0000000000000000 RSI: 00007f7f92f680fc RDI: ffff881020a90000
[  304.260466] RBP: ffff88101fda3da8 R08: 0000000000000001 R09: 0000000000000000
[  304.260466] R10: 0000000000000000 R11: 0000000000000000 R12: ffff881021358000
[  304.260466] R13: 0000000000000000 R14: ffff8810213580a8 R15: ffff881021358000
[  304.260466] FS:  00007f7f92f8d700(0000) GS:ffff880f2ba00000(0000) knlGS:0000000000000000
[  304.260466] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  304.260466] CR2: ffff88020d37f800 CR3: 000000101fd6b000 CR4: 00000000000006a0
[  304.260466] Stack:
[  304.260466]  ffff88101fda3dd8 ffffffff812a7610 ffffffff844abd82 00007f7f92f680fc
[  304.260466]  00007f7f92f680fc 00000000000000a8 ffff88101fda3ef8 ffffffff844abdd6
[  304.260466]  ffff88101fda3e08 ffffffff811a60d6 0000000000000000 ffff881020a90000
[  304.260466] Call Trace:
[  304.260466]  [<ffffffff812a7610>] find_vma+0x20/0x90
[  304.260466]  [<ffffffff844abd82>] ? __do_page_fault+0x302/0x5d0
[  304.260466]  [<ffffffff844abdd6>] __do_page_fault+0x356/0x5d0
[  304.260466]  [<ffffffff811a60d6>] ? trace_hardirqs_off_caller+0x16/0x1a0
[  304.260466]  [<ffffffff8118ab46>] ? vtime_account_user+0x96/0xb0
[  304.260466]  [<ffffffff844ac4d2>] ? preempt_count_sub+0xe2/0x120
[  304.260466]  [<ffffffff81269567>] ? context_tracking_user_exit+0x187/0x1d0
[  304.260466]  [<ffffffff811a60d6>] ? trace_hardirqs_off_caller+0x16/0x1a0
[  304.260466]  [<ffffffff844ac115>] do_page_fault+0x45/0x70
[  304.260466]  [<ffffffff844ab3c6>] do_async_page_fault+0x36/0x100
[  304.260466]  [<ffffffff844a7f58>] async_page_fault+0x28/0x30
[  304.260466] Code: 42 10 00 00 00 00 48 c7 42 18 00 00 00 00 eb 38 66 0f 1f 44 00 00 31 d2 48 89 c7 48 63 ca 48 8b 84 cf b8 07 00 00 48 85 c0 74 0b <48> 39 30 77 06 48 3b 70 08 72 12 ff c2 83 fa 04 75 de 66 0f 1f
[  304.260466] RIP  [<ffffffff81299385>] vmacache_find+0x75/0xa0
[  304.260466]  RSP <ffff88101fda3da8>
[  304.260466] CR2: ffff88020d37f800

3. This one is a new issue. Might be related to something else but it seems related as I've never
saw it before this patch:

[  560.473342] kernel BUG at mm/mmap.c:439!
[  560.473766] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  560.474723] Dumping ftrace buffer:
[  560.475410]    (ftrace buffer empty)
[  560.476098] Modules linked in:
[  560.476241] CPU: 10 PID: 17037 Comm: trinity-c84 Tainted: G        W    3.14.0-rc5-next-20140307-sasha-00009-g3b24300-dirty #137
[  560.477651] task: ffff880424310000 ti: ffff8803eec4c000 task.ti: ffff8803eec4c000
[  560.478595] RIP: 0010:[<ffffffff812a6ef5>]  [<ffffffff812a6ef5>] validate_mm+0x115/0x140
[  560.479749] RSP: 0018:ffff8803eec4de98  EFLAGS: 00010296
[  560.480471] RAX: 0000000000000012 RBX: 00007fff8ae88000 RCX: 0000000000000006
[  560.481490] RDX: 0000000000000006 RSI: ffff880424310cf0 RDI: 0000000000000282
[  560.481490] RBP: ffff8803eec4dec8 R08: 0000000000000001 R09: 0000000000000001
[  560.481490] R10: 0000000000000001 R11: 0000000000000001 R12: ffff8803f61aa000
[  560.481490] R13: 0000000000000001 R14: 0000000000000000 R15: 0000000000000048
[  560.481490] FS:  00007f799ddf6700(0000) GS:ffff880b2b800000(0000) knlGS:0000000000000000
[  560.481490] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  560.481490] CR2: 0000000004502048 CR3: 00000003f8bcb000 CR4: 00000000000006a0
[  560.481490] Stack:
[  560.481490]  ffff8803eec4dec8 0000000000000000 ffff8803f61aa000 ffff8800a22fae00
[  560.481490]  0000000000000000 00007f799d4dc000 ffff8803eec4df28 ffffffff812a8fb7
[  560.481490]  ffffffff00000001 ffff880b21453600 ffff8800a22fae10 ffff8803f61aa008
[  560.481490] Call Trace:
[  560.481490]  [<ffffffff812a8fb7>] do_munmap+0x307/0x360
[  560.493775]  [<ffffffff812a9056>] ? vm_munmap+0x46/0x80
[  560.493775]  [<ffffffff812a9064>] vm_munmap+0x54/0x80
[  560.493775]  [<ffffffff812a90bc>] SyS_munmap+0x2c/0x40
[  560.493775]  [<ffffffff844b1690>] tracesys+0xdd/0xe2
[  560.493775] Code: 32 fd ff ff 41 8b 74 24 58 39 f0 74 19 89 c2 48 c7 c7 19 f5 6d 85 31 c0 e8 45 8c 1f 03 eb 0c 0f 1f 80 00 00 00 00 45 85 ed 74 0d <0f> 0b 66 0f 1f 84 00 00 00 00 00 eb fe 48 83 c4 08 5b 41 5c 41
[  560.493775] RIP  [<ffffffff812a6ef5>] validate_mm+0x115/0x140
[  560.493775]  RSP <ffff8803eec4de98>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
