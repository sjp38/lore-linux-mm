Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id CD6B36B002B
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 19:32:00 -0500 (EST)
Received: by mail-vb0-f48.google.com with SMTP id fc21so9188486vbb.21
        for <linux-mm@kvack.org>; Wed, 26 Dec 2012 16:31:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBB9Tqv9c_Wv+N8yJOftfkJeUS10vLuz14eoLH1eEtjmBQ@mail.gmail.com>
References: <1621091901.34838094.1356409676820.JavaMail.root@redhat.com>
	<535932623.34838584.1356410331076.JavaMail.root@redhat.com>
	<CAJd=RBB9Tqv9c_Wv+N8yJOftfkJeUS10vLuz14eoLH1eEtjmBQ@mail.gmail.com>
Date: Thu, 27 Dec 2012 03:31:59 +0300
Message-ID: <CAA1sL1TNq5QiA_6A9+qNjndr0dRL37hhhHgvvLLqr6tgj7CgOw@mail.gmail.com>
Subject: Re: kernel BUG at mm/huge_memory.c:1798!
From: Alexander Beregalov <a.beregalov@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Johannes Weiner <jweiner@redhat.com>, mgorman@suse.de, hughd@google.com, Andrea Arcangeli <aarcange@redhat.com>

On 25 December 2012 16:05, Hillf Danton <dhillf@gmail.com> wrote:
> On Tue, Dec 25, 2012 at 12:38 PM, Zhouping Liu <zliu@redhat.com> wrote:
>> Hello all,
>>
>> I found the below kernel bug using latest mainline(637704cbc95),
>> my hardware has 2 numa nodes, and it's easy to reproduce the issue
>> using LTP test case: "# ./mmap10 -a -s -c 200":
>
> Can you test with 5a505085f0 and 4fc3f1d66b1 reverted?
>

Hello,
does it look like the same problem?

mapcount 0 page_mapcount 1
------------[ cut here ]------------
kernel BUG at mm/huge_memory.c:1798!
invalid opcode: 0000 [#1] PREEMPT SMP
Modules linked in: r8169 radeon cfbfillrect cfbimgblt cfbcopyarea
i2c_algo_bit backlight drm_kms_helper ttm drm agpgart
CPU 3
Pid: 15825, comm: firefox Not tainted 3.8.0-rc1-00004-g637704c #1
Gigabyte Technology Co., Ltd. P35-DS3/P35-DS3
RIP: 0010:[<ffffffff810e89c9>]  [<ffffffff810e89c9>] split_huge_page+0x739/0x7a0
RSP: 0018:ffff880193b43b78  EFLAGS: 00010297
RAX: 0000000000000001 RBX: ffffea0002fd0000 RCX: ffffffff8175e078
RDX: 000000000000003e RSI: ffffea0002fd0000 RDI: 0000000000000246
RBP: ffff880193b43c48 R08: 000000000000ffff R09: 0000000000000000
R10: 00000000000002d5 R11: 0000000000000000 R12: 0000000000000000
R13: ffff880173533464 R14: 00007f0973000000 R15: ffffea0002fd0000
FS:  00007f09b8db6740(0000) GS:ffff88019fd80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007ff210e78008 CR3: 0000000195379000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process firefox (pid: 15825, threadinfo ffff880193b42000, task ffff880198af9f90)
Stack:
 0000000000000000 ffff880193b43e1c 0000000000000000 0000000000000019
 ffff880193b43c08 ffff880100000000 ffff88017af80180 ffff880100000000
 ffff880173533400 ffff880198af9f90 000000009fc91540 ffff88017af801b0
Call Trace:
 [<ffffffff810e9d74>] __split_huge_page_pmd+0xe4/0x280
 [<ffffffff810a9b9e>] ? free_hot_cold_page_list+0x3e/0x60
 [<ffffffff810c22cd>] unmap_single_vma+0x77d/0x820
 [<ffffffff810c2c14>] zap_page_range+0xa4/0xe0
 [<ffffffff813d9846>] ? sys_recvfrom+0xd6/0x120
 [<ffffffff810bfa7d>] sys_madvise+0x31d/0x660
 [<ffffffff81482b2d>] system_call_fastpath+0x1a/0x1f
Code: 83 39 00 f3 90 49 8b 45 00 a9 00 00 80 00 75 f3 41 ff 84 24 44
e0 ff ff f0 41 0f ba 6d 00 17 19 c0 85 c0 0f 84 d7 fa ff ff eb c8 <0f>
0b 8b 53 18 8b 75 9c ff c2 48 c7 c7 60 95 5c 81 31 c0 e8 ac
RIP  [<ffffffff810e89c9>] split_huge_page+0x739/0x7a0
 RSP <ffff880193b43b78>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
