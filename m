Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 40406828F2
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 10:13:12 -0500 (EST)
Received: by mail-oi0-f47.google.com with SMTP id c203so62469225oia.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 07:13:12 -0800 (PST)
Received: from mail-ob0-x22f.google.com (mail-ob0-x22f.google.com. [2607:f8b0:4003:c01::22f])
        by mx.google.com with ESMTPS id zm1si4601143obc.11.2016.03.02.07.13.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 07:13:11 -0800 (PST)
Received: by mail-ob0-x22f.google.com with SMTP id xx9so87615523obc.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 07:13:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D6DC13.8060008@huawei.com>
References: <56D6DC13.8060008@huawei.com>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Wed, 2 Mar 2016 23:12:32 +0800
Message-ID: <CAHz2CGV484L9BGpDGiu_k6isUsPxss6-36ZU8Hi7KceXvU1tQA@mail.gmail.com>
Subject: Re: a question about slub in function __slab_free()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, js1304@gmail.com

On Wed, Mar 2, 2016 at 8:26 PM, Xishi Qiu <qiuxishi@huawei.com> wrote:
> __slab_free()
>         prior = page->freelist;  // prior is NULL
>         was_frozen = new.frozen;  // was_frozen is 0
>         ...
>                 /*
>                  * Slab was on no list before and will be
>                  * partially empty
>                  * We can defer the list move and instead
>                  * freeze it.
>                  */
>                 new.frozen = 1;
>         ...
>
> I don't understand why "Slab was on no list before"?

in this  __slab_free() code path, we are freeing an object to a remote CPU.

Consider the condition that leads to this branch, that is:

new.inuse  && !prior && !was_frozen

new.inuse means that slab page has free objects after we do this free operiton.

!prior && !was_frozen together means  that slab page has previously
depleted all objects
and forgotten(SLUB don't remember a slab page that has got all its
object allocated).

All these 3 conditions mean that,

A slab page on a remote CPU has got all tis objects allocated and it
was forgotten by SLUB,
so  "Slab was on no list before",

and then at the present, we (on local CPU) are freeing object back to
that CPU,  that "will make
the slab page partially empty".

But we don't bother to immediately add it back to the node partial
list( to avoid the list->lock contention),
so "we can defer the list move".

But how do we handle this?  Easy, just mark it frozen,  and latter
that CPU's  per-cpu freelist queue will
use it.


Regards,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
