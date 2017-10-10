Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0516C6B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:05:16 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d28so18328446pfe.2
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 05:05:15 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id z5si8223770pgr.165.2017.10.10.05.05.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Oct 2017 05:05:13 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
In-Reply-To: <20170918070834.13083-2-mhocko@kernel.org>
References: <20170918070834.13083-1-mhocko@kernel.org> <20170918070834.13083-2-mhocko@kernel.org>
Date: Tue, 10 Oct 2017 23:05:08 +1100
Message-ID: <87bmlfw6mj.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

Michal Hocko <mhocko@kernel.org> writes:

> From: Michal Hocko <mhocko@suse.com>
>
> Memory offlining can fail just too eagerly under a heavy memory pressure.
>
> [ 5410.336792] page:ffffea22a646bd00 count:255 mapcount:252 mapping:ffff88ff926c9f38 index:0x3
> [ 5410.336809] flags: 0x9855fe40010048(uptodate|active|mappedtodisk)
> [ 5410.336811] page dumped because: isolation failed
> [ 5410.336813] page->mem_cgroup:ffff8801cd662000
> [ 5420.655030] memory offlining [mem 0x18b580000000-0x18b5ffffffff] failed
>
> Isolation has failed here because the page is not on LRU. Most probably
> because it was on the pcp LRU cache or it has been removed from the LRU
> already but it hasn't been freed yet. In both cases the page doesn't look
> non-migrable so retrying more makes sense.

This breaks offline for me.

Prior to this commit:
  /sys/devices/system/memory/memory0# time echo 0 > online
  -bash: echo: write error: Device or resource busy
  
  real	0m0.001s
  user	0m0.000s
  sys	0m0.001s

After:
  /sys/devices/system/memory/memory0# time echo 0 > online
  -bash: echo: write error: Device or resource busy
  
  real	2m0.009s
  user	0m0.000s
  sys	1m25.035s


There's no way that block can be removed, it contains the kernel text,
so it should instantly fail - which it used to.


With commit 3aa2823fdf66 ("mm, memory_hotplug: remove timeout from
__offline_memory") also applied, it appears to just get stuck forever,
and I get lots of:

  [ 1232.112953] INFO: task kworker/3:0:4609 blocked for more than 120 seconds.
  [ 1232.113067]       Not tainted 4.14.0-rc4-gcc6-next-20171009-g49827b9 #1
  [ 1232.113183] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
  [ 1232.113319] kworker/3:0     D11984  4609      2 0x00000800
  [ 1232.113416] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
  [ 1232.113531] Call Trace:
  [ 1232.113579] [c0000000fb2db7a0] [c0000000fb2db900] 0xc0000000fb2db900 (unreliable)
  [ 1232.113717] [c0000000fb2db970] [c00000000001c964] __switch_to+0x304/0x6e0
  [ 1232.113840] [c0000000fb2dba10] [c000000000a408c0] __schedule+0x2e0/0xa80
  [ 1232.113978] [c0000000fb2dbae0] [c000000000a410a8] schedule+0x48/0xc0
  [ 1232.114113] [c0000000fb2dbb10] [c000000000a44d88] rwsem_down_read_failed+0x128/0x1b0
  [ 1232.114269] [c0000000fb2dbb70] [c0000000001696a8] __percpu_down_read+0x108/0x110
  [ 1232.114426] [c0000000fb2dbba0] [c00000000032e498] get_online_mems+0x68/0x80
  [ 1232.115487] [c0000000fb2dbbc0] [c0000000002c82ec] memcg_create_kmem_cache+0x4c/0x190
  [ 1232.115651] [c0000000fb2dbc60] [c0000000003483b8] memcg_kmem_cache_create_func+0x38/0xf0
  [ 1232.115809] [c0000000fb2dbc90] [c000000000121594] process_one_work+0x2b4/0x590
  [ 1232.115964] [c0000000fb2dbd20] [c000000000121908] worker_thread+0x98/0x5d0
  [ 1232.116095] [c0000000fb2dbdc0] [c00000000012a134] kthread+0x164/0x1b0
  [ 1232.116229] [c0000000fb2dbe30] [c00000000000bae0] ret_from_kernel_thread+0x5c/0x7c


cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
