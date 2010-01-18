Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 796766B0096
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 17:56:36 -0500 (EST)
From: Jiri Slaby <jslaby@suse.cz>
Subject: [RFC 1/1] bootmem: move big allocations behing 4G
Date: Mon, 18 Jan 2010 23:56:30 +0100
Message-Id: <1263855390-32497-1-git-send-email-jslaby@suse.cz>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: hannes@cmpxchg.org, linux-kernel@vger.kernel.org, jirislaby@gmail.com
List-ID: <linux-mm.kvack.org>

Hi, I'm fighting a bug where Grub loads the kernel just fine, whereas
isolinux doesn't. I found out, it's due to different addresses of
loaded initrd. On a machine with 128G of memory, grub loads the
initrd at 895M in our case and flat mem_map (2G long) is allocated
above 4G due to 2-4G BIOS reservation.

On the other hand, with isolinux, the 0-2G is free and mem_map is
placed there leaving no space for others, hence kernel panics for
swiotlb which needs to be below 4G.

I use the patch below, but it seems, from the code, like it won't
work out for section allocations.

Any ideas?

--

If there is a big amount of memory (128G) in a machine and 2G of
low 4 gigs are reserved by BIOS, the rest of the "low" memory is
consumed by mem_map with flat mapping enabled.

Consequent allocations with limit being 4G (e.g. swiotlb) fails to
allocate and kernel panics.

Try to avoid that situation on 64-bit by allocating space bigger
than 128M above 4G if possible. With that, mem_map is allocated above
4G and there is enough space for others (swiotlb) in low 4G.
---
 mm/bootmem.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 7d14868..365a0d1 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -486,6 +486,11 @@ static void * __init alloc_bootmem_core(struct bootmem_data *bdata,
 
 	step = max(align >> PAGE_SHIFT, 1UL);
 
+	/* on 64-bit: allocate 128M+ at 4G if satisfies limit */
+	if (BITS_PER_LONG == 64 && size >= (128UL << 20) &&
+			(4UL << 30) + size < (max << PAGE_SHIFT))
+		goal = 4UL << (30 - PAGE_SHIFT);
+
 	if (goal && min < goal && goal < max)
 		start = ALIGN(goal, step);
 	else
-- 
1.6.5.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
