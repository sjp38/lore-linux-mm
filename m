Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
From: Nick Piggin <nickpiggin@yahoo.com.au>
In-Reply-To: <Pine.LNX.4.58.0508012039120.3341@g5.osdl.org>
References: <20050801032258.A465C180EC0@magilla.sf.frob.com>
	 <42EDDB82.1040900@yahoo.com.au>
	 <Pine.LNX.4.58.0508010833250.14342@g5.osdl.org>
	 <42EECC1F.9000902@yahoo.com.au>
	 <Pine.LNX.4.58.0508012039120.3341@g5.osdl.org>
Content-Type: text/plain
Date: Tue, 02 Aug 2005 14:25:13 +1000
Message-Id: <1122956713.6338.19.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@osdl.org>, Roland McGrath <roland@redhat.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-08-01 at 20:45 -0700, Linus Torvalds wrote:
> 
> On Tue, 2 Aug 2005, Nick Piggin wrote:
> > 
> > Surely this introduces integrity problems when `force` is not set?
> 
> "force" changes how we test the vma->vm_flags, that was always the 
> meaning from a security standpoint (and that hasn't changed).
> 

Of course, this test catches the problem I had in mind.

> The old code had this "lookup_write = write && !force;" thing because
> there it used "force" to _clear_ the write bit test, and that was what
> caused the race in the first place - next time around we would accept a
> non-writable page, even if it hadn't actually gotten COW'ed.
> 
> So no, the patch doesn't introduce integrity problems by ignoring "force".  
> Quite the reverse - it _removes_ the integrity problems by ignoring it
> there. That's kind of the whole point.
> 

OK, I'm convinced. One last thing - your fix might have a non
trivial overhead in terms of spin locks and simply entering the
high level page fault handler when dealing with clean, writeable
ptes for write.

Any chance you can change the __follow_page test to account for
writeable clean ptes? Something like

	if (write && !pte_dirty(pte) && !pte_write(pte))
		goto out;

And then you would re-add the set_page_dirty logic further on.

Not that I know what Robin's customer is doing exactly, but it
seems like something you can optimise easily enough.

Nick

-- 
SUSE Labs, Novell Inc.



Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
