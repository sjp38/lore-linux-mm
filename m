Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C38628025A
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 17:35:03 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p190so3937622wmp.3
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 14:35:03 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id y63si1114869wmb.140.2016.11.03.14.35.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 14:35:02 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id u144so6532276wmu.1
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 14:35:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161103141607.855925f33be627dea9731eb3@linux-foundation.org>
References: <20161103220428.984a8d09d0c9569e6bc6b8cc@gmail.com> <20161103141607.855925f33be627dea9731eb3@linux-foundation.org>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Thu, 3 Nov 2016 22:35:01 +0100
Message-ID: <CAMJBoFNRs3HqToqFaoxigD6aHzDHjWkpOQ+mK0HiodgFdwh+kQ@mail.gmail.com>
Subject: Re: [PATH] z3fold: extend compaction function
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>

On Thu, Nov 3, 2016 at 10:16 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 3 Nov 2016 22:04:28 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:
>
>> z3fold_compact_page() currently only handles the situation when
>> there's a single middle chunk within the z3fold page. However it
>> may be worth it to move middle chunk closer to either first or
>> last chunk, whichever is there, if the gap between them is big
>> enough.
>
> "may be worth it" is vague.  Does the patch improve the driver or does
> it not?  If it *does* improve the driver then in what way?  *Why* is is
> "worth it"?

Yep, I must admit I wasn't clear enough here. Basically compression
ratio wise, it always makes sense to move middle chunk as close as
possible to another in-page z3fold object, because then the third
object can use all the remaining space. However, moving big object
just by one chunk will hurt performance without gaining much
compression ratio wise. So the gap between the middle object and the
edge object should be big enough to justify the move.

So,
this patch improves compression ratio because in-page compaction
becomes more comprehensive;
this patch (which came as a surprise) also increases performance in
fio randrw tests (I am not 100% sure why, but probably due to less
actual page allocations on hot path due to denser in-page allocation).

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
