Subject: Re: 2.6.18-rc3-mm2: rcu radix tree patches break page migration
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <44D82508.9020409@yahoo.com.au>
References: <Pine.LNX.4.64.0608071556530.23088@schroedinger.engr.sgi.com>
	 <44D7E7DF.1080106@yahoo.com.au>
	 <Pine.LNX.4.64.0608072041010.24071@schroedinger.engr.sgi.com>
	 <44D82508.9020409@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 08 Aug 2006 10:53:19 -0400
Message-Id: <1155048800.8184.23.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-08-08 at 15:45 +1000, Nick Piggin wrote:
> Christoph Lameter wrote:
> 
> >On Tue, 8 Aug 2006, Nick Piggin wrote:
> >
> >
> >>Question: can you replace the lookup_slot with a regular lookup, then
> >>replace the pointer switch with a radix_tree_delete + radix_tree_insert
> >>and see if that works?
> >>
> >
> >Ahh... Okay that makes things work the right way.
> >
> >Does that mean we need to get rid of radix tree replaces in 
> >general?
> >
> 
> I think it just means that my lookup_slot has a bug somewhere. Also: good
> to know that I'm not corrupting anyones pagecache (except yours, and Lee's).

I saw this under heavy "auto-migration" of just anon pages during
parallel kernel builds:  "make -j32" on a 16cpu/4node numa system.  

The symptom I saw was when two tasks raced in do_swap_page to refault a
page that I had forcibly pushed to the swap cache [but still resident in
memory] to allow possible migrate on fault.  The loser of the race would
wait behind the page lock, holding a reference handed out by
find_get_page().  When it awakened, after the winner had migrated the
page, it would see that the page had been migrated out from under it,
release the ref and retry the lookup.  When it released the reference,
the count would go to zero, and the page would be freed.  It would
ultimately hit a BUG_ON in list_del() called from free_pages_bulk():
entry->prev->next != entry.

Now that the mbind() failure seems fixed, I'm rebasing my patches.  I
think I'll be able to reproduce this fairly regularly.

> 
> Let me work out what I'm doing wrong. In the meantime if you could send
> that patch to akpm as a fixup, that would keep you running. Thanks guys.

I'm willing to test anything you come up with.  I'll take a look at the
lookup, as well, code once I can reproduce the failure.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
