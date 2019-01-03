Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Roman Penyaev <rpenyaev@suse.de>
Subject: [PATCH 1/3] mm/vmalloc: fix size check for remap_vmalloc_range_partial()
Date: Thu,  3 Jan 2019 15:59:52 +0100
Message-Id: <20190103145954.16942-2-rpenyaev@suse.de>
In-Reply-To: <20190103145954.16942-1-rpenyaev@suse.de>
References: <20190103145954.16942-1-rpenyaev@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
Cc: Roman Penyaev <rpenyaev@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org
List-ID: <linux-mm.kvack.org>

area->size can include adjacent guard page but get_vm_area_size()
returns actual size of the area.

This fixes possible kernel crash when userspace tries to map area
on 1 page bigger: size check passes but the following vmalloc_to_page()
returns NULL on last guard (non-existing) page.

Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Joe Perches <joe@perches.com>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org
---
 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 871e41c55e23..2cd24186ba84 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2248,7 +2248,7 @@ int remap_vmalloc_range_partial(struct vm_area_struct *vma, unsigned long uaddr,
 	if (!(area->flags & VM_USERMAP))
 		return -EINVAL;
 
-	if (kaddr + size > area->addr + area->size)
+	if (kaddr + size > area->addr + get_vm_area_size(area))
 		return -EINVAL;
 
 	do {
-- 
2.19.1
