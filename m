Date: Wed, 4 Apr 2007 13:56:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: missing madvise functionality
Message-Id: <20070404135618.d39f98f4.akpm@linux-foundation.org>
In-Reply-To: <4613E9AF.3030802@redhat.com>
References: <46128051.9000609@redhat.com>
	<p73648dz5oa.fsf@bingen.suse.de>
	<46128CC2.9090809@redhat.com>
	<20070403172841.GB23689@one.firstfloor.org>
	<20070403125903.3e8577f4.akpm@linux-foundation.org>
	<4612B645.7030902@redhat.com>
	<20070403202937.GE355@devserv.devel.redhat.com>
	<20070403144948.fe8eede6.akpm@linux-foundation.org>
	<20070403160231.33aa862d.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0704040949050.17341@blonde.wat.veritas.com>
	<20070404110406.c79b850d.akpm@linux-foundation.org>
	<4613E9AF.3030802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hugh@veritas.com>, Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 04 Apr 2007 14:08:47 -0400
Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> 
> > There are other ways of doing it - I guess we could use a new page flag to
> > indicate that this is one-of-those-pages, and add new code to handle it in
> > all the right places.
> 
> That's what I did.  I'm currently working on the
> zap_page_range() side of things.

Let's try to avoid consuming another page flag if poss, please.  Perhaps
use PAGE_MAPPING_ANON's neighbouring bit?

> > One thing which we haven't sorted out with all this stuff: once the
> > application has marked an address range (and some pages) as
> > whatever-were-going-call-this-feature, how does the application undo that
> > change? 
> 
> It doesn't have to do anything.  Just access the page and the
> MMU will mark it dirty/accessed and the VM will not reclaim
> it.

um, OK.  I suspect it would be good to clear the page's
PageWhateverWereGoingToCallThisThing() state when this happens.  Otherwise
when the page gets clean again (ie: added to swapcache then written out)
then it will look awfully similar to one of these new types of pages and
things might get confusing.  We'll see.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
