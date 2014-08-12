Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3F33D6B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 19:47:00 -0400 (EDT)
Received: by mail-oi0-f52.google.com with SMTP id h136so7104561oig.39
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 16:46:59 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id w8si213891obn.30.2014.08.12.16.46.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 12 Aug 2014 16:46:59 -0700 (PDT)
Message-ID: <1407887208.2695.9.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] mm: introduce for_each_vma helpers
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 12 Aug 2014 16:46:48 -0700
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
> 
> Your for_each_vma(vma) assumes "mm" from the scope. This can be confusing
> for reader: whether it uses "mm" from the scope or "current->mm". This
> will lead to very hard to find bug one day.

I think its fairly obvious to see where the mm is coming from -- the
helpers *do not* necessarily use current, it uses whatever mm was
already there in the first place. I have not changed anything related to
this from the callers. 

The only related change I can think of, is for some callers that do:

for (vma = current->mm->mmap; vma != NULL; vma = vma->vm_next)

So we just add a local mm from current->mm and replace the for() with
for_each_vma(). I don't see anything particularly ambiguous with that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
