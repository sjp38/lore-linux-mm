Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id C67A66B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 21:35:00 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id g203so14874909iof.2
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 18:35:00 -0800 (PST)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id v13si1173084ioi.70.2016.02.23.18.34.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 18:35:00 -0800 (PST)
Received: by mail-io0-x233.google.com with SMTP id 9so15112626iom.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 18:34:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1456277927-12044-1-git-send-email-hannes@cmpxchg.org>
References: <1456277927-12044-1-git-send-email-hannes@cmpxchg.org>
Date: Tue, 23 Feb 2016 18:34:59 -0800
Message-ID: <CA+55aFzQr-8fOfzA97nZd07L8EFRgXSLSorrw1xVm_KMYinfdA@mail.gmail.com>
Subject: Re: [PATCH] mm: readahead: do not cap readahead() and MADV_WILLNEED
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Tue, Feb 23, 2016 at 5:38 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> Since both readahead() and MADV_WILLNEED take an explicit length
> parameter, it seems weird to truncate that request quietly. Just do
> what the user asked for and leave the limiting to the heuristics.

Why the hell do people continue to try to push these kinds of changes?

Just read the code that you changed: the size_t is a trivially
user-supplied number that any user can set to any value. And you just
removed all sanity checking for it, so now people can basically do
unlimited IO that is not even killable.

Seriously.

[ It's slightly saved by the fact that you have to find a file that is
large and readable, which will happily limit things a lot on practice,
but it's still something we should worry about.

  It is also at least partially mitigated by the fact that read-ahead
allocations use __GFP_NORETRY and hopefully thus don't do the worst
kind of damage to the memory management, but I'd hate to have to rely
on that ]

At least with regular read() system calls, we try to use killable IO
(well - some filesystems might not do it, but the core pagecache
functions support it), and we limit the maximum IO size even if that
limit happens to be pretty high.

You just completely removed that limiting for the readahead code. So
now you can pass in any arbitrary 64-bit size.

Why do you think that "Just do what the user asked for" is obviously
the right thing?

What if I as a user asked to overwrite /etc/passwd with my own data?
Would that be right?

And if that isn't right, then why do you assume it is right that you
can do infinite readahead?

Now, it is entirely possible that we should raise the limit (note that
"raise" is different from "remove"). But that requires

 (a) thought
 (b) data

and this patch had neither.

If we raise the limit, we need to do so intelligently. It's almost
certainly going to involve looking at how much free memory we have,
because part of "readahead" is very much also "don't disturb other
users and IO too much".

The current choice for the limit is "small enough that we don't need
to think too much about it". If we raise it to hundreds of megs, we
very definitely will want to think about it much more. We might also
want to make sure that the operation can be properly aborted,
something we haven't needed to worry about for the small limit we have
now.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
