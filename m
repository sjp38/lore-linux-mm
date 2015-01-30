Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id EF9F66B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 18:19:26 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so57945331pad.1
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 15:19:26 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id y4si15438193pdl.50.2015.01.30.15.19.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 15:19:26 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so57802105pab.12
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 15:19:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150130151643.400b369ba4fc3c50a1353ddf@linux-foundation.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-7-git-send-email-a.ryabinin@samsung.com>
	<20150129151243.fd76aca21757b1ca5b62163e@linux-foundation.org>
	<54CBB9C9.3060500@samsung.com>
	<20150130134217.73d6f43f8257936275351834@linux-foundation.org>
	<CAPAsAGxPOC7j9Z=xjtobcdMEgGJB0L+drO1m4TWBgkNNfZWmSw@mail.gmail.com>
	<20150130151643.400b369ba4fc3c50a1353ddf@linux-foundation.org>
Date: Sat, 31 Jan 2015 03:19:25 +0400
Message-ID: <CAPAsAGyRqj40Eah4QVP_64kNH35cnWSr1zumnTxiZz1iv8GmdA@mail.gmail.com>
Subject: Re: [PATCH v10 06/17] mm: slub: introduce metadata_access_enable()/metadata_access_disable()
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

2015-01-31 2:16 GMT+03:00 Andrew Morton <akpm@linux-foundation.org>:
> On Sat, 31 Jan 2015 03:11:55 +0400 Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
>
>> >> > kasan_disable_local/kasan_enable_local are also undocumented doesn't
>> >> > help.
>> >> >
>> >>
>> >> Ok, How about this?
>> >>
>> >> /*
>> >>  * This hooks separate payload access from metadata access.
>> >>  * Useful for memory checkers that have to know when slub
>> >>  * accesses metadata.
>> >>  */
>> >
>> > "These hooks".
>> >
>> > I still don't understand :( Maybe I'm having a more-stupid-than-usual
>> > day.
>>
>> I think it's me being stupid today ;) I'll try to explain better.
>>
>> > How can a function "separate access"?  What does this mean?  More
>> > details, please.  I think I've only once seen a comment which had too
>> > much info!
>> >
>>
>> slub could access memory marked by kasan as inaccessible (object's metadata).
>> Kasan shouldn't print report in that case because this access is valid.
>> Disabling instrumentation of slub.c code is not enough to achieve this
>> because slub passes pointer to object's metadata into memchr_inv().
>>
>> We can't disable instrumentation for memchr_inv() because this is quite
>> generic function.
>>
>> So metadata_access_enable/metadata_access_disable wrap some
>> places in slub.c where access to object's metadata starts/end.
>> And kasan_disable_local/kasan_enable_local just disable/enable
>> error reporting in this places.
>
> ooh, I see.  Something like this?
>

Yes! Thank you, this looks much better.

> /*
>  * slub is about to manipulate internal object metadata.  This memory lies
>  * outside the range of the allocated object, so accessing it would normally
>  * be reported by kasan as a bounds error.  metadata_access_enable() is used
>  * to tell kasan that these accesses are OK.
>  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
