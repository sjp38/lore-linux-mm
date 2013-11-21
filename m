Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4E67F6B0039
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 06:19:28 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so4922632pbc.5
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 03:19:27 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id qu5si4089140pbc.30.2013.11.21.03.19.26
        for <linux-mm@kvack.org>;
        Thu, 21 Nov 2013 03:19:27 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131120144014.386293ce24e7b298ebab7b8e@linux-foundation.org>
References: <20131120174211.GF10323@ZenIV.linux.org.uk>
 <20131120174712.GG10323@ZenIV.linux.org.uk>
 <CA+55aFw_SuTAtTM0YTgiGf1pq4v4j5jbB1af=ExxjyFRbAJ4Ow@mail.gmail.com>
 <20131120144014.386293ce24e7b298ebab7b8e@linux-foundation.org>
Subject: Re: [git pull] vfs.git bits and pieces
Content-Transfer-Encoding: 7bit
Message-Id: <20131121111906.B97AEE0090@blue.fi.intel.com>
Date: Thu, 21 Nov 2013 13:19:06 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org

Andrew Morton wrote:
> On Wed, 20 Nov 2013 14:33:35 -0800 Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > On Wed, Nov 20, 2013 at 9:47 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > >
> > > BTW, something odd happened to mm/memory.c - either a mangled patch
> > > or a lost followup:
> > >
> > >     commit ea1e7ed33708
> > >     mm: create a separate slab for page->ptl allocation
> > >
> > > Fair enough, and yes, it does create that separate slab.  The problem is,
> > > it's still using kmalloc/kfree for those beasts - page_ptl_cachep isn't
> > > used at all...
> > 
> > Ok, it looks straightforward enough to just replace the kmalloc/kfree
> > with using a slab allocation using the page_ptl_cachep pointer. I'd do
> > it myself, but I would like to know how it got lost? Also, much
> > testing to make sure the cachep is initialized early enough.
> 
> agh, I went through hell keeping that patch alive and it appears I lost
> some of it.

Actually, I've lost it while adding BLOATED_SPINLOCKS :(

> > Or should we just revert the commit that added the pointless/unused
> > slab pointer?
> > 
> > Andrew, Kirill, comments?
> 
> Let's just kill it please.  We can try again for 3.14.

I'm okay with that.
Only side note: it's useful not only for debug case, but also for
PREEMPT_RT where spinlock_t is always bloated.

Fixed patch:
