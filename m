Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 278A24403DA
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 19:44:06 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y128so527474pfg.5
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 16:44:06 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id s186si2849921pgc.383.2017.10.31.16.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 16:44:05 -0700 (PDT)
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <9e45a167-3528-8f93-80bf-c333ae6acb71@linux.intel.com>
Date: Tue, 31 Oct 2017 16:44:03 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>

On 10/31/2017 04:27 PM, Linus Torvalds wrote:
> Inconveniently, the people you cc'd on the actual patches did *not*
> get cc'd with this 00/23 cover letter email.

Urg, sorry about that.

>  (a) is this on top of Andy's entry cleanups?
> 
>      If not, that probably needs to be sorted out.

It is not.  However, I did a version on top of his earlier cleanups, so
I know this can be easily ported on top of them.  It didn't make a major
difference in the number of places that KAISER had to patch, unfortunately.

>  (b) the TLB global bit really is nastily done. You basically disable
> _PAGE_GLOBAL entirely.
> 
>      I can see how/why that would make things simpler, but it's almost
> certainly the wrong approach. The small subset of kernel pages that
> are always mapped should definitely retain the global bit, so that you
> don't always take a TLB miss on those! Those are probably some of the
> most latency-critical pages, since there's generally no prefetching
> for the kernel entry code or for things like IDT/GDT accesses..
> 
>      So even if you don't want to have global pages for normal kernel
> entries, you don't want to just make _PAGE_GLOBAL be defined as zero.
> You'd want to just use _PAGE_GLOBAL conditionally.
> 
>      Hmm?

That's a good point.  Shouldn't be hard to implement at all.  We'll just
need to take _PAGE_GLOBAL out of the default _KERNPG_TABLE definition, I
think.

>  (c) am I reading the code correctly, and the shadow page tables are
> *completely* duplicated?
> 
>      That seems insane. Why isn't only tyhe top level shadowed, and
> then lower levels are shared between the shadowed and the "kernel"
> page tables?

There are obviously two PGDs.  The userspace half of the PGD is an exact
copy so all the lower levels are shared.  You can see this bit in the
memcpy that we do in clone_pgd_range().

For the kernel half, we don't share any of the lower levels.  That's
mostly because the stuff that we're mapping into the user/shadow copy is
only 4k aligned and (probably) never >2MB, so there's really no
opportunity to share.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
