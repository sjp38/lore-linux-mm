Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 961B56B009A
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 14:42:14 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so2822315pbc.29
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 11:42:14 -0700 (PDT)
Received: from mail-pb0-x232.google.com (mail-pb0-x232.google.com [2607:f8b0:400e:c01::232])
        by mx.google.com with ESMTPS id ns7si20944867pbb.248.2014.06.06.11.42.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 11:42:13 -0700 (PDT)
Received: by mail-pb0-f50.google.com with SMTP id ma3so2820769pbc.9
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 11:42:13 -0700 (PDT)
Date: Fri, 6 Jun 2014 11:40:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 3.15-rc8 oops in copy_page_rep after page fault.
In-Reply-To: <CA+55aFxiOsceOsm7zYyvFAxDF3=gxUXj=_61Nce3VkELfJr7cg@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1406061128480.15624@eggly.anvils>
References: <20140606174317.GA1741@redhat.com> <CA+55aFxiOsceOsm7zYyvFAxDF3=gxUXj=_61Nce3VkELfJr7cg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>

On Fri, 6 Jun 2014, Linus Torvalds wrote:
> On Fri, Jun 6, 2014 at 10:43 AM, Dave Jones <davej@redhat.com> wrote:
> >
> > RIP: 0010:[<ffffffff8b3287b5>]  [<ffffffff8b3287b5>] copy_page_rep+0x5/0x10
> 
> Ok, it's the first iteration of "rep movsq" (%rcx is still 0x200) for
> copying a page, and the pages are
> 
>   RSI: ffff880052766000
>   RDI: ffff880014efe000
> 
> which both look like reasonable kernel addresses. So I'm assuming it's
> DEBUG_PAGEALLOC that makes this trigger, and since the error code is
> 0, and the CR2 value matches RSI, it's the source page that seems to
> have been freed.
> 
> And I see absolutely _zero_ reason for wht your 64k mmap_min_addr
> should make any difference what-so-ever. That's just odd.
> 
> Anyway, can you try to figure out _which_ copy_user_highpage() it is
> (by looking at what is around the call-site at
> "handle_mm_fault+0x1e0". The fact that we have a stale
> do_huge_pmd_wp_page() on the stack makes me suspect that we have hit
> that VM_FAULT_FALLBACK case and this is related to splitting. Adding a
> few more people explicitly to the cc in case anybody sees anything
> (original email on lkml and linux-mm for context, guys).

It's a familiar one, that Sasha first reported over a year ago:
see https://lkml.org/lkml/2013/3/29/103

Somewhere in that thread I suggest that it's due to the source THPage
being split, and a tail page freed, while copy is in progress; and
not a problem without DEBUG_PAGEALLOC, since the pmd_same check
will prevent a miscopy from being made visible.

It's not a v3.15 regression, and it's no worry without DEBUG_PAGEALLOC.

If it's becoming easier to trigger and thus interfering with trinity,
then I guess we shall have to do something about it.  Kirill tried one
approach that didn't work out, and we have so far both felt reluctant
to make the code uglier just to satisfy DEBUG_PAGEALLOC.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
