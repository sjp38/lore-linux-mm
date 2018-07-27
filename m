Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 068DD6B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 10:29:18 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w23-v6so3064989pgv.1
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 07:29:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w11-v6sor1409569plq.1.2018.07.27.07.29.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Jul 2018 07:29:16 -0700 (PDT)
Date: Sat, 28 Jul 2018 00:29:06 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH resend] powerpc/64s: fix page table fragment refcount
 race vs speculative references
Message-ID: <20180728002906.531d0211@roar.ozlabs.ibm.com>
In-Reply-To: <20180727134156.GA13348@bombadil.infradead.org>
References: <20180727114817.27190-1-npiggin@gmail.com>
	<20180727134156.GA13348@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, linux-mm@kvack.org

On Fri, 27 Jul 2018 06:41:56 -0700
Matthew Wilcox <willy@infradead.org> wrote:

> On Fri, Jul 27, 2018 at 09:48:17PM +1000, Nicholas Piggin wrote:
> > The page table fragment allocator uses the main page refcount racily
> > with respect to speculative references. A customer observed a BUG due
> > to page table page refcount underflow in the fragment allocator. This
> > can be caused by the fragment allocator set_page_count stomping on a
> > speculative reference, and then the speculative failure handler
> > decrements the new reference, and the underflow eventually pops when
> > the page tables are freed.  
> 
> Oof.  Can't you fix this instead by using page_ref_add() instead of
> set_page_count()?

It's ugly doing it that way. The problem is we have a page table
destructor and that would be missed if the spec ref was the last
put. In practice with RCU page table freeing maybe you can say
there will be no spec ref there (unless something changes), but
still it just seems much simpler doing this and avoiding any
complexity or relying on other synchronization.

> 
> > Any objection to the struct page change to grab the arch specific
> > page table page word for powerpc to use? If not, then this should
> > go via powerpc tree because it's inconsequential for core mm.  
> 
> I want (eventually) to get to the point where every struct page carries
> a pointer to the struct mm that it belongs to.  It's good for debugging
> as well as handling memory errors in page tables.

That doesn't seem like it should be a problem, there's some spare
words there for arch independent users.

Thanks,
Nick
