Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 885C86B025E
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 13:32:25 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q3so1919856pgv.16
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 10:32:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d30si1729501pld.747.2017.12.13.10.32.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 10:32:24 -0800 (PST)
Date: Wed, 13 Dec 2017 19:32:09 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Message-ID: <20171213183209.GZ3165@worktop.lehotels.local>
References: <20171212173221.496222173@linutronix.de>
 <20171212173333.669577588@linutronix.de>
 <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
 <20171213122211.bxcb7xjdwla2bqol@hirez.programming.kicks-ass.net>
 <20171213125739.fllckbl3o4nonmpx@node.shutemov.name>
 <b303fac7-34af-5065-f996-4494fb8c09a2@intel.com>
 <20171213153202.qtxnloxoc66lhsbf@hirez.programming.kicks-ass.net>
 <e6ef40c8-8966-c973-3ae4-ac9475699e40@intel.com>
 <20171213155427.p24i2xdh2s65e4d2@hirez.programming.kicks-ass.net>
 <CA+55aFw0JTRDXked3_OJ+cFx59BE18yDWOt7-ZRTzFS10zYnrg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw0JTRDXked3_OJ+cFx59BE18yDWOt7-ZRTzFS10zYnrg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>

On Wed, Dec 13, 2017 at 10:08:30AM -0800, Linus Torvalds wrote:
> On Wed, Dec 13, 2017 at 7:54 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > Which is why get_user_pages() _should_ enforce this.
> >
> > What use are protection keys if you can trivially circumvent them?
> 
> No, we will *not* worry about protection keys in get_user_pages().
> 
> They are not "security". They are a debug aid and safety against random mis-use.
> 
> In particular, they are very much *NOT* about "trivially circumvent
> them". The user could just change their mapping thing, for chrissake!
> 
> We already allow access to PROT_NONE for gdb and friends, very much on purpose.
> 
> We're not going to make the VM more complex for something that
> absolutely nobody cares about, and has zero security issues.

OK, that might have been my phrasing that was off -- mostly because I
was looking at it from the VM_NOUSER angle, but currently:

  - gup_pte_range() has pte_access_permitted()

  - follow_page_pte() has pte_access_permitted() for FOLL_WRITE only

All I'm saying is that that is inconsistent and we should change
follow_page_pte() to use pte_access_permitted() for FOLL_GET, such that
__get_user_pages_fast() and __get_user_pages() have matching semantics.

Now, if VM_NOUSER were to live, the above change would ensure write(2)
cannot read from such VMAs, where the existing test for FOLL_WRITE
already disallows read(2) from writing to them.

But even without VM_NOUSER it makes the VM more consistent than it is
today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
