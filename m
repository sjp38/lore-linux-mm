Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f176.google.com (mail-vc0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id AC8BC6B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 17:55:41 -0400 (EDT)
Received: by mail-vc0-f176.google.com with SMTP id lc6so8745550vcb.21
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 14:55:41 -0700 (PDT)
Received: from mail-vc0-x234.google.com (mail-vc0-x234.google.com [2607:f8b0:400c:c03::234])
        by mx.google.com with ESMTPS id sw4si3990729vdc.174.2014.04.28.14.55.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 14:55:40 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id hq16so6370653vcb.39
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 14:55:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com>
References: <535EA976.1080402@linux.vnet.ibm.com>
	<CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com>
Date: Mon, 28 Apr 2014 14:55:40 -0700
Message-ID: <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com>
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Davidlohr Bueso <davidlohr@hp.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Mon, Apr 28, 2014 at 2:20 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> That said, the bug does seem to be that some path doesn't invalidate
> the vmacache sufficiently, or something inserts a vmacache entry into
> the current process when looking up a remote process or whatever.
> Davidlohr, ideas?

Maybe we missed some use_mm() call. That will change the current mm
without flushing the vma cache. The code considers kernel threads to
be bad targets for vma caching for this reason (and perhaps others),
but maybe we missed something.

I wonder if we should just invalidate the vma cache in use_mm(), and
remote the "kernel tasks are special" check.

Srivatsa, are you doing something peculiar on that system that would
trigger this? I see some kdump failures in the log, anything else?

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
