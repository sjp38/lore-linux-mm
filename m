Date: Thu, 8 Feb 2007 14:24:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Drop PageReclaim()
Message-Id: <20070208142431.eb81ae70.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702081411030.14424@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702071428590.30412@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0702081319530.12048@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702081331290.12167@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702081340380.13255@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702081351270.14036@schroedinger.engr.sgi.com>
	<20070208140338.971b3f53.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702081411030.14424@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Feb 2007 14:14:39 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 8 Feb 2007, Andrew Morton wrote:
> 
> > During the vmscan we encounter a page at the tail of the inactive list
> > which we want to reclaim, but it's dirty.  So we start writeout and then
> > move it to the head of the inactive list and keep scanning.
> > 
> > When writeback completes, we take a look at the page to see if it still
> > seems to be reclaimable and if so, move it to the tail of the inactive list
> > so that it will be reclaimed very soon.
> 
> Still reclaimable means on the LRU and not activated?

See the tests in rotate_reclaimable_page():

	if (PageLocked(page))
		return 1;
	if (PageDirty(page))
		return 1;
	if (PageActive(page))
		return 1;
	if (!PageLRU(page))
		return 1;

> > PG_reclaim is used to indicate pages which need this treatment.
> 
> We have a mechanism to trigger events based on the end of writeback 
> (also triggered in end_page_writeback).

Not sure what you're referring to there.

> But I guess we are not using it 
> because we do not have a process context?

end_page_writeback() usually runs in hard IRQ context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
