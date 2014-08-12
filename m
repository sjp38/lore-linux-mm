Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9BD6B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 19:30:02 -0400 (EDT)
Received: by mail-yk0-f179.google.com with SMTP id 142so7745835ykq.38
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 16:30:01 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id x61si151680yhk.194.2014.08.12.16.30.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 12 Aug 2014 16:30:01 -0700 (PDT)
Message-ID: <1407886188.2695.3.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] mm: introduce for_each_vma helpers
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 12 Aug 2014 16:29:48 -0700
In-Reply-To: <20140812215213.GB17497@node.dhcp.inet.fi>
References: <1407865523.2633.3.camel@buesod1.americas.hpqcorp.net>
	 <20140812215213.GB17497@node.dhcp.inet.fi>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Robert Richter <rric@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aswin@hp.com

On Wed, 2014-08-13 at 00:52 +0300, Kirill A. Shutemov wrote:
> On Tue, Aug 12, 2014 at 10:45:23AM -0700, Davidlohr Bueso wrote:
> > The most common way of iterating through the list of vmas, is via:
> >     for (vma = mm->mmap; vma; vma = vma->vm_next)
> > 
> > This patch replaces this logic with a new for_each_vma(vma) helper,
> > which 1) encapsulates this logic, and 2) make it easier to read.
> 
> Why does it need to be encapsulated?
> Do you have problem with reading plain for()?

No problem in particular. But encapsulation is always good to have, and
we have a number of examples similar to what I'm proposing all
throughout the kernel (just like at vma_interval_tree_foreach).

> Your for_each_vma(vma) assumes "mm" from the scope. This can be confusing
> for reader: whether it uses "mm" from the scope or "current->mm". This
> will lead to very hard to find bug one day.
> I don't like this.
> 
> > It also updates most of the callers, so its a pretty good start.
> > 
> > Similarly, we also have for_each_vma_start(vma, start) when the user
> > does not want to start at the beginning of the list. And lastly the
> > for_each_vma_start_inc(vma, start, inc) helper in introduced to allow
> > users to create higher level special vma abstractions, such as with
> > the case of ELF binaries.
> 
> for_each_vma_start_inc() is pretty much the plain for() but with
> really_long_and_fancy_name(). Why?

Because we can implement things like for_each_vma_gate() on top.

Thanks,
Davidlohr


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
