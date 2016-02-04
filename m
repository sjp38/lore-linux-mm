Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id C7CD96B0281
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 11:21:13 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id j125so18482699oih.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 08:21:13 -0800 (PST)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id bg4si618814oec.74.2016.02.04.08.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 08:21:13 -0800 (PST)
Received: by mail-oi0-x230.google.com with SMTP id w5so18404934oie.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 08:21:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56B30C52.7040907@de.ibm.com>
References: <1454565386-10489-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1454565386-10489-3-git-send-email-iamjoonsoo.kim@lge.com>
	<56B30C52.7040907@de.ibm.com>
Date: Fri, 5 Feb 2016 01:21:12 +0900
Message-ID: <CAAmzW4Oce1zeVj=cjcgNVYV8CSE6JbQgdDbxroTrBMt02C13Yw@mail.gmail.com>
Subject: Re: [PATCH 2/5] mm/slub: query dynamic DEBUG_PAGEALLOC setting
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Takashi Iwai <tiwai@suse.com>, Chris Metcalf <cmetcalf@ezchip.com>, Christoph Lameter <cl@linux.com>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-02-04 17:31 GMT+09:00 Christian Borntraeger <borntraeger@de.ibm.com>:
> On 02/04/2016 06:56 AM, Joonsoo Kim wrote:
>> We can disable debug_pagealloc processing even if the code is complied
>> with CONFIG_DEBUG_PAGEALLOC. This patch changes the code to query
>> whether it is enabled or not in runtime.
>>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> ---
>>  mm/slub.c | 11 ++++++-----
>>  1 file changed, 6 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 7d4da68..7b5a965 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -256,11 +256,12 @@ static inline void *get_freepointer_safe(struct kmem_cache *s, void *object)
>>  {
>>       void *p;
>>
>> -#ifdef CONFIG_DEBUG_PAGEALLOC
>> -     probe_kernel_read(&p, (void **)(object + s->offset), sizeof(p));
>> -#else
>> -     p = get_freepointer(s, object);
>> -#endif
>> +     if (debug_pagealloc_enabled()) {
>> +             probe_kernel_read(&p,
>> +                     (void **)(object + s->offset), sizeof(p));
>
> Hmm, this might be a good case for a line longer than 80 chars....
>
> As an alternative revert the logic and return early:
>
>
>         if (!debug_pagealloc_enabled())
>                 return get_freepointer(s, object);
>         probe_kernel_read(&p, (void **)(object + s->offset), sizeof(p));
>         return p;
>

Looks better!
I will fix it on next version.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
