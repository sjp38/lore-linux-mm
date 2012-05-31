Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id E63D76B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 07:56:19 -0400 (EDT)
Received: by wefh52 with SMTP id h52so757608wef.14
        for <linux-mm@kvack.org>; Thu, 31 May 2012 04:56:18 -0700 (PDT)
Date: Thu, 31 May 2012 14:55:38 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: kmemleak:
Message-ID: <20120531115537.GA3676@swordfish.minsk.epam.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello,

I'm seeing pretty often (may be 10-15 times during last 2 months) kmemleak failed
allocation:

	[ 8213.936237] kmemleak: Kernel memory leak detector disabled
	[ 8214.660454] kmemleak: Automatic memory scanning thread ended


I've a patch that gives a bit more info on last kmemleak step (for example):

[ 8213.935927] kmemleak: Cannot allocate a kmemleak_object structure
[ 8213.935950] kmemleak: size: 192, mask: 70144
[ 8213.935955] Pid: 444, comm: kswapd0 Not tainted 3.5.0-rc0-dbg-10118-gaf992ce-dirty #1152
[ 8213.935957] Call Trace:
[ 8213.935986]  [<ffffffff8111ec4c>] create_object+0x7d/0x305
[ 8213.936009]  [<ffffffff810dc89e>] ? mempool_alloc_slab+0x15/0x17
[ 8213.936014]  [<ffffffff810dc89e>] ? mempool_alloc_slab+0x15/0x17
[ 8213.936020]  [<ffffffff8149a2e3>] kmemleak_alloc+0x26/0x43
[ 8213.936041]  [<ffffffff81114d54>] kmem_cache_alloc+0xd7/0x1e6
[ 8213.936046]  [<ffffffff810dc89e>] mempool_alloc_slab+0x15/0x17
[ 8213.936050]  [<ffffffff810dcb28>] mempool_alloc+0x81/0x146
[ 8213.936074]  [<ffffffff81284052>] ? do_raw_spin_lock+0x69/0xe9
[ 8213.936079]  [<ffffffff81150829>] bio_alloc_bioset+0x33/0xc4
[ 8213.936085]  [<ffffffff8110a0f9>] ? get_swap_bio+0x79/0x79
[ 8213.936089]  [<ffffffff811508cf>] bio_alloc+0x15/0x24
[ 8213.936109]  [<ffffffff8110a09f>] get_swap_bio+0x1f/0x79
[ 8213.936114]  [<ffffffff8110a20b>] swap_writepage+0x3d/0x9f
[ 8213.936120]  [<ffffffff810e8cde>] pageout.isra.48+0x127/0x2f9
[ 8213.936141]  [<ffffffff810ea570>] shrink_inactive_list+0x4eb/0x94f
[ 8213.936146]  [<ffffffff810ead10>] shrink_lruvec+0x33c/0x46f
[ 8213.936151]  [<ffffffff810ebb94>] kswapd+0x680/0xa58
[ 8213.936172]  [<ffffffff810eb514>] ? try_to_free_pages+0x27f/0x27f
[ 8213.936178]  [<ffffffff81053da5>] kthread+0x8b/0x93
[ 8213.936184]  [<ffffffff814be134>] kernel_thread_helper+0x4/0x10
[ 8213.936207]  [<ffffffff814b59f0>] ? retint_restore_args+0x13/0x13
[ 8213.936211]  [<ffffffff81053d1a>] ? __init_kthread_worker+0x5a/0x5a
[ 8213.936215]  [<ffffffff814be130>] ? gs_change+0x13/0x13

The question is - could it be of any use to printk stack trace with function parameters
(size, flag) for failed allocation?

If so, I'll prepare a proper patch.



Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

---

 mm/kmemleak.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 45eb621..60c49a5 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -521,8 +521,10 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 
 	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
 	if (!object) {
+		write_lock_irqsave(&kmemleak_lock, flags);
 		pr_warning("Cannot allocate a kmemleak_object structure\n");
-		kmemleak_disable();
+		kmemleak_stop("size: %zu, mask: %u\n", size, gfp_kmemleak_mask(gfp));
+		write_unlock_irqrestore(&kmemleak_lock, flags);
 		return NULL;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
