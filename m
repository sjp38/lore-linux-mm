Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 83BE46B0003
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 17:25:25 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id p5-v6so33986pfh.11
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 14:25:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f191-v6sor7329pfc.144.2018.08.01.14.25.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 14:25:24 -0700 (PDT)
Date: Thu, 2 Aug 2018 00:25:18 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Linux 4.18-rc7
Message-ID: <20180801212518.jjdwf53p3sj4b455@kshutemo-mobl1>
References: <alpine.LSU.2.11.1807301940460.5904@eggly.anvils>
 <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com>
 <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
 <20180731170328.ocb5oikwhwtkyzrj@kshutemo-mobl1>
 <20180731174349.GA12944@agluck-desk>
 <CA+55aFxJpJvcYKos-sVTsn9q4wK0-m4up1SXrcqfbXHKxaKxjg@mail.gmail.com>
 <CA+55aFz0eKks=v872LA-tDx4qcmBtxTYXbeztZcWbgx6SeQHNg@mail.gmail.com>
 <20180801205156.zv45fcveexwa2dqs@kshutemo-mobl1>
 <CA+55aFzDxsUU8jUyJN7J35TfeUh7n2xRDjEbW-A-2Fq1CDYQ0w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzDxsUU8jUyJN7J35TfeUh7n2xRDjEbW-A-2Fq1CDYQ0w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Amit Pundir <amit.pundir@linaro.org>, John Stultz <john.stultz@linaro.org>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling 257 <youling257@gmail.com>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

On Wed, Aug 01, 2018 at 01:56:19PM -0700, Linus Torvalds wrote:
> On Wed, Aug 1, 2018 at 1:52 PM Kirill A. Shutemov <kirill@shutemov.name> wrote:
> >
> > Is there a reason why we pass vma to flush_tlb_range?
> 
> Yes. It's even in that patch.
> 
> The fact is, real MM users *have* a vma, and passing it in to the TLB
> flushing is the right thing to do. That allows architectures that care
> (mainly powerpc, I think) to notice that "hey, this range only had
> execute permissions, so I only need to flush the ITLB".
> 
> The people who use tlb_flush_range() any other way are doing an
> arch-specific hack.  It's not how tlb_flush_range() was defined, and
> it's not how you can use it in general.

Okay, I see.

ARM, unicore32 and xtensa avoid iTLB flush for non-executable VMAs.

> 
> > It's not obvious to me what information from VMA can be useful for an
> > implementation.
> 
> See the patch I sent, which had this as part of it:
> 
> -                * XXX fix me: flush_tlb_range() should take an mm
> pointer instead of a
> -                * vma pointer.
> +                * flush_tlb_range() takes a vma instead of a mm pointer because
> +                * some architectures want the vm_flags for ITLB/DTLB flush.
> 
> because I wanted to educate people about why the interface was what it
> was, and the "fixme" was bogus shit.

I didn't noticied this. Sorry.

-- 
 Kirill A. Shutemov
