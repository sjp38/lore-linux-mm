Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E572B6B03AB
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 05:37:44 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s15so28078379pfi.1
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 02:37:44 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id s2si7907124plk.179.2017.04.10.02.37.42
        for <linux-mm@kvack.org>;
        Mon, 10 Apr 2017 02:37:43 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <58E8E81E.6090304@huawei.com> <0a1a01d2b1c5$9ce961e0$d6bc25a0$@alibaba-inc.com> <58EB48D6.1050308@huawei.com>
In-Reply-To: <58EB48D6.1050308@huawei.com>
Subject: Re: NULL pointer dereference in the kernel 3.10
Date: Mon, 10 Apr 2017 17:37:25 +0800
Message-ID: <0a3c01d2b1de$104c0800$30e41800$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Xishi Qiu' <qiuxishi@huawei.com>
Cc: 'zhong jiang' <zhongjiang@huawei.com>, 'Michal Hocko' <mhocko@suse.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, vdavydov.dev@gmail.com, mgorman@techsingularity.net, 'Vlastimil Babka' <vbabka@suse.cz>, 'Linux Memory Management List' <linux-mm@kvack.org>, 'LKML' <linux-kernel@vger.kernel.org>

On April 10, 2017 4:57 PM Xishi Qiu wrote: 
> On 2017/4/10 14:42, Hillf Danton wrote:
> 
> > On April 08, 2017 9:40 PM zhong Jiang wrote:
> >>
> >> when runing the stabile docker cases in the vm.   The following issue will come up.
> >>
> >> #40 [ffff8801b57ffb30] async_page_fault at ffffffff8165c9f8
> >>     [exception RIP: down_read_trylock+5]
> >>     RIP: ffffffff810aca65  RSP: ffff8801b57ffbe8  RFLAGS: 00010202
> >>     RAX: 0000000000000000  RBX: ffff88018ae858c1  RCX: 0000000000000000
> >>     RDX: 0000000000000000  RSI: 0000000000000000  RDI: 0000000000000008
> >>     RBP: ffff8801b57ffc10   R8: ffffea0006903de0   R9: ffff8800b3c61810
> >>     R10: 00000000000022cb  R11: 0000000000000000  R12: ffff88018ae858c0
> >>     R13: ffffea0006903dc0  R14: 0000000000000008  R15: ffffea0006903dc0
> >>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000
> >> #41 [ffff8801b57ffbe8] page_lock_anon_vma_read at ffffffff811b241c
> >> #42 [ffff8801b57ffc18] page_referenced at ffffffff811b26a7
> >> #43 [ffff8801b57ffc90] shrink_active_list at ffffffff8118d634
> >> #44 [ffff8801b57ffd48] balance_pgdat at ffffffff8118f088
> >> #45 [ffff8801b57ffe20] kswapd at ffffffff8118f633
> >> #46 [ffff8801b57ffec8] kthread at ffffffff810a795f
> >> #47 [ffff8801b57fff50] ret_from_fork at ffffffff81665398
> >> crash> struct page.mapping ffffea0006903dc0
> >>   mapping = 0xffff88018ae858c1
> >> crash> struct anon_vma 0xffff88018ae858c0
> >> struct anon_vma {
> >>   root = 0x0,
> >>   rwsem = {
> >>     count = 0,
> >>     wait_lock = {
> >>       raw_lock = {
> >>         {
> >>           head_tail = 1,
> >>           tickets = {
> >>             head = 1,
> >>             tail = 0
> >>           }
> >>         }
> >>       }
> >>     },
> >>     wait_list = {
> >>       next = 0x0,
> >>       prev = 0x0
> >>     }
> >>   },
> >>   refcount = {
> >>     counter = 0
> >>   },
> >>   rb_root = {
> >>     rb_node = 0x0
> >>   }
> >> }
> >>
> >> This maks me wonder,  the anon_vma do not come from slab structure.
> >> and the content is abnormal. IMO,  At least anon_vma->root will not NULL.
> >> The issue can be reproduced every other week.
> >>
> > Check please if commit
> > 624483f3ea8 ("mm: rmap: fix use-after-free in __put_anon_vma")
> > is included in the 3.10 you are running.
> >
> We missed this patch in RHEL 7.2
> Could you please give more details for how it triggered?

Sorry, I could not. 
I guess it is UAF as described in the log of that commit.
And if it works for you, we know how.

Hillf



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
