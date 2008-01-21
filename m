Message-ID: <479469A4.6090607@de.ibm.com>
Date: Mon, 21 Jan 2008 10:45:08 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [patch] #ifdef very expensive debug check in page fault path
References: <1200506488.32116.11.camel@cotte.boeblingen.de.ibm.com> <20080116234540.GB29823@wotan.suse.de> <20080116161021.c9a52c0f.akpm@linux-foundation.org> <Pine.LNX.4.64.0801182023350.5249@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0801182023350.5249@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, mschwid2@linux.vnet.ibm.com, Holger Wolf <holger.wolf@de.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> And so you have already, commit 9723198c219f3546982cb469e5aed26e68399055
> 
> I'm very surprised that's considered suitable material for post-rc8.
> 
> We know very well that page tables are almost honeytraps for random
> corruption, and we've long adhered to the practice of preceding any
> pfn_to_page by a pfn_valid check, to make sure we don't veer off the
> end of the mem_map (or whatever), causing our page manipulations to
> corrupt unrelated memory with less foreseeable consequences.  That
> good practice dates from long before some of the checking got
> separated out into vm_normal_page.
> 
> That said, perhaps I'm over-reacting: I can remember countless rmap.c
> BUGs or Eeeks, and countless Bad page states, and quite a number of
> swap_free errors, all usually symptoms of similar corruption; yet
> not a single instance of that Bad pte message which Nick was good
> enough to add a couple of years back.
> 
> Hmm, it's my own memory that's bad: a grep through old mailboxes
> does show them; though I've not stopped to look, to see whether
> perhaps they can all be argued away on some good grounds.
> 
> Well: that patch still gets my Nack, but I guess I'm too late.  If
> s390 pagetables are better protected than x86 ones, add an s390 ifdef?
The alternative would be to just make
#define pfn_valid(pfn) (1)
on s390. That would also get _us_ rid of the check while others do 
benefit. We would trap access to mem_map beyond its limits because we 
don't have a kernel mapping there. For us, it would not silently 
corrupt things but crash proper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
