Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id F0BE66B005D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 23:51:26 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so7347320ied.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 20:51:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5089A05E.7040000@gmail.com>
References: <508086DA.3010600@oracle.com> <5089A05E.7040000@gmail.com>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Fri, 2 Nov 2012 23:51:06 -0400
Message-ID: <CA+1xoqf2v_jEapwU68BzXyi4abSRmi_=AiaJVHM3dBbHtsBnqQ@mail.gmail.com>
Subject: Re: mm: NULL ptr deref in anon_vma_interval_tree_verify
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Michel Lespinasse <walken@google.com>, hughd@google.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

Ping?

On Thu, Oct 25, 2012 at 4:26 PM, Sasha Levin <levinsasha928@gmail.com> wrote:
> On 10/18/2012 06:46 PM, Sasha Levin wrote:
>> Hi all,
>>
>> While fuzzing with trinity inside a KVM tools (lkvm) guest, on today's linux-next kernel,
>> I saw the following:
>>
>> [ 1857.278176] BUG: unable to handle kernel NULL pointer dereference at 0000000000000090
>> [ 1857.283725] IP: [<ffffffff81229d0f>] anon_vma_interval_tree_verify+0xf/0xa0
>> [ 1857.283725] PGD 6e19e067 PUD 6e19f067 PMD 0
>> [ 1857.283725] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>> [ 1857.283725] Dumping ftrace buffer:
>> [ 1857.283725]    (ftrace buffer empty)
>> [ 1857.283725] CPU 2
>> [ 1857.283725] Pid: 15637, comm: trinity-child18 Tainted: G        W    3.7.0-rc1-next-20121018-sasha-00002-g60a870d-dirty #61
>> [ 1857.283725] RIP: 0010:[<ffffffff81229d0f>]  [<ffffffff81229d0f>] anon_vma_interval_tree_verify+0xf/0xa0
>> [ 1857.283725] RSP: 0018:ffff88007df0fce8  EFLAGS: 00010296
>> [ 1857.283725] RAX: ffff880089db1000 RBX: ffff880089db0ff0 RCX: ffff8800869e6928
>> [ 1857.283725] RDX: 0000000000000000 RSI: ffff880089db1008 RDI: ffff880089db0ff0
>> [ 1857.283725] RBP: ffff88007df0fcf8 R08: ffff88006427d508 R09: ffff88012bb95f20
>> [ 1857.283725] R10: 0000000000000001 R11: ffff8800c8525c60 R12: ffff88006e199370
>> [ 1857.283725] R13: ffff88006e199300 R14: 0000000000000000 R15: ffff880089db1000
>> [ 1857.283725] FS:  00007f322fd4c700(0000) GS:ffff88004d600000(0000) knlGS:0000000000000000
>> [ 1857.283725] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [ 1857.283725] CR2: 0000000000000090 CR3: 000000006e19d000 CR4: 00000000000406e0
>> [ 1857.283725] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> [ 1857.283725] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> [ 1857.283725] Process trinity-child18 (pid: 15637, threadinfo ffff88007df0e000, task ffff88007ac80000)
>> [ 1857.283725] Stack:
>> [ 1857.283725]  ffff88007df0fd38 ffff880089db0ff0 ffff88007df0fd48 ffffffff81233b58
>> [ 1857.283725]  ffff88007df0fd38 ffff880089db1000 00000000000080d0 ffff880089db1000
>> [ 1857.283725]  ffff88012bb95f20 ffff8800005d97c8 ffff8800005d97d8 ffff880089db1000
>> [ 1857.283725] Call Trace:
>> [ 1857.283725]  [<ffffffff81233b58>] validate_mm+0x58/0x1e0
>> [ 1857.283725]  [<ffffffff81233da4>] vma_link+0x94/0xe0
>> [ 1857.283725]  [<ffffffff83a67fd4>] ? _raw_spin_unlock_irqrestore+0x84/0xb0
>> [ 1857.283725]  [<ffffffff81235f75>] mmap_region+0x3f5/0x5c0
>> [ 1857.283725]  [<ffffffff812363f7>] do_mmap_pgoff+0x2b7/0x330
>> [ 1857.283725]  [<ffffffff81220fd1>] ? vm_mmap_pgoff+0x61/0xa0
>> [ 1857.283725]  [<ffffffff81220fea>] vm_mmap_pgoff+0x7a/0xa0
>> [ 1857.283725]  [<ffffffff81234c72>] sys_mmap_pgoff+0x182/0x1a0
>> [ 1857.283725]  [<ffffffff8107dc40>] ? syscall_trace_enter+0x20/0x2e0
>> [ 1857.283725]  [<ffffffff810738dd>] sys_mmap+0x1d/0x20
>> [ 1857.283725]  [<ffffffff83a69ad8>] tracesys+0xe1/0xe6
>> [ 1857.283725] Code: 48 39 ce 77 9e f3 c3 0f 1f 44 00 00 31 c0 c3 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 53 48 89 fb
>> 48 83 ec 08 48 8b 17 <48> 8b 8a 90 00 00 00 48 39 4f 40 74 34 80 3d a6 82 5b 04 00 75
>> [ 1857.283725] RIP  [<ffffffff81229d0f>] anon_vma_interval_tree_verify+0xf/0xa0
>> [ 1857.283725]  RSP <ffff88007df0fce8>
>> [ 1857.283725] CR2: 0000000000000090
>> [ 1858.611277] ---[ end trace b51cc425e9b07fc0 ]---
>>
>> The obvious part is that anon_vma_interval_tree_verify() got called with node == NULL, but when
>> looking at the caller:
>>
>>                 list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
>>                         anon_vma_interval_tree_verify(avc);
>>
>> How it got called with said NULL becomes less obvious.
>
> I've hit a similar one with today's -next. It isn't exactly the same, but
> I suspect it's the same issue.
>
> [ 1523.657950] BUG: unable to handle kernel paging request at fffffffffffffff0
> [ 1523.660022] IP: [<ffffffff8122c29c>] anon_vma_interval_tree_verify+0xc/0xa0
> [ 1523.660022] PGD 4e28067 PUD 4e29067 PMD 0
> [ 1523.675725] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 1523.750066] CPU 0
> [ 1523.750066] Pid: 9050, comm: trinity-child64 Tainted: G        W    3.7.0-rc2-next-20121025-sasha-00001-g673f98e-dirty #77
> [ 1523.750066] RIP: 0010:[<ffffffff8122c29c>]  [<ffffffff8122c29c>] anon_vma_interval_tree_verify+0xc/0xa0
> [ 1523.750066] RSP: 0018:ffff880045f81d48  EFLAGS: 00010296
> [ 1523.750066] RAX: 0000000000000000 RBX: fffffffffffffff0 RCX: 0000000000000000
> [ 1523.750066] RDX: 0000000000000000 RSI: 0000000000000001 RDI: fffffffffffffff0
> [ 1523.750066] RBP: ffff880045f81d58 R08: 0000000000000000 R09: 0000000000000f14
> [ 1523.750066] R10: 0000000000000f12 R11: 0000000000000000 R12: ffff8800096c8d70
> [ 1523.750066] R13: ffff8800096c8d00 R14: 0000000000000000 R15: ffff8800095b45e0
> [ 1523.750066] FS:  00007f7a923f3700(0000) GS:ffff880013600000(0000) knlGS:0000000000000000
> [ 1523.750066] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1523.750066] CR2: fffffffffffffff0 CR3: 000000000969d000 CR4: 00000000000406f0
> [ 1523.750066] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 1523.750066] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [ 1523.750066] Process trinity-child64 (pid: 9050, threadinfo ffff880045f80000, task ffff880048eb0000)
> [ 1523.750066] Stack:
> [ 1523.750066]  ffff88000d7533f0 fffffffffffffff0 ffff880045f81da8 ffffffff812361d8
> [ 1523.750066]  ffff880045f81d98 ffff880048ee9000 ffff8800095b4580 ffff8800095b4580
> [ 1523.750066]  ffff88001d1cdb00 ffff8800095b45f0 ffff880022a4d630 ffff8800095b45e0
> [ 1523.750066] Call Trace:
> [ 1523.750066]  [<ffffffff812361d8>] validate_mm+0x58/0x1e0
> [ 1523.750066]  [<ffffffff81236aa5>] vma_adjust+0x635/0x6b0
> [ 1523.750066]  [<ffffffff81236c81>] __split_vma.isra.22+0x161/0x220
> [ 1523.750066]  [<ffffffff81237934>] split_vma+0x24/0x30
> [ 1523.750066]  [<ffffffff8122ce6a>] sys_madvise+0x5da/0x7b0
> [ 1523.750066]  [<ffffffff811cd14c>] ? rcu_eqs_exit+0x9c/0xb0
> [ 1523.750066]  [<ffffffff811802cd>] ? trace_hardirqs_on+0xd/0x10
> [ 1523.750066]  [<ffffffff83aee198>] tracesys+0xe1/0xe6
> [ 1523.750066] Code: 4c 09 ff 48 39 ce 77 9e f3 c3 0f 1f 44 00 00 31 c0 c3 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 53
> 48 89 fb 48 83 ec 08 <48> 8b 17 48 8b 8a 90 00 00 00 48 39 4f 40 74 34 80 3d f7 1f 5c
> [ 1523.750066] RIP  [<ffffffff8122c29c>] anon_vma_interval_tree_verify+0xc/0xa0
> [ 1523.750066]  RSP <ffff880045f81d48>
> [ 1523.750066] CR2: fffffffffffffff0
> [ 1523.750066] ---[ end trace e35e5fa49072faf9 ]---
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
