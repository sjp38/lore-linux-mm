Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6BB6E6B009C
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 14:49:33 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id bs8so1520954wib.0
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 11:49:32 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.230])
        by mx.google.com with ESMTP id c9si18914120wja.128.2014.06.06.11.49.31
        for <linux-mm@kvack.org>;
        Fri, 06 Jun 2014 11:49:32 -0700 (PDT)
Date: Fri, 6 Jun 2014 21:49:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: 3.15-rc8 oops in copy_page_rep after page fault.
Message-ID: <20140606184926.GA16083@node.dhcp.inet.fi>
References: <20140606174317.GA1741@redhat.com>
 <CA+55aFxiOsceOsm7zYyvFAxDF3=gxUXj=_61Nce3VkELfJr7cg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxiOsceOsm7zYyvFAxDF3=gxUXj=_61Nce3VkELfJr7cg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>

On Fri, Jun 06, 2014 at 11:26:14AM -0700, Linus Torvalds wrote:
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

Looks like a known false positive from DEBUG_PAGEALLOC:

https://lkml.org/lkml/2013/3/29/103

We huge copy page in do_huge_pmd_wp_page() without ptl taken and the page
can be splitted and freed under us. Once page is copied we take ptl again
and recheck that PMD is not changed. If changed, we don't use new page.
Not a bug, never triggered with DEBUG_PAGEALLOC disabled.

It would be nice to have a way to mark this kind of speculative access.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
