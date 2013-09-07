Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 3571E6B0031
	for <linux-mm@kvack.org>; Sat,  7 Sep 2013 17:32:22 -0400 (EDT)
Message-ID: <522B9B5D.4010207@oracle.com>
Date: Sat, 07 Sep 2013 17:32:13 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: gpf in find_vma
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, walken@google.com, riel@redhat.com, hughd@google.com, khlebnikov@openvz.org, trinity@vger.kernel.org

Hi all,

While fuzzing with trinity inside a KVM tools guest, running latest -next kernel, I've
stumbled on the following:

[13600.008029] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[13600.010235] Modules linked in:
[13600.010742] CPU: 30 PID: 26329 Comm: kworker/u128:2 Tainted: G        W 
3.11.0-next-20130906-sasha #3985
[13600.012301] task: ffff880e54630000 ti: ffff880e52380000 task.ti: ffff880e52380000
[13600.013553] RIP: 0010:[<ffffffff81258b82>]  [<ffffffff81258b82>] find_vma+0x12/0x70
[13600.014929] RSP: 0018:ffff880e52381c38  EFLAGS: 00010282
[13600.016808] RAX: f0000040f0000040 RBX: 00007fffffffe000 RCX: ffff880e54630000
[13600.016808] RDX: 0000000000000000 RSI: 00007fffffffe000 RDI: ffff880000000000
[13600.016808] RBP: ffff880e52381c38 R08: 0000000000000017 R09: ffff880e52381d70
[13600.016808] R10: ffff880e52381d70 R11: 0000000000000007 R12: ffff880e54630000
[13600.016808] R13: ffff880000000000 R14: 000000000000000f R15: 0000000000000000
[13600.016808] FS:  0000000000000000(0000) GS:ffff880fe3200000(0000) knlGS:0000000000000000
[13600.016808] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[13600.016808] CR2: 0000000004a66678 CR3: 0000000e520fe000 CR4: 00000000000006e0
[13600.016808] Stack:
[13600.016808]  ffff880e52381c68 ffffffff8125a36b ffff880fb7d373c8 ffff880fb6f82238
[13600.016808]  ffff880e54630000 ffff880000000000 ffff880e52381d28 ffffffff8125622d
[13600.016808]  ffff880e52381c98 ffffffff84109b7c 00000000b7d373c8 ffff880e52380010
[13600.016808] Call Trace:
[13600.016808]  [<ffffffff8125a36b>] find_extend_vma+0x2b/0x90
[13600.016808]  [<ffffffff8125622d>] __get_user_pages+0xdd/0x630
[13600.016808]  [<ffffffff84109b7c>] ? _raw_spin_unlock_irqrestore+0x7c/0xa0
[13600.016808]  [<ffffffff81256832>] get_user_pages+0x52/0x60
[13600.016808]  [<ffffffff812adecc>] get_arg_page+0x5c/0x100
[13600.016808]  [<ffffffff812ade58>] ? get_user_arg_ptr+0x58/0x70
[13600.016808]  [<ffffffff812ae084>] copy_strings+0x114/0x260
[13600.016808]  [<ffffffff812ae21b>] copy_strings_kernel+0x4b/0x60
[13600.016808]  [<ffffffff812b0203>] do_execve_common+0x2f3/0x4d0
[13600.016808]  [<ffffffff812b001c>] ? do_execve_common+0x10c/0x4d0
[13600.016808]  [<ffffffff812b04a7>] do_execve+0x37/0x40
[13600.016808]  [<ffffffff81140721>] ____call_usermodehelper+0x111/0x130
[13600.016808]  [<ffffffff8115f270>] ? schedule_tail+0x30/0xb0
[13600.016808]  [<ffffffff81140610>] ? __call_usermodehelper+0xb0/0xb0
[13600.016808]  [<ffffffff841125ec>] ret_from_fork+0x7c/0xb0
[13600.016808]  [<ffffffff81140610>] ? __call_usermodehelper+0xb0/0xb0
[13600.016808] Code: 40 20 83 f0 01 83 e0 01 eb 09 0f 1f 80 00 00 00 00 31 c0 c9 c3 0f 1f 40 00 55 
48 89 e5 66 66 66 66 90 48 8b 47 10 48 85 c0 74 0b <48> 39 70 08 76 05 48 3b 30 73 4d 48 8b 57 08 31 
c0 48 85 d2 74
[13600.016808] RIP  [<ffffffff81258b82>] find_vma+0x12/0x70
[13600.016808]  RSP <ffff880e52381c38>

The disassembly is:

         /* Check the cache first. */
         /* (Cache hit rate is typically around 35%.) */
         vma = ACCESS_ONCE(mm->mmap_cache);
      1f9:       48 8b 47 10             mov    0x10(%rdi),%rax
         if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
      1fd:       48 85 c0                test   %rax,%rax
      200:       74 0b                   je     20d <find_vma+0x1d>
      202:       48 39 70 08             cmp    %rsi,0x8(%rax)		<--- here
      206:       76 05                   jbe    20d <find_vma+0x1d>
      208:       48 3b 30                cmp    (%rax),%rsi
      20b:       73 4d                   jae    25a <find_vma+0x6a>


Note that I've started seeing this when I started testing with 64 vcpus.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
