Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E90946B0005
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:23:50 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u188so9962233pfb.6
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:23:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l61-v6si9535519plb.95.2018.03.05.08.23.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 05 Mar 2018 08:23:49 -0800 (PST)
Date: Mon, 5 Mar 2018 08:23:43 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
Message-ID: <20180305162343.GA8230@bombadil.infradead.org>
References: <20180227131338.3699-1-blackzert@gmail.com>
 <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
 <20180228183349.GA16336@bombadil.infradead.org>
 <CA+DvKQKoo1U7T_iOOLhfEf9c+K1pzD068au+kGtx0RokFFNKHw@mail.gmail.com>
 <2CF957C6-53F2-4B00-920F-245BEF3CA1F6@gmail.com>
 <CA+DvKQ+mrnm4WX+3cBPuoSLFHmx2Zwz8=FsEx51fH-7yQMAd9w@mail.gmail.com>
 <20180304034704.GB20725@bombadil.infradead.org>
 <20180304205614.GC23816@bombadil.infradead.org>
 <7FA6631B-951F-42F4-A7BF-8E5BB734D709@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7FA6631B-951F-42F4-A7BF-8E5BB734D709@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilya Smith <blackzert@gmail.com>
Cc: Daniel Micay <danielmicay@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Mon, Mar 05, 2018 at 04:09:31PM +0300, Ilya Smith wrote:
> > On 4 Mar 2018, at 23:56, Matthew Wilcox <willy@infradead.org> wrote:
> > Thinking about this more ...
> > 
> > - When you call munmap, if you pass in the same (addr, length) that were
> >   used for mmap, then it should unmap the guard pages as well (that
> >   wasn't part of the patch, so it would have to be added)
> > - If 'addr' is higher than the mapped address, and length at least
> >   reaches the end of the mapping, then I would expect the guard pages to
> >   "move down" and be after the end of the newly-shortened mapping.
> > - If 'addr' is higher than the mapped address, and the length doesn't
> >   reach the end of the old mapping, we split the old mapping into two.
> >   I would expect the guard pages to apply to both mappings, insofar as
> >   they'll fit.  For an example, suppose we have a five-page mapping with
> >   two guard pages (MMMMMGG), and then we unmap the fourth page.  Now we
> >   have a three-page mapping with one guard page followed immediately
> >   by a one-page mapping with two guard pages (MMMGMGG).
> 
> Ia??m analysing that approach and see much more problems:
> - each time you call mmap like this, you still  increase count of vmas as my 
> patch did

Umm ... yes, each time you call mmap, you get a VMA.  I'm not sure why
that's a problem with my patch.  I was trying to solve the problem Daniel
pointed out, that mapping a guard region after each mmap cost twice as
many VMAs, and it solves that problem.

> - now feature vma_merge shouldna??t work at all, until MAP_FIXED is set or
> PROT_GUARD(0)

That's true.

> - the entropy you provide is like 16 bit, that is really not so hard to brute

It's 16 bits per mapping.  I think that'll make enough attacks harder
to be worthwhile.

> - in your patch you dona??t use vm_guard at address searching, I see many roots 
> of bugs here

Don't need to.  vm_end includes the guard pages.

> - if you unmap/remap one page inside region, field vma_guard will show head 
> or tail pages for vma, not both; kernel dona??t know how to handle it

There are no head pages.  The guard pages are only placed after the real end.

> - user mode now choose entropy with PROT_GUARD macro, where did he gets it? 
> User mode shouldna??t be responsible for entropy at all

I can't agree with that.  The user has plenty of opportunities to get
randomness; from /dev/random is the easiest, but you could also do timing
attacks on your own cachelines, for example.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
