Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 433ED6B005C
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 10:56:25 -0400 (EDT)
Message-ID: <522F330E.4030500@oracle.com>
Date: Tue, 10 Sep 2013 10:56:14 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: hugetlb: NULL ptr deref in region_truncate
References: <522C8DA8.6030701@oracle.com> <20130909023949.GA22390@lge.com>
In-Reply-To: <20130909023949.GA22390@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.cz, dhillf@gmail.com, liwanp@linux.vnet.ibm.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, trinity@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, aneesh.kumar@linux.vnet.ibm.com

On 09/08/2013 10:39 PM, Joonsoo Kim wrote:
> On Sun, Sep 08, 2013 at 10:46:00AM -0400, Sasha Levin wrote:
>> Hi all,
>>
>> While fuzzing with trinity inside a KVM tools guest, running latest -next kernel, I've
>> stumbled on the following:
>>
>> [  998.281867] BUG: unable to handle kernel NULL pointer dereference at 0000000000000274
>> [  998.283333] IP: [<ffffffff812707c4>] region_truncate+0x64/0xd0
>> [  998.284288] PGD 0
>> [  998.284717] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>> [  998.286506] Modules linked in:
>> [  998.287101] CPU: 88 PID: 24650 Comm: trinity-child85 Tainted: G
>> B   W 3.11.0-next-20130906-sasha #3985
>> [  998.288844] task: ffff8800c1110000 ti: ffff8800c544a000 task.ti: ffff8800c544a000
>> [  998.290257] RIP: 0010:[<ffffffff812707c4>]  [<ffffffff812707c4>] region_truncate+0x64/0xd0
>> [  998.290301] RSP: 0018:ffff8800c544ba58  EFLAGS: 00010293
>> [  998.290301] RAX: 0000000000000274 RBX: ffff880f47d3b0f8 RCX: 000000003fd075fc
>> [  998.290301] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880f47d3b0f8
>> [  998.290301] RBP: ffff8800c544ba78 R08: 0000000000000000 R09: 0000000000000000
>> [  998.290301] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
>> [  998.290301] R13: ffffffff8741bc60 R14: 0000000000000000 R15: ffff880e9d8b5590
>> [  998.290301] FS:  00007f47f28c2700(0000) GS:ffff880fe2200000(0000) knlGS:0000000000000000
>> [  998.290301] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [  998.290301] CR2: 0000000000000274 CR3: 0000000005a23000 CR4: 00000000000006e0
>> [  998.290301] Stack:
>> [  998.290301]  ffff880f47d3ad50 0000000000000000 ffffffff8741bc60 0000000000000000
>> [  998.290301]  ffff8800c544bac8 ffffffff81274856 0000000000000000 ffff8800c544bb18
>> [  998.290301]  0000000000000000 0000000000000000 0000000000000000 ffff8800c544bb18
>> [  998.290301] Call Trace:
>> [  998.290301]  [<ffffffff81274856>] hugetlb_unreserve_pages+0x46/0xd0
>> [  998.290301]  [<ffffffff8142abe2>] truncate_hugepages+0x202/0x220
>> [  998.290301]  [<ffffffff812d2ec8>] ? inode_wait_for_writeback+0x28/0x50
>> [  998.290301]  [<ffffffff81150fe7>] ? bit_waitqueue+0x17/0xc0
>> [  998.290301]  [<ffffffff812d2ed8>] ? inode_wait_for_writeback+0x38/0x50
>> [  998.290301]  [<ffffffff8142ac18>] hugetlbfs_evict_inode+0x18/0x30
>> [  998.290301]  [<ffffffff812c4001>] evict+0xc1/0x1a0
>> [  998.290301]  [<ffffffff812c4243>] iput_final+0x163/0x180
>> [  998.290301]  [<ffffffff812c42af>] iput+0x4f/0x60
>> [  998.290301]  [<ffffffff812bf5a8>] dentry_iput+0xc8/0xf0
>> [  998.290301]  [<ffffffff812c200a>] dput+0x17a/0x1a0
>> [  998.290301]  [<ffffffff812a9ea7>] __fput+0x2b7/0x2d0
>> [  998.290301]  [<ffffffff812a9f8e>] ____fput+0xe/0x10
>> [  998.290301]  [<ffffffff81149b4e>] task_work_run+0xae/0xf0
>> [  998.290301]  [<ffffffff81127c09>] do_exit+0x2d9/0x4d0
>> [  998.290301]  [<ffffffff81127ea9>] do_group_exit+0xa9/0xe0
>> [  998.290301]  [<ffffffff8113c185>] get_signal_to_deliver+0x475/0x4d0
>> [  998.290301]  [<ffffffff81067c2b>] do_signal+0x4b/0x120
>> [  998.290301]  [<ffffffff8114ba24>] ? __rcu_read_unlock+0x44/0x80
>> [  998.290301]  [<ffffffff8116911c>] ? vtime_account_user+0x5c/0x70
>> [  998.290301]  [<ffffffff81222215>] ? context_tracking_user_exit+0x145/0x150
>> [  998.290301]  [<ffffffff81067f8a>] do_notify_resume+0x5a/0xe0
>> [  998.290301]  [<ffffffff841129a0>] int_signal+0x12/0x17
>> [  998.290301] Code: 0e 48 8b 00 48 39 d8 75 ee eb 6c 0f 1f 40 00 45
>> 31 f6 48 3b 70 10 90 7e 0e 4c 8b 70 18 48 89 70 18 49 29 f6 48 8b 00
>> 48 8b 40 08 <4c> 8b 28 4d 8b 65 00 4c 89 ef 4d 3b 6d 08 74 44 4c 39
>> eb 75 12
>> [  998.290301] RIP  [<ffffffff812707c4>] region_truncate+0x64/0xd0
>> [  998.290301]  RSP <ffff8800c544ba58>
>> [  998.290301] CR2: 0000000000000274
>
> More ccing to experts.
>
> It looks like region tracking list corruption,
> but I'm not sure that it is related to recent changes,
> because, theoretically, the race is possible on region tracking long time ago.
>
> Sasha, Is it easily reproducible?
> If so, could you tell me how to reproduce it?

No, it's not too easy to reproduce. I've seen it only once so far.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
