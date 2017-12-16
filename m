Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2806D6B0261
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 21:49:08 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id r20so5901021wrg.23
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 18:49:08 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id d4si6055495wrc.518.2017.12.15.18.49.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 18:49:06 -0800 (PST)
Date: Sat, 16 Dec 2017 02:48:24 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Message-ID: <20171216024824.GK21978@ZenIV.linux.org.uk>
References: <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com>
 <20171214205450.GI3326@worktop>
 <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com>
 <CA+55aFyA1+_hnqKO11gVNTo7RV6d9qygC-p8yiAzFMb=9aR5-A@mail.gmail.com>
 <20171215075147.nzpsmb7asyr6etig@hirez.programming.kicks-ass.net>
 <CA+55aFxdHSYYA0HOctCXeqLMjku8WjuAcddCGR_Lr5sOfca10Q@mail.gmail.com>
 <CAPcyv4hFCHGNadbMv8iTsLqbWm9rkBc7ww-Zax9tjaMJGrXu+w@mail.gmail.com>
 <CA+55aFz2aY-0hG1E_x7Don1pwgDQkHZfP2J3qW+QbvcvLBWTNQ@mail.gmail.com>
 <629d90d9-df33-2c31-e644-0bc356b61f25@intel.com>
 <CA+55aFxcA4Ht2urZY+ZvaTHKDjOHH5NqPWHCrvZYnsG=EOx4jQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxcA4Ht2urZY+ZvaTHKDjOHH5NqPWHCrvZYnsG=EOx4jQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Dec 15, 2017 at 06:28:36PM -0800, Linus Torvalds wrote:
> On Fri, Dec 15, 2017 at 5:25 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> >
> > I think the reason we needed VMA and PTE checks was the
> > get_user_pages_fast() path not having a VMA.
> 
> That is indeed the point of get_user_pages_fast(): no vma lookup, no
> locking, just "do the default case as streamlined as possible".
> 
> But part of it is also that we should fall back to the slow case if
> the fast case doesn't work (eg because the page isn't there or
> whatever).
> 
> So what we could do - perhaps - is to just make get_user_pages_fast()
> check whether any of the protection key bits are set, and fail for
> that case.

FWIW, a good description of fast path in get_user_pages_fast() is
"simulate a TLB miss", the slow path being "... and go for simulated
page fault if TLB miss would have escalated to #PF".

Treating protection key bits as "escalate to page fault and let that
deal with the checks" should be fine - page fault handler must
cope with the page actually being present in page tables anyway, for
obvious reasons...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
