Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id B9C306B03AF
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 05:57:01 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id r16so30416690ioi.7
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 02:57:01 -0700 (PDT)
Received: from dggrg03-dlp.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id p130si7275958itd.44.2017.04.10.02.56.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 02:57:01 -0700 (PDT)
Message-ID: <58EB561F.6050805@huawei.com>
Date: Mon, 10 Apr 2017 17:53:35 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: NULL pointer dereference in the kernel 3.10
References: <58E8E81E.6090304@huawei.com> <0a1a01d2b1c5$9ce961e0$d6bc25a0$@alibaba-inc.com> <58EB48D6.1050308@huawei.com> <0a3c01d2b1de$104c0800$30e41800$@alibaba-inc.com>
In-Reply-To: <0a3c01d2b1de$104c0800$30e41800$@alibaba-inc.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'zhong jiang' <zhongjiang@huawei.com>, 'Michal Hocko' <mhocko@suse.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, vdavydov.dev@gmail.com, mgorman@techsingularity.net, 'Vlastimil Babka' <vbabka@suse.cz>, 'Linux
 Memory Management List' <linux-mm@kvack.org>, 'LKML' <linux-kernel@vger.kernel.org>

On 2017/4/10 17:37, Hillf Danton wrote:

> On April 10, 2017 4:57 PM Xishi Qiu wrote: 
>> On 2017/4/10 14:42, Hillf Danton wrote:
>>
>>> On April 08, 2017 9:40 PM zhong Jiang wrote:
>>>>
>>>> when runing the stabile docker cases in the vm.   The following issue will come up.
>>>>
>>>> #40 [ffff8801b57ffb30] async_page_fault at ffffffff8165c9f8
>>>>     [exception RIP: down_read_trylock+5]
>>>>     RIP: ffffffff810aca65  RSP: ffff8801b57ffbe8  RFLAGS: 00010202
>>>>     RAX: 0000000000000000  RBX: ffff88018ae858c1  RCX: 0000000000000000
>>>>     RDX: 0000000000000000  RSI: 0000000000000000  RDI: 0000000000000008
>>>>     RBP: ffff8801b57ffc10   R8: ffffea0006903de0   R9: ffff8800b3c61810
>>>>     R10: 00000000000022cb  R11: 0000000000000000  R12: ffff88018ae858c0
>>>>     R13: ffffea0006903dc0  R14: 0000000000000008  R15: ffffea0006903dc0
>>>>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000
>>>> #41 [ffff8801b57ffbe8] page_lock_anon_vma_read at ffffffff811b241c
>>>> #42 [ffff8801b57ffc18] page_referenced at ffffffff811b26a7
>>>> #43 [ffff8801b57ffc90] shrink_active_list at ffffffff8118d634
>>>> #44 [ffff8801b57ffd48] balance_pgdat at ffffffff8118f088
>>>> #45 [ffff8801b57ffe20] kswapd at ffffffff8118f633
>>>> #46 [ffff8801b57ffec8] kthread at ffffffff810a795f
>>>> #47 [ffff8801b57fff50] ret_from_fork at ffffffff81665398
>>>> crash> struct page.mapping ffffea0006903dc0
>>>>   mapping = 0xffff88018ae858c1
>>>> crash> struct anon_vma 0xffff88018ae858c0
>>>> struct anon_vma {
>>>>   root = 0x0,
>>>>   rwsem = {
>>>>     count = 0,
>>>>     wait_lock = {
>>>>       raw_lock = {
>>>>         {
>>>>           head_tail = 1,
>>>>           tickets = {
>>>>             head = 1,
>>>>             tail = 0
>>>>           }
>>>>         }
>>>>       }
>>>>     },
>>>>     wait_list = {
>>>>       next = 0x0,
>>>>       prev = 0x0
>>>>     }
>>>>   },
>>>>   refcount = {
>>>>     counter = 0
>>>>   },
>>>>   rb_root = {
>>>>     rb_node = 0x0
>>>>   }
>>>> }
>>>>
>>>> This maks me wonder,  the anon_vma do not come from slab structure.
>>>> and the content is abnormal. IMO,  At least anon_vma->root will not NULL.
>>>> The issue can be reproduced every other week.
>>>>
>>> Check please if commit
>>> 624483f3ea8 ("mm: rmap: fix use-after-free in __put_anon_vma")
>>> is included in the 3.10 you are running.
>>>
>> We missed this patch in RHEL 7.2
>> Could you please give more details for how it triggered?
> 
> Sorry, I could not. 
> I guess it is UAF as described in the log of that commit.
> And if it works for you, we know how.
> 
> Hillf
> 

__put_anon_vma            |   page_lock_anon_vma_read
  anon_vma_free(root)     |
                          |     root_anon_vma = ACCESS_ONCE(anon_vma->root)
                          |     down_read_trylock(&root_anon_vma->rwsem)
  anon_vma_free(anon_vma) |

I find anon_vma was created by SLAB_DESTROY_BY_RCU, so it will not merge
by other slabs, and free_slab() will not free it during page_lock_anon_vma_read(),
because it holds rcu_read_lock(), right?

If root_anon_vma was reuse by someone, why "crash> struct anon_vma"
shows almost zero?

Thanks,
Xishi Qiu

> 
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
