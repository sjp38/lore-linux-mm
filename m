Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 829386B026B
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 18:50:22 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id i193so476019069oib.3
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 15:50:22 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id o3si3469572oih.214.2016.09.25.15.50.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 15:50:22 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id a62so12547467oib.1
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 15:50:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1474842875.17726.38.camel@redhat.com>
References: <20160911225425.10388-1-lstoakes@gmail.com> <20160925184731.GA20480@lucifer>
 <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com> <1474842875.17726.38.camel@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 25 Sep 2016 15:50:21 -0700
Message-ID: <CA+55aFyL+qFsJpxQufgRKgWeB6Yj0e1oapdu5mdU9_t+zwtBjg@mail.gmail.com>
Subject: Re: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA balancing
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Lorenzo Stoakes <lstoakes@gmail.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, tbsaunde@tbsaunde.org, robert@ocallahan.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Sep 25, 2016 at 3:34 PM, Rik van Riel <riel@redhat.com> wrote:
>
> The patch looks good to me, too.
>
> Acked-by: Rik van Riel <riel@redhat.com>

Thanks, amended the commit since I hadn't pushed out yet.

Btw, the only reason this bug could happen is that we do that
"force=1" for remote vm accesses, which turns into FOLL_FORCE, which
in turn will turn into us allowing an access even when we technically
shouldn't.

I'd really like to re-open the "drop FOLL_FORCE entirely" discussion,
because the thing really is disgusting.

I realize that debuggers etc sometimes would want to punch through
PROT_NONE protections, and I also realize that right now we only have
a read/write flag, and we have that whole issue with "what if it's
executable but not readable", which currently FOLL_FORCE makes a
non-issue.

But at the same time, FOLL_FORCE really is a major nasty thing. It
shouldn't be a security issue (we still do check VM_MAY_READ/WRITE etc
to verify that even if something isn't readable or writable we *could*
have had permissions to do this), but this bug is a prime example of
how it violates our deeply held beliefs of how VM permissions *should*
work, and it screwed up the numa case as a result.

So how about we consider getting rid of FOLL_FORCE? Addign Hugh
Dickins to the cc, because I think he argued for that many moons ago..

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
