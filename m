Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 096D928026B
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 21:05:58 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id i193so483020030oib.3
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 18:05:58 -0700 (PDT)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id h136si11541641oib.266.2016.09.25.18.05.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 18:05:57 -0700 (PDT)
Received: by mail-oi0-x244.google.com with SMTP id a62so12668582oib.1
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 18:05:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1474850960.17726.48.camel@redhat.com>
References: <20160911225425.10388-1-lstoakes@gmail.com> <20160925184731.GA20480@lucifer>
 <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com>
 <1474842875.17726.38.camel@redhat.com> <CA+55aFyL+qFsJpxQufgRKgWeB6Yj0e1oapdu5mdU9_t+zwtBjg@mail.gmail.com>
 <1474850960.17726.48.camel@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 25 Sep 2016 18:05:56 -0700
Message-ID: <CA+55aFyP2Aw7ET5oNX9fB644PGKrguk-mhXdcEN_aHvnVVsUjg@mail.gmail.com>
Subject: Re: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA balancing
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Lorenzo Stoakes <lstoakes@gmail.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, tbsaunde@tbsaunde.org, robert@ocallahan.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Sep 25, 2016 at 5:49 PM, Rik van Riel <riel@redhat.com> wrote:
>
> Reading the code for a little bit, it looks like get_user_pages
> interprets both PROT_NONE and PAGE_NUMA ptes as present, and will
> simply return the page to the caller.

So the thing is, I don't think the code should even get that far.

It should just fail in check_vma_flags() (possibly after doing the
fast-lookup of the page tables, but that would fail with PROT_NONE).

But thanks to FOLL_FORCE, it doesn't. So things that actually use the
page array and prot_none can get access to the underlying data.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
