Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f178.google.com (mail-ve0-f178.google.com [209.85.128.178])
	by kanga.kvack.org (Postfix) with ESMTP id E29D96B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 11:07:18 -0400 (EDT)
Received: by mail-ve0-f178.google.com with SMTP id jw12so1341121veb.9
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 08:07:18 -0700 (PDT)
Received: from mail-vc0-x234.google.com (mail-vc0-x234.google.com [2607:f8b0:400c:c03::234])
        by mx.google.com with ESMTPS id cb3si212597vdc.167.2014.04.23.08.07.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 08:07:16 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id hy4so1270921vcb.25
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 08:07:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140423144901.GA24220@redhat.com>
References: <20140422180308.GA19038@redhat.com>
	<CA+55aFxjADAB80AV6qK-b4QPzP7fgog_EyH-7dSpWVgzpZmL8Q@mail.gmail.com>
	<alpine.LSU.2.11.1404221303060.6220@eggly.anvils>
	<20140423144901.GA24220@redhat.com>
Date: Wed, 23 Apr 2014 08:07:16 -0700
Message-ID: <CA+55aFziPHmSP5yjxDP6h_hRY-H2VgWZKsqC7w8+B9d9wXqn6Q@mail.gmail.com>
Subject: Re: 3.15rc2 hanging processes on exit.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, Apr 23, 2014 at 7:49 AM, Dave Jones <davej@redhat.com> wrote:
>
> So for reasons I can't figure out, I've not been able to hit it on 3.14
> The only 'interesting' thing I've hit in overnight testing is this, which
> I'm not sure if I've also seen in my .15rc testing, but it doesn't look
> familiar to me.  (Though the vm oopses I've seen the last few months
> are starting to all blur together in my memory)
>
>
> kernel BUG at mm/mlock.c:82!

That's

  mlock_vma_page:
    BUG_ON(!PageLocked(page));

which is odd, because:

> Call Trace:
>  [<ffffffffbe196612>] try_to_unmap_nonlinear+0x2a2/0x530
>  [<ffffffffbe1972a7>] rmap_walk+0x157/0x320
>  [<ffffffffbe1976e3>] try_to_unmap+0x93/0xf0
>  [<ffffffffbe1bb8f6>] migrate_pages+0x3b6/0x7b0

All the calls to "try_to_unmap()" in mm/migrate.c are preceded by the pattern

        if (!trylock_page(page)) {
                 ....
                lock_page(page);
        }

where there are just a few "goto out" style cases for the "ok, we're
not going to wait for this page lock" in there.

Very odd.  Does anybody see anything I missed?

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
