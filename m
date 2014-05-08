Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f50.google.com (mail-oa0-f50.google.com [209.85.219.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3646B00FC
	for <linux-mm@kvack.org>; Thu,  8 May 2014 12:03:18 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id i7so3329546oag.23
        for <linux-mm@kvack.org>; Thu, 08 May 2014 09:03:17 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ov9si739933pbc.170.2014.05.08.09.03.16
        for <linux-mm@kvack.org>;
        Thu, 08 May 2014 09:03:17 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CAMSv6X0+3-uNeiyEPD3sA5dA6Af_M+BT0aeVpa3qMv1aga0q9g@mail.gmail.com>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CAMSv6X0+3-uNeiyEPD3sA5dA6Af_M+BT0aeVpa3qMv1aga0q9g@mail.gmail.com>
Subject: Re: [PATCHv2 0/2] remap_file_pages() decommission
Content-Transfer-Encoding: 7bit
Message-Id: <20140508160205.A0EC7E009B@blue.fi.intel.com>
Date: Thu,  8 May 2014 19:02:05 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Armin Rigo <arigo@tunes.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org

Armin Rigo wrote:
> Hi everybody,
> 
> Here is a note from the PyPy project (mentioned earlier in this
> thread, and at https://lwn.net/Articles/587923/ ).
> 
> Yes, we use remap_file_pages() heavily on the x86-64 architecture.
> However, the individual calls to remap_file_pages() are not
> performance-critical, so it is easy to switch to using multiple
> mmap()s.  We need to perform more measurements to know exactly what
> the overhead would be, in terms notably of kernel memory.
> 
> However, an issue with that approach is the upper bound on the number
> of VMAs.  By default, it is not large enough.  Right now, it is
> possible to remap say 10% of the individual pages from an anonymous
> mmap of multiple GBs in size; but doing so with individual calls to
> mmap hits this arbitrary limit.

The limit is not totaly random. We use ELF format for coredumps and ELF has
limitation (16-bit field) on number of sections it can store.

With ELF extended numbering we can bypass 16-bit limit, but some userspace
can be surprised by that.

> I have no particular weight to give
> for or against keeping remap_file_pages() in the kernel, but if it is
> removed or emulated, it would be a plus if the programs would run on a
> machine with the default configuration --- i.e. if you remove or
> emulate remap_file_pages(), please increase the default limit as well.

It's fine to me. Andrew?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
