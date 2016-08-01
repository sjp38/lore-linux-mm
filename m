Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD996B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 07:02:03 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p85so72989132lfg.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 04:02:03 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id 206si14098985ljf.82.2016.08.01.04.02.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 04:02:01 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id l89so8312726lfi.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 04:02:01 -0700 (PDT)
Subject: Re: [4.7+] various memory corruption reports.
References: <20160729150513.GB29545@codemonkey.org.uk>
 <20160729151907.GC29545@codemonkey.org.uk>
 <CAPAsAGxDOvD64+5T4vPiuJgHkdHaaXGRfikFxXGHDRRiW4ivVQ@mail.gmail.com>
 <20160729154929.GA30611@codemonkey.org.uk> <579B9339.7030707@gmail.com>
 <579B98B8.40007@gmail.com> <20160729183925.GA28376@codemonkey.org.uk>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <579F2C73.6090406@gmail.com>
Date: Mon, 1 Aug 2016 14:03:15 +0300
MIME-Version: 1.0
In-Reply-To: <20160729183925.GA28376@codemonkey.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>, Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 07/29/2016 09:39 PM, Dave Jones wrote:
> On Fri, Jul 29, 2016 at 08:56:08PM +0300, Andrey Ryabinin wrote:
> 
>  > >>  > I suspect this is false positives due to changes in KASAN.
>  > >>  > Bisection probably will point to
>  > >>  > 80a9201a5965f4715d5c09790862e0df84ce0614 ("mm, kasan: switch SLUB to
>  > >>  > stackdepot, enable memory quarantine for SLUB)"
>  > >>
>  > >> good call. reverting that changeset seems to have solved it.
>  > > Could you please try with this?
>  > Actually, this is not quite right, it should be like this:
> 
> 
> Seems to have stopped the corruption, but now I get NMi watchdog traces..
> 
> 

This should help:

---
 mm/kasan/kasan.c      | 4 ++--
 mm/kasan/quarantine.c | 8 ++++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 3019cec..c99ef40 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -565,7 +565,7 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 	unsigned long redzone_start;
 	unsigned long redzone_end;
 
-	if (flags & __GFP_RECLAIM)
+	if (gfpflags_allow_blocking(flags))
 		quarantine_reduce();
 
 	if (unlikely(object == NULL))
@@ -596,7 +596,7 @@ void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 	unsigned long redzone_start;
 	unsigned long redzone_end;
 
-	if (flags & __GFP_RECLAIM)
+	if (gfpflags_allow_blocking(flags))
 		quarantine_reduce();
 
 	if (unlikely(ptr == NULL))
diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 65793f1..4852625 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -147,10 +147,14 @@ static void qlink_free(struct qlist_node *qlink, struct kmem_cache *cache)
 	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
 	unsigned long flags;
 
-	local_irq_save(flags);
+	if (IS_ENABLED(CONFIG_SLAB))
+		local_irq_save(flags);
+
 	alloc_info->state = KASAN_STATE_FREE;
 	___cache_free(cache, object, _THIS_IP_);
-	local_irq_restore(flags);
+
+	if (IS_ENABLED(CONFIG_SLAB))
+		local_irq_restore(flags);
 }
 
 static void qlist_free_all(struct qlist_head *q, struct kmem_cache *cache)
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
