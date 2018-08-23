Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 640A56B2809
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 00:16:52 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g12-v6so1937270plo.1
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 21:16:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5-v6sor908359pgc.408.2018.08.22.21.16.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 21:16:51 -0700 (PDT)
Date: Thu, 23 Aug 2018 14:16:42 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/4] mm/tlb: Remove tlb_remove_table() non-concurrent
 condition
Message-ID: <20180823141642.38b53175@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFyY4fG8Hhds4ykSm5vUMdxbLdB7mYmC2pOPk8UKBXtpjA@mail.gmail.com>
References: <20180822153012.173508681@infradead.org>
	<20180822154046.772017055@infradead.org>
	<20180823133103.30d6a16b@roar.ozlabs.ibm.com>
	<CA+55aFyY4fG8Hhds4ykSm5vUMdxbLdB7mYmC2pOPk8UKBXtpjA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, 22 Aug 2018 20:35:16 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Aug 22, 2018 at 8:31 PM Nicholas Piggin <npiggin@gmail.com> wrote:
> >
> >
> > So that leaves speculative operations. I don't see where the problem is
> > with those either -- this shortcut needs to ensure there are no other
> > *non speculative* operations. mm_users is correct for that.  
> 
> No. Because mm_users doesn't contain any lazy tlb users.
> 
> And yes, those lazy tlbs are all kernel threads, but they can still
> speculatively load user addresses.

So?

If the arch does not shoot those all down after the user page tables
are removed then it's buggy regardless of this short cut.

The only real problem I could see would be if a page walk cache still
points to the freed table, then the table gets re-allocated and used
elsewhere, and meanwhile a speculative access tries to load an entry
from the page that is an invalid form of page table that might cause
a machine check or something. That would be (u)arch specific, but if
that's what we're concerned with here it's a different issue and needs
to be documented as such.

I'll have a look at powerpc and see if we can cope with it. If so, I'll
make it an arch specific opt-in short cut.

Thanks,
Nick
