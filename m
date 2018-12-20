Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH RFC] mm: vmalloc: do not allow kzalloc to fail
Date: Thu, 20 Dec 2018 21:23:57 +0100
Message-Id: <1545337437-673-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chintan Pandya <cpandya@codeaurora.org>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Arun KS <arunks@codeaurora.org>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
List-ID: <linux-mm.kvack.org>

While this is in a very early stage of the system boot and if memory
were exhausted the system has a more serious problem anyway - but still
the kzalloc here seems unsafe. Looking at the history it was previously
switched from alloc_bootmem() to kzalloc() using GFP_NOWAIT flag but
there never seems to have been a check for NULL return. So if this is
expected to never fail should it not be using | __GFP_NOFAIL here ?
Or put differently - what is the rational for GFP_NOWAIT to be safe here ?

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
Fixes 43ebdac42f16 ("vmalloc: use kzalloc() instead of alloc_bootmem()")
---

Problem was found by an experimental coccinelle script

Patch was only compile tested for x86_64_defconfig

Patch is against v4.20-rc7 (localversion-next next-20181220)

 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 871e41c..1c118d7 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1258,7 +1258,7 @@ void __init vmalloc_init(void)
 
 	/* Import existing vmlist entries. */
 	for (tmp = vmlist; tmp; tmp = tmp->next) {
-		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
+		va = kzalloc(sizeof(*va), GFP_NOWAIT | __GFP_NOFAIL);
 		va->flags = VM_VM_AREA;
 		va->va_start = (unsigned long)tmp->addr;
 		va->va_end = va->va_start + tmp->size;
-- 
2.1.4
