Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 547526B0005
	for <linux-mm@kvack.org>; Sun,  4 Mar 2018 15:56:34 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v3so5178968pfm.21
        for <linux-mm@kvack.org>; Sun, 04 Mar 2018 12:56:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u8-v6si8293532plh.219.2018.03.04.12.56.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 04 Mar 2018 12:56:33 -0800 (PST)
Date: Sun, 4 Mar 2018 12:56:14 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
Message-ID: <20180304205614.GC23816@bombadil.infradead.org>
References: <20180227131338.3699-1-blackzert@gmail.com>
 <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
 <20180228183349.GA16336@bombadil.infradead.org>
 <CA+DvKQKoo1U7T_iOOLhfEf9c+K1pzD068au+kGtx0RokFFNKHw@mail.gmail.com>
 <2CF957C6-53F2-4B00-920F-245BEF3CA1F6@gmail.com>
 <CA+DvKQ+mrnm4WX+3cBPuoSLFHmx2Zwz8=FsEx51fH-7yQMAd9w@mail.gmail.com>
 <20180304034704.GB20725@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180304034704.GB20725@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Ilya Smith <blackzert@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Sat, Mar 03, 2018 at 07:47:04PM -0800, Matthew Wilcox wrote:
> On Sat, Mar 03, 2018 at 04:00:45PM -0500, Daniel Micay wrote:
> > The main thing I'd like to see is just the option to get a guarantee
> > of enforced gaps around mappings, without necessarily even having
> > randomization of the gap size. It's possible to add guard pages in
> > userspace but it adds overhead by doubling the number of system calls
> > to map memory (mmap PROT_NONE region, mprotect the inner portion to
> > PROT_READ|PROT_WRITE) and *everything* using mmap would need to
> > cooperate which is unrealistic.
> 
> So something like this?
> 
> To use it, OR in PROT_GUARD(n) to the PROT flags of mmap, and it should
> pad the map by n pages.  I haven't tested it, so I'm sure it's buggy,
> but it seems like a fairly cheap way to give us padding after every
> mapping.
> 
> Running it on an old kernel will result in no padding, so to see if it
> worked or not, try mapping something immediately after it.

Thinking about this more ...

 - When you call munmap, if you pass in the same (addr, length) that were
   used for mmap, then it should unmap the guard pages as well (that
   wasn't part of the patch, so it would have to be added)
 - If 'addr' is higher than the mapped address, and length at least
   reaches the end of the mapping, then I would expect the guard pages to
   "move down" and be after the end of the newly-shortened mapping.
 - If 'addr' is higher than the mapped address, and the length doesn't
   reach the end of the old mapping, we split the old mapping into two.
   I would expect the guard pages to apply to both mappings, insofar as
   they'll fit.  For an example, suppose we have a five-page mapping with
   two guard pages (MMMMMGG), and then we unmap the fourth page.  Now we
   have a three-page mapping with one guard page followed immediately
   by a one-page mapping with two guard pages (MMMGMGG).

I would say that mremap cannot change the number of guard pages.
Although I'm a little tempted to add an mremap flag to permit the mapping
to expand into the guard pages.  That would give us a nice way to reserve
address space for a mapping we think is going to expand.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
