Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77571830A2
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 14:02:47 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id m130so69792236ioa.1
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 11:02:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w202si731846itb.36.2016.08.18.11.02.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 11:02:46 -0700 (PDT)
Message-ID: <1471543363.2581.30.camel@redhat.com>
Subject: Re: [PATCH] usercopy: Skip multi-page bounds checking on SLOB
From: Rik van Riel <riel@redhat.com>
Date: Thu, 18 Aug 2016 14:02:43 -0400
In-Reply-To: <CA+55aFxYHn+4jJP89Pv=mKSKeKR+zkuJbZc8TSj6kORDUD1Qqw@mail.gmail.com>
References: <20160817222921.GA25148@www.outflux.net>
	 <1471530118.2581.13.camel@redhat.com>
	 <CA+55aFxYHn+4jJP89Pv=mKSKeKR+zkuJbZc8TSj6kORDUD1Qqw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@fedoraproject.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, kernel test robot <xiaolong.ye@intel.com>

On Thu, 2016-08-18 at 10:42 -0700, Linus Torvalds wrote:
> On Thu, Aug 18, 2016 at 7:21 AM, Rik van Riel <riel@redhat.com>
> wrote:
> > 
> > One big question I have for Linus is, do we want
> > to allow code that does a higher order allocation,
> > and then frees part of it in smaller orders, or
> > individual pages, and keeps using the remainder?
> 
> Yes. We've even had people do that, afaik. IOW, if you know you're
> going to allocate 16 pages, you can try to do an order-4 allocation
> and just use the 16 pages directly (but still as individual pages),
> and avoid extra allocation costs (and to perhaps get better access
> patterns if the allocation succeeds etc etc).
> 
> That sounds odd, but it actually makes sense when you have the order-
> 4
> allocation as a optimistic path (and fall back to doing smaller
> orders
> when a big-order allocation fails). To make that *purely* just an
> optimization, you need to let the user then treat that order-4
> allocation as individual pages, and free them one by one etc.
> 
> So I'm not sure anybody actually does that, but the buddy allocator
> was partly designed for that case.

That makes sense. A With that in mind,
it would probably be better to just drop
all of the multi-page bounds checking
from the usercopy code, not conditionally
on SLOB.

Alternatively, we could turn the
__GFP_COMP flag into its negative, and
set it only on the code paths that do
what Linus describes (if anyone does
it).

A WARN_ON_ONCE in the page freeing code
could catch these cases, and point people
at exactly what to do if they trigger the
warning.

I am unclear no how to exclude legitimate
usercopies that are larger than PAGE_SIZE
from triggering warnings/errors, if we
cannot identify every buffer where larger
copies are legitimately going.

Having people rewrite their usercopy code
into loops that automatically avoids
triggering page crossing or >PAGE_SIZE
checks would be counterproductive, since
that might just opens up new attack surface.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
