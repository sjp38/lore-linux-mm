Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5124F6B0083
	for <linux-mm@kvack.org>; Thu, 28 May 2009 08:08:51 -0400 (EDT)
Date: Thu, 28 May 2009 14:08:54 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090528120854.GJ6920@wotan.suse.de>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528093141.GD1065@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090528093141.GD1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: hugh@veritas.com, riel@redhat.com, akpm@linux-foundation.org, chris.mason@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Thu, May 28, 2009 at 11:31:41AM +0200, Andi Kleen wrote:
> On Thu, May 28, 2009 at 10:26:16AM +0200, Nick Piggin wrote:
> 
> Thanks for the review.
> 
> > > + *
> > > + * Also there are some races possible while we get from the
> > > + * error detection to actually handle it.
> > > + */
> > > +
> > > +struct to_kill {
> > > +	struct list_head nd;
> > > +	struct task_struct *tsk;
> > > +	unsigned long addr;
> > > +};
> > 
> > It would be kinda nice to have a field in task_struct that is usable
> > say for anyone holding the tasklist lock for write. Then you could
> 
> I don't want to hold the tasklist lock for writing all the time, memory
> failure handling can sleep.
> 
> > make a list with them. But I guess it isn't worthwhile unless there
> > are other users.
> 
> It would need to be reserved for this, which definitely doesn't make
> worth it. Also I need the  address too, a list head alone wouldn't be enough.

Right, it was just an idea. It would not have to be reserved for that
so long as it was synchronized with the right lock. But not a big deal,
forget it.


> > > +			printk(KERN_ERR "MCE: Out of memory while machine check handling\n");
> > > +			return;
> > > +		}
> > > +	}
> > > +	tk->addr = page_address_in_vma(p, vma);
> > > +	if (tk->addr == -EFAULT) {
> > > +		printk(KERN_INFO "MCE: Failed to get address in VMA\n");
> > 
> > I don't know if this is very helpful message. I could legitimately happen and
> > nothing anybody can do about it...
> 
> Can you suggest a better message?

Well, for userspace, nothing? At the very least ratelimited, and preferably
telling a more high level of what the problem and consequences are.


> > > +		tk->addr = 0;
> > > +		fail = 1;
> > 
> > Fail doesn't seem to be used anywhere.
> 
> Ah yes that was a remnant of a error checking scheme I discard later.
> I'll remove it thanks.
> 
> > > +	list_add_tail(&tk->nd, to_kill);
> > > +}
> > > +
> > > +/*
> > > + * Kill the processes that have been collected earlier.
> > > + */
> > > +static void kill_procs_ao(struct list_head *to_kill, int doit, int trapno,
> > > +			  int fail, unsigned long pfn)
> > 
> > I guess "doit" etc is obvious once reading the code and caller, but maybe a
> > quick comment in the header to describe?
> 
> Ok.
> 
> > 
> > > +{
> > > +	struct to_kill *tk, *next;
> > > +
> > > +	list_for_each_entry_safe (tk, next, to_kill, nd) {
> > > +		if (doit) {
> > > +			/*
> > > +			 * In case something went wrong with munmaping
> > > +			 * make sure the process doesn't catch the
> > > +			 * signal and then access the memory. So reset
> > > +			 * the signal handlers
> > > +			 */
> > > +			if (fail)
> > > +				flush_signal_handlers(tk->tsk, 1);
> > 
> > Is this a legitimate thing to do? Is it racy? Why would you not send a
> > sigkill or something if you want them to die right now?
> 
> That's a very unlikely case it could be probably just removed, when
> something during unmapping fails (mostly out of memory)
> 
> It's more paranoia than real need.
> 
> Yes SIGKILL would be probably better.

OK, maybe just remove it? (keep simple first?)


> > > + */
> > > +static void collect_procs_file(struct page *page, struct list_head *to_kill,
> > > +			      struct to_kill **tkc)
> > > +{
> > > +	struct vm_area_struct *vma;
> > > +	struct task_struct *tsk;
> > > +	struct prio_tree_iter iter;
> > > +	struct address_space *mapping = page_mapping(page);
> > > +
> > > +	read_lock(&tasklist_lock);
> > > +	spin_lock(&mapping->i_mmap_lock);
> > 
> > You have tasklist_lock(R) nesting outside i_mmap_lock, and inside anon_vma
> > lock. And anon_vma lock nests inside i_mmap_lock.
> > 
> > This seems fragile. If rwlocks ever become FIFO or tasklist_lock changes
> > type (maybe -rt kernels do it), then you could have a task holding
> > anon_vma lock and waiting for tasklist_lock, and another holding tasklist
> > lock and waiting for i_mmap_lock, and another holding i_mmap_lock and
> > waiting for anon_vma lock.
> 
> So you're saying I should change the order?

Well I don't _think_ we have a dependency already. Yes I would just change
the order to be either outside both VM locks or inside both. Maybe with
a note that it does not really matter which order (in case another user
comes up who needs the opposite ordering).


> > I think nesting either inside or outside these locks consistently is less
> > fragile. Do we already have a dependency?... I don't know of one, but you
> > should document this in mm/rmap.c and mm/filemap.c.
> 
> Ok.
> 
> > > +	DELAYED,
> > > +	IGNORED,
> > > +	RECOVERED,
> > > +};
> > > +
> > > +static const char *action_name[] = {
> > > +	[FAILED] = "Failed",
> > > +	[DELAYED] = "Delayed",
> > > +	[IGNORED] = "Ignored",
> > 
> > How is delayed different to ignored (or failed, for that matter)?
> 
> Part of it is documentation.
> 
> DELAYED means it's handled somewhere else (e.g. in the case of free pages)
> 
> > 
> > 
> > > +	[RECOVERED] = "Recovered",
> > 
> > And what does recovered mean? THe processes were killed and the page taken
> 
> Not necessarily killed, it might have been a clean page or so.
> 
> > out of circulation, but the machine is still in some unknown state of corruption
> > henceforth, right?
> 
> It's in a known state of corruption -- there was this error on that page
> and otherwise it's fine (or at least no errors known at this point)
> The CPU generally tells you when it's in a unknown state and in this case this 
> code is not executed, but just panic directly.

Then the data can not have been consumed, by DMA or otherwise? What
about transient kernel references to the (pagecache/anonymous) page
(such as, find_get_page for read(2), or get_user_pages callers).


> > > +
> > > +	/*
> > > +	 * remove_from_page_cache assumes (mapping && !mapped)
> > > +	 */
> > > +	if (page_mapping(p) && !page_mapped(p)) {
> > > +		remove_from_page_cache(p);
> > > +		page_cache_release(p);
> > > +	}
> > 
> > remove_mapping would probably be a better idea. Otherwise you can
> > probably introduce pagecache removal vs page fault races whi
> > will make the kernel bug.
> 
> Can you be more specific about the problems?

Hmm, actually now that we hold the page lock over __do_fault (at least
for pagecache pages), this may not be able to trigger the race I was
thinking of (page becoming mapped). But I think still it is better
to use remove_mapping which is the standard way to remove such a page.

BTW. I don't know if you are checking for PG_writeback often enough?
You can't remove a PG_writeback page from pagecache. The normal
pattern is lock_page(page); wait_on_page_writeback(page); which I
think would be safest (then you never have to bother with the writeback
bit again).


> > > +			page_to_pfn(p));
> > > +	if (mapping) {
> > > +		/*
> > > +		 * Truncate does the same, but we're not quite the same
> > > +		 * as truncate. Needs more checking, but keep it for now.
> > > +		 */
> > 
> > What's different about truncate? It would be good to reuse as much as possible.
> 
> Truncating removes the block on disk (we don't). Truncating shrinks
> the end of the file (we don't). It's more "temporal hole punch"
> Probably from the VM point of view it's very similar, but it's
> not the same.

Right, I just mean the pagecache side of the truncate. So you should
use truncate_inode_pages_range here.


> > > +		cancel_dirty_page(p, PAGE_CACHE_SIZE);
> > > +
> > > +		/*
> > > +		 * IO error will be reported by write(), fsync(), etc.
> > > +		 * who check the mapping.
> > > +		 */
> > > +		mapping_set_error(mapping, EIO);
> > 
> > Interesting. It's not *exactly* an IO error (well, not like one we're usually
> > used to).
> 
> It's a new kind, but conceptually it's the same. Dirty IO data got corrupted.

Well, the dirty data has never been corrupted before (ie. the data
in pagecache has been OK). It was just unable to make it back to
backing store. So a program could retry the write/fsync/etc or
try to write the data somewhere else.

It kind of wants a new error code, but I can't imagine the difficulty
in doing that...


> We actually had a lot of grief with the error reporting; a lot of
> code does "report error once then clear from mapping", which
> broke all the tests for that in the test suite. IMHO that's a shady
> area in the kernel.

Yeah, it's annoying. I ran over this problem when auditing some
data integrity problems in the kernel recently. IIRC even a
misplaced sync from another process can come and suck up the IO
error that your DBMS was expecting to get from fsync.

We kind of need another type of syscall to tell the kernel whether
it can discard errors for a given file/range. But this is not the
problem for your patch.


> Right now these are "expected but incorrect failures" in the tester.
> 
> 
> > > +
> > > +	delete_from_swap_cache(p);
> > > +
> > > +	return RECOVERED;
> > > +}
> > 
> > All these handlers are quite interesting in that they need to
> > know about most of the mm. What are you trying to do in each
> > of them would be a good idea to say, and probably they should
> > rather go into their appropriate files instead of all here
> > (eg. swapcache stuff should go in mm/swap_state for example).
> 
> Hmm. I think I would prefer to first merge before
> thinking about such things. But they could be moved at some 
> point.
> 
> I suspect people first need to get more used to the idea of poisoned pages
> before we can force it to them directly like this.

Well these are messing with the internals of those subsystems, so
maintainers etc do need to think about such things and get used
to the idea.

I think it is actually a good idea thinking about it more. Basically
each subsystem will just have calls in response to handle errors in
their pages.


> > You haven't waited on writeback here AFAIKS, and have you
> > *really* verified it is safe to call delete_from_swap_cache?
> 
> Verified in what way? me and Fengguang went over the code.
> The original attempt at doing this was quite broken, but this
> one should be better (it's the third iteration or so)

I was thinking maybe it can be PG_writeback at that point which
would go BUG there. Maybe I missed somewhere where you filter
that out.


> > > +
> > > +#define dirty		(1UL << PG_dirty)
> > > +#define swapcache	(1UL << PG_swapcache)
> > > +#define unevict		(1UL << PG_unevictable)
> > > +#define mlocked		(1UL << PG_mlocked)
> > > +#define writeback	(1UL << PG_writeback)
> > > +#define lru		(1UL << PG_lru)
> > > +#define swapbacked	(1UL << PG_swapbacked)
> > > +#define head		(1UL << PG_head)
> > > +#define tail		(1UL << PG_tail)
> > > +#define compound	(1UL << PG_compound)
> > > +#define slab		(1UL << PG_slab)
> > > +#define buddy		(1UL << PG_buddy)
> > > +#define reserved	(1UL << PG_reserved)
> > 
> > This looks like more work than just putting 1UL << (...) in each entry
> 
> I had this originally, but it looked rather ugly.
> 
> > in your table. Hmm, does this whole table thing even buy you much (versus a
> > much simpler switch statement?)
> 
> I don't think the switch would be particularly simple. Also I like
> tables.
> 
> > 
> > And seeing as you are doing a lot of checking for various page flags anyway,
> > (eg. in your prepare function). Just seems like needless complexity.
> 
> Yes that grew over time unfortunately. Originally there was very little
> explicit flag checking.
> 
> I still think the table is a good approach. 

Just seems overengineered. We could rewrite any if/switch statement like
that (and actually the compiler probably will if it is beneficial).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
