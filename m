Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5A46B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 17:08:03 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so351888pab.33
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 14:08:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id uj2si2352484pbc.60.2014.08.13.14.08.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Aug 2014 14:08:02 -0700 (PDT)
Date: Wed, 13 Aug 2014 14:08:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: introduce for_each_vma helpers
Message-Id: <20140813140800.df0310a05e5fad6ed6b55886@linux-foundation.org>
In-Reply-To: <1407887208.2695.9.camel@buesod1.americas.hpqcorp.net>
References: <1407865523.2633.3.camel@buesod1.americas.hpqcorp.net>
	<20140812215213.GB17497@node.dhcp.inet.fi>
	<1407887208.2695.9.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Robert Richter <rric@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aswin@hp.com

On Tue, 12 Aug 2014 16:46:48 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:

> On Wed, 2014-08-13 at 00:52 +0300, Kirill A. Shutemov wrote:
> > On Tue, Aug 12, 2014 at 10:45:23AM -0700, Davidlohr Bueso wrote:
> > > The most common way of iterating through the list of vmas, is via:
> > >     for (vma = mm->mmap; vma; vma = vma->vm_next)
> > > 
> > > This patch replaces this logic with a new for_each_vma(vma) helper,
> > > which 1) encapsulates this logic, and 2) make it easier to read.
> > 
> > Why does it need to be encapsulated?
> > Do you have problem with reading plain for()?
> > 
> > Your for_each_vma(vma) assumes "mm" from the scope. This can be confusing
> > for reader: whether it uses "mm" from the scope or "current->mm". This
> > will lead to very hard to find bug one day.
> 
> I think its fairly obvious to see where the mm is coming from -- the
> helpers *do not* necessarily use current, it uses whatever mm was
> already there in the first place. I have not changed anything related to
> this from the callers. 

It is a bit of a hand-grenade for those (rare) situations where code is
dealing with other-tasks-mm.  It's simple enough to add an `mm' arg?

> The only related change I can think of, is for some callers that do:
> 
> for (vma = current->mm->mmap; vma != NULL; vma = vma->vm_next)
> 
> So we just add a local mm from current->mm and replace the for() with
> for_each_vma(). I don't see anything particularly ambiguous with that.

Adding a local to support a macro which secretly uses that local is
pretty nasty.


Overall, I'm not really sure that

-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	for_each_vma(mm, vma) {

is much of an improvement.  I'll wait to see what others think...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
