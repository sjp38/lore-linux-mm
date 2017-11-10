Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E458E440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 20:26:44 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 4so5852252pge.8
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 17:26:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y24sor663584pll.125.2017.11.09.17.26.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Nov 2017 17:26:43 -0800 (PST)
Date: Fri, 10 Nov 2017 12:26:25 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
Message-ID: <20171110122625.4ea3c897@roar.ozlabs.ibm.com>
In-Reply-To: <20171109194421.GA12789@bombadil.infradead.org>
References: <d52581f4-8ca4-5421-0862-3098031e29a8@linux.vnet.ibm.com>
	<546d4155-5b7c-6dba-b642-29c103e336bc@redhat.com>
	<20171107160705.059e0c2b@roar.ozlabs.ibm.com>
	<20171107111543.ep57evfxxbwwlhdh@node.shutemov.name>
	<20171107222228.0c8a50ff@roar.ozlabs.ibm.com>
	<20171107122825.posamr2dmzlzvs2p@node.shutemov.name>
	<20171108002448.6799462e@roar.ozlabs.ibm.com>
	<2ce0a91c-985c-aad8-abfa-e91bc088bb3e@linux.vnet.ibm.com>
	<20171107140158.iz4b2lchhrt6eobe@node.shutemov.name>
	<20171110041526.6137bc9a@roar.ozlabs.ibm.com>
	<20171109194421.GA12789@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Florian Weimer <fweimer@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 9 Nov 2017 11:44:21 -0800
Matthew Wilcox <willy@infradead.org> wrote:

> On Fri, Nov 10, 2017 at 04:15:26AM +1100, Nicholas Piggin wrote:
> > So these semantics are what we're going with? Anything that does mmap() is
> > guaranteed of getting a 47-bit pointer and it can use the top 17 bits for
> > itself? Is intended to be cross-platform or just x86 and power specific?  
> 
> It is x86 and powerpc specific.  The arm64 people have apparently stumbled
> across apps that expect to be able to use bit 48 for their own purposes.
> And their address space is 48 bit by default.  Oops.

Okay, so it's something we should make into an "official" API?

> 
> > Also, this may follow from deduction from 1-3, but for explicit
> > specification in man page:
> > 
> > 4) To get an unspecified allocation with the largest possible address range,
> > we pass in -1 for mmap hint.
> > 
> > Are we allowing 8 bits bits of unused address in this case, or must the
> > app not assume anything about number of bits used?  
> 
> Maybe document it as: "If the app wants to use the top N bits of addresses
> for its own purposes, pass in (~0UL >> N) as the mmap hint."  ?

Well we don't have code for that yet, but the problem would also be that
it succeeds, and actually it probably goes over the limit. So you would
have to map a dummy page there so subsequent hints to fail and fall back.
Not sure... it would be nice to be able to specify number of bits, but I
think this gets a bit hairy. -1 to use all bits seems a bit easier.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
