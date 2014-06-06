Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id E309F6B00A0
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 15:08:13 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id up15so2833039pbc.16
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 12:08:13 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ah1si21169676pbc.97.2014.06.06.12.08.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 12:08:13 -0700 (PDT)
Message-ID: <5392108F.8060405@oracle.com>
Date: Fri, 06 Jun 2014 15:03:43 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: 3.15-rc8 oops in copy_page_rep after page fault.
References: <20140606174317.GA1741@redhat.com> <CA+55aFxiOsceOsm7zYyvFAxDF3=gxUXj=_61Nce3VkELfJr7cg@mail.gmail.com> <20140606184926.GA16083@node.dhcp.inet.fi>
In-Reply-To: <20140606184926.GA16083@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>

On 06/06/2014 02:49 PM, Kirill A. Shutemov wrote:
> On Fri, Jun 06, 2014 at 11:26:14AM -0700, Linus Torvalds wrote:
>> > On Fri, Jun 6, 2014 at 10:43 AM, Dave Jones <davej@redhat.com> wrote:
>>> > >
>>> > > RIP: 0010:[<ffffffff8b3287b5>]  [<ffffffff8b3287b5>] copy_page_rep+0x5/0x10
>> > 
>> > Ok, it's the first iteration of "rep movsq" (%rcx is still 0x200) for
>> > copying a page, and the pages are
>> > 
>> >   RSI: ffff880052766000
>> >   RDI: ffff880014efe000
>> > 
>> > which both look like reasonable kernel addresses. So I'm assuming it's
>> > DEBUG_PAGEALLOC that makes this trigger, and since the error code is
>> > 0, and the CR2 value matches RSI, it's the source page that seems to
>> > have been freed.
>> > 
>> > And I see absolutely _zero_ reason for wht your 64k mmap_min_addr
>> > should make any difference what-so-ever. That's just odd.
>> > 
>> > Anyway, can you try to figure out _which_ copy_user_highpage() it is
>> > (by looking at what is around the call-site at
>> > "handle_mm_fault+0x1e0". The fact that we have a stale
>> > do_huge_pmd_wp_page() on the stack makes me suspect that we have hit
>> > that VM_FAULT_FALLBACK case and this is related to splitting. Adding a
>> > few more people explicitly to the cc in case anybody sees anything
>> > (original email on lkml and linux-mm for context, guys).
> Looks like a known false positive from DEBUG_PAGEALLOC:
> 
> https://lkml.org/lkml/2013/3/29/103
> 
> We huge copy page in do_huge_pmd_wp_page() without ptl taken and the page
> can be splitted and freed under us. Once page is copied we take ptl again
> and recheck that PMD is not changed. If changed, we don't use new page.
> Not a bug, never triggered with DEBUG_PAGEALLOC disabled.
> 
> It would be nice to have a way to mark this kind of speculative access.

FWIW, this issue makes fuzzing with DEBUG_PAGEALLOC nearly impossible since
this thing is so common we never get to do anything "fun" before this issue
triggers.

A fix would be more than welcome.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
