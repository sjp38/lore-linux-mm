Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 247426B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 12:05:27 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so54421125pab.5
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:05:26 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id ht1si14364101pac.134.2015.01.30.09.05.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 30 Jan 2015 09:05:26 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ00031I2BOK3B0@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 30 Jan 2015 17:09:24 +0000 (GMT)
Message-id: <54CBB9C9.3060500@samsung.com>
Date: Fri, 30 Jan 2015 20:05:13 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v10 06/17] mm: slub: introduce
 metadata_access_enable()/metadata_access_disable()
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-7-git-send-email-a.ryabinin@samsung.com>
 <20150129151243.fd76aca21757b1ca5b62163e@linux-foundation.org>
In-reply-to: <20150129151243.fd76aca21757b1ca5b62163e@linux-foundation.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On 01/30/2015 02:12 AM, Andrew Morton wrote:
> On Thu, 29 Jan 2015 18:11:50 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> 
>> Wrap access to object's metadata in external functions with
>> metadata_access_enable()/metadata_access_disable() function calls.
>>
>> This hooks separates payload accesses from metadata accesses
>> which might be useful for different checkers (e.g. KASan).
>>
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -467,13 +467,23 @@ static int slub_debug;
>>  static char *slub_debug_slabs;
>>  static int disable_higher_order_debug;
>>  
>> +static inline void metadata_access_enable(void)
>> +{
>> +}
>> +
>> +static inline void metadata_access_disable(void)
>> +{
>> +}
> 
> Some code comments here would be useful.  What they do, why they exist,
> etc.  The next patch fills them in with
> kasan_disable_local/kasan_enable_local but that doesn't help the reader
> to understand what's going on.  The fact that
> kasan_disable_local/kasan_enable_local are also undocumented doesn't
> help.
> 

Ok, How about this?

/*
 * This hooks separate payload access from metadata access.
 * Useful for memory checkers that have to know when slub
 * accesses metadata.
 */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
