Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f175.google.com (mail-ve0-f175.google.com [209.85.128.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6BC6B00CE
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 13:13:56 -0500 (EST)
Received: by mail-ve0-f175.google.com with SMTP id oz11so1698433veb.6
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 10:13:55 -0800 (PST)
Received: from mail-ve0-x22f.google.com (mail-ve0-x22f.google.com [2607:f8b0:400c:c01::22f])
        by mx.google.com with ESMTPS id uw4si3352229vdc.1.2014.02.21.10.13.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 10:13:55 -0800 (PST)
Received: by mail-ve0-f175.google.com with SMTP id oz11so1698415veb.6
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 10:13:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1392960523.3039.16.camel@buesod1.americas.hpqcorp.net>
References: <1392960523.3039.16.camel@buesod1.americas.hpqcorp.net>
Date: Fri, 21 Feb 2014 10:13:54 -0800
Message-ID: <CA+55aFw1_Ecbjjv9vijj3o46mkq3NrJn0X-FnbpCGBZG2=NuOA@mail.gmail.com>
Subject: Re: [PATCH] mm: per-thread vma caching
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Feb 20, 2014 at 9:28 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> From: Davidlohr Bueso <davidlohr@hp.com>
>
> This patch is a continuation of efforts trying to optimize find_vma(),
> avoiding potentially expensive rbtree walks to locate a vma upon faults.

Ok, so I like this one much better than the previous version.

However, I do wonder if the per-mm vmacache is actually worth it.
Couldn't the per-thread one replace it entirely?

Also, the hash you use for the vmacache index is *particularly* odd.

        int idx =  (addr >> 10) & 3;

you're using the top two bits of the address *within* the page.
There's a lot of places that round addresses down to pages, and in
general it just looks really odd to use an offset within a page as an
index, since in some patterns (linear accesses, whatever), the page
faults will always be to the beginning of the page, so index 0 ends up
being special.

What am I missing?

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
