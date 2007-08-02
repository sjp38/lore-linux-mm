Received: by mu-out-0910.google.com with SMTP id g7so632920muf
        for <linux-mm@kvack.org>; Thu, 02 Aug 2007 15:55:30 -0700 (PDT)
From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Re: [PATCH] Fix two potential mem leaks in MPT Fusion (mpt_attach())
Date: Fri, 3 Aug 2007 00:53:44 +0200
References: <200708020155.33690.jesper.juhl@gmail.com> <20070801172653.1fd44e99.akpm@linux-foundation.org> <9a8748490708020120w4bbfe6d1n6f6986aec507316@mail.gmail.com>
In-Reply-To: <9a8748490708020120w4bbfe6d1n6f6986aec507316@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708030053.45297.jesper.juhl@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, James Bottomley <James.Bottomley@steeleye.com>, Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Thursday 02 August 2007 10:20:47 Jesper Juhl wrote:
> On 02/08/07, Andrew Morton <akpm@linux-foundation.org> wrote:
[snip]
> > y'know, we could have a debug option which will spit warnings if someone
> > does a !__GFP_WAIT allocation while !in_atomic() (only works if
> > CONFIG_PREEMPT).
> >
> > But please, make it depend on !CONFIG_AKPM.  I shudder to think about all
> > the stuff it would pick up.
> >
> 
> I can try to cook up something like that tonight...
> 

Ok, so I did a quick hack and I'm drowning in dmesg WARN_ON() traces 
with my usual config.

This is what I added : 

diff --git a/mm/slub.c b/mm/slub.c
index 6c6d74f..e60dd9e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -20,6 +20,7 @@
 #include <linux/mempolicy.h>
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
+#include <linux/hardirq.h>
 
 /*
  * Lock order:
@@ -1568,6 +1569,10 @@ static void __always_inline *slab_alloc(struct kmem_cache *s,
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
+#ifdef CONFIG_PREEMPT
+	WARN_ON( !in_atomic() && !(gfpflags & __GFP_WAIT) );
+#endif
+
 	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
@@ -2370,6 +2375,10 @@ void *__kmalloc(size_t size, gfp_t flags)
 {
 	struct kmem_cache *s = get_slab(size, flags);
 
+#ifdef CONFIG_PREEMPT
+	WARN_ON( !in_atomic() && !(flags & __GFP_WAIT) );
+#endif
+
 	if (ZERO_OR_NULL_PTR(s))
 		return s;
 


And this is what I'm getting heaps of : 

...
[  165.128607]  =======================
[  165.128609] WARNING: at mm/slub.c:1573 kmem_cache_alloc()
[  165.128611]  [<c010400a>] show_trace_log_lvl+0x1a/0x30
[  165.128614]  [<c0104cd2>] show_trace+0x12/0x20
[  165.128616]  [<c0104cf6>] dump_stack+0x16/0x20
[  165.128619]  [<c0175ad3>] kmem_cache_alloc+0xe3/0x110
[  165.128622]  [<c015b10e>] mempool_alloc_slab+0xe/0x10
[  165.128625]  [<c015b211>] mempool_alloc+0x31/0xf0
[  165.128628]  [<c019d033>] bio_alloc_bioset+0x73/0x140
[  165.128631]  [<c019d10e>] bio_alloc+0xe/0x20
[  165.128634]  [<c019d6e1>] bio_map_kern+0x31/0x100
[  165.128637]  [<c02207b2>] blk_rq_map_kern+0x52/0x90
[  165.128640]  [<c02c418b>] scsi_execute+0x4b/0xe0
[  165.128643]  [<c02e5f28>] sr_do_ioctl+0xa8/0x230
[  165.128646]  [<c02e64f6>] sr_read_tochdr+0x76/0xb0
[  165.128649]  [<c02e654b>] sr_disk_status+0x1b/0xa0
[  165.128652]  [<c02e69db>] sr_cd_check+0x9b/0x1b0
[  165.128655]  [<c02e4fbd>] sr_media_change+0x7d/0x250
[  165.128659]  [<c02e6b8e>] media_changed+0x5e/0xa0
[  165.128662]  [<c02e6c01>] cdrom_media_changed+0x31/0x40
[  165.128665]  [<c02e51be>] sr_block_media_changed+0xe/0x10
[  165.128668]  [<c019e5a0>] check_disk_change+0x20/0x80
[  165.128671]  [<c02eaec3>] cdrom_open+0x173/0xa10
[  165.128674]  [<c02e526e>] sr_block_open+0x5e/0xa0
[  165.128677]  [<c019ed55>] do_open+0x85/0x2c0
[  165.128680]  [<c019f1b3>] blkdev_open+0x33/0x80
[  165.128683]  [<c0177c34>] __dentry_open+0xe4/0x200
[  165.128686]  [<c0177df5>] nameidata_to_filp+0x35/0x40
[  165.128689]  [<c0177e49>] do_filp_open+0x49/0x60
[  165.128692]  [<c0177ea9>] do_sys_open+0x49/0xe0
[  165.128695]  [<c0177f7c>] sys_open+0x1c/0x20
[  165.128697]  [<c0102fba>] syscall_call+0x7/0xb
...
[  165.134957] WARNING: at mm/slub.c:1573 kmem_cache_alloc()
[  165.134959]  [<c010400a>] show_trace_log_lvl+0x1a/0x30
[  165.134962]  [<c0104cd2>] show_trace+0x12/0x20
[  165.134965]  [<c0104cf6>] dump_stack+0x16/0x20
[  165.134969]  [<c0175ad3>] kmem_cache_alloc+0xe3/0x110
[  165.134971]  [<c015b10e>] mempool_alloc_slab+0xe/0x10
[  165.134974]  [<c015b211>] mempool_alloc+0x31/0xf0
[  165.134977]  [<c0220b3c>] get_request+0xac/0x260
[  165.134981]  [<c022155c>] get_request_wait+0x1c/0x100
[  165.134983]  [<c0221672>] blk_get_request+0x32/0x70
[  165.134986]  [<c02c4162>] scsi_execute+0x22/0xe0
[  165.134989]  [<c02c428c>] scsi_execute_req+0x6c/0xd0
[  165.134991]  [<c02bff70>] ioctl_internal_command+0x40/0x100
[  165.134996]  [<c02c008c>] scsi_set_medium_removal+0x5c/0x90
[  165.134999]  [<c02e5e76>] sr_lock_door+0x16/0x20
[  165.135002]  [<c02e83d4>] cdrom_release+0x104/0x250
[  165.135005]  [<c02e5d74>] sr_block_release+0x24/0x40
[  165.135008]  [<c019eb96>] __blkdev_put+0x146/0x150
[  165.135012]  [<c019ebaa>] blkdev_put+0xa/0x10
[  165.135015]  [<c019f5e2>] blkdev_close+0x32/0x40
[  165.135018]  [<c017a586>] __fput+0xb6/0x180
[  165.135021]  [<c017a6b9>] fput+0x19/0x20
[  165.135024]  [<c0177a37>] filp_close+0x47/0x80
[  165.135027]  [<c0178e46>] sys_close+0x66/0xc0
[  165.135030]  [<c0102fba>] syscall_call+0x7/0xb
[  165.135032]  =======================
[  166.564998] WARNING: at mm/slub.c:1573 kmem_cache_alloc()
[  166.565006]  [<c010400a>] show_trace_log_lvl+0x1a/0x30
[  166.565013]  [<c0104cd2>] show_trace+0x12/0x20
[  166.565016]  [<c0104cf6>] dump_stack+0x16/0x20
[  166.565020]  [<c0175ad3>] kmem_cache_alloc+0xe3/0x110
[  166.565030]  [<c015b10e>] mempool_alloc_slab+0xe/0x10
[  166.565039]  [<c015b211>] mempool_alloc+0x31/0xf0
[  166.565047]  [<c019cfdf>] bio_alloc_bioset+0x1f/0x140
[  166.565057]  [<c019d10e>] bio_alloc+0xe/0x20
[  166.565066]  [<c01997b3>] submit_bh+0x63/0x100
[  166.565075]  [<c01c96f8>] journal_do_submit_data+0x28/0x40
[  166.565085]  [<c01c9e18>] journal_commit_transaction+0x658/0x1290
[  166.565095]  [<c01ce5f2>] kjournald+0xb2/0x1e0
[  166.565103]  [<c013b9a2>] kthread+0x42/0x70
[  166.565112]  [<c0103bff>] kernel_thread_helper+0x7/0x18
[  166.565121]  =======================
...

etc...

So, where do we go from here?

Obviously my patch above is nothing but a quick hack.  
Should I turn that into a proper debug config option?  
Do we even want to clean up this stuff?
Am I even looking at the right thing?

I'm more than willing to try and create a proper debug option patch 
as well as clean up some of these allocations if wanted... What say 
"the powers that be" ?


Kind regards,

  Jesper Juhl <jesper.juhl@gmail.com>


   PS. Please keep me on Cc when replying.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
