Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 195706B009E
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 14:53:45 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id i50so5322911qgf.31
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 11:53:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t4si14572311qar.58.2014.06.06.11.53.44
        for <linux-mm@kvack.org>;
        Fri, 06 Jun 2014 11:53:44 -0700 (PDT)
Date: Fri, 6 Jun 2014 14:39:33 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: 3.15-rc8 oops in copy_page_rep after page fault.
Message-ID: <20140606183933.GA6636@redhat.com>
References: <20140606174317.GA1741@redhat.com>
 <CA+55aFxiOsceOsm7zYyvFAxDF3=gxUXj=_61Nce3VkELfJr7cg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxiOsceOsm7zYyvFAxDF3=gxUXj=_61Nce3VkELfJr7cg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>

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

I did some further experimenting.  With it set to 4k it ran for a while
until I got bored. With it set to 8k I saw the crash above, but it took
longer to happen.  With 64k it takes seconds to reproduce.
It might just be coincidental due to the way what mmaps trinity tries
succeed/fail, but it is curious.

 > Anyway, can you try to figure out _which_ copy_user_highpage() it is
 > (by looking at what is around the call-site at
 > "handle_mm_fault+0x1e0". The fact that we have a stale
 > do_huge_pmd_wp_page() on the stack makes me suspect that we have hit
 > that VM_FAULT_FALLBACK case and this is related to splitting. Adding a
 > few more people explicitly to the cc in case anybody sees anything
 > (original email on lkml and linux-mm for context, guys).

full disasm at http://codemonkey.org.uk/junk/memory.S.txt

handle_mm_fault+0x1e0 looks to be 0x49f0 which is..

			if (dirty && !pmd_write(orig_pmd)) {
				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
    49d8:	4d 89 f8             	mov    %r15,%r8
    49db:	48 89 d9             	mov    %rbx,%rcx
    49de:	4c 89 e2             	mov    %r12,%rdx
    49e1:	44 89 55 d0          	mov    %r10d,-0x30(%rbp)
    49e5:	4c 89 ee             	mov    %r13,%rsi
    49e8:	4c 89 f7             	mov    %r14,%rdi
    49eb:	e8 00 00 00 00       	callq  49f0 <handle_mm_fault+0x1e0>
							  orig_pmd);
				if (!(ret & VM_FAULT_FALLBACK))
    49f0:	44 8b 55 d0          	mov    -0x30(%rbp),%r10d
    49f4:	f6 c4 08             	test   $0x8,%ah
    49f7:	41 89 c3             	mov    %eax,%r11d
    49fa:	0f 84 5e ff ff ff    	je     495e <handle_mm_fault+0x14e>
    4a00:	48 8b 03             	mov    (%rbx),%rax

which seems to concur with your VM_FAULT_FALLBACK theory.

	Dave



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
