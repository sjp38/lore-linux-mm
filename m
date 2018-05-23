Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 740546B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 08:32:24 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id r4-v6so4021618pgq.2
        for <linux-mm@kvack.org>; Wed, 23 May 2018 05:32:24 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0112.outbound.protection.outlook.com. [104.47.2.112])
        by mx.google.com with ESMTPS id d25-v6si19061713plj.344.2018.05.23.05.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 23 May 2018 05:32:22 -0700 (PDT)
Subject: Re: [PATCH] mm/kasan: Don't vfree() nonexistent vm_area.
References: <12c9e499-9c11-d248-6a3f-14ec8c4e07f1@molgen.mpg.de>
 <20180201163349.8700-1-aryabinin@virtuozzo.com>
 <4fc394ae-65e8-7c51-112a-81bee0fb8429@virtuozzo.com>
 <20180522140305.5e0f8c62dcc2d735ed4ee84c@linux-foundation.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <dabee6ab-3a7a-51cd-3b86-5468718e0390@virtuozzo.com>
Date: Wed, 23 May 2018 15:33:34 +0300
MIME-Version: 1.0
In-Reply-To: <20180522140305.5e0f8c62dcc2d735ed4ee84c@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, Matthew Wilcox <willy@infradead.org>



On 05/23/2018 12:03 AM, Andrew Morton wrote:
> On Tue, 22 May 2018 19:44:06 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> 
>>> Obviously we can't call vfree() to free memory that wasn't allocated via
>>> vmalloc(). Use find_vm_area() to see if we can call vfree().
>>>
>>> Unfortunately it's a bit tricky to properly unmap and free shadow allocated
>>> during boot, so we'll have to keep it. If memory will come online again
>>> that shadow will be reused.
>>>
>>> Fixes: fa69b5989bb0 ("mm/kasan: add support for memory hotplug")
>>> Reported-by: Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>
>>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>>> Cc: <stable@vger.kernel.org>
>>> ---
>>
>> This seems stuck in -mm. Andrew, can we proceed?
> 
> OK.
> 
> Should there be a code comment explaining the situation that Matthew
> asked about?  It's rather obscure.
> 

Ok. Here is my attempt to improve the situation. If something is still not clear,
I'm open to suggestions.



From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] mm-kasan-dont-vfree-nonexistent-vm_area-fix

Improve comments.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/kasan/kasan.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 135ce2838c89..ea44dd0bc4e7 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -812,7 +812,7 @@ static bool shadow_mapped(unsigned long addr)
 	/*
 	 * We can't use pud_large() or pud_huge(), the first one
 	 * is arch-specific, the last one depend on HUGETLB_PAGE.
-	 * So let's abuse pud_bad(), if bud is bad it's has to
+	 * So let's abuse pud_bad(), if pud is bad than it's bad
 	 * because it's huge.
 	 */
 	if (pud_bad(*pud))
@@ -871,9 +871,16 @@ static int __meminit kasan_mem_notifier(struct notifier_block *nb,
 		struct vm_struct *vm;
 
 		/*
-		 * Only hot-added memory have vm_area. Freeing shadow
-		 * mapped during boot would be tricky, so we'll just
-		 * have to keep it.
+		 * shadow_start was either mapped during boot by kasan_init()
+		 * or during memory online by __vmalloc_node_range().
+		 * In the latter case we can use vfree() to free shadow.
+		 * Non-NULL result of the find_vm_area() will tell us if
+		 * that was the second case.
+		 *
+		 * Currently it's not possible to free shadow mapped
+		 * during boot by kasan_init(). It's because the code
+		 * to do that hasn't been written yet. So we'll just
+		 * leak the memory.
 		 */
 		vm = find_vm_area((void *)shadow_start);
 		if (vm)
-- 
2.16.1
