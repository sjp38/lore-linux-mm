Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 83FA36B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 03:41:33 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t5so213010505qkc.1
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 00:41:33 -0700 (PDT)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTPS id 18si1961930ybf.209.2016.04.22.00.41.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Apr 2016 00:41:32 -0700 (PDT)
From: Chen Feng <puck.chen@hisilicon.com>
Subject: Is the page always in swapcache?
Message-ID: <5719D549.6020400@hisilicon.com>
Date: Fri, 22 Apr 2016 15:39:53 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, hughd@google.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Zhuangluan Su <suzhuangluan@hisilicon.com>, Dan Zhao <dan.zhao@hisilicon.com>, l00215322 <albert.lubing@hisilicon.com>, Yiping Xu <xuyiping@hisilicon.com>, oliver.fu@hisilicon.com, qijiwen@hisilicon.com, "yudongbin@hisilicon.com" <yudongbin@hisilicon.com>, saberlily.xia@hisilicon.com

Hi Matainers,

In the file mm/migrate.c

 316 int migrate_page_move_mapping(struct address_space *mapping,
 317                 struct page *newpage, struct page *page,
 318                 struct buffer_head *head, enum migrate_mode mode,
 319                 int extra_count)
 320 {
 321         struct zone *oldzone, *newzone;
 322         int dirty;
 323         int expected_count = 1 + extra_count;
 324         void **pslot;
	     ....
 344
 345         pslot = radix_tree_lookup_slot(&mapping->page_tree,
 346                                         page_index(page));
 347
 348         expected_count += 1 + page_has_private(page);
 349         if (page_count(page) != expected_count ||
 350                 radix_tree_deref_slot_protected(pslot, &mapping->tree_lock) != page) {
    		     ...
 353         }

In the line 345, Is the page is always in the swap-cache?


I got the follow crash issue with compaction.


[ 4433.467956s][2016:04:13 11:06:41][pid:324,cpu2,lmkd]Unable to handle kernel NULL pointer dereference at virtual address 00000000
[ 4433.467987s][2016:04:13 11:06:41][pid:324,cpu2,lmkd]pgd = ffffffc0b46f9000
[ 4433.467987s][00000000] *pgd=0000000000000000
[ 4433.468017s][2016:04:13 11:06:41][pid:324,cpu2,lmkd]Internal error: Oops: 96000005 [#1] PREEMPT SMP
[ 4433.468048s]Modules linked in:
[ 4433.468078s][2016:04:13 11:06:41][pid:324,cpu2,lmkd]CPU: 2 PID: 324 Comm: lmkd Tainted: G        W    3.10.94-g0daa20e #1
[ 4433.468109s][2016:04:13 11:06:41][pid:324,cpu2,lmkd]task: ffffffc0b7783980 ti: ffffffc0b46c8000 task.ti: ffffffc0b46c8000
[ 4433.468139s][2016:04:13 11:06:41][pid:324,cpu2,lmkd]PC is at migrate_page_move_mapping.part.28+0x7c/0x21c
[ 4433.468170s][2016:04:13 11:06:41][pid:324,cpu2,lmkd]LR is at migrate_page_move_mapping.part.28+0x50/0x21c
[ 4433.468170s][2016:04:13 11:06:41][pid:324,cpu2,lmkd]pc : [<ffffffc0001928b8>] lr : [<ffffffc00019288c>] pstate: 60000185
[ 4433.468200s][2016:04:13 11:06:41][pid:324,cpu2,lmkd]sp : ffffffc0b46cbb20
[ 4433.468200s]x29: ffffffc0b46cbb20 x28: 00000000fffffff5
[ 4433.468231s]x27: ffffffc0bb20b000 x26: 0000000000000000
[ 4433.468261s]x25: 0000000000000000 x24: 0000000000000001
[ 4433.468292s]x23: ffffffc0013be1a8 x22: 0000000000000000
[ 4433.468322s]x21: 0000000000000002 x20: ffffffc0bdbfc900
[ 4433.468353s]x19: ffffffc0bb20b000 x18: 0000000000000000
[ 4433.468353s]x17: 0000000000000000 x16: 0000000000000000
[ 4433.468383s]x15: 0000000000000000 x14: fffffff8fffffff8
[ 4433.468414s]x13: fffffff8fffffff8 x12: fffffff8fffffff8
[ 4433.468444s]x11: fffffff8fffffff8 x10: 00000000ffffffff
[ 4433.468475s]x9 : d61f0220913be210 x8 : ffffffc0ba60ee80
[ 4433.468475s]x7 : 0000000000000006 x6 : 0000000000000001
[ 4433.468505s]x5 : 000001440006010b x4 : 0000000000000001
[ 4433.468536s]x3 : 0000000000000000 x2 : 000001440006010b
[ 4433.468566s]x1 : 000001440006010b x0 : 0000000000000002
[ 4433.468597s][2016:04:13 11:06:41][pid:324,cpu2,lmkd]
[ 4433.468597s]PC: 0xffffffc000192838:
[ 4433.468597s]2838  d65f03c0 a9bb7bfd 910003fd a90363f7 91006017 2a0403f8 a90153f3 a9025bf5
[ 4433.468658s]2858  aa0203f3 aa0003f5 aa1703e0 aa0103f4 a9046bf9 aa0303f9 942c336b f9400260
[ 4433.468719s]2878  910022b5 37880ba0 f9400a61 aa1503e0 9407a477 aa0003fa f9400262 aa1303e0
[ 4433.468780s]2898  f9400261 f274045f 1a9f07f6 11000ad5 37800a81 b9401c00 6b0002bf 540008a1
[ 4433.468811s]28b8  f9400340 eb00027f 54000841 d5033bbf 52800001 91007263 885f7c60 6b15001f
[ 4433.468872s]28d8  54000061 88027c61 35ffff82 d5033bbf 6b0002bf 540006e1 350000d8 b40000b9
[ 4433.468933s]28f8  aa1903e0 97ffff8f 53001c00 34000600 f9400280 378009c0 91007282 885f7c40
[ 4433.468994s]2918  11000400 88017c40 35ffffa1 f9400260 37880420 12000295 37000734 d5033abf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
