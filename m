Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] Page table sharing
Date: Tue, 19 Feb 2002 01:27:42 +0100
References: <Pine.LNX.4.21.0202182358190.1021-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.21.0202182358190.1021-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E16cy8E-0000xp-00@starship.berlin>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, Rik van Riel <riel@conectiva.com.br>, mingo@redhat.com, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On February 19, 2002 01:03 am, Hugh Dickins wrote:
> On Tue, 19 Feb 2002, Daniel Phillips wrote:
> > On February 18, 2002 08:04 pm, Hugh Dickins wrote:
> > > On Mon, 18 Feb 2002, Daniel Phillips wrote:
> > > > On February 18, 2002 09:09 am, Hugh Dickins wrote:
> > > > > Since copy_page_range would not copy shared page tables, I'm wrong to
> > > > > point there.  But __pte_alloc does copy shared page tables (to unshare
> > > > > them), and needs them to be stable while it does so: so locking against
> > > > > swap_out really is required.  It also needs locking against read faults,
> > > > > and they against each other: but there I imagine it's just a matter of
> > > > > dropping the write arg to __pte_alloc, going back to pte_alloc again.
> > 
> > I'm not sure what you mean here, you're not suggesting we should unshare the
> > page table on read fault are you?
> 
> I am.  But I can understand that you'd prefer not to do it that way.
> Hugh

No, that's not nearly studly enough ;-)

Since we have gone to all the trouble of sharing the page table, we should
swap in/out for all sharers at the same time.  That is, keep it shared, saving
memory and cpu.

Now I finally see what you were driving at: before, we could count on the
mm->page_table_lock for exclusion on read fault, now we can't, at least not
when ptb->count is great than one[1].  So let's come up with something nice as
a substitute, any suggestions?

[1] I think that's a big, broad hint.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
