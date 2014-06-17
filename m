Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 500DC6B0036
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 16:32:51 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kq14so2874299pab.6
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 13:32:51 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ql2si15591580pbb.240.2014.06.17.13.32.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 13:32:50 -0700 (PDT)
Message-ID: <53A0A5AF.3000509@oracle.com>
Date: Tue, 17 Jun 2014 16:31:43 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: 3.15-rc8 oops in copy_page_rep after page fault.
References: <20140606174317.GA1741@redhat.com> <CA+55aFxiOsceOsm7zYyvFAxDF3=gxUXj=_61Nce3VkELfJr7cg@mail.gmail.com> <20140606184926.GA16083@node.dhcp.inet.fi> <5392108F.8060405@oracle.com> <alpine.LSU.2.11.1406151957560.5820@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1406151957560.5820@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>

On 06/15/2014 11:01 PM, Hugh Dickins wrote:
> On Fri, 6 Jun 2014, Sasha Levin wrote:
>> > On 06/06/2014 02:49 PM, Kirill A. Shutemov wrote:
>>> > > On Fri, Jun 06, 2014 at 11:26:14AM -0700, Linus Torvalds wrote:
>>>>> > >> > On Fri, Jun 6, 2014 at 10:43 AM, Dave Jones <davej@redhat.com> wrote:
>>>>>>> > >>> > >
>>>>>>> > >>> > > RIP: 0010:[<ffffffff8b3287b5>]  [<ffffffff8b3287b5>] copy_page_rep+0x5/0x10
>>>>> > >> > 
>>>>> > >> > Ok, it's the first iteration of "rep movsq" (%rcx is still 0x200) for
>>>>> > >> > copying a page, and the pages are
>>>>> > >> > 
>>>>> > >> >   RSI: ffff880052766000
>>>>> > >> >   RDI: ffff880014efe000
>>>>> > >> > 
>>>>> > >> > which both look like reasonable kernel addresses. So I'm assuming it's
>>>>> > >> > DEBUG_PAGEALLOC that makes this trigger, and since the error code is
>>>>> > >> > 0, and the CR2 value matches RSI, it's the source page that seems to
>>>>> > >> > have been freed.
>>>>> > >> > 
>>>>> > >> > And I see absolutely _zero_ reason for wht your 64k mmap_min_addr
>>>>> > >> > should make any difference what-so-ever. That's just odd.
>>>>> > >> > 
>>>>> > >> > Anyway, can you try to figure out _which_ copy_user_highpage() it is
>>>>> > >> > (by looking at what is around the call-site at
>>>>> > >> > "handle_mm_fault+0x1e0". The fact that we have a stale
>>>>> > >> > do_huge_pmd_wp_page() on the stack makes me suspect that we have hit
>>>>> > >> > that VM_FAULT_FALLBACK case and this is related to splitting. Adding a
>>>>> > >> > few more people explicitly to the cc in case anybody sees anything
>>>>> > >> > (original email on lkml and linux-mm for context, guys).
>>> > > Looks like a known false positive from DEBUG_PAGEALLOC:
>>> > > 
>>> > > https://lkml.org/lkml/2013/3/29/103
>>> > > 
>>> > > We huge copy page in do_huge_pmd_wp_page() without ptl taken and the page
>>> > > can be splitted and freed under us. Once page is copied we take ptl again
>>> > > and recheck that PMD is not changed. If changed, we don't use new page.
>>> > > Not a bug, never triggered with DEBUG_PAGEALLOC disabled.
>>> > > 
>>> > > It would be nice to have a way to mark this kind of speculative access.
>> > 
>> > FWIW, this issue makes fuzzing with DEBUG_PAGEALLOC nearly impossible since
>> > this thing is so common we never get to do anything "fun" before this issue
>> > triggers.
>> > 
>> > A fix would be more than welcome.
> Please give this a try: I think it's right, but I could easily be wrong.
> 
> 
> [PATCH] thp: fix DEBUG_PAGEALLOC oops in copy_page_rep
> 
> Trinity has for over a year been reporting a CONFIG_DEBUG_PAGEALLOC
> oops in copy_page_rep() called from copy_user_huge_page() called from
> do_huge_pmd_wp_page().
> 
> I believe this is a DEBUG_PAGEALLOC false positive, due to the source
> page being split, and a tail page freed, while copy is in progress; and
> not a problem without DEBUG_PAGEALLOC, since the pmd_same() check will
> prevent a miscopy from being made visible.
> 
> Fix by adding get_user_huge_page() and put_user_huge_page(): reducing
> to the usual get_page() and put_page() on head page in the usual config;
> but get and put references to all of the tail pages when DEBUG_PAGEALLOC.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Works great, thanks Hugh!


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
