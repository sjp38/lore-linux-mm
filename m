Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id DDE1F6B000A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 09:50:37 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id b185-v6so4294615qkg.19
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 06:50:37 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id o20-v6si4068167qtb.83.2018.07.27.06.50.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 06:50:37 -0700 (PDT)
Subject: Re: [PATCH 1/3] dmapool: improve scalability of dma_pool_alloc
References: <15ff502d-d840-1003-6c45-bc17f0d81262@cybernetics.com>
 <CAHp75VcXVgAtUWY5yRBFg85C5NPN2BAFyAfAkPLkKq5+SsNHpg@mail.gmail.com>
 <2a04ee8b-478d-39f1-09a0-1b2f8c6ee8c6@cybernetics.com>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <2a7cf138-3c2e-6db8-de87-7f4689404adb@cybernetics.com>
Date: Fri, 27 Jul 2018 09:50:34 -0400
MIME-Version: 1.0
In-Reply-To: <2a04ee8b-478d-39f1-09a0-1b2f8c6ee8c6@cybernetics.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Matthew Wilcox <willy@infradead.org>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com


> That would be true if the test were "if
> (list_empty(&pool->avail_page_list))".A  But it is testing the list
> pointers in the item rather than the list pointers in the pool.A  It may
> be a bit confusing if you have never seen that usage before, which is
> why I added a comment.A  Basically, if you use list_del_init() instead of
> list_del(), then you can use list_empty() on the item itself to test if
> the item is present in a list or not.A  For example, the comments in
> list.h warn not to use list_empty() on the entry after just list_del():
>
> /**
>  * list_del - deletes entry from list.
>  * @entry: the element to delete from the list.
>  * Note: list_empty() on entry does not return true after this, the entry is
>  * in an undefined state.
>  */

Sorry for the crappy line length (fixed above).A  Should have just used
Preformat in Thunderbird like always rather than following
Documentation/process/email-clients.rst and changing mailnews.wraplength
from 72 to 0.

Anyway, I have been using list_del_init() for a long time in various
places, but now I can't find where any of its useful features are
documented.A  I will have to submit a separate patch to add more
documentation for it.A  I find it useful for two things.

1) If you use list_del_init(), you can delete an item from a list
multiple times without checking if it has already been deleted.A  So the
following is safe:

list_add(entry, list);
list_del_init(entry);
list_del_init(entry);

That would not be safe if just using list_del().

2) If you use list_del_init(), you can test if an item is present in a
list using list_empty() on the entry.A  So:

list_add(entry, list);
/* list_empty(entry) is false */
list_del_init(entry);
/* list_empty(entry) is true */

That would not work if using just list_del().

Since the list_empty() name is unintuitive for this purpose, it might be
useful to add a new macro for this use case.
