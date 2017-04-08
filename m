Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB4C6B0038
	for <linux-mm@kvack.org>; Sat,  8 Apr 2017 09:40:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k3so5788848pfg.19
        for <linux-mm@kvack.org>; Sat, 08 Apr 2017 06:40:04 -0700 (PDT)
Received: from dggrg03-dlp.huawei.com ([45.249.212.189])
        by mx.google.com with ESMTPS id j16si8203418pli.140.2017.04.08.06.40.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 08 Apr 2017 06:40:03 -0700 (PDT)
Message-ID: <58E8E81E.6090304@huawei.com>
Date: Sat, 8 Apr 2017 21:39:42 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: NULL pointer dereference in the kernel 3.10
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov.dev@gmail.com, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

when runing the stabile docker cases in the vm.   The following issue will come up.

#40 [ffff8801b57ffb30] async_page_fault at ffffffff8165c9f8
    [exception RIP: down_read_trylock+5]
    RIP: ffffffff810aca65  RSP: ffff8801b57ffbe8  RFLAGS: 00010202
    RAX: 0000000000000000  RBX: ffff88018ae858c1  RCX: 0000000000000000
    RDX: 0000000000000000  RSI: 0000000000000000  RDI: 0000000000000008
    RBP: ffff8801b57ffc10   R8: ffffea0006903de0   R9: ffff8800b3c61810
    R10: 00000000000022cb  R11: 0000000000000000  R12: ffff88018ae858c0
    R13: ffffea0006903dc0  R14: 0000000000000008  R15: ffffea0006903dc0
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000
#41 [ffff8801b57ffbe8] page_lock_anon_vma_read at ffffffff811b241c
#42 [ffff8801b57ffc18] page_referenced at ffffffff811b26a7
#43 [ffff8801b57ffc90] shrink_active_list at ffffffff8118d634
#44 [ffff8801b57ffd48] balance_pgdat at ffffffff8118f088
#45 [ffff8801b57ffe20] kswapd at ffffffff8118f633
#46 [ffff8801b57ffec8] kthread at ffffffff810a795f
#47 [ffff8801b57fff50] ret_from_fork at ffffffff81665398
crash> struct page.mapping ffffea0006903dc0
  mapping = 0xffff88018ae858c1
crash> struct anon_vma 0xffff88018ae858c0
struct anon_vma {
  root = 0x0,
  rwsem = {
    count = 0,
    wait_lock = {
      raw_lock = {
        {
          head_tail = 1,
          tickets = {
            head = 1,
            tail = 0
          }
        }
      }
    },
    wait_list = {
      next = 0x0,
      prev = 0x0
    }
  },
  refcount = {
    counter = 0
  },
  rb_root = {
    rb_node = 0x0
  }
}

This maks me wonder,  the anon_vma do not come from slab structure.
and the content is abnormal. IMO,  At least anon_vma->root will not NULL.
The issue can be reproduced every other week.

Any comments will be appreciated.

Thanks
zhongjiang



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
