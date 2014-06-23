Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 685E56B0035
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 00:16:35 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id hi2so3380268wib.7
        for <linux-mm@kvack.org>; Sun, 22 Jun 2014 21:16:34 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id fx16si3066883wjc.31.2014.06.22.21.16.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 22 Jun 2014 21:16:34 -0700 (PDT)
Date: Mon, 23 Jun 2014 00:16:21 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm] memcg: mem_cgroup_charge_statistics needs
 preempt_disable
Message-ID: <20140623041621.GM7331@cmpxchg.org>
References: <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <1403282171-25502-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403282171-25502-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 20, 2014 at 06:36:11PM +0200, Michal Hocko wrote:
> preempt_disable was previously disabled by lock_page_cgroup which has
> been removed by "mm: memcontrol: rewrite uncharge API".
> 
> This fixes the a flood of splats like this:
> [    3.149371] BUG: using __this_cpu_add() in preemptible [00000000] code: udevd/1271
> [    3.151458] caller is __this_cpu_preempt_check+0x13/0x15
> [    3.152927] CPU: 0 PID: 1271 Comm: udevd Not tainted 3.15.0-test1 #366
> [    3.154637] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> [    3.156788]  0000000000000000 ffff88000005fba8 ffffffff814efe3f 0000000000000000
> [    3.158810]  ffff88000005fbd8 ffffffff8125b969 ffff880007413448 0000000000000001
> [    3.160836]  ffffea00001e8c00 0000000000000001 ffff88000005fbe8 ffffffff8125b9a8
> [    3.162950] Call Trace:
> [    3.163598]  [<ffffffff814efe3f>] dump_stack+0x4e/0x7a
> [    3.164942]  [<ffffffff8125b969>] check_preemption_disabled+0xd2/0xe5
> [    3.166618]  [<ffffffff8125b9a8>] __this_cpu_preempt_check+0x13/0x15
> [    3.168267]  [<ffffffff8112b630>] mem_cgroup_charge_statistics.isra.36+0xb5/0xc6
> [    3.170169]  [<ffffffff8112d2c5>] commit_charge+0x23c/0x256
> [    3.171823]  [<ffffffff8113101b>] mem_cgroup_commit_charge+0xb8/0xd7
> [    3.173838]  [<ffffffff810f5dab>] shmem_getpage_gfp+0x399/0x605
> [    3.175363]  [<ffffffff810f7456>] shmem_write_begin+0x3d/0x58
> [    3.176854]  [<ffffffff810e1361>] generic_perform_write+0xbc/0x192
> [    3.178445]  [<ffffffff8114a086>] ? file_update_time+0x34/0xac
> [    3.179952]  [<ffffffff810e2ae4>] __generic_file_aio_write+0x2c0/0x300
> [    3.181655]  [<ffffffff810e2b76>] generic_file_aio_write+0x52/0xbd
> [    3.183234]  [<ffffffff81133944>] do_sync_write+0x59/0x78
> [    3.184630]  [<ffffffff81133ea8>] vfs_write+0xc4/0x181
> [    3.185957]  [<ffffffff81134801>] SyS_write+0x4a/0x91
> [    3.187258]  [<ffffffff814fd30e>] tracesys+0xd0/0xd5
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Thanks, Michal.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
