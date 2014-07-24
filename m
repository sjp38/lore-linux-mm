Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA8F6B0035
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 04:46:50 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u56so2362224wes.14
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 01:46:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dd4si10393870wjb.26.2014.07.24.01.46.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 01:46:48 -0700 (PDT)
Date: Thu, 24 Jul 2014 10:46:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140724084644.GA14578@dhcp22.suse.cz>
References: <20140718071246.GA21565@dhcp22.suse.cz>
 <20140718144554.GG29639@cmpxchg.org>
 <CAJfpegt9k+YULet3vhmG3br7zSiHy-DRL+MiEE=HRzcs+mLzbw@mail.gmail.com>
 <20140719173911.GA1725@cmpxchg.org>
 <20140722150825.GA4517@dhcp22.suse.cz>
 <CAJfpegscT-ptQzq__uUV2TOn7Uvs6x4FdWGTQb9Fe9MEJr2KjA@mail.gmail.com>
 <20140723143847.GB16721@dhcp22.suse.cz>
 <20140723150608.GF1725@cmpxchg.org>
 <CAJfpegs-k5QC+42SzLKUSaHrdPxWBaT_dF+SOPqoDvg8h5p_Tw@mail.gmail.com>
 <20140723210241.GH1725@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140723210241.GH1725@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed 23-07-14 17:02:41, Johannes Weiner wrote:
[...]
> From 2c3525cb556313936845a7c57f4c4adc655b6680 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Wed, 23 Jul 2014 15:00:15 -0400
> Subject: [patch] mm: memcontrol: rewrite uncharge API fix - page cache
>  migration 2
> 
> In case of fuse page cache replacement the target page in migration
> can already be charged when splice steals it from page cache.  That
> triggers the !PageCgrouUsed() assertion during commit:
> 
> [  755.141095] page:ffffea00031f9b00 count:2 mapcount:0 mapping:ffff8800c84d1858 index:0x0
> [  755.141097] page flags: 0x3fffc000000029(locked|uptodate|lru)
> [  755.141098] page dumped because: VM_BUG_ON_PAGE(PageCgroupUsed(pc))
> [  755.141098] pc:ffff880215cfe6c0 pc->flags:7 pc->mem_cgroup:ffff880216c23000
> [  755.141113] ------------[ cut here ]------------
> [  755.141113] kernel BUG at /home/hannes/src/linux/linux/mm/memcontrol.c:2736!
> [  755.141115] invalid opcode: 0000 [#1] SMP
> [  755.141117] CPU: 0 PID: 342 Comm: lt-fusexmp_fh Not tainted 3.16.0-rc5-mm1-00502-g5e5b90c20054 #367
> [  755.141117] Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./H61M-DGS, BIOS P1.30 05/10/2012
> [  755.141118] task: ffff880213104580 ti: ffff8800c9204000 task.ti: ffff8800c9204000
> [  755.141121] RIP: 0010:[<ffffffff81188497>]  [<ffffffff81188497>] commit_charge+0xa7/0xb0
> [  755.141122] RSP: 0018:ffff8800c9207c18  EFLAGS: 00010286
> [  755.141123] RAX: 000000000000003f RBX: ffffea00031f9b00 RCX: 0000000000004c4b
> [  755.141123] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff880213104580
> [  755.141124] RBP: ffff8800c9207c40 R08: 0000000000000001 R09: 0000000000000000
> [  755.141124] R10: 0000000000000000 R11: 0000000000000000 R12: ffff880216c23000
> [  755.141125] R13: 0000000000000001 R14: ffff8800c84d1858 R15: 0000000000000000
> [  755.141125] FS:  00007fc15f7fe700(0000) GS:ffff88021f200000(0000) knlGS:0000000000000000
> [  755.141126] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  755.141127] CR2: 00007f693db3b6b0 CR3: 0000000211d54000 CR4: 00000000000407f0
> [  755.141127] Stack:
> [  755.141128]  ffffea00031f8480 ffffea00031f9b00 ffffea00031f8480 ffffea00031f9b00
> [  755.141129]  0000000000000000 ffff8800c9207c78 ffffffff8118e283 00000001c9207c60
> [  755.141130]  ffff880215cfe120 00000001c9207c78 ffffea00031f9b00 ffffea00031f8480
> [  755.141131] Call Trace:
> [  755.141133]  [<ffffffff8118e283>] mem_cgroup_migrate+0xe3/0x210
> [  755.141135]  [<ffffffff8111a086>] replace_page_cache_page+0xf6/0x1c0
> [  755.141137]  [<ffffffff8127aceb>] fuse_copy_page+0x1bb/0x5f0
> [  755.141138]  [<ffffffff8127b20f>] fuse_copy_args+0xef/0x140
> [  755.141140]  [<ffffffff8127caba>] fuse_dev_do_write+0x7ba/0xd30
> [  755.141143]  [<ffffffff8109518d>] ? trace_hardirqs_on_caller+0x15d/0x200
> [  755.141146]  [<ffffffff816a83ea>] ? __mutex_unlock_slowpath+0xaa/0x180
> [  755.141147]  [<ffffffff8109518d>] ? trace_hardirqs_on_caller+0x15d/0x200
> [  755.141148]  [<ffffffff8109523d>] ? trace_hardirqs_on+0xd/0x10
> [  755.141150]  [<ffffffff8127d2b2>] fuse_dev_splice_write+0x282/0x360
> [  755.141152]  [<ffffffff811c4ce1>] SyS_splice+0x351/0x800
> [  755.141153]  [<ffffffff8109518d>] ? trace_hardirqs_on_caller+0x15d/0x200
> [  755.141155]  [<ffffffff816ab192>] system_call_fastpath+0x16/0x1b
> [  755.141166] Code: 07 48 89 10 8b 75 e4 e8 f8 fd ff ff 48 83 c4 10 5b 41 5c 41 5d 5d c3 0f 1f 44 00 00 48 c7 c6 68 0b 9c 81 48 89 df e8 e9 a2 f9 ff <0f> 0b 0f 1f 80 00 00 00 00 66 66 66 66 90 48 39 f7 74 26 48 85
> [  755.141167] RIP  [<ffffffff81188497>] commit_charge+0xa7/0xb0
> [  755.141167]  RSP <ffff8800c9207c18>
> [  755.141665] ---[ end trace 2d0ea36c8e3ded5b ]---
> 
> If the target page is already charged, just leave it as is and abort
> the charge migration attempt.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

We can reduce the lookup only to lruvec==true case, no?

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b7c9a202dee9..3eaa6e83c168 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6660,6 +6660,12 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>  	if (mem_cgroup_disabled())
>  		return;
>  
> +	/* Page cache replacement: new page already charged? */
> +	pc = lookup_page_cgroup(newpage);
> +	if (PageCgroupUsed(pc))
> +		return;
> +
> +	/* Re-entrant migration: old page already uncharged? */
>  	pc = lookup_page_cgroup(oldpage);
>  	if (!PageCgroupUsed(pc))
>  		return;
> -- 
> 2.0.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
