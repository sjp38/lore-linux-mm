Received: from linux.wat.veritas.com([10.10.97.50]) (2051 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m1E7x2I-0001AAC@megami.veritas.com>
	for <linux-mm@kvack.org>; Wed, 24 Aug 2005 08:19:30 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Wed, 24 Aug 2005 16:21:30 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFT][PATCH 0/2] pagefault scalability alternative
In-Reply-To: <20050824142749.14667.qmail@science.horizon.com>
Message-ID: <Pine.LNX.4.61.0508241557430.5493@goblin.wat.veritas.com>
References: <20050824142749.14667.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux@horizon.com
Cc: clameter@engr.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Aug 2005 linux@horizon.com wrote:

> > Atomicity can be guaranteed to some degree by using the present bit. 
> > For an update the present bit is first switched off. When a 
> > new value is written, it is first written in the piece of the entry that 
> > does not contain the pte bit which keeps the entry "not present". Last the 
> > word with the present bit is written.
> 
> Er... no.  That would work if reads were atomic but writes weren't, but
> consider the following:
> 
> Reader		Writer
> Read first half
> 		Write not-present bit
> 		Write other half
> 		Write present bit
> Read second half
> 
> Voila, mismatched halves.

True.  But not an issue for the patch under discussion.

In the case of the pt entries, all the writes are done within ptlock,
and any reads done outside of ptlock (to choose which fault handler)
are rechecked within ptlock before making any critical decision
(in the PAE case which might have mismatched halves).

In the case of the pmd entries, a transition from present to not
present is only made in free_pgtables (either while mmap_sem is
held exclusively, or when the mm no longer has users), after
unlinking from the prio_tree and anon_vma list by which kswapd
might have got to them without mmap_sem (the unlinking taking
the necessary locks).  And pfn is never changed while present.

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
