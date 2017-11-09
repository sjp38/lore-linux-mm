Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5D0440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 14:44:28 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 192so75194pgd.18
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 11:44:28 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a28si6968291pgd.464.2017.11.09.11.44.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 11:44:26 -0800 (PST)
Date: Thu, 9 Nov 2017 11:44:21 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
Message-ID: <20171109194421.GA12789@bombadil.infradead.org>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171110041526.6137bc9a@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Florian Weimer <fweimer@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Nov 10, 2017 at 04:15:26AM +1100, Nicholas Piggin wrote:
> So these semantics are what we're going with? Anything that does mmap() is
> guaranteed of getting a 47-bit pointer and it can use the top 17 bits for
> itself? Is intended to be cross-platform or just x86 and power specific?

It is x86 and powerpc specific.  The arm64 people have apparently stumbled
across apps that expect to be able to use bit 48 for their own purposes.
And their address space is 48 bit by default.  Oops.

> Also, this may follow from deduction from 1-3, but for explicit
> specification in man page:
> 
> 4) To get an unspecified allocation with the largest possible address range,
> we pass in -1 for mmap hint.
> 
> Are we allowing 8 bits bits of unused address in this case, or must the
> app not assume anything about number of bits used?

Maybe document it as: "If the app wants to use the top N bits of addresses
for its own purposes, pass in (~0UL >> N) as the mmap hint."  ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
