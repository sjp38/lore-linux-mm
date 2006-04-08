Date: Sat, 8 Apr 2006 14:39:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page Migration: Make do_swap_page redo the fault
In-Reply-To: <Pine.LNX.4.64.0604082022170.12196@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0604081430280.17911@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0604032228150.24182@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604081312200.14441@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604081058290.16914@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604082022170.12196@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Apr 2006, Hugh Dickins wrote:

> On Sat, 8 Apr 2006, Christoph Lameter wrote:
> > 
> > Hmmm..,. There are still two other checks for !PageSwapCache after 
> > obtaining a page lock in shmem_getpage() and in try_to_unuse(). 
> > However, both are getting to the page via the swap maps. So we need to 
> > keep those.
> 
> Sure, those are long standing checks, necessary long before migration
> came on the scene; whereas the check in do_swap_page was recently added
> just for a page migration case, and now turns out to be redundant.

Those two checks were added for migration together with the one we 
are removing now. Sounds like you think they additionally fix some other 
race conditions?

The check we are discussing only becomes unnecessary if the swap ptes are 
replaced by regular ptes. The swap pte would refer to the old page from 
which the SwapCache bit was cleared. This is dependent on remove_from_swap 
always functioning properly which happened pretty late in the 2.6.16 
cycle.

Here is the description from V9 of the direct migration patchset which 
introduced the 3 checks for PageSwapCache():



Check for PageSwapCache after looking up and locking a swap page.

The page migration code may change a swap pte to point to a different page
under lock_page().

If that happens then the vm must retry the lookup operation in the swap
space to find the correct page number. There are a couple of locations
in the VM where a lock_page() is done on a swap page. In these locations
we need to check afterwards if the page was migrated. If the page was 
migrated
then the old page that was looked up before was freed and no longer has 
the
PageSwapCache bit set.

Signed-off-by: Hirokazu Takahashi <taka@valinux.co.jp>
Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
Signed-off-by: Christoph Lameter <clameter@@sgi.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
