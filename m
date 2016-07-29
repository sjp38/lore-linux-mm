Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3307E6B0260
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 13:31:32 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so43694310wml.0
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 10:31:32 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id pp3si19846060wjb.275.2016.07.29.10.31.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 10:31:31 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id q128so16672955wma.1
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 10:31:31 -0700 (PDT)
Subject: Re: [4.7+] various memory corruption reports.
References: <20160729150513.GB29545@codemonkey.org.uk>
 <20160729151907.GC29545@codemonkey.org.uk>
 <CAPAsAGxDOvD64+5T4vPiuJgHkdHaaXGRfikFxXGHDRRiW4ivVQ@mail.gmail.com>
 <20160729154929.GA30611@codemonkey.org.uk>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <579B9339.7030707@gmail.com>
Date: Fri, 29 Jul 2016 20:32:41 +0300
MIME-Version: 1.0
In-Reply-To: <20160729154929.GA30611@codemonkey.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>, Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 07/29/2016 06:49 PM, Dave Jones wrote:
> On Fri, Jul 29, 2016 at 06:21:12PM +0300, Andrey Ryabinin wrote:
>  > 2016-07-29 18:19 GMT+03:00 Dave Jones <davej@codemonkey.org.uk>:
>  > > On Fri, Jul 29, 2016 at 11:05:14AM -0400, Dave Jones wrote:
>  > >  > I've just gotten back into running trinity on daily pulls of master, and it seems pretty horrific
>  > >  > right now.  I can reproduce some kind of memory corruption within a couple minutes runtime.
>  > >  >
>  > >  > ,,,
>  > >  >
>  > >  > I'll work on narrowing down the exact syscalls needed to trigger this.
>  > >
>  > > Even limiting it to do just a simple syscall like execve (which fails most the time in trinity)
>  > > triggers it, suggesting it's not syscall related, but the fact that trinity is forking/killing
>  > > tons of processes at high rate is stressing something more fundamental.
>  > >
>  > > Given how easy this reproduces, I'll see if bisecting gives up something useful.
>  > 
>  > I suspect this is false positives due to changes in KASAN.
>  > Bisection probably will point to
>  > 80a9201a5965f4715d5c09790862e0df84ce0614 ("mm, kasan: switch SLUB to
>  > stackdepot, enable memory quarantine for SLUB)"
> 
> good call. reverting that changeset seems to have solved it.
> 

Unfortunately, I wasn't able to reproduce it.

Could you please try with this?

---
 mm/kasan/kasan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index b6f99e8..bf25340 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -543,8 +543,8 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
 		switch (alloc_info->state) {
 		case KASAN_STATE_ALLOC:
 			alloc_info->state = KASAN_STATE_QUARANTINE;
-			quarantine_put(free_info, cache);
 			set_track(&free_info->track, GFP_NOWAIT);
+			quarantine_put(free_info, cache);
 			kasan_poison_slab_free(cache, object);
 			return true;
 		case KASAN_STATE_QUARANTINE:
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
