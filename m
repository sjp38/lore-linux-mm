Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id F2C5D6B0036
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 11:35:01 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kq14so6657153pab.39
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 08:35:00 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id ba9si23743091pdb.146.2014.09.15.08.34.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 15 Sep 2014 08:34:59 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NBY0053S8QXAQ60@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 15 Sep 2014 16:37:45 +0100 (BST)
Message-id: <5417058E.1010206@samsung.com>
Date: Mon, 15 Sep 2014 19:28:14 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH v2 01/10] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-2-git-send-email-a.ryabinin@samsung.com>
 <5414F0F3.4000001@infradead.org>
In-reply-to: <5414F0F3.4000001@infradead.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Michal Marek <mmarek@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On 09/14/2014 05:35 AM, Randy Dunlap wrote:
> Following sentence is confusing.  I'm not sure how to fix it.
> 


Perhaps rephrase is like this:

Do not use slub poisoning with KASan if user tracking enabled (iow slub_debug=PU).
User tracking info (allocation/free stacktraces) are stored inside slub object's metadata.
Slub poisoning overwrites slub object and it's metadata with poison value on freeing.
So if KASan will detect use after free, allocation/free stacktraces will be overwritten
and KASan won't be able to print them.


>> +Please don't use slab poisoning with KASan (slub_debug=P), beacuse if KASan will
> 
>                                                                          drop: will
> 
>> +detects use after free allocation and free stacktraces will be overwritten by
> 
> maybe:     use after free,
> 
>> +poison bytes, and KASan won't be able to print this backtraces.
> 
>                                                        backtrace.
> 
>> +
>> +Each shadow byte corresponds to 8 bytes of the main memory. We use the
>> +following encoding for each shadow byte: 0 means that all 8 bytes of the
>> +corresponding memory region are addressable; k (1 <= k <= 7) means that
>> +the first k bytes are addressable, and other (8 - k) bytes are not;
>> +any negative value indicates that the entire 8-byte word is unaddressable.
>> +We use different negative values to distinguish between different kinds of
>> +unaddressable memory (redzones, freed memory) (see mm/kasan/kasan.h).
>> +
> 
> Is there any need for something similar to k (1 <= k <= 7) but meaning that the
> *last* k bytes are addressable instead of the first k bytes?
> 

There is no need for that. Slub allocations are always 8 byte aligned (at least on 64bit systems).
Now I realized that it could be a problem for 32bit systems. Anyway, the best way to deal
with that would be align allocation to 8 bytes.

>> +Poisoning or unpoisoning a byte in the main memory means writing some special
>> +value into the corresponding shadow memory. This value indicates whether the
>> +byte is addressable or not.
>> +
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
