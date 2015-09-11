Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id A5CDB6B0256
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 10:32:33 -0400 (EDT)
Received: by obbbh8 with SMTP id bh8so61787945obb.0
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 07:32:33 -0700 (PDT)
Received: from mail-ob0-x22d.google.com (mail-ob0-x22d.google.com. [2607:f8b0:4003:c01::22d])
        by mx.google.com with ESMTPS id xj4si364547oeb.73.2015.09.11.07.32.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Sep 2015 07:32:32 -0700 (PDT)
Received: by obqa2 with SMTP id a2so61836337obq.3
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 07:32:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509081249240.26204@east.gentwo.org>
References: <OF591717D2.930C6B40-ON48257E7D.0017016C-48257E7D.0020AFB4@zte.com.cn>
	<20150729152803.67f593847050419a8696fe28@linux-foundation.org>
	<20150731001827.GA15029@js1304-P5Q-DELUXE>
	<alpine.DEB.2.11.1507310845440.11895@east.gentwo.org>
	<20150807015609.GB15802@js1304-P5Q-DELUXE>
	<20150904132902.5d62a09077435d742d6f2f1b@linux-foundation.org>
	<20150907053855.GC21207@js1304-P5Q-DELUXE>
	<alpine.DEB.2.11.1509081249240.26204@east.gentwo.org>
Date: Fri, 11 Sep 2015 23:32:32 +0900
Message-ID: <CAAmzW4O9d6i1cDArzG72WpBQfn5VgmiQVr1DBS8QN4o4V7gPHg@mail.gmail.com>
Subject: Re: slab:Fix the unexpected index mapping result of
 kmalloc_size(INDEX_NODE + 1)
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, liu.hailong6@zte.com.cn, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, jiang.xuexin@zte.com.cn, David Rientjes <rientjes@google.com>

2015-09-09 2:49 GMT+09:00 Christoph Lameter <cl@linux.com>:
> On Mon, 7 Sep 2015, Joonsoo Kim wrote:
>
>> Sure. It should be fixed soon. If Christoph agree with my approach, I
>> will make it to proper formatted patch.
>
> Could you explain that approach again?

Instead of following hunk,
-       if (size >= kmalloc_size(INDEX_NODE + 1)
+       if (size >= kmalloc_size(INDEX_NODE) * 2 &&

Using this hunk.
-       if (size >= kmalloc_size(INDEX_NODE + 1)
+       if (!slab_early_init &&
+               size >= kmalloc_size(INDEX_NODE) &&
+               size >= 256 &&

What this codes intend for is to determine whether this slab
can be debugged by debug_pagealloc. It become possible
when off slab management is possible so this condition is to
check whether off slab management is possible or not. Off slab
management requires small sized slab so we should not allow
debug_pagealloc until proper sized slab is initialized.
Initialization sequence is like:

The mapping table in the latest kernel is like:
    index = {0,   1,  2 ,  3,  4,   5,   6,   n}
     size = {0,   96, 192, 8, 16,  32,  64,   2^n}

So, when we initialize 96, 192 or 8, proper slab isn't initialized.
If we allow debug_pagealloc larger than 256 sized slab,
small sized slab would be already initialized so no error
happens. I think it is better than
kmalloc_size(INDEX_NODE) * 2, because that doesn't
guarantee size is larger than 192.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
