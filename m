Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D79D96B0005
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 13:54:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p129so43905125wmp.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 10:54:57 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id o187si9354720lfo.274.2016.07.29.10.54.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 10:54:56 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id 33so5655734lfw.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 10:54:56 -0700 (PDT)
Subject: Re: [4.7+] various memory corruption reports.
References: <20160729150513.GB29545@codemonkey.org.uk>
 <20160729151907.GC29545@codemonkey.org.uk>
 <CAPAsAGxDOvD64+5T4vPiuJgHkdHaaXGRfikFxXGHDRRiW4ivVQ@mail.gmail.com>
 <20160729154929.GA30611@codemonkey.org.uk> <579B9339.7030707@gmail.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <579B98B8.40007@gmail.com>
Date: Fri, 29 Jul 2016 20:56:08 +0300
MIME-Version: 1.0
In-Reply-To: <579B9339.7030707@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>, Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 07/29/2016 08:32 PM, Andrey Ryabinin wrote:
> 
> 
> On 07/29/2016 06:49 PM, Dave Jones wrote:
>> On Fri, Jul 29, 2016 at 06:21:12PM +0300, Andrey Ryabinin wrote:
>>  > 2016-07-29 18:19 GMT+03:00 Dave Jones <davej@codemonkey.org.uk>:
>>  > > On Fri, Jul 29, 2016 at 11:05:14AM -0400, Dave Jones wrote:
>>  > >  > I've just gotten back into running trinity on daily pulls of master, and it seems pretty horrific
>>  > >  > right now.  I can reproduce some kind of memory corruption within a couple minutes runtime.
>>  > >  >
>>  > >  > ,,,
>>  > >  >
>>  > >  > I'll work on narrowing down the exact syscalls needed to trigger this.
>>  > >
>>  > > Even limiting it to do just a simple syscall like execve (which fails most the time in trinity)
>>  > > triggers it, suggesting it's not syscall related, but the fact that trinity is forking/killing
>>  > > tons of processes at high rate is stressing something more fundamental.
>>  > >
>>  > > Given how easy this reproduces, I'll see if bisecting gives up something useful.
>>  > 
>>  > I suspect this is false positives due to changes in KASAN.
>>  > Bisection probably will point to
>>  > 80a9201a5965f4715d5c09790862e0df84ce0614 ("mm, kasan: switch SLUB to
>>  > stackdepot, enable memory quarantine for SLUB)"
>>
>> good call. reverting that changeset seems to have solved it.
>>
> 
> Unfortunately, I wasn't able to reproduce it.
> 
> Could you please try with this?
> 
> ---
>  mm/kasan/kasan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index b6f99e8..bf25340 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -543,8 +543,8 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
>  		switch (alloc_info->state) {
>  		case KASAN_STATE_ALLOC:
>  			alloc_info->state = KASAN_STATE_QUARANTINE;
> -			quarantine_put(free_info, cache);
>  			set_track(&free_info->track, GFP_NOWAIT);
> +			quarantine_put(free_info, cache);
>  			kasan_poison_slab_free(cache, object);
>  			return true;
>  		case KASAN_STATE_QUARANTINE:
> 

Actually, this is not quite right, it should be like this:

---
 mm/kasan/kasan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index b6f99e8..3019cec 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -543,9 +543,9 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
 		switch (alloc_info->state) {
 		case KASAN_STATE_ALLOC:
 			alloc_info->state = KASAN_STATE_QUARANTINE;
-			quarantine_put(free_info, cache);
 			set_track(&free_info->track, GFP_NOWAIT);
 			kasan_poison_slab_free(cache, object);
+			quarantine_put(free_info, cache);
 			return true;
 		case KASAN_STATE_QUARANTINE:
 		case KASAN_STATE_FREE:
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
