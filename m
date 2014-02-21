Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 82C506B00D4
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 15:53:42 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id vb8so4632667obc.2
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 12:53:42 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id us4si4055664obc.57.2014.02.21.12.53.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 12:53:41 -0800 (PST)
Message-ID: <1393016019.3039.40.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] mm: per-thread vma caching
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 21 Feb 2014 12:53:39 -0800
In-Reply-To: <CA+55aFw1_Ecbjjv9vijj3o46mkq3NrJn0X-FnbpCGBZG2=NuOA@mail.gmail.com>
References: <1392960523.3039.16.camel@buesod1.americas.hpqcorp.net>
	 <CA+55aFw1_Ecbjjv9vijj3o46mkq3NrJn0X-FnbpCGBZG2=NuOA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, 2014-02-21 at 10:13 -0800, Linus Torvalds wrote:
> On Thu, Feb 20, 2014 at 9:28 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> > From: Davidlohr Bueso <davidlohr@hp.com>
> >
> > This patch is a continuation of efforts trying to optimize find_vma(),
> > avoiding potentially expensive rbtree walks to locate a vma upon faults.
> 
> Ok, so I like this one much better than the previous version.
> 
> However, I do wonder if the per-mm vmacache is actually worth it.
> Couldn't the per-thread one replace it entirely?

I think you are right. I just reran some of the tests and things are
pretty much the same, so we could get rid of it. I originally left it
there because I recall seeing a slightly better hit rate for some java
workloads (map/reduce, specifically), but it wasn't a big deal - some
slots endup being redundant with a per mm cache. It does however
guarantee that we access hot vmas immediately, instead of potentially
slightly more reads when we go into per-thread checking. I'm happy with
the results either way.

> Also, the hash you use for the vmacache index is *particularly* odd.
> 
>         int idx =  (addr >> 10) & 3;
> 
> you're using the top two bits of the address *within* the page.
> There's a lot of places that round addresses down to pages, and in
> general it just looks really odd to use an offset within a page as an
> index, since in some patterns (linear accesses, whatever), the page
> faults will always be to the beginning of the page, so index 0 ends up
> being special.

Ah, this comes from tediously looking at access patterns. I actually
printed pages of them. I agree that it is weird, and I'm by no means
against changing it. However, the results are just too good, specially
for ebizzy, so I decided to keep it, at least for now. I am open to
alternatives.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
