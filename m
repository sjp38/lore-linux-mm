Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3AF6B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 13:32:33 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so2876631pdi.19
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 10:32:33 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id wh4si5707359pbc.297.2014.03.06.10.32.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Mar 2014 10:32:32 -0800 (PST)
Date: Thu, 6 Mar 2014 12:29:41 -0600
From: Josh Cartwright <joshc@codeaurora.org>
Subject: [PATCH -next] slub: Replace __this_cpu_inc usage w/ SLUB_STATS
Message-ID: <20140306182941.GH18529@joshc.qualcomm.com>
References: <20140306194821.3715d0b6212cc10415374a68@canb.auug.org.au>
 <20140306155316.GG18529@joshc.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140306155316.GG18529@joshc.qualcomm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Thu, Mar 06, 2014 at 09:53:16AM -0600, Josh Cartwright wrote:
> Booting on my Samsung Series 9 laptop gives me loads and loads of BUGs
> triggered by __this_cpu_add(), making making the system completely
> unusable:
> 
> [    5.808326] BUG: using __this_cpu_add() in preemptible [00000000] code: swapper/0/1
> [    5.812331] caller is __this_cpu_preempt_check+0x2b/0x30
> [    5.815654] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.14.0-rc5-next-20140306-joshc-08290-g0ffb2fe #1
> [    5.819553] Hardware name: SAMSUNG ELECTRONICS CO., LTD. 900X3C/900X3D/900X3E/900X4C/900X4D/NP900X3E-A02US, BIOS P07ABK 04/09/2013
> [    5.823558]  ffff8801182157c0 ffff880118215790 ffffffff81a64cec 0000000000000000
> [    5.827177]  ffff8801182157b0 ffffffff81462360 ffff8800c3d553e0 ffffea00030f5500
> [    5.830744]  ffff8801182157e8 ffffffff814623bb 635f736968745f5f 29286464615f7570
> [    5.834134] Call Trace:
> [    5.836848]  [<ffffffff81a64cec>] dump_stack+0x4e/0x7a
> [    5.839943]  [<ffffffff81462360>] check_preemption_disabled+0xd0/0xe0
> [    5.842997]  [<ffffffff814623bb>] __this_cpu_preempt_check+0x2b/0x30
> [    5.846022]  [<ffffffff81a6331d>] __slab_free+0x38/0x590
> [    5.848863]  [<ffffffff811759dd>] ? get_parent_ip+0xd/0x50
> [    5.850467] BUG: using __this_cpu_add() in preemptible [00000000] code: khubd/36
> [    5.850472] caller is __this_cpu_preempt_check+0x2b/0x30
> [    5.859125]  [<ffffffff81175b3b>] ? preempt_count_sub+0x6b/0xf0
> [    5.862521]  [<ffffffff81a7175a>] ? _raw_spin_unlock_irqrestore+0x4a/0x80
> [    5.865599]  [<ffffffff81462e5e>] ? __debug_check_no_obj_freed+0x13e/0x240
> [    5.868738]  [<ffffffff814623bb>] ? __this_cpu_preempt_check+0x2b/0x30
> [    5.871799]  [<ffffffff81287327>] kfree+0x2f7/0x300

FWIW, it looks like the magic combination of options are:
	- CONFIG_DEBUG_PREEMPT=y
	- CONFIG_SLUB=y
	- CONFIG_SLUB_STATS=y

Looks like the new percpu() checks are complaining about SLUB's use of
__this_cpu_inc() for maintaining it's stat counters.  The below patch
seems to fix it.

Although, I'm wondering how exact these statistics need to be.  Is
making them preemption safe even a concern?

Thanks,
  Josh

--8<--
Make slub statistics maintenance preemption-safe.

Fixes the following warning when CONFIG_SLUB_STATS and
CONFIG_DEBUG_PREEMPT:

	BUG: using __this_cpu_add() in preemptible [00000000] code: systemd-journal/226
	caller is __this_cpu_preempt_check+0x2b/0x30
	Call Trace:
	    dump_stack+0x4e/0x7a
	    check_preemption_disabled+0xd0/0xe0
	    __this_cpu_preempt_check+0x2b/0x30
	    __slab_free+0x38/0x590
	    kmem_cache_free+0x367/0x3a0
	    jbd2_journal_stop+0x24d/0x500
	    __ext4_journal_stop+0x37/0x90
	    ext4_truncate+0x1ab/0x570
	    ext4_setattr+0x2d3/0x810
	    notify_change+0x159/0x3a0
	    do_truncate+0x6f/0xa0
	    do_sys_ftruncate.constprop.18+0x10e/0x160
	    SyS_ftruncate+0xe/0x10
	    system_call_fastpath+0x1a/0x1f

Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: Josh Cartwright <joshc@codeaurora.org>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index c6eb29d..c873e61 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -224,7 +224,7 @@ static inline void memcg_propagate_slab_attrs(struct kmem_cache *s) { }
 static inline void stat(const struct kmem_cache *s, enum stat_item si)
 {
 #ifdef CONFIG_SLUB_STATS
-	__this_cpu_inc(s->cpu_slab->stat[si]);
+	this_cpu_inc(s->cpu_slab->stat[si]);
 #endif
 }
 
-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
