Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id B903C6B0037
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 22:02:14 -0500 (EST)
Received: by mail-yk0-f178.google.com with SMTP id 79so44469394ykr.9
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 19:02:14 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id t26si18639626yhl.255.2014.02.03.19.02.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 19:02:14 -0800 (PST)
Message-ID: <52F05827.1040401@oracle.com>
Date: Mon, 03 Feb 2014 22:01:59 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in do_huge_pmd_wp_page
References: <51559150.3040407@oracle.com> <20130410080202.GB21292@blaptop> <5166CEDD.9050301@oracle.com> <20130411151323.89D40E0085@blue.fi.intel.com> <5166D355.2060103@oracle.com> <20130424154607.60e9b9895539eb5668d2f505@linux-foundation.org> <5179CF8F.7000702@oracle.com> <20130426020101.GA21162@redhat.com>
In-Reply-To: <20130426020101.GA21162@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 04/25/2013 10:01 PM, Dave Jones wrote:
> On Thu, Apr 25, 2013 at 08:51:27PM -0400, Sasha Levin wrote:
>   > On 04/24/2013 06:46 PM, Andrew Morton wrote:
>   > > Guys, did this get fixed?
>   >
>   > I've stopped seeing that during fuzzing, so I guess that it got fixed somehow...
>
> We've had reports of users hitting this in 3.8
>
> eg:
> https://bugzilla.redhat.com/show_bug.cgi?id=947985
> https://bugzilla.redhat.com/show_bug.cgi?id=956730
>
> I'm sure there are other reports of it too.
>
> Would be good if we can figure out what fixed it (if it is actually fixed)
> for backporting to stable

It's been a while (7 months?), but this one is back...

Just hit it again with today's -next:

[  762.701278] BUG: unable to handle kernel paging request at ffff88009eae6000
[  762.702462] IP: [<ffffffff81ae8455>] copy_page_rep+0x5/0x10
[  762.703369] PGD 84bb067 PUD 22fa81067 PMD 22f98b067 PTE 800000009eae6060
[  762.704411] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  762.705873] Dumping ftrace buffer:
[  762.707606]    (ftrace buffer empty)
[  762.708311] Modules linked in:
[  762.708762] CPU: 16 PID: 17920 Comm: trinity-c16 Tainted: G        W    3.13.0-next-2
0140203-sasha-00007-gf4985e2 #23
[  762.710135] task: ffff8801ac358000 ti: ffff880199234000 task.ti: ffff880199234000
[  762.710135] RIP: 0010:[<ffffffff81ae8455>]  [<ffffffff81ae8455>] copy_page_rep+0x5/0x
10
[  762.710135] RSP: 0018:ffff880199235c90  EFLAGS: 00010286
[  762.710135] RAX: 0000000080000002 RBX: 00000000056db980 RCX: 0000000000000200
[  762.710135] RDX: ffff8801ac358000 RSI: ffff88009eae6000 RDI: ffff88015b6e6000
[  762.710135] RBP: ffff880199235cd8 R08: 0000000000000000 R09: 0000000000000000
[  762.710135] R10: 0000000000000001 R11: 0000000000000000 R12: 00000000027ab980
[  762.710135] R13: 0000000000000200 R14: 00000000000000e6 R15: ffff880000000000
[  762.710135] FS:  00007fb0804e1700(0000) GS:ffff88003da00000(0000) knlGS:0000000000000
000
[  762.710135] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  762.710135] CR2: ffff88009eae6000 CR3: 0000000199225000 CR4: 00000000000006e0
[  762.710135] Stack:
[  762.710135]  ffffffff81298995 ffff8801a841ae00 ffff88003d084520 ffff880199227090
[  762.710135]  800000009ea008e5 ffff8801a841ae00 ffffea00027a8000 ffff880199227090
[  762.710135]  ffffea00056d8000 ffff880199235d58 ffffffff812d7260 ffff880199235cf8
[  762.710135] Call Trace:
[  762.710135]  [<ffffffff81298995>] ? copy_user_huge_page+0x1a5/0x210
[  762.710135]  [<ffffffff812d7260>] do_huge_pmd_wp_page+0x3d0/0x650
[  762.710135]  [<ffffffff811a308e>] ? put_lock_stats+0xe/0x30
[  762.710135]  [<ffffffff8129b511>] __handle_mm_fault+0x2b1/0x3d0
[  762.710135]  [<ffffffff8129b763>] handle_mm_fault+0x133/0x1c0
[  762.710135]  [<ffffffff8129bcf8>] __get_user_pages+0x438/0x630
[  762.710135]  [<ffffffff811a308e>] ? put_lock_stats+0xe/0x30
[  762.710135]  [<ffffffff8129cfc4>] __mlock_vma_pages_range+0xd4/0xe0
[  762.710135]  [<ffffffff8129d0e0>] __mm_populate+0x110/0x190
[  762.710135]  [<ffffffff8129dcd0>] SyS_mlockall+0x160/0x1b0
[  762.710135]  [<ffffffff84450650>] tracesys+0xdd/0xe2
[  762.710135] Code: 90 90 90 90 90 90 9c fa 65 48 3b 06 75 14 65 48 3b 56 08 75 0d 65 48 89 1e 65 
48 89 4e 08 9d b0 01 c3 9d 30 c0 c3 b9 00 02 00 00 <f3> 48 a5 c3 0f 1f 80 00
00 00 00 eb ee 66 66 66 90 66 66 66 90
[  762.710135] RIP  [<ffffffff81ae8455>] copy_page_rep+0x5/0x10
[  762.710135]  RSP <ffff880199235c90>
[  762.710135] CR2: ffff88009eae6000


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
