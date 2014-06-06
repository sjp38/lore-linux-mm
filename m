Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id E87E06B0098
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 14:26:15 -0400 (EDT)
Received: by mail-vc0-f180.google.com with SMTP id hq11so3548045vcb.11
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 11:26:15 -0700 (PDT)
Received: from mail-ve0-x22e.google.com (mail-ve0-x22e.google.com [2607:f8b0:400c:c01::22e])
        by mx.google.com with ESMTPS id x1si7086454vem.40.2014.06.06.11.26.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 11:26:15 -0700 (PDT)
Received: by mail-ve0-f174.google.com with SMTP id us18so1569910veb.19
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 11:26:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140606174317.GA1741@redhat.com>
References: <20140606174317.GA1741@redhat.com>
Date: Fri, 6 Jun 2014 11:26:14 -0700
Message-ID: <CA+55aFxiOsceOsm7zYyvFAxDF3=gxUXj=_61Nce3VkELfJr7cg@mail.gmail.com>
Subject: Re: 3.15-rc8 oops in copy_page_rep after page fault.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>

On Fri, Jun 6, 2014 at 10:43 AM, Dave Jones <davej@redhat.com> wrote:
>
> RIP: 0010:[<ffffffff8b3287b5>]  [<ffffffff8b3287b5>] copy_page_rep+0x5/0x10

Ok, it's the first iteration of "rep movsq" (%rcx is still 0x200) for
copying a page, and the pages are

  RSI: ffff880052766000
  RDI: ffff880014efe000

which both look like reasonable kernel addresses. So I'm assuming it's
DEBUG_PAGEALLOC that makes this trigger, and since the error code is
0, and the CR2 value matches RSI, it's the source page that seems to
have been freed.

And I see absolutely _zero_ reason for wht your 64k mmap_min_addr
should make any difference what-so-ever. That's just odd.

Anyway, can you try to figure out _which_ copy_user_highpage() it is
(by looking at what is around the call-site at
"handle_mm_fault+0x1e0". The fact that we have a stale
do_huge_pmd_wp_page() on the stack makes me suspect that we have hit
that VM_FAULT_FALLBACK case and this is related to splitting. Adding a
few more people explicitly to the cc in case anybody sees anything
(original email on lkml and linux-mm for context, guys).

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
