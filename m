Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CE836B0290
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 13:55:47 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id b35so127064631uaa.1
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 10:55:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m19si11802022vkd.133.2016.10.31.10.55.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Oct 2016 10:55:46 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: remove get_user_pages_locked()
References: <20161031100228.17917-1-lstoakes@gmail.com>
 <20161031100228.17917-3-lstoakes@gmail.com>
 <cc508436-156e-eb4b-ae01-b44f33c2d692@redhat.com>
 <20161031134849.GA13609@lucifer>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <ddbe34d0-5d29-abce-1627-f464635bbfe6@redhat.com>
Date: Mon, 31 Oct 2016 18:55:33 +0100
MIME-Version: 1.0
In-Reply-To: <20161031134849.GA13609@lucifer>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, kvm@vger.kernel.org, linux-media@vger.kernel.org, devel@driverdev.osuosl.org



On 31/10/2016 14:48, Lorenzo Stoakes wrote:
> On Mon, Oct 31, 2016 at 12:45:36PM +0100, Paolo Bonzini wrote:
>>
>>
>> On 31/10/2016 11:02, Lorenzo Stoakes wrote:
>>> - *
>>> - * get_user_pages should be phased out in favor of
>>> - * get_user_pages_locked|unlocked or get_user_pages_fast. Nothing
>>> - * should use get_user_pages because it cannot pass
>>> - * FAULT_FLAG_ALLOW_RETRY to handle_mm_fault.
>>
>> This comment should be preserved in some way.  In addition, removing
> 
> Could you clarify what you think should be retained?
> 
> The comment seems to me to be largely rendered redundant by this change -
> get_user_pages() now offers identical behaviour, and of course the latter part
> of the comment ('because it cannot pass FAULT_FLAG_ALLOW_RETRY') is rendered
> incorrect by this change.
> 
> It could be replaced with a recommendation to make use of VM_FAULT_RETRY logic
> if possible.

Yes, exactly.  locked == NULL should be avoided whenever mmap_sem can 
be dropped, and the comment indirectly said so.  Now most of those cases
actually are those where you can just call get_user_pages_unlocked.

>> get_user_pages_locked() makes it harder (compared to a simple "git grep
>> -w") to identify callers that lack allow-retry functionality).  So I'm
>> not sure about the benefits of these patches.
> 
> That's a fair point, and certainly this cleanup series is less obviously helpful
> than previous ones.
> 
> However, there are a few points in its favour:
> 
> 1. get_user_pages_remote() was the mirror of get_user_pages() prior to adding an
>    int *locked parameter to the former (necessary to allow for the unexport of
>    __get_user_pages_unlocked()), differing only in task/mm being specified and
>    FOLL_REMOTE being set. This patch series keeps these functions 'synchronised'
>    in this respect.
> 
> 2. There is currently only one caller of get_user_pages_locked() in
>    mm/frame_vector.c which seems to suggest this function isn't widely
>    used/known.

Or not widely necessary. :)

> 3. This change results in all slow-path get_user_pages*() functions having the
>    ability to use VM_FAULT_RETRY logic rather than 'defaulting' to using
>    get_user_pages() that doesn't let you do this even if you wanted to.

This is only true if someone does the work though.  From a quick look 
at your series, the following files can be trivially changed to use 
get_user_pages_unlocked:

- drivers/gpu/drm/via/via_dmablit.c
- drivers/platform/goldfish/goldfish_pipe.c
- drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c
- drivers/rapidio/devices/rio_mport_cdev.c
- drivers/virt/fsl_hypervisor.c

Also, videobuf_dma_init_user could be changed to use retry by adding a 
*locked argument to videobuf_dma_init_user_locked, prototype patch 
after my signature.

Everything else is probably best kept using get_user_pages.

> 4. It's somewhat confusing/redundant having both get_user_pages_locked() and
>    get_user_pages() functions which both require mmap_sem to be held (i.e. both
>    are 'locked' versions.)
> 
>> If all callers were changed, then sure removing the _locked suffix would
>> be a good idea.
> 
> It seems many callers cannot release mmap_sem so VM_FAULT_RETRY logic couldn't
> happen anyway in this cases and in these cases we couldn't change the caller.

But then get_user_pages_locked remains a less-common case, so perhaps 
it's a good thing to give it a longer name!

> Overall, an alternative here might be to remove get_user_pages() and update
> get_user_pages_locked() to add a 'vmas' parameter, however doing this renders
> get_user_pages_unlocked() asymmetric as it would lack an vmas parameter (adding
> one there would make no sense as VM_FAULT_RETRY logic invalidates VMAs) though
> perhaps not such a big issue as it makes sense as to why this is the case.

Adding the 'vmas' parameter to get_user_pages_locked would make little 
sense.  Since VM_FAULT_RETRY invalidates it and g_u_p_locked can and 
does retry, it would generally not be useful.

So I think we have the right API now:

- do not have lock?  Use get_user_pages_unlocked, get retry for free,
no need to handle  mmap_sem and the locked argument; cannot get back vmas.

- have and cannot drop lock?  User get_user_pages, no need to pass NULL 
for the locked argument; can get back vmas.

- have but can drop lock (rare case)?  Use get_user_pages_locked, 
cannot get back vams.

Paolo

> get_user_pages_unlocked() definitely seems to be a useful helper and therefore
> makes sense to retain.

> Of course another alternative is to leave things be :)
> 

diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index 1db0af6c7f94..dae4eb8e9d5b 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -152,7 +152,8 @@ static void videobuf_dma_init(struct videobuf_dmabuf *dma)
 }
 
 static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
-			int direction, unsigned long data, unsigned long size)
+			int direction, unsigned long data, unsigned long size,
+			int *locked)
 {
 	unsigned long first, last;
 	int err, rw = 0;
@@ -185,8 +186,17 @@ static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
 	dprintk(1, "init user [0x%lx+0x%lx => %d pages]\n",
 		data, size, dma->nr_pages);
 
-	err = get_user_pages(data & PAGE_MASK, dma->nr_pages,
-			     flags, dma->pages, NULL);
+	if (locked && !*locked) {
+		down_read(&current->mm->mmap_sem);
+		*locked = 1;
+	}
+
+	/*
+	 * If the caller cannot have mmap_sem dropped, it passes locked == NULL
+	 * so get_user_pages_locked will not release it.
+	 */
+	err = get_user_pages_locked(data & PAGE_MASK, dma->nr_pages,
+				    flags, dma->pages, locked);
 
 	if (err != dma->nr_pages) {
 		dma->nr_pages = (err >= 0) ? err : 0;
@@ -200,10 +210,11 @@ static int videobuf_dma_init_user(struct videobuf_dmabuf *dma, int direction,
 			   unsigned long data, unsigned long size)
 {
 	int ret;
+	int locked = 0;
 
-	down_read(&current->mm->mmap_sem);
-	ret = videobuf_dma_init_user_locked(dma, direction, data, size);
-	up_read(&current->mm->mmap_sem);
+	ret = videobuf_dma_init_user_locked(dma, direction, data, size, &locked);
+	if (locked)
+		up_read(&current->mm->mmap_sem);
 
 	return ret;
 }
@@ -540,7 +551,7 @@ static int __videobuf_iolock(struct videobuf_queue *q,
 
 			err = videobuf_dma_init_user_locked(&mem->dma,
 						      DMA_FROM_DEVICE,
-						      vb->baddr, vb->bsize);
+						      vb->baddr, vb->bsize, NULL);
 			if (0 != err)
 				return err;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
