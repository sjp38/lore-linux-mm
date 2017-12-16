Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C0DEB6B025E
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 22:21:47 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u3so9331295pfl.5
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 19:21:47 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id a5si5423074plh.609.2017.12.15.19.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 19:21:46 -0800 (PST)
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
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
 <20171216024824.GK21978@ZenIV.linux.org.uk>
 <CA+55aFzehO00PH-WQuHJroRddiRMyLhO66b4Cv2sJA=7D2CeAw@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <d205cddd-33bc-029c-a004-bc74d82853a5@intel.com>
Date: Fri, 15 Dec 2017 19:21:45 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFzehO00PH-WQuHJroRddiRMyLhO66b4Cv2sJA=7D2CeAw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Dan Williams <dan.j.williams@intel.com>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 12/15/2017 06:52 PM, Linus Torvalds wrote:
> On Fri, Dec 15, 2017 at 6:48 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>> Treating protection key bits as "escalate to page fault and let that
>> deal with the checks" should be fine
> 
> Well, it's *semantically* fine and I think it's the right model from
> that standpoint.

It's _close_ to fine.  :)

Practically, we're going to have two classes of things in the world:
1. Things that are protected with protection keys and have non-zero bits
   in the pkey PTE bits.
2. Things that are _not_ protected will have zeros in there.

But, in the hardware, *everything* has a pkey.  0 is the default,
obviously, but the hardware treats it the same as all the other values.
So, if we go checking for the "pkey bits being set", and have behavior
diverge when they are set, we end up with pkey=0 being even more special
compared to the rest.

This might be OK, but it's going to be interesting to document and write
tests for it.  I'm already dreading the manpage updates.

> However, since the main use case of protection keys is probably
> databases (Dave?) and since those also might be performance-sensitive
> about direct-IO doing page table lookups, it might not be great in
> practice.

Yeah, databases are definitely the heavy-hitters that care about it.

But, these PKRU checks are cheap.  I forget the actual cycle counts, but
I remember thinking that it's pretty darn cheap to read PKRU.  In the
grand scheme of doing a page table walk and incrementing an atomic, it's
surely in the noise for direct I/O to large pages, which is basically
guaranteed for the database guys.

I did some get_user_pages() torture tests (on small pages IIRC) before I
put the code in and could not detect a delta from the code being there
or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
