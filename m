Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 522506B0035
	for <linux-mm@kvack.org>; Sun, 31 Aug 2014 20:17:27 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id q5so5176682wiv.12
        for <linux-mm@kvack.org>; Sun, 31 Aug 2014 17:17:26 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id b7si8088428wie.24.2014.08.31.17.17.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Aug 2014 17:17:23 -0700 (PDT)
Message-ID: <5403BB0A.8040000@infradead.org>
Date: Sun, 31 Aug 2014 17:17:14 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [PATCH -mmotm v2] mm: fix kmemcheck.c build errors
References: <5400fba1.732YclygYZprDXeI%akpm@linux-foundation.org> <54012D74.7010302@infradead.org> <CAPAsAGz4458YgHN0b04Z4fTwvo-guh+ESNAXy7j=c-bc7v4gcA@mail.gmail.com> <540335C5.3030905@infradead.org> <5403B0B8.8010507@infradead.org> <20140901001312.GA25599@js1304-P5Q-DELUXE>
In-Reply-To: <20140901001312.GA25599@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, Pekka Enberg <penberg@kernel.org>, Vegard Nossum <vegardno@ifi.uio.no>

On 08/31/14 17:13, Joonsoo Kim wrote:
> On Sun, Aug 31, 2014 at 04:33:12PM -0700, Randy Dunlap wrote:
>> On 08/31/14 07:48, Randy Dunlap wrote:
>>> On 08/31/14 04:36, Andrey Ryabinin wrote:
>>>> 2014-08-30 5:48 GMT+04:00 Randy Dunlap <rdunlap@infradead.org>:
>>>>> From: Randy Dunlap <rdunlap@infradead.org>
>>>>>
>>>>> Add header file to fix kmemcheck.c build errors:
>>>>>
>>>>> ../mm/kmemcheck.c:70:7: error: dereferencing pointer to incomplete type
>>>>> ../mm/kmemcheck.c:83:15: error: dereferencing pointer to incomplete type
>>>>> ../mm/kmemcheck.c:95:8: error: dereferencing pointer to incomplete type
>>>>> ../mm/kmemcheck.c:95:21: error: dereferencing pointer to incomplete type
>>>>>
>>>>> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
>>>>> ---
>>>>>  mm/kmemcheck.c |    1 +
>>>>>  1 file changed, 1 insertion(+)
>>>>>
>>>>> Index: mmotm-2014-0829-1515/mm/kmemcheck.c
>>>>> ===================================================================
>>>>> --- mmotm-2014-0829-1515.orig/mm/kmemcheck.c
>>>>> +++ mmotm-2014-0829-1515/mm/kmemcheck.c
>>>>> @@ -2,6 +2,7 @@
>>>>>  #include <linux/mm_types.h>
>>>>>  #include <linux/mm.h>
>>>>>  #include <linux/slab.h>
>>>>> +#include <linux/slab_def.h>
>>>>
>>>> This will work only for CONFIG_SLAB=y. struct kmem_cache definition
>>>> was moved to internal header [*],
>>>> so you need to include it here:
>>>> #include "slab.h"
>>>>
>>>> [*] http://ozlabs.org/~akpm/mmotm/broken-out/mm-slab_common-move-kmem_cache-definition-to-internal-header.patch
>>>
>>> Thanks.  That makes sense.  [testing]  mm/kmemcheck.c still has a build error:
>>>
>>> In file included from ../mm/kmemcheck.c:5:0:
>>> ../mm/slab.h: In function 'cache_from_obj':
>>> ../mm/slab.h:283:2: error: implicit declaration of function 'memcg_kmem_enabled' [-Werror=implicit-function-declaration]
>>>
>>
>> Naughty header file.  It uses something from <linux/memcontrol.h> without
>> #including that header file...
> 
> 
> Hello.
> 
> Indeed...
> Thanks for catching this.
> 
>>
>> Working patch is below.
> 
> With your patch, build also failed if CONFIG_MEMCG_KMEM=y.
> Right fix is something like below.
> 
> Thanks.
> 
> --------->8----------
> diff --git a/mm/kmemcheck.c b/mm/kmemcheck.c
> index fd814fd..cab58bb 100644
> --- a/mm/kmemcheck.c
> +++ b/mm/kmemcheck.c
> @@ -2,6 +2,7 @@
>  #include <linux/mm_types.h>
>  #include <linux/mm.h>
>  #include <linux/slab.h>
> +#include "slab.h"
>  #include <linux/kmemcheck.h>
>  
>  void kmemcheck_alloc_shadow(struct page *page, int order, gfp_t flags, int node)
> diff --git a/mm/slab.h b/mm/slab.h
> index 13845d0..963a3f8 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -37,6 +37,8 @@ struct kmem_cache {
>  #include <linux/slub_def.h>
>  #endif
>  
> +#include <linux/memcontrol.h>
> +
>  /*
>   * State of the slab allocator.
>   *
> --

Um, yeah, looks equivalent to what I sent as v2.

Thanks.

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
