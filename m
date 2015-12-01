Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id D5F3D6B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 08:34:36 -0500 (EST)
Received: by ioir85 with SMTP id r85so8968805ioi.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 05:34:36 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id c93si2565048ioj.151.2015.12.01.05.34.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 01 Dec 2015 05:34:36 -0800 (PST)
Date: Tue, 1 Dec 2015 22:34:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: memcg uncharge page counter mismatch
Message-ID: <20151201133455.GB27574@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

With new test on mmotm-2015-11-25-17-08, I saw below WARNING message
several times. I couldn't see it with reverting new THP refcount
redesign.

I will try to make reproducer when I have a time but not sure.
Before that, I hope someone catches it up.

------------[ cut here ]------------
WARNING: CPU: 0 PID: 1340 at mm/page_counter.c:26 page_counter_cancel+0x34/0x40()
Modules linked in:
CPU: 0 PID: 1340 Comm: madvise_test Not tainted 4.4.0-rc2-mm1-kirill+ #12
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffffffff81782eeb ffff880072b97be8 ffffffff8126f476 0000000000000000
 ffff880072b97c20 ffffffff8103e476 ffff88006b35d0b0 00000000000001fe
 0000000000000000 00000000000001fe ffff88006b35d000 ffff880072b97c30
Call Trace:
 [<ffffffff8126f476>] dump_stack+0x44/0x5e
 [<ffffffff8103e476>] warn_slowpath_common+0x86/0xc0
 [<ffffffff8103e56a>] warn_slowpath_null+0x1a/0x20
 [<ffffffff8114c754>] page_counter_cancel+0x34/0x40
 [<ffffffff8114c852>] page_counter_uncharge+0x22/0x30
 [<ffffffff8114fe17>] uncharge_batch+0x47/0x140
 [<ffffffff81150033>] uncharge_list+0x123/0x190
 [<ffffffff8115222b>] mem_cgroup_uncharge_list+0x1b/0x20
 [<ffffffff810fe9bb>] release_pages+0xdb/0x350
 [<ffffffff8113044d>] free_pages_and_swap_cache+0x9d/0x120
 [<ffffffff8111a546>] tlb_flush_mmu_free+0x36/0x60
 [<ffffffff8111b63c>] tlb_finish_mmu+0x1c/0x50
 [<ffffffff81125f38>] exit_mmap+0xd8/0x130
 [<ffffffff8103bd56>] mmput+0x56/0xe0
 [<ffffffff8103ff4d>] do_exit+0x1fd/0xaa0
 [<ffffffff8104086f>] do_group_exit+0x3f/0xb0
 [<ffffffff810408f4>] SyS_exit_group+0x14/0x20
 [<ffffffff8142b617>] entry_SYSCALL_64_fastpath+0x12/0x6a
---[ end trace 7864cf719fb83e12 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
