Date: Tue, 7 Nov 2000 14:37:07 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#02, fault-in fix
Message-ID: <20001107143707.I1276@inspiron.random>
References: <20001106150539.A19112@redhat.com> <Pine.LNX.4.10.10011060912120.7955-100000@penguin.transmeta.com> <20001107115744.E1384@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001107115744.E1384@redhat.com>; from sct@redhat.com on Tue, Nov 07, 2000 at 11:57:44AM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 07, 2000 at 11:57:44AM +0000, Stephen C. Tweedie wrote:
> Is this a 2.5 cleanup or do you want things rearranged in the 2.4
> bugfix too?

I'm sorry but I've not understood exactly the suggestion (the shown pseudocode
will stack overflow btw).

I don't think returning the page gives advantages.  The point here is the
locking. We need to do this atomically (with the spinlock acquired):

	spin_lock(&mm->page_table_lock);
	check the pte is ok
	get_page(page);
	spin_unlock(&mm->page_table_lock);

The above is not necessary for any real page fault. That's needed only by
map_user_kiobuf that must atomically (atomically w.r.t. swap_out) pin the
physical page. IMHO it would be silly to add the locking and a get_page() (plus
a put_page after the page is returned to the page fault arch code) inside the
common page fault handler just to skip a walk of the pagetables for the case
where rawio is accessing a not correctly mapped page.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
