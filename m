Received: from mail.ccr.net (ccr@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA29017
	for <linux-mm@kvack.org>; Wed, 25 Nov 1998 16:23:34 -0500
Subject: Re: Linux-2.1.129..
References: <199811241525.PAA00862@dax.scot.redhat.com> 	<Pine.LNX.3.95.981124092641.10767A-100000@penguin.transmeta.com> <199811251419.OAA00990@dax.scot.redhat.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 25 Nov 1998 15:07:39 -0600
In-Reply-To: "Stephen C. Tweedie"'s message of "Wed, 25 Nov 1998 14:19:28 GMT"
Message-ID: <m1u2znbhwj.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> However, for pages which become dirty in memory, we _do_ populate the
ST> swap cache only at page-out time.  That's why the sharing still works.
ST> I think that the real change we need is to cleanly support PG_dirty
ST> flags per page.  Once we do that, not only do all of the dirty inode
ST> pageouts get fixed, but we also automatically get MAP_SHARED |
ST> MAP_ANONYMOUS.


ST> While we're on that subject, Linus, do you still have Andrea's patch to
ST> propogate page writes around all shared ptes?  I noticed that Zlatko
ST> Calusic recently re-posted it, and it looks like the sort of short-term
ST> fix we need for this issue in 2.2 (assuming we don't have time to do a
ST> proper PG_dirty fix).

What do you consider a proper PG_dirty fix?

I have been working on it (what I would call a PG_dirty fix) and have
most thing working but my code has a lot of policy questions still to
answer.



But as far as MAP_SHARED | MAP_ANONYMOUS to retain our current
swapping model (of never rewriting a swap page), and for swapoff
support we need the ability to change which swap page all of the pages
are associated with.

There are 2 ways to do this.  
1) Implement it like SYSV shared mem.
2) Just maintain vma structs for the memory, with vma_next_share used!
   Then when we allocate a new swap page we can walk the
   *vm_area_struct's to find the page_tables that need to be updated.

   The real tricky case to get right is simulaneous COW & SOW.
   SOW == Share On Write.

  The question right now is where do we anchor the vma_next_share
  linked list, as we don't have an inode.


Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
