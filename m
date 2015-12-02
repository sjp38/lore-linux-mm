Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id AC1196B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 05:16:46 -0500 (EST)
Received: by wmuu63 with SMTP id u63so208105402wmu.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 02:16:46 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id bn7si3298746wjc.186.2015.12.02.02.16.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 02:16:45 -0800 (PST)
Received: by wmww144 with SMTP id w144so208137749wmw.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 02:16:45 -0800 (PST)
Date: Wed, 2 Dec 2015 11:16:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memcg uncharge page counter mismatch
Message-ID: <20151202101643.GC25284@dhcp22.suse.cz>
References: <20151201133455.GB27574@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151201133455.GB27574@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 01-12-15 22:34:55, Minchan Kim wrote:
> With new test on mmotm-2015-11-25-17-08, I saw below WARNING message
> several times. I couldn't see it with reverting new THP refcount
> redesign.

Just a wild guess. What prevents migration/compaction from calling
split_huge_page on thp zero page? There is VM_BUG_ON but it is not clear
whether you run with CONFIG_DEBUG_VM enabled.

Also, how big is the underflow?

> I will try to make reproducer when I have a time but not sure.
> Before that, I hope someone catches it up.
> 
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 1340 at mm/page_counter.c:26 page_counter_cancel+0x34/0x40()
> Modules linked in:
> CPU: 0 PID: 1340 Comm: madvise_test Not tainted 4.4.0-rc2-mm1-kirill+ #12
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffffffff81782eeb ffff880072b97be8 ffffffff8126f476 0000000000000000
>  ffff880072b97c20 ffffffff8103e476 ffff88006b35d0b0 00000000000001fe
>  0000000000000000 00000000000001fe ffff88006b35d000 ffff880072b97c30
> Call Trace:
>  [<ffffffff8126f476>] dump_stack+0x44/0x5e
>  [<ffffffff8103e476>] warn_slowpath_common+0x86/0xc0
>  [<ffffffff8103e56a>] warn_slowpath_null+0x1a/0x20
>  [<ffffffff8114c754>] page_counter_cancel+0x34/0x40
>  [<ffffffff8114c852>] page_counter_uncharge+0x22/0x30
>  [<ffffffff8114fe17>] uncharge_batch+0x47/0x140
>  [<ffffffff81150033>] uncharge_list+0x123/0x190
>  [<ffffffff8115222b>] mem_cgroup_uncharge_list+0x1b/0x20
>  [<ffffffff810fe9bb>] release_pages+0xdb/0x350
>  [<ffffffff8113044d>] free_pages_and_swap_cache+0x9d/0x120
>  [<ffffffff8111a546>] tlb_flush_mmu_free+0x36/0x60
>  [<ffffffff8111b63c>] tlb_finish_mmu+0x1c/0x50
>  [<ffffffff81125f38>] exit_mmap+0xd8/0x130
>  [<ffffffff8103bd56>] mmput+0x56/0xe0
>  [<ffffffff8103ff4d>] do_exit+0x1fd/0xaa0
>  [<ffffffff8104086f>] do_group_exit+0x3f/0xb0
>  [<ffffffff810408f4>] SyS_exit_group+0x14/0x20
>  [<ffffffff8142b617>] entry_SYSCALL_64_fastpath+0x12/0x6a
> ---[ end trace 7864cf719fb83e12 ]---

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
