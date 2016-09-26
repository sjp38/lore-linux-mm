Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 74C6A280274
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 17:30:04 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id i193so559354715oib.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 14:30:04 -0700 (PDT)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id 65si13826180oih.11.2016.09.26.14.30.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 14:30:01 -0700 (PDT)
Received: by mail-oi0-x233.google.com with SMTP id a62so223291560oib.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 14:30:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1474925009.17726.61.camel@redhat.com>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <1474925009.17726.61.camel@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 26 Sep 2016 14:30:00 -0700
Message-ID: <CA+55aFzsNuX7djeiaeC_7efcp6-_YGAqwGnYFgmipiemU8vkPQ@mail.gmail.com>
Subject: Re: page_waitqueue() considered harmful
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>

On Mon, Sep 26, 2016 at 2:23 PM, Rik van Riel <riel@redhat.com> wrote:
>
> Why are we touching file pages at all during fork()?

This is *not* fork. This is fork/exec/exit. It's a real load, it's
just fairly concentrated by the scripts being many and small.

It's easy enough to try yourself:

   perf record -e cycles:pp make -j16 test

in the git tree.

> Could we get away with skipping copy_page_range on VMAs
> that do not have any anonymous pages?

You still have to duplicate those ranges, but that's fairly cheap.
>From what I can tell, the expensive part really is the "page in new
executable/library pages" and then tearing them down again (because it
was just a quick small git process or a very small shell script).

So forget about fork(). I'm not even sure how much of that there is,
it's possible that you end up having vfork() instead. It's exec/exit
that matters most in this load.

(You can see that in the profile with things like strnlen_user()
actually being fairly high on the profile too - mostly the environment
variables during exec).

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
