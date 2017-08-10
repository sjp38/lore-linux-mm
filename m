Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0A66B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 07:56:08 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x43so719642wrb.9
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:56:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o189si3850765wme.197.2017.08.10.04.56.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 04:56:07 -0700 (PDT)
Date: Thu, 10 Aug 2017 13:56:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: kernel panic on null pointer on page->mem_cgroup
Message-ID: <20170810115605.GQ23863@dhcp22.suse.cz>
References: <20170805155241.GA94821@jaegeuk-macbookpro.roam.corp.google.com>
 <20170808010150.4155-1-bradleybolen@gmail.com>
 <20170808162122.GA14689@cmpxchg.org>
 <20170808165601.GA7693@jaegeuk-macbookpro.roam.corp.google.com>
 <20170808173704.GA22887@cmpxchg.org>
 <CADvgSZSn1v-tTpa07ebqr19heQbkzbavdPM_nbRNR1WF-EBnFw@mail.gmail.com>
 <20170808200849.GA1104@cmpxchg.org>
 <20170809014459.GB7693@jaegeuk-macbookpro.roam.corp.google.com>
 <CADvgSZSNn7N3R7+jjeCgns2ZEPtYc6c3MWmkkQ3PA+0LHO_MfA@mail.gmail.com>
 <20170809183825.GA26387@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170809183825.GA26387@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Brad Bolen <bradleybolen@gmail.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 09-08-17 14:38:25, Johannes Weiner wrote:
> On Tue, Aug 08, 2017 at 10:39:27PM -0400, Brad Bolen wrote:
> > Yes, the BUG_ON(!page_count(page)) fired for me as well.
> 
> Brad, Jaegeuk, does the following patch address this problem?
> 
> ---
> 
> >From cf0060892eb70bccbc8cedeac0a5756c8f7b975e Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Wed, 9 Aug 2017 12:06:03 -0400
> Subject: [PATCH] mm: memcontrol: fix NULL pointer crash in
>  test_clear_page_writeback()
> 
> Jaegeuk and Brad report a NULL pointer crash when writeback ending
> tries to update the memcg stats:
> 
> [] BUG: unable to handle kernel NULL pointer dereference at 00000000000003b0
> [] IP: test_clear_page_writeback+0x12e/0x2c0
> [...]
> [] RIP: 0010:test_clear_page_writeback+0x12e/0x2c0
> [] RSP: 0018:ffff8e3abfd03d78 EFLAGS: 00010046
> [] RAX: 0000000000000000 RBX: ffffdb59c03f8900 RCX: ffffffffffffffe8
> [] RDX: 0000000000000000 RSI: 0000000000000010 RDI: ffff8e3abffeb000
> [] RBP: ffff8e3abfd03da8 R08: 0000000000020059 R09: 00000000fffffffc
> [] R10: 0000000000000000 R11: 0000000000020048 R12: ffff8e3a8c39f668
> [] R13: 0000000000000001 R14: ffff8e3a8c39f680 R15: 0000000000000000
> [] FS:  0000000000000000(0000) GS:ffff8e3abfd00000(0000) knlGS:0000000000000000
> [] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [] CR2: 00000000000003b0 CR3: 000000002c5e1000 CR4: 00000000000406e0
> [] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [] Call Trace:
> []  <IRQ>
> []  end_page_writeback+0x47/0x70
> []  f2fs_write_end_io+0x76/0x180 [f2fs]
> []  bio_endio+0x9f/0x120
> []  blk_update_request+0xa8/0x2f0
> []  scsi_end_request+0x39/0x1d0
> []  scsi_io_completion+0x211/0x690
> []  scsi_finish_command+0xd9/0x120
> []  scsi_softirq_done+0x127/0x150
> []  __blk_mq_complete_request_remote+0x13/0x20
> []  flush_smp_call_function_queue+0x56/0x110
> []  generic_smp_call_function_single_interrupt+0x13/0x30
> []  smp_call_function_single_interrupt+0x27/0x40
> []  call_function_single_interrupt+0x89/0x90
> [] RIP: 0010:native_safe_halt+0x6/0x10
> 
> (gdb) l *(test_clear_page_writeback+0x12e)
> 0xffffffff811bae3e is in test_clear_page_writeback (./include/linux/memcontrol.h:619).
> 614		mod_node_page_state(page_pgdat(page), idx, val);
> 615		if (mem_cgroup_disabled() || !page->mem_cgroup)
> 616			return;
> 617		mod_memcg_state(page->mem_cgroup, idx, val);
> 618		pn = page->mem_cgroup->nodeinfo[page_to_nid(page)];
> 619		this_cpu_add(pn->lruvec_stat->count[idx], val);
> 620	}
> 621
> 622	unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
> 623							gfp_t gfp_mask,
> 
> The issue is that writeback doesn't hold a page reference and the page
> might get freed after PG_writeback is cleared (and the mapping is
> unlocked) in test_clear_page_writeback(). The stat functions looking
> up the page's node or zone are safe, as those attributes are static
> across allocation and free cycles. But page->mem_cgroup is not, and it
> will get cleared if we race with truncation or migration.

Is there anything that prevents us from holding a reference on a page
under writeback?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
