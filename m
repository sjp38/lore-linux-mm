Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD446B0035
	for <linux-mm@kvack.org>; Sun, 31 Aug 2014 10:48:47 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id g10so4075906pdj.21
        for <linux-mm@kvack.org>; Sun, 31 Aug 2014 07:48:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ey4si9178447pab.231.2014.08.31.07.48.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Aug 2014 07:48:44 -0700 (PDT)
Message-ID: <540335C5.3030905@infradead.org>
Date: Sun, 31 Aug 2014 07:48:37 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [PATCH -mmotm] mm: fix kmemcheck.c build errors
References: <5400fba1.732YclygYZprDXeI%akpm@linux-foundation.org>	<54012D74.7010302@infradead.org> <CAPAsAGz4458YgHN0b04Z4fTwvo-guh+ESNAXy7j=c-bc7v4gcA@mail.gmail.com>
In-Reply-To: <CAPAsAGz4458YgHN0b04Z4fTwvo-guh+ESNAXy7j=c-bc7v4gcA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, Pekka Enberg <penberg@kernel.org>, Vegard Nossum <vegardno@ifi.uio.no>

On 08/31/14 04:36, Andrey Ryabinin wrote:
> 2014-08-30 5:48 GMT+04:00 Randy Dunlap <rdunlap@infradead.org>:
>> From: Randy Dunlap <rdunlap@infradead.org>
>>
>> Add header file to fix kmemcheck.c build errors:
>>
>> ../mm/kmemcheck.c:70:7: error: dereferencing pointer to incomplete type
>> ../mm/kmemcheck.c:83:15: error: dereferencing pointer to incomplete type
>> ../mm/kmemcheck.c:95:8: error: dereferencing pointer to incomplete type
>> ../mm/kmemcheck.c:95:21: error: dereferencing pointer to incomplete type
>>
>> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
>> ---
>>  mm/kmemcheck.c |    1 +
>>  1 file changed, 1 insertion(+)
>>
>> Index: mmotm-2014-0829-1515/mm/kmemcheck.c
>> ===================================================================
>> --- mmotm-2014-0829-1515.orig/mm/kmemcheck.c
>> +++ mmotm-2014-0829-1515/mm/kmemcheck.c
>> @@ -2,6 +2,7 @@
>>  #include <linux/mm_types.h>
>>  #include <linux/mm.h>
>>  #include <linux/slab.h>
>> +#include <linux/slab_def.h>
> 
> This will work only for CONFIG_SLAB=y. struct kmem_cache definition
> was moved to internal header [*],
> so you need to include it here:
> #include "slab.h"
> 
> [*] http://ozlabs.org/~akpm/mmotm/broken-out/mm-slab_common-move-kmem_cache-definition-to-internal-header.patch

Thanks.  That makes sense.  [testing]  mm/kmemcheck.c still has a build error:

In file included from ../mm/kmemcheck.c:5:0:
../mm/slab.h: In function 'cache_from_obj':
../mm/slab.h:283:2: error: implicit declaration of function 'memcg_kmem_enabled' [-Werror=implicit-function-declaration]


Maybe Andrew should just drop that patch and its associated patches.


>>  #include <linux/kmemcheck.h>
>>
>>  void kmemcheck_alloc_shadow(struct page *page, int order, gfp_t flags, int node)
>>
> 
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
