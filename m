Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Liviu Dudau <liviu@dudau.co.uk>
Subject: [PATCH] mm/vmalloc.c: don't dereference possible NULL pointer in __vunmap.
Date: Fri, 28 Dec 2018 17:10:09 +0000
Message-Id: <20181228171009.22269-1-liviu@dudau.co.uk>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chintan Pandya <cpandya@codeaurora.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Liviu Dudau <liviu@dudau.co.uk>
List-ID: <linux-mm.kvack.org>

find_vmap_area() can return a NULL pointer and we're going to dereference
it without checking it first. Use the existing find_vm_area() function
which does exactly what we want and checks for the NULL pointer.

Fixes: f3c01d2f3ade ("mm: vmalloc: avoid racy handling of debugobjects
in vunmap")

Signed-off-by: Liviu Dudau <liviu@dudau.co.uk>
---
 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 871e41c55e239..806047d7fda3c 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1505,7 +1505,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			addr))
 		return;
 
-	area = find_vmap_area((unsigned long)addr)->vm;
+	area = find_vm_area(addr);
 	if (unlikely(!area)) {
 		WARN(1, KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n",
 				addr);
-- 
2.20.1
