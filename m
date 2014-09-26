Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 510956B003A
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 13:36:56 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id hq12so3150182vcb.40
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 10:36:54 -0700 (PDT)
Received: from mail-vc0-x22f.google.com (mail-vc0-x22f.google.com [2607:f8b0:400c:c03::22f])
        by mx.google.com with ESMTPS id ip5si2651829vcb.52.2014.09.26.10.36.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 10:36:54 -0700 (PDT)
Received: by mail-vc0-f175.google.com with SMTP id hy4so2221263vcb.34
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 10:36:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aJ9htaruQ1Nn7+MSGwtNzRb_hfytQo98J1wq5N6oh1BA@mail.gmail.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1411562649-28231-1-git-send-email-a.ryabinin@samsung.com>
	<1411562649-28231-12-git-send-email-a.ryabinin@samsung.com>
	<CACT4Y+aJ9htaruQ1Nn7+MSGwtNzRb_hfytQo98J1wq5N6oh1BA@mail.gmail.com>
Date: Fri, 26 Sep 2014 21:36:54 +0400
Message-ID: <CAPAsAGxLxCxOayqcu=PbgFG6J7JEuL8J3+ouz94p_k0v0Hy=wA@mail.gmail.com>
Subject: Re: [PATCH v3 11/13] kmemleak: disable kasan instrumentation for kmemleak
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>

2014-09-26 21:10 GMT+04:00 Dmitry Vyukov <dvyukov@google.com>:
> Looks good to me.
>
> We can disable kasan instrumentation of this file as well.
>

Yes, but why? I don't think we need that.

> On Wed, Sep 24, 2014 at 5:44 AM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
>> kmalloc internally round up allocation size, and kmemleak
>> uses rounded up size as object's size. This makes kasan
>> to complain while kmemleak scans memory or calculates of object's
>> checksum. The simplest solution here is to disable kasan.
>>
>> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
>> ---
>>  mm/kmemleak.c | 6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
>> index 3cda50c..9bda1b3 100644
>> --- a/mm/kmemleak.c
>> +++ b/mm/kmemleak.c
>> @@ -98,6 +98,7 @@
>>  #include <asm/processor.h>
>>  #include <linux/atomic.h>
>>
>> +#include <linux/kasan.h>
>>  #include <linux/kmemcheck.h>
>>  #include <linux/kmemleak.h>
>>  #include <linux/memory_hotplug.h>
>> @@ -1113,7 +1114,10 @@ static bool update_checksum(struct kmemleak_object *object)
>>         if (!kmemcheck_is_obj_initialized(object->pointer, object->size))
>>                 return false;
>>
>> +       kasan_disable_local();
>>         object->checksum = crc32(0, (void *)object->pointer, object->size);
>> +       kasan_enable_local();
>> +
>>         return object->checksum != old_csum;
>>  }
>>
>> @@ -1164,7 +1168,9 @@ static void scan_block(void *_start, void *_end,
>>                                                   BYTES_PER_POINTER))
>>                         continue;
>>
>> +               kasan_disable_local();
>>                 pointer = *ptr;
>> +               kasan_enable_local();
>>
>>                 object = find_and_get_object(pointer, 1);
>>                 if (!object)
>> --
>> 2.1.1
>>
>


-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
