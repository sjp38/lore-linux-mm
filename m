Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 12AFB28027D
	for <linux-mm@kvack.org>; Sat, 11 Nov 2017 05:31:07 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id r6so9888614pfj.14
        for <linux-mm@kvack.org>; Sat, 11 Nov 2017 02:31:07 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p1sor3032537pfi.4.2017.11.11.02.31.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 11 Nov 2017 02:31:05 -0800 (PST)
Date: Sat, 11 Nov 2017 21:30:50 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
Message-ID: <20171111213050.34a4f585@roar.ozlabs.ibm.com>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD00B84EF@AcuExch.aculab.com>
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
	<063D6719AE5E284EB5DD2968C1650D6DD00B84EF@AcuExch.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>
Cc: 'Matthew Wilcox' <willy@infradead.org>, Florian Weimer <fweimer@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Peter
 Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, linux-mm <linux-mm@kvack.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Thomas
 Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, 10 Nov 2017 12:08:35 +0000
David Laight <David.Laight@ACULAB.COM> wrote:

> From: Matthew Wilcox
> > Sent: 09 November 2017 19:44
> > 
> > On Fri, Nov 10, 2017 at 04:15:26AM +1100, Nicholas Piggin wrote:  
> > > So these semantics are what we're going with? Anything that does mmap() is
> > > guaranteed of getting a 47-bit pointer and it can use the top 17 bits for
> > > itself? Is intended to be cross-platform or just x86 and power specific?  
> > 
> > It is x86 and powerpc specific.  The arm64 people have apparently stumbled
> > across apps that expect to be able to use bit 48 for their own purposes.
> > And their address space is 48 bit by default.  Oops.  
> 
> (Do you mean 49bit?)

I think he meant bit 47, which makes sense because they were probably
ported from x86-64 with 47 bit address. That seems to be why x86-64
5-level and powerpc decided to limit to a 47 bit address space by
default.

> 
> Aren't such apps just doomed to be broken?

Well they're not portable but they are not broken if virtual address
is limited.

> 
> ISTR there is something on (IIRC) sparc64 that does a 'match'
> on the high address bits to make it much harder to overrun
> one area into another.

I'm not sure about that but I think the problem would be the app
masking out bits from the pointer for its own use before ever
dereferencing it.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
