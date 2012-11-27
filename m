Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 1C8046B0070
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 20:16:49 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id t2so10630884qcq.14
        for <linux-mm@kvack.org>; Mon, 26 Nov 2012 17:16:48 -0800 (PST)
Message-ID: <50B4145C.3010406@gmail.com>
Date: Mon, 26 Nov 2012 20:16:12 -0500
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] fix missing rb_subtree_gap updates on vma insert/erase
References: <1352721091-27022-1-git-send-email-walken@google.com> <50A16212.8090507@gmail.com>
In-Reply-To: <50A16212.8090507@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/12/2012 03:54 PM, Sasha Levin wrote:
> On 11/12/2012 06:51 AM, Michel Lespinasse wrote:
>> Using the trinity fuzzer, Sasha Levin uncovered a case where
>> rb_subtree_gap wasn't correctly updated.
>>
>> Digging into this, the root cause was that vma insertions and removals
>> require both an rbtree insert or erase operation (which may trigger
>> tree rotations), and an update of the next vma's gap (which does not
>> change the tree topology, but may require iterating on the node's
>> ancestors to propagate the update). The rbtree rotations caused the
>> rb_subtree_gap values to be updated in some of the internal nodes, but
>> without upstream propagation. Then the subsequent update on the next
>> vma didn't iterate as high up the tree as it should have, as it
>> stopped as soon as it hit one of the internal nodes that had been
>> updated as part of a tree rotation.
>>
>> The fix is to impose that all rb_subtree_gap values must be up to date
>> before any rbtree insertion or erase, with the possible exception that
>> the node being erased doesn't need to have an up to date rb_subtree_gap.
>>
>> These 3 patches apply on top of the stack I previously sent (or equally,
>> on top of the last published mmotm).
>>
>> Michel Lespinasse (3):
>>   mm: ensure safe rb_subtree_gap update when inserting new VMA
>>   mm: ensure safe rb_subtree_gap update when removing VMA
>>   mm: debug code to verify rb_subtree_gap updates are safe
>>
>>  mm/mmap.c |  121 +++++++++++++++++++++++++++++++++++++------------------------
>>  1 files changed, 73 insertions(+), 48 deletions(-)
>>
> 
> Looking good: old warnings gone, no new warnings.


I've built today's -next, and got the following BUG pretty quickly (2-3 hours):

[ 1556.479284] BUG: unable to handle kernel paging request at 0000000000412000
[ 1556.480036] IP: [<ffffffff81238184>] validate_mm+0x34/0x130
[ 1556.480036] PGD 31739067 PUD 4fbc4067 PMD 1c936067 PTE 0
[ 1556.480036] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 1556.480036] Dumping ftrace buffer:
[ 1556.480036]    (ftrace buffer empty)
[ 1556.480036] CPU 0
[ 1556.480036] Pid: 10274, comm: trinity-child29 Tainted: G        W    3.7.0-rc6-next-20121126-sasha-00015-gb04382b-dirty #201
[ 1556.480036] RIP: 0010:[<ffffffff81238184>]  [<ffffffff81238184>] validate_mm+0x34/0x130
[ 1556.480036] RSP: 0018:ffff88004fbc7d08  EFLAGS: 00010206
[ 1556.480036] RAX: 0000000000412000 RBX: 0000000000000000 RCX: 0000000000000000
[ 1556.512120] RDX: 0000000000000000 RSI: ffff88001c1a6008 RDI: ffff88001c1a6000
[ 1556.512120] RBP: ffff88004fbc7d38 R08: ffff8800371e7808 R09: ffff88004fb56cf0
[ 1556.512120] R10: 0000000000000001 R11: 0000000000001000 R12: ffff88001c1a6000
[ 1556.512120] R13: ffff8800371e7b00 R14: 0000000000000000 R15: ffff88001c1a6000
[ 1556.512120] FS:  00007f4e0f8e3700(0000) GS:ffff8800bfc00000(0000) knlGS:0000000000000000
[ 1556.512120] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1556.512120] CR2: 0000000000412000 CR3: 000000002faec000 CR4: 00000000000406f0
[ 1556.512120] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1556.512120] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1556.512120] Process trinity-child29 (pid: 10274, threadinfo ffff88004fbc6000, task ffff88004fbb0000)
[ 1556.512120] Stack:
[ 1556.512120]  ffff8800bf80aa80 ffff88001c1a6000 ffff88004fb56cf0 ffff8800371e7818
[ 1556.512120]  ffff8800371e7808 ffff88001c1a6000 ffff88004fbc7d88 ffffffff8123843c
[ 1556.512120]  0000000000000001 ffff88004fb56da8 ffff880000000000 ffff8800371e7818
[ 1556.512120] Call Trace:
[ 1556.512120]  [<ffffffff8123843c>] vma_link+0xcc/0xf0
[ 1556.512120]  [<ffffffff8123a8ac>] mmap_region+0x40c/0x5a0
[ 1556.512120]  [<ffffffff8123aceb>] do_mmap_pgoff+0x2ab/0x310
[ 1556.512120]  [<ffffffff8122477c>] ? vm_mmap_pgoff+0x6c/0xb0
[ 1556.512120]  [<ffffffff81224794>] vm_mmap_pgoff+0x84/0xb0
[ 1556.512120]  [<ffffffff81239483>] sys_mmap_pgoff+0x193/0x1a0
[ 1556.512120]  [<ffffffff81182b08>] ? trace_hardirqs_on_caller+0x118/0x140
[ 1556.512120]  [<ffffffff810729ad>] sys_mmap+0x1d/0x20
[ 1556.512120]  [<ffffffff83c88418>] tracesys+0xe1/0xe6
[ 1556.512120] Code: 31 f6 41 55 41 54 49 89 fc 53 31 db 48 83 ec 08 4c 8b 2f 4d 85 ed 74 75 0f 1f 80 00 00 00 00 49 8b 85 88 00 00
00 48 85 c0 74 0e <48> 8b 38 31 f6 48 83 c7 08 e8 0e bc a4 02 49 8b 45 78 4d 8d 7d
[ 1556.512120] RIP  [<ffffffff81238184>] validate_mm+0x34/0x130
[ 1556.512120]  RSP <ffff88004fbc7d08>
[ 1556.512120] CR2: 0000000000412000
[ 1557.729958] ---[ end trace d2a29e98cc9e2568 ]---

The bit that's failing is:

        struct vm_area_struct *vma = mm->mmap; // mm->mmap = 0x412000
        while (vma) {
                struct anon_vma_chain *avc;
                vma_lock_anon_vma(vma); // BOOM!


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
