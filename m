Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED3D82F86
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 09:17:21 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id q63so17456545pfb.0
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 06:17:21 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id 86si6738766pfs.88.2015.12.23.06.17.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Dec 2015 06:17:20 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id cy9so51595105pac.0
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 06:17:20 -0800 (PST)
Date: Wed, 23 Dec 2015 23:17:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: KVM: memory ballooning bug?
Message-ID: <20151223141710.GA20931@blaptop.local>
References: <20151223052228.GA31269@bbox>
 <20151223111448.GA16626@t510.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151223111448.GA16626@t510.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-kernel@vger.kernel.org

On Wed, Dec 23, 2015 at 06:14:49AM -0500, Rafael Aquini wrote:
> On Wed, Dec 23, 2015 at 02:22:28PM +0900, Minchan Kim wrote:
> > During my compaction-related stuff, I encountered some problems with
> > ballooning.
> > 
> > Firstly, with repeated inflating and deflating cycle, guest memory(ie,
> > cat /proc/meminfo | grep MemTotal) decreased and couldn't recover.
> > 
> > When I review source code, balloon_lock should cover release_pages_balloon.
> > Otherwise, struct virtio_balloon fields could be overwritten by race
> > of fill_balloon(e,g, vb->*pfns could be critical).
> > Below patch fixed the problem.
> > 
> > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > index 7efc32945810..7d3e5d0e9aa4 100644
> > --- a/drivers/virtio/virtio_balloon.c
> > +++ b/drivers/virtio/virtio_balloon.c
> > @@ -209,8 +209,8 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
> >          */
> >         if (vb->num_pfns != 0)
> >                 tell_host(vb, vb->deflate_vq);
> > -       mutex_unlock(&vb->balloon_lock);
> >         release_pages_balloon(vb);
> > +       mutex_unlock(&vb->balloon_lock);
> >         return num_freed_pages;
> >  }
> >  
> > Secondly, in balloon_page_dequeue, pages_lock should cover
> > list_for_each_entry_safe loop. Otherwise, the cursor page
> > could be isolated by compaction and then list_del by isolation
> > could poison the page->lru so the loop could access wrong address
> > like this.
> > 
> > general protection fault: 0000 [#1] SMP 
> > Dumping ftrace buffer:
> >    (ftrace buffer empty)
> > Modules linked in:
> > CPU: 2 PID: 82 Comm: vballoon Not tainted 4.4.0-rc5-mm1+ #1906
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> > task: ffff8800a7ff0000 ti: ffff8800a7fec000 task.ti: ffff8800a7fec000
> > RIP: 0010:[<ffffffff8115e754>]  [<ffffffff8115e754>] balloon_page_dequeue+0x54/0x130
> > RSP: 0018:ffff8800a7fefdc0  EFLAGS: 00010246
> > RAX: ffff88013fff9a70 RBX: ffffea000056fe00 RCX: 0000000000002b7d
> > RDX: ffff88013fff9a70 RSI: ffffea000056fe00 RDI: ffff88013fff9a68
> > RBP: ffff8800a7fefde8 R08: ffffea000056fda0 R09: 0000000000000000
> > R10: ffff8800a7fefd90 R11: 0000000000000001 R12: dead0000000000e0
> > R13: ffffea000056fe20 R14: ffff880138809070 R15: ffff880138809060
> > FS:  0000000000000000(0000) GS:ffff88013fc40000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 00007f229c10e000 CR3: 00000000b8b53000 CR4: 00000000000006a0
> > Stack:
> >  0000000000000100 ffff880138809088 ffff880138809000 ffff880138809060
> >  0000000000000046 ffff8800a7fefe28 ffffffff812c86d3 ffff880138809020
> >  ffff880138809000 fffffffffff91900 0000000000000100 ffff880138809060
> > Call Trace:
> >  [<ffffffff812c86d3>] leak_balloon+0x93/0x1a0
> >  [<ffffffff812c8bc7>] balloon+0x217/0x2a0
> >  [<ffffffff8143739e>] ? __schedule+0x31e/0x8b0
> >  [<ffffffff81078160>] ? abort_exclusive_wait+0xb0/0xb0
> >  [<ffffffff812c89b0>] ? update_balloon_stats+0xf0/0xf0
> >  [<ffffffff8105b6e9>] kthread+0xc9/0xe0
> >  [<ffffffff8105b620>] ? kthread_park+0x60/0x60
> >  [<ffffffff8143b4af>] ret_from_fork+0x3f/0x70
> >  [<ffffffff8105b620>] ? kthread_park+0x60/0x60
> > Code: 8d 60 e0 0f 84 af 00 00 00 48 8b 43 20 a8 01 75 3b 48 89 d8 f0 0f ba 28 00 72 10 48 8b 03 f6 c4 08 75 2f 48 89 df e8 8c 83 f9 ff <49> 8b 44 24 20 4d 8d 6c 24 20 48 83 e8 20 4d 39 f5 74 7a 4c 89 
> > RIP  [<ffffffff8115e754>] balloon_page_dequeue+0x54/0x130
> >  RSP <ffff8800a7fefdc0>
> > ---[ end trace 43cf28060d708d5f ]---
> > Kernel panic - not syncing: Fatal exception
> > Dumping ftrace buffer:
> >    (ftrace buffer empty)
> > Kernel Offset: disabled
> > 
> > We could fix it by protecting the entire loop by pages_lock but
> > problem is irq latency during walking the list.
> > But I doubt how often such worst scenario happens because
> > in normal situation, the loop would exit easily via succeeding
> > trylock_page.
> > 
> > Any comments?
> 
> Nope, I think the simplest way to address both cases you stumbled
> across is by replacing the locking to extend those critical sections as
> you suggested.

I couldn't understand why you said "Nope" and which lock do you mean?
There are two locks to need to extend.
If you are on same page with me, I suggested this.

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 7efc329..7d3e5d0 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -209,8 +209,8 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 	 */
 	if (vb->num_pfns != 0)
 		tell_host(vb, vb->deflate_vq);
-	mutex_unlock(&vb->balloon_lock);
 	release_pages_balloon(vb);
+	mutex_unlock(&vb->balloon_lock);
 	return num_freed_pages;
 }
 
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index d3116be..300117f 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -61,6 +61,7 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 	bool dequeued_page;
 
 	dequeued_page = false;
+	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
 	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
 		/*
 		 * Block others from accessing the 'page' while we get around
@@ -75,15 +76,14 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 				continue;
 			}
 #endif
-			spin_lock_irqsave(&b_dev_info->pages_lock, flags);
 			balloon_page_delete(page);
 			__count_vm_event(BALLOON_DEFLATE);
-			spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
 			unlock_page(page);
 			dequeued_page = true;
 			break;
 		}
 	}
+	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
 
 	if (!dequeued_page) {
 		/*
Do you agree this patch? If so, I will send patch after X-mas.
Otherwise, please elaborate it more.

Happy Happy Xmas!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
