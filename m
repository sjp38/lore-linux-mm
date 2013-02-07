Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id E47086B0005
	for <linux-mm@kvack.org>; Thu,  7 Feb 2013 00:42:50 -0500 (EST)
Message-ID: <51133EC6.4010902@oracle.com>
Date: Thu, 07 Feb 2013 00:42:30 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] mm: accelerate munlock() treatment of THP pages
References: <1359962232-20811-1-git-send-email-walken@google.com>  <1359962232-20811-4-git-send-email-walken@google.com>  <5112EAE8.8070503@oracle.com> <1360205438.13550.11.camel@ThinkPad-T5421.cn.ibm.com>
In-Reply-To: <1360205438.13550.11.camel@ThinkPad-T5421.cn.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: Michel Lespinasse <walken@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/06/2013 09:50 PM, Li Zhong wrote:
> On Wed, 2013-02-06 at 18:44 -0500, Sasha Levin wrote:
>> On 02/04/2013 02:17 AM, Michel Lespinasse wrote:
>>> munlock_vma_pages_range() was always incrementing addresses by PAGE_SIZE
>>> at a time. When munlocking THP pages (or the huge zero page), this resulted
>>> in taking the mm->page_table_lock 512 times in a row.
>>>
>>> We can do better by making use of the page_mask returned by follow_page_mask
>>> (for the huge zero page case), or the size of the page munlock_vma_page()
>>> operated on (for the true THP page case).
>>>
>>> Note - I am sending this as RFC only for now as I can't currently put
>>> my finger on what if anything prevents split_huge_page() from operating
>>> concurrently on the same page as munlock_vma_page(), which would mess
>>> up our NR_MLOCK statistics. Is this a latent bug or is there a subtle
>>> point I missed here ?
>>>
>>> Signed-off-by: Michel Lespinasse <walken@google.com>
>>
>> Hi Michel,
>>
>> Fuzzing with trinity inside a KVM tools guest produces a steady stream of:
>>
>>
>> [   51.823275] ------------[ cut here ]------------
>> [   51.823302] kernel BUG at include/linux/page-flags.h:421!
>> [   51.823307] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>> [   51.823307] Dumping ftrace buffer:
>> [   51.823314]    (ftrace buffer empty)
>> [   51.823314] Modules linked in:
>> [   51.823314] CPU 2
>> [   51.823314] Pid: 7116, comm: trinity Tainted: G        W    3.8.0-rc6-next-20130206-sasha-00027-g3b5963c-dirty #273
>> [   51.823316] RIP: 0010:[<ffffffff81242792>]  [<ffffffff81242792>] munlock_vma_page+0x12/0xf0
>> [   51.823317] RSP: 0018:ffff880009641bb8  EFLAGS: 00010282
>> [   51.823319] RAX: 011ffc0000008001 RBX: ffffea0000410040 RCX: 0000000000000000
>> [   51.823320] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffea0000410040
>> [   51.823321] RBP: ffff880009641bc8 R08: 0000000000000000 R09: 0000000000000000
>> [   51.823322] R10: 0000000000000000 R11: 0000000000000000 R12: ffff880009633958
>> [   51.823324] R13: 0000000001252000 R14: ffffea0000410040 R15: 00000000000000ff
>> [   51.823326] FS:  00007fe7a9046700(0000) GS:ffff88000ba00000(0000) knlGS:0000000000000000
>> [   51.823327] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   51.823328] CR2: 00007fc583b90fcb CR3: 0000000009bc8000 CR4: 00000000000406e0
>> [   51.823334] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> [   51.823338] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> [   51.823340] Process trinity (pid: 7116, threadinfo ffff880009640000, task ffff880009638000)
>> [   51.823341] Stack:
>> [   51.823344]  0000000000a01000 ffff880009633958 ffff880009641c08 ffffffff812429bd
>> [   51.823373]  ffff880009638000 000001ff09638000 ffff880009ade000 ffff880009633958
>> [   51.823373]  ffff880009638810 ffff880009ade098 ffff880009641cb8 ffffffff81246d81
>> [   51.823373] Call Trace:
>> [   51.823373]  [<ffffffff812429bd>] munlock_vma_pages_range+0x8d/0xf0
>> [   51.823373]  [<ffffffff81246d81>] exit_mmap+0x51/0x170
>> [   51.823373]  [<ffffffff81278b4a>] ? __khugepaged_exit+0x8a/0xf0
>> [   51.823373]  [<ffffffff8126a09f>] ? kmem_cache_free+0x22f/0x3b0
>> [   51.823373]  [<ffffffff81278b4a>] ? __khugepaged_exit+0x8a/0xf0
>> [   51.823373]  [<ffffffff8110af97>] mmput+0x77/0xe0
>> [   51.823377]  [<ffffffff81114403>] exit_mm+0x113/0x120
>> [   51.823381]  [<ffffffff83d727f1>] ? _raw_spin_unlock_irq+0x51/0x80
>> [   51.823384]  [<ffffffff8111465a>] do_exit+0x24a/0x590
>> [   51.823387]  [<ffffffff81114a6a>] do_group_exit+0x8a/0xc0
>> [   51.823390]  [<ffffffff81128591>] get_signal_to_deliver+0x501/0x5b0
>> [   51.823394]  [<ffffffff8106dd42>] do_signal+0x42/0x110
>> [   51.823399]  [<ffffffff811d8ea4>] ? rcu_eqs_exit_common+0x64/0x340
>> [   51.823404]  [<ffffffff81184a0d>] ? trace_hardirqs_on+0xd/0x10
>> [   51.823407]  [<ffffffff811849c8>] ? trace_hardirqs_on_caller+0x128/0x160
>> [   51.823409]  [<ffffffff81184a0d>] ? trace_hardirqs_on+0xd/0x10
>> [   51.823412]  [<ffffffff8106de58>] do_notify_resume+0x48/0xa0
>> [   51.823415]  [<ffffffff83d732fb>] retint_signal+0x4d/0x92
>> [   51.823449] Code: 85 c0 75 0d 48 89 df e8 0d 30 fe ff 0f 1f 44 00 00 48 83 c4 08 5b 5d c3 90 55 48 89 e5 41 54 53 48 89 fb 48
>> 8b 07 f6 c4 80 74 06 <0f> 0b 0f 1f 40 00 48 8b 07 48 c1 e8 0e 83 e0 01 83 f8 01 48 8b
>> [   51.823449] RIP  [<ffffffff81242792>] munlock_vma_page+0x12/0xf0
>> [   51.823450]  RSP <ffff880009641bb8>
>> [   51.826846] ---[ end trace a7919e7f17c0a72a ]---
>>
> 
> The similar warning prevents my system from booting. And it seems to me
> that in munlock_vma_pages_range(), the page_mask needs be the page
> number returned from munlock_vma_page() minus 1. And the following fix
> solved my problem. Would you please have a try? 

Solved it here as well, awesome!


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
