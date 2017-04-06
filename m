Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2248E6B0390
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 19:22:27 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id b10so52579163pgn.8
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 16:22:27 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d129si2960799pfc.335.2017.04.06.16.22.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 16:22:26 -0700 (PDT)
Date: Fri, 7 Apr 2017 02:21:37 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 8/8] x86/mm: Allow to have userspace mappings above
 47-bits
Message-ID: <20170406232137.uk7y2knbkcsru4pi@black.fi.intel.com>
References: <20170406140106.78087-1-kirill.shutemov@linux.intel.com>
 <20170406140106.78087-9-kirill.shutemov@linux.intel.com>
 <3cb79f4b-76f5-6e31-6973-e9281b2e4553@virtuozzo.com>
 <eaf4c954-e6c0-a9b4-50f1-49889dbd0f4b@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <eaf4c954-e6c0-a9b4-50f1-49889dbd0f4b@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Apr 06, 2017 at 10:15:47PM +0300, Dmitry Safonov wrote:
> On 04/06/2017 09:43 PM, Dmitry Safonov wrote:
> > Hi Kirill,
> > 
> > On 04/06/2017 05:01 PM, Kirill A. Shutemov wrote:
> > > On x86, 5-level paging enables 56-bit userspace virtual address space.
> > > Not all user space is ready to handle wide addresses. It's known that
> > > at least some JIT compilers use higher bits in pointers to encode their
> > > information. It collides with valid pointers with 5-level paging and
> > > leads to crashes.
> > > 
> > > To mitigate this, we are not going to allocate virtual address space
> > > above 47-bit by default.
> > > 
> > > But userspace can ask for allocation from full address space by
> > > specifying hint address (with or without MAP_FIXED) above 47-bits.
> > > 
> > > If hint address set above 47-bit, but MAP_FIXED is not specified, we try
> > > to look for unmapped area by specified address. If it's already
> > > occupied, we look for unmapped area in *full* address space, rather than
> > > from 47-bit window.
> > 
> > Do you wish after the first over-47-bit mapping the following mmap()
> > calls return also over-47-bits if there is free space?
> > It so, you could simplify all this code by changing only mm->mmap_base
> > on the first over-47-bit mmap() call.
> > This will do simple trick.

No.

I want every allocation to explicitely opt-in large address space. It's
additional fail-safe: if a library can't handle large addresses it has
better chance to survive if its own allocation will stay within 47-bits.

> I just tried to define it like this:
> -#define DEFAULT_MAP_WINDOW     ((1UL << 47) - PAGE_SIZE)
> +#define DEFAULT_MAP_WINDOW     (test_thread_flag(TIF_ADDR32) ?         \
> +                               IA32_PAGE_OFFSET : ((1UL << 47) -
> PAGE_SIZE))
> 
> And it looks working better.

Okay, thanks. I'll send v2.

> > > +    if (addr > DEFAULT_MAP_WINDOW && !in_compat_syscall())
> > > +        info.high_limit += TASK_SIZE - DEFAULT_MAP_WINDOW;
> > 
> > Hmm, TASK_SIZE depends now on TIF_ADDR32, which is set during exec().
> > That means for ia32/x32 ELF which has TASK_SIZE < 4Gb as TIF_ADDR32
> > is set, which can do 64-bit syscalls - the subtraction will be
> > a negative..

With your proposed change to DEFAULT_MAP_WINDOW difinition it should be
okay, right?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
