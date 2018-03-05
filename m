Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B08AF6B0006
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:47:41 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m18so743295pgu.14
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:47:41 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m1-v6si9673403plb.777.2018.03.05.11.47.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 05 Mar 2018 11:47:40 -0800 (PST)
Date: Mon, 5 Mar 2018 11:47:28 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
Message-ID: <20180305194728.GB10418@bombadil.infradead.org>
References: <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
 <20180228183349.GA16336@bombadil.infradead.org>
 <CA+DvKQKoo1U7T_iOOLhfEf9c+K1pzD068au+kGtx0RokFFNKHw@mail.gmail.com>
 <2CF957C6-53F2-4B00-920F-245BEF3CA1F6@gmail.com>
 <CA+DvKQ+mrnm4WX+3cBPuoSLFHmx2Zwz8=FsEx51fH-7yQMAd9w@mail.gmail.com>
 <20180304034704.GB20725@bombadil.infradead.org>
 <20180304205614.GC23816@bombadil.infradead.org>
 <7FA6631B-951F-42F4-A7BF-8E5BB734D709@gmail.com>
 <20180305162343.GA8230@bombadil.infradead.org>
 <EC4E37F1-C2B8-4112-8EAD-FF072602DD08@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <EC4E37F1-C2B8-4112-8EAD-FF072602DD08@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilya Smith <blackzert@gmail.com>
Cc: Daniel Micay <danielmicay@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Mon, Mar 05, 2018 at 10:27:32PM +0300, Ilya Smith wrote:
> > On 5 Mar 2018, at 19:23, Matthew Wilcox <willy@infradead.org> wrote:
> > On Mon, Mar 05, 2018 at 04:09:31PM +0300, Ilya Smith wrote:
> >> Ia??m analysing that approach and see much more problems:
> >> - each time you call mmap like this, you still  increase count of vmas as my 
> >> patch did
> > 
> > Umm ... yes, each time you call mmap, you get a VMA.  I'm not sure why
> > that's a problem with my patch.  I was trying to solve the problem Daniel
> > pointed out, that mapping a guard region after each mmap cost twice as
> > many VMAs, and it solves that problem.
> > 
> The issue was in VMAs count as Daniel mentioned. 
> The more count, the harder walk tree. I think this is fine

The performance problem Daniel was mentioning with your patch was not
with the number of VMAs but with the scattering of addresses across the
page table tree.

> >> - the entropy you provide is like 16 bit, that is really not so hard to brute
> > 
> > It's 16 bits per mapping.  I think that'll make enough attacks harder
> > to be worthwhile.
> 
> Well yes, its ok, sorry. I just would like to have 32 bit entropy maximum some day :)

We could put 32 bits of padding into the prot argument on 64-bit systems
(and obviously you need a 64-bit address space to use that many bits).  The
thing is that you can't then put anything else into those pages (without
using MAP_FIXED).

> >> - if you unmap/remap one page inside region, field vma_guard will show head 
> >> or tail pages for vma, not both; kernel dona??t know how to handle it
> > 
> > There are no head pages.  The guard pages are only placed after the real end.
> 
> Ok, we have MG where G = vm_guard, right? so when you do vm_split, 
> you may come to situation - m1g1m2G, how to handle it? I mean when M is 
> split with only one page inside this region. How to handle it?

I thought I covered that in my earlier email.  Using one letter per page,
and a five-page mapping with two guard pages: MMMMMGG.  Now unmap the
fourth page, and the VMA gets split into two.  You get: MMMGMGG.

> > I can't agree with that.  The user has plenty of opportunities to get
> > randomness; from /dev/random is the easiest, but you could also do timing
> > attacks on your own cachelines, for example.
> 
> I think the usual case to use randomization for any mmap or not use it at all 
> for whole process. So here I think would be nice to have some variable 
> changeable with sysctl (root only) and ioctl (for greedy processes).

I think this functionality can just as well live inside libc as in
the kernel.

> Well, let me summary:
> My approach chose random gap inside gap range with following strings:
> 
> +	addr = get_random_long() % ((high - low) >> PAGE_SHIFT);
> +	addr = low + (addr << PAGE_SHIFT);
> 
> Could be improved limiting maximum possible entropy in this shift.
> To prevent situation when attacker may massage allocations and 
> predict chosen address, I randomly choose memory region. Ia??m still
> like my idea, but not going to push it anymore, since you have yours now.
> 
> Your idea just provide random non-mappable and non-accessable offset
> from best-fit region. This consumes memory (1GB gap if random value 
> is 0xffff). But it works and should work faster and should resolve the issue.

umm ... 64k * 4k is a 256MB gap, not 1GB.  And it consumes address space,
not memory.

> My point was that current implementation need to be changed and you
> have your own approach for that. :)
> Lets keep mine in the mind till better times (or worse?) ;)
> Will you finish your approach and upstream it?

I'm just putting it out there for discussion.  If people think this is
the right approach, then I'm happy to finish it off.  If the consensus
is that we should randomly pick addresses instead, I'm happy if your
approach gets merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
