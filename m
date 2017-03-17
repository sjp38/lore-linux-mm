Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C86F46B0038
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 22:42:05 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y193so34306818lfd.3
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 19:42:05 -0700 (PDT)
Received: from dggrg02-dlp.huawei.com ([45.249.212.188])
        by mx.google.com with ESMTPS id u27si3445693lfg.201.2017.03.16.19.42.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 19:42:04 -0700 (PDT)
Message-ID: <58CB4C1B.9060703@huawei.com>
Date: Fri, 17 Mar 2017 10:38:19 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: Is it fixed by following patch
References: <58CA429E.6000109@huawei.com> <20170316084226.GA2025@esperanza> <58CA565C.20803@huawei.com> <20170316153225.GB2025@esperanza>
In-Reply-To: <20170316153225.GB2025@esperanza>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@tarantool.org>
Cc: Rik van Riel <riel@redhat.com>, Xishi Qiu <qiuxishi@huawei.com>, Linux
 Memory Management List <linux-mm@kvack.org>

On 2017/3/16 23:32, Vladimir Davydov wrote:
> On Thu, Mar 16, 2017 at 05:09:48PM +0800, zhong jiang wrote:
>> On 2017/3/16 16:42, Vladimir Davydov wrote:
>>> On Thu, Mar 16, 2017 at 03:45:34PM +0800, zhong jiang wrote:
>>>> Hi,  Vladimir
>>>>
>>>> I find upstream 414e2fb8ce5a ("rmap: fix theoretical race between do_wp_page and shrink_active_list ")
>>>> fix the bug maybe is  the same as the following issue, but I'm not sure. 
>>> It looks like in your case shrink_active_list() ran into a page with
>>> page->mapping set to PAGE_MAPPING_ANON, which made page_referenced()
>>> call page_referenced_anon(), which in turn called
>>> page_lock_anon_vma_read(), which hit the bug trying to dereference
>>> (page->mapping - PAGE_MAPPING_ANON) = NULL.
>>   Yes,  That is what we think.
>>> Theoretically, this could happen if page->mapping was updated
>>> non-atomically by page_move_anon_rmap(), which is the case the commit
>>> you mentioned fixes. However, I find it unlikely to happen on x86 with
>>> any sane compiler: on x86 it should be cheaper to first load the result
>>> (PAGE_MAPPING_ANON + addr in this case) to a register and only then
>>> store it in memory as a whole (page->mapping). To be sure, you should
>>> check assembly of page_move_anon_rmap() if it updates page->mapping
>>> non-atomically.
>>   The following is the assembly code.
>>  
>> (gdb) disassemble page_move_anon_rmap
>>  Dump of assembler code for function page_move_anon_rmap:
>>    0xffffffff811a4e10 <+0>:     callq  0xffffffff8164d9c0 <__fentry__>
>>    0xffffffff811a4e15 <+5>:     mov    0x88(%rsi),%rax
> Load vma->anon_vma address to RAX.
>
>>    0xffffffff811a4e1c <+12>:    push   %rbp
>>    0xffffffff811a4e1d <+13>:    mov    %rsp,%rbp
>>    0xffffffff811a4e20 <+16>:    add    $0x1,%rax
> Add PAGE_MAPPING_ANON to RAX.
>
>>    0xffffffff811a4e24 <+20>:    mov    %rax,0x8(%rdi)
> Move the result to page->mapping.
>
> This is atomic, so the commit you mentioned won't help, unfortunately.
  Yes,  The issue had reoccur after adding the patch.
  anyway,  thanks you for reply.

  Thanks
  zhongjiang
>>    0xffffffff811a4e28 <+24>:    pop    %rbp
>>    0xffffffff811a4e29 <+25>:    retq
>>  End of assembler dump.
>>  (gdb)
>>>> 9381.005212] CPU: 3 PID: 12737 Comm: docker-runc Tainted: G           OE  ---- -------   3.10.0-327.36.58.4.x86_64 #1
>>>> [19381.005212] Hardware name: OpenStack Foundation OpenStack Nova, BIOS rel-1.8.1-0-g4adadbd-20160826_044443-hghoulaslx112 04/01/2014
>>>> [19381.005212] task: ffff880002938000 ti: ffff880232254000 task.ti: ffff880232254000
>>>> [19381.005212] RIP: 0010:[<ffffffff810aca65>]  [<ffffffff810aca65>] down_read_trylock+0x5/0x50
>>>> [19381.005212] RSP: 0018:ffff8802322576c0  EFLAGS: 00010202
>>>> [19381.005212] RAX: 0000000000000000 RBX: ffff880230cabbc0 RCX: 0000000000000000
>>>> [19381.005212] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000008
>>>> [19381.005212] RBP: ffff8802322576e8 R08: ffffea00083725a0 R09: ffff8800b185b408
>>>> [19381.005212] R10: 0000000000000000 R11: fff00000fe000000 R12: ffff880230cabbc1
>>>> [19381.005212] R13: ffffea0008372580 R14: 0000000000000008 R15: ffffea0008372580
>>>> [19381.005212] FS:  00007f66aea00700(0000) GS:ffff88023ed80000(0000) knlGS:0000000000000000
>>>> [19381.005212] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>>> [19381.005212] CR2: 0000000000000008 CR3: 0000000231be8000 CR4: 00000000001407e0
>>>> [19381.005212] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>>>> [19381.005212] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>>>> [19381.018017] Stack:
>>>> [19381.018017]  ffffffff811b22b5 ffffea0008372580 0000000000000000 0000000000000004
>>>> [19381.018017]  0000000000000001 ffff880232257760 ffffffff811b2537 ffff8800b18ab1c0
>>>> [19381.018017]  00000007fcd103e2 ffff8802322577b0 0000000100000000 00000007fcd0fbe6
>>>> [19381.018017] Call Trace:
>>>> [19381.018017]  [<ffffffff811b22b5>] ? page_lock_anon_vma_read+0x55/0x110
>>>> [19381.018017]  [<ffffffff811b2537>] page_referenced+0x1c7/0x350
>>>> [19381.018017]  [<ffffffff8118d634>] shrink_active_list+0x1e4/0x400
>>>> [19381.018017]  [<ffffffff8118dd0d>] shrink_lruvec+0x4bd/0x770
>>>> [19381.018017]  [<ffffffff8118e036>] shrink_zone+0x76/0x1a0
>>>> [19381.018017]  [<ffffffff8118e530>] do_try_to_free_pages+0xe0/0x3f0
>>>> [19381.018017]  [<ffffffff8118e93c>] try_to_free_pages+0xfc/0x180
>>>> [19381.018017]  [<ffffffff81182218>] __alloc_pages_nodemask+0x818/0xcc0
>>>> [19381.018017]  [<ffffffff811cabfa>] alloc_pages_vma+0x9a/0x150
>>>> [19381.018017]  [<ffffffff811e0346>] do_huge_pmd_wp_page+0x106/0xb60
>>>> [19381.018017]  [<ffffffffa01c27d0>] ? dm_get_queue_limits+0x30/0x30 [dm_mod]
>>>> [19381.018017]  [<ffffffff811a6518>] handle_mm_fault+0x638/0xfa0
>>>> [19381.018017]  [<ffffffff81313cf2>] ? radix_tree_lookup_slot+0x22/0x50
>>>> [19381.018017]  [<ffffffff8117771e>] ? __find_get_page+0x1e/0xa0
>>>> [19381.018017]  [<ffffffff81160097>] ? rtos_hungtask_acquired+0x57/0x140
>>>> [19381.018017]  [<ffffffff81660435>] __do_page_fault+0x145/0x490
>>>> [19381.018017]  [<ffffffff81660843>] trace_do_page_fault+0x43/0x110
>>>> [19381.018017]  [<ffffffff8165fef9>] do_async_page_fault+0x29/0xe0
>>>> [19381.018017]  [<ffffffff8165c538>] async_page_fault+0x28/0x30
>>>> [19381.018017]  [<ffffffff8131af79>] ? copy_user_enhanced_fast_string+0x9/0x20
>>>> [19381.018017]  [<ffffffff81207c9c>] ? poll_select_copy_remaining+0xfc/0x150
>>>> [19381.018017]  [<ffffffff81208c2c>] SyS_select+0xcc/0x110
>>>> [19381.018017]  [<ffffffff81664ff3>] system_call_fastpath+0x16/0x1b
>>> .
>>>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
