Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02E0D6B0007
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 09:42:03 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w23-v6so2996419pgv.1
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 06:42:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r3-v6si3892737pgg.201.2018.07.27.06.42.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 27 Jul 2018 06:42:01 -0700 (PDT)
Date: Fri, 27 Jul 2018 06:41:56 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH resend] powerpc/64s: fix page table fragment refcount
 race vs speculative references
Message-ID: <20180727134156.GA13348@bombadil.infradead.org>
References: <20180727114817.27190-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180727114817.27190-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, linux-mm@kvack.org

On Fri, Jul 27, 2018 at 09:48:17PM +1000, Nicholas Piggin wrote:
> The page table fragment allocator uses the main page refcount racily
> with respect to speculative references. A customer observed a BUG due
> to page table page refcount underflow in the fragment allocator. This
> can be caused by the fragment allocator set_page_count stomping on a
> speculative reference, and then the speculative failure handler
> decrements the new reference, and the underflow eventually pops when
> the page tables are freed.

Oof.  Can't you fix this instead by using page_ref_add() instead of
set_page_count()?

> Any objection to the struct page change to grab the arch specific
> page table page word for powerpc to use? If not, then this should
> go via powerpc tree because it's inconsequential for core mm.

I want (eventually) to get to the point where every struct page carries
a pointer to the struct mm that it belongs to.  It's good for debugging
as well as handling memory errors in page tables.
