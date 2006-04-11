Subject: Re: Page Migration: Make do_swap_page redo the fault
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0604101303350.24029@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0604032228150.24182@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0604081312200.14441@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0604081058290.16914@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0604082022170.12196@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0604081430280.17911@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0604090357350.5312@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0604101933400.26478@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0604101303350.24029@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 11 Apr 2006 10:58:21 -0400
Message-Id: <1144767501.5160.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2006-04-10 at 13:19 -0700, Christoph Lameter wrote:
> On Mon, 10 Apr 2006, Hugh Dickins wrote:
> 
> > I have now checked through, and I'm relieved to conclude that neither
> > of those other two PageSwapCache rechecks are necessary; and the rules
> > are much as before.
> 
> Note that the removal of the check in do_swap_page does only work
> since the remove_from_swap() changes the pte. Without that pte change 
> do_swap_page could retrieve the old page via the swap map. It would wait 
> until page migration finished its migration and then find that the page is 
> not in the pagecache anymore. Note that Lee Schermerhorn's lazy page 
> migration may rely on disabling remove_from_swap() for his migration 
> scheme. Lee? Looks like we are putting new barriers in front of you?

Yes.  I noticed.  If the current code doesn't depend on these check, I
guess you should probably rip 'em out and I'll carry any necessary check
in my series.

> 
> > In the try_to_unuse case, it's quite possible that !PageSwapCache there,
> > because of a racing delete_from_swap_cache; but that case is correctly
> > handled in the code that follows.
> 
> Ah. I see a later check 
> 
> if ((*swap_map > 1) && PageDirty(page) && PageSwapCache(page)) {
> 
> > So I believe we can safely remove these other two
> > "Page migration has occured" blocks - can't we?
> 
> Hmmm... The increased count is also an argument against having to check 
> for the race in do_swap_page(). So maybe Lee's lazy migration patchset 
> should also be fine without these checks and there is actually no need
> to rely on the ptes not being the same.

May still be some work in do_swap_page().  The unmap has already
occurred.  In the general case [support for migrating pages w/ > 1 pte
mapping], two or more tasks could race faulting the cache pte.  IMO one
should perform the migration [replacing old page in cache with new
page], others should block and then use the new page to resolve their
own faults.  I think this means a check and then at least another cache
lookup.  Maybe redo the fault, as Christoph has said.

Don't know about direct migration.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
