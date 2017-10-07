Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E90EE6B0260
	for <linux-mm@kvack.org>; Sat,  7 Oct 2017 07:30:25 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u144so11141351pgb.0
        for <linux-mm@kvack.org>; Sat, 07 Oct 2017 04:30:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r17si2912467pgu.619.2017.10.07.04.30.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 07 Oct 2017 04:30:24 -0700 (PDT)
Subject: Re: [RFC] [PATCH] mm,oom: Offload OOM notify callback to a kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201710022205.IGD04659.HSOMJFFQtFOLOV@I-love.SAKURA.ne.jp>
	<20171002131330.5c5mpephrosfuxsa@dhcp22.suse.cz>
	<201710022252.DDJ51535.JFQSLFHFVOtOOM@I-love.SAKURA.ne.jp>
	<20171002171641-mutt-send-email-mst@kernel.org>
	<201710022344.JII17368.HQtLOMJOOSFFVF@I-love.SAKURA.ne.jp>
In-Reply-To: <201710022344.JII17368.HQtLOMJOOSFFVF@I-love.SAKURA.ne.jp>
Message-Id: <201710072030.HGE12424.HFFMVLJOOStFQO@I-love.SAKURA.ne.jp>
Date: Sat, 7 Oct 2017 20:30:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: mhocko@kernel.org, linux-mm@kvack.org

Tetsuo Handa wrote:
> Michael S. Tsirkin wrote:
> > > Yes, conditional GFP_KERNEL allocation attempt from virtqueue_add() might
> > > still cause this deadlock. But that depends on whether you can trigger this
> > > deadlock. As far as I know, there is no report. Thus, I think that avoiding
> > > theoretical deadlock using timeout will be sufficient.
> > 
> > 
> > So first of all IMHO GFP_KERNEL allocations do not happen in
> > virtqueue_add_outbuf at all. They only trigger through add_sgs.
> 
> I did not notice that total_sg == 1 is true for virtqueue_add_outbuf().
> 
> > 
> > IMHO this is an API bug, we should just drop the gfp parameter
> > from this API.
> 
> OK.
> 
> > 
> > 
> > so the issue is balloon_page_enqueue only.
> > 
> 
> Since you explained that there is "the deflate on OOM flag", we don't
> want to skip deflating upon lock contention.
> 

I tested virtballoon_oom_notify() path using artificial stress
(with inverted virtio_has_feature(VIRTIO_BALLOON_F_DEFLATE_ON_OOM) check
because the QEMU I have does not seem to support deflate-on-oom option),
but I could not trigger the OOM lockup. Thus, I think that we don't need
to worry about

  IMHO it definitely fixes the deadlock. But it does not fix the bug
  that balloon isn't sometimes deflated on oom even though the deflate on
  oom flag is set.

because this is not easy to trigger.

Even if we make sure that the balloon is guaranteed to deflate on oom by
doing memory allocation for inflation outside of balloon_lock, we after all
have to inflate balloon to the size the host has requested by OOM killing
processes in the guest, don't we?

Then, I think that skipping deflating upon lock contention for now is
acceptable. Below is a patch. What do you think?



>From 6a0fd8a5e013ac63a6bcd06bd2ae6fdb25a4f3de Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 7 Oct 2017 19:29:21 +0900
Subject: [PATCH] virtio: avoid possible OOM lockup at virtballoon_oom_notify()

In leak_balloon(), mutex_lock(&vb->balloon_lock) is called in order to
serialize against fill_balloon(). But in fill_balloon(),
alloc_page(GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY) is
called with vb->balloon_lock mutex held. Since GFP_HIGHUSER[_MOVABLE]
implies __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS, despite __GFP_NORETRY
is specified, this allocation attempt might depend on somebody else's
__GFP_DIRECT_RECLAIM memory allocation. And such __GFP_DIRECT_RECLAIM
memory allocation might call leak_balloon() via virtballoon_oom_notify()
via blocking_notifier_call_chain() callback via out_of_memory() when it
reached __alloc_pages_may_oom() and held oom_lock mutex. Since
vb->balloon_lock mutex is already held by fill_balloon(), it will cause
OOM lockup. Thus, do not wait for vb->balloon_lock mutex if
leak_balloon() is called from out_of_memory().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 drivers/virtio/virtio_balloon.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index f0b3a0b..7dbacfb 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -192,7 +192,7 @@ static void release_pages_balloon(struct virtio_balloon *vb,
 	}
 }
 
-static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
+static unsigned leak_balloon(struct virtio_balloon *vb, size_t num, bool wait)
 {
 	unsigned num_freed_pages;
 	struct page *page;
@@ -202,7 +202,10 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
 
-	mutex_lock(&vb->balloon_lock);
+	if (wait)
+		mutex_lock(&vb->balloon_lock);
+	else if (!mutex_trylock(&vb->balloon_lock))
+		return 0;
 	/* We can't release more pages than taken */
 	num = min(num, (size_t)vb->num_pages);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
@@ -367,7 +370,7 @@ static int virtballoon_oom_notify(struct notifier_block *self,
 		return NOTIFY_OK;
 
 	freed = parm;
-	num_freed_pages = leak_balloon(vb, oom_pages);
+	num_freed_pages = leak_balloon(vb, oom_pages, false);
 	update_balloon_size(vb);
 	*freed += num_freed_pages;
 
@@ -395,7 +398,7 @@ static void update_balloon_size_func(struct work_struct *work)
 	if (diff > 0)
 		diff -= fill_balloon(vb, diff);
 	else if (diff < 0)
-		diff += leak_balloon(vb, -diff);
+		diff += leak_balloon(vb, -diff, true);
 	update_balloon_size(vb);
 
 	if (diff)
@@ -597,7 +600,7 @@ static void remove_common(struct virtio_balloon *vb)
 {
 	/* There might be pages left in the balloon: free them. */
 	while (vb->num_pages)
-		leak_balloon(vb, vb->num_pages);
+		leak_balloon(vb, vb->num_pages, true);
 	update_balloon_size(vb);
 
 	/* Now we reset the device so we can clean up the queues. */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
