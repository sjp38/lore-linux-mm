Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 57BA56B0035
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 16:45:21 -0400 (EDT)
Received: by mail-yh0-f48.google.com with SMTP id z6so9247570yhz.35
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 13:45:21 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f64si38242493yhq.104.2014.03.11.13.45.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 13:45:20 -0700 (PDT)
Message-ID: <531F75D1.3060909@oracle.com>
Date: Tue, 11 Mar 2014 16:45:05 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: mmap_sem lock assertion failure in __mlock_vma_pages_range
References: <531F6689.60307@oracle.com>	<1394568453.2786.28.camel@buesod1.americas.hpqcorp.net> <20140311133051.bf5ca716ef189746ebcff431@linux-foundation.org>
In-Reply-To: <20140311133051.bf5ca716ef189746ebcff431@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr@hp.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On 03/11/2014 04:30 PM, Andrew Morton wrote:
> All I can think is that find_vma() went and returned a vma from a
> different mm, which would be odd.  How about I toss this in there?
>
> --- a/mm/vmacache.c~a
> +++ a/mm/vmacache.c
> @@ -72,8 +72,10 @@ struct vm_area_struct *vmacache_find(str
>   	for (i = 0; i < VMACACHE_SIZE; i++) {
>   		struct vm_area_struct *vma = current->vmacache[i];
>
> -		if (vma && vma->vm_start <= addr && vma->vm_end > addr)
> +		if (vma && vma->vm_start <= addr && vma->vm_end > addr) {
> +			BUG_ON(vma->vm_mm != mm);
>   			return vma;
> +		}
>   	}
>
>   	return NULL;

Bingo! With the above patch:

[  243.565794] kernel BUG at mm/vmacache.c:76!
[  243.566720] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  243.568048] Dumping ftrace buffer:
[  243.568740]    (ftrace buffer empty)
[  243.569481] Modules linked in:
[  243.570203] CPU: 10 PID: 10073 Comm: trinity-c332 Tainted: G        W    3.14.0-rc5-next-20140307-sasha-00010-g1f812cb-dirty #143
[  243.571505] task: ffff8800b8698000 ti: ffff8800b8694000 task.ti: ffff8800b8694000
[  243.571505] RIP: 0010:[<ffffffff81299396>]  [<ffffffff81299396>] vmacache_find+0x86/0xb0
[  243.571505] RSP: 0000:ffff8800b8695da8  EFLAGS: 00010287
[  243.571505] RAX: ffff88042890e400 RBX: 0000000002d6cb18 RCX: 0000000000000002
[  243.571505] RDX: 0000000000000002 RSI: 0000000002d6cb18 RDI: ffff8800b86a8000
[  243.571505] RBP: ffff8800b8695da8 R08: ffff8800b8698000 R09: 0000000000000000
[  243.571505] R10: 0000000000000001 R11: 0000000000000000 R12: ffff8800b86a8000
[  243.571505] R13: 00000000000014f1 R14: ffff8800b86a80a8 R15: ffff8800b86a8000
[  243.582665] FS:  00007f74df081700(0000) GS:ffff880b2b800000(0000) knlGS:0000000000000000
[  243.582665] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  243.582665] CR2: 0000000002d6cb18 CR3: 00000000b8682000 CR4: 00000000000006a0
[  243.582665] Stack:
[  243.582665]  ffff8800b8695dd8 ffffffff812a7620 ffffffff844abd82 0000000002d6cb18
[  243.582665]  0000000002d6cb18 00000000000000a9 ffff8800b8695ef8 ffffffff844abdd6
[  243.582665]  ffff8800b8698000 ffff8800b8698000 0000000000000002 ffff8800b8698000
[  243.582665] Call Trace:
[  243.582665]  [<ffffffff812a7620>] find_vma+0x20/0x90
[  243.582665]  [<ffffffff844abd82>] ? __do_page_fault+0x302/0x5d0
[  243.582665]  [<ffffffff844abdd6>] __do_page_fault+0x356/0x5d0
[  243.582665]  [<ffffffff8118ab46>] ? vtime_account_user+0x96/0xb0
[  243.582665]  [<ffffffff844ac4d2>] ? preempt_count_sub+0xe2/0x120
[  243.582665]  [<ffffffff81269567>] ? context_tracking_user_exit+0x187/0x1d0
[  243.582665]  [<ffffffff844ac115>] do_page_fault+0x45/0x70
[  243.582665]  [<ffffffff844ab3c6>] do_async_page_fault+0x36/0x100
[  243.582665]  [<ffffffff844a7f58>] async_page_fault+0x28/0x30
[  243.582665] Code: 00 eb 44 66 90 31 d2 49 89 c0 48 63 ca 49 8b 84 c8 b8 07 00 00 48 85 c0 74 23 48 39 30 77 1e 48 3b 70 08 73 18 48 3b 78 40 74 1c <0f> 0b 0f 1f 84 00 00 00 00 00 eb fe 66 0f 1f 44 00 00 ff c2 83
[  243.582665] RIP  [<ffffffff81299396>] vmacache_find+0x86/0xb0
[  243.582665]  RSP <ffff8800b8695da8>


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
