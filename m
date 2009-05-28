Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A19BC6B004F
	for <linux-mm@kvack.org>; Thu, 28 May 2009 09:38:09 -0400 (EDT)
Date: Thu, 28 May 2009 15:45:20 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090528134520.GH1065@one.firstfloor.org>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528093141.GD1065@one.firstfloor.org> <20090528120854.GJ6920@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090528120854.GJ6920@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, hugh@veritas.com, riel@redhat.com, akpm@linux-foundation.org, chris.mason@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Thu, May 28, 2009 at 02:08:54PM +0200, Nick Piggin wrote:
> > > > +			printk(KERN_ERR "MCE: Out of memory while machine check handling\n");
> > > > +			return;
> > > > +		}
> > > > +	}
> > > > +	tk->addr = page_address_in_vma(p, vma);
> > > > +	if (tk->addr == -EFAULT) {
> > > > +		printk(KERN_INFO "MCE: Failed to get address in VMA\n");
> > > 
> > > I don't know if this is very helpful message. I could legitimately happen and
> > > nothing anybody can do about it...
> > 
> > Can you suggest a better message?
> 
> Well, for userspace, nothing? At the very least ratelimited, and preferably
> telling a more high level of what the problem and consequences are.

I changed it to 

 "MCE: Unable to determine user space address during error handling\n")

Still not perfect, but hopefully better.


> > > > +				flush_signal_handlers(tk->tsk, 1);
> > > 
> > > Is this a legitimate thing to do? Is it racy? Why would you not send a
> > > sigkill or something if you want them to die right now?
> > 
> > That's a very unlikely case it could be probably just removed, when
> > something during unmapping fails (mostly out of memory)
> > 
> > It's more paranoia than real need.
> > 
> > Yes SIGKILL would be probably better.
> 
> OK, maybe just remove it? (keep simple first?)

I changed it to always do a SIGKILL

> > > You have tasklist_lock(R) nesting outside i_mmap_lock, and inside anon_vma
> > > lock. And anon_vma lock nests inside i_mmap_lock.
> > > 
> > > This seems fragile. If rwlocks ever become FIFO or tasklist_lock changes
> > > type (maybe -rt kernels do it), then you could have a task holding
> > > anon_vma lock and waiting for tasklist_lock, and another holding tasklist
> > > lock and waiting for i_mmap_lock, and another holding i_mmap_lock and
> > > waiting for anon_vma lock.
> > 
> > So you're saying I should change the order?
> 
> Well I don't _think_ we have a dependency already. Yes I would just change
> the order to be either outside both VM locks or inside both. Maybe with
> a note that it does not really matter which order (in case another user
> comes up who needs the opposite ordering).

Ok. I can add a comment.

> > > > +	[RECOVERED] = "Recovered",
> > > 
> > > And what does recovered mean? THe processes were killed and the page taken
> > 
> > Not necessarily killed, it might have been a clean page or so.
> > 
> > > out of circulation, but the machine is still in some unknown state of corruption
> > > henceforth, right?
> > 
> > It's in a known state of corruption -- there was this error on that page
> > and otherwise it's fine (or at least no errors known at this point)
> > The CPU generally tells you when it's in a unknown state and in this case this 
> > code is not executed, but just panic directly.
> 
> Then the data can not have been consumed, by DMA or otherwise? What

When the data was consumed we get a different machine check
(or a different error if it was consumed by a IO device)

This code right now just handles the case of "CPU detected a page is broken
is wrong, but hasn't consumed it yet"

> about transient kernel references to the (pagecache/anonymous) page
> (such as, find_get_page for read(2), or get_user_pages callers).	

There are always races, after all the CPU could be just about 
right now to consume. If we lose the race there will be just
another machine check that stops the consumption of bad data.
The hardware takes care of that.

The code here doesn't try to be a 100% coverage of all
cases (that's obviously impossible), just to handle
common page types. I also originally had ideas for more handlers,
but found out how hard it is to test, so I burried a lot of fancy
ideas :-)

If there are left over references we complain at least.

> > > > +	/*
> > > > +	 * remove_from_page_cache assumes (mapping && !mapped)
> > > > +	 */
> > > > +	if (page_mapping(p) && !page_mapped(p)) {
> > > > +		remove_from_page_cache(p);
> > > > +		page_cache_release(p);
> > > > +	}
> > > 
> > > remove_mapping would probably be a better idea. Otherwise you can
> > > probably introduce pagecache removal vs page fault races whi
> > > will make the kernel bug.
> > 
> > Can you be more specific about the problems?
> 
> Hmm, actually now that we hold the page lock over __do_fault (at least
> for pagecache pages), this may not be able to trigger the race I was
> thinking of (page becoming mapped). But I think still it is better
> to use remove_mapping which is the standard way to remove such a page.

I had this originally, but Fengguang redid it because there was
trouble with the reference count. remove_mapping always expects it to
be 2, which we cannot guarantee.

> 
> BTW. I don't know if you are checking for PG_writeback often enough?
> You can't remove a PG_writeback page from pagecache. The normal
> pattern is lock_page(page); wait_on_page_writeback(page); which I

So pages can be in writeback without being locked? I still
wasn't able to find such a case (in fact unless I'm misreading
the code badly the writeback bit is only used by NFS and a few  
obscure cases)

> think would be safest 

Okay. I'll just add it after the page lock.

> (then you never have to bother with the writeback bit again)

Until Fengguang does something fancy with it.

> > > > +	if (mapping) {
> > > > +		/*
> > > > +		 * Truncate does the same, but we're not quite the same
> > > > +		 * as truncate. Needs more checking, but keep it for now.
> > > > +		 */
> > > 
> > > What's different about truncate? It would be good to reuse as much as possible.
> > 
> > Truncating removes the block on disk (we don't). Truncating shrinks
> > the end of the file (we don't). It's more "temporal hole punch"
> > Probably from the VM point of view it's very similar, but it's
> > not the same.
> 
> Right, I just mean the pagecache side of the truncate. So you should
> use truncate_inode_pages_range here.

Why?  I remember I was trying to use that function very early on but
there was some problem.  For once it does its own locking which
would conflict with ours.

Also we already do a lot of the stuff it does (like unmapping).

Is there anything concretely wrong with the current code?

> > > > +		cancel_dirty_page(p, PAGE_CACHE_SIZE);
> > > > +
> > > > +		/*
> > > > +		 * IO error will be reported by write(), fsync(), etc.
> > > > +		 * who check the mapping.
> > > > +		 */
> > > > +		mapping_set_error(mapping, EIO);
> > > 
> > > Interesting. It's not *exactly* an IO error (well, not like one we're usually
> > > used to).
> > 
> > It's a new kind, but conceptually it's the same. Dirty IO data got corrupted.
> 
> Well, the dirty data has never been corrupted before (ie. the data
> in pagecache has been OK). It was just unable to make it back to
> backing store. So a program could retry the write/fsync/etc or
> try to write the data somewhere else.

In theory it could, but in practice it is very unlikely it would.

> It kind of wants a new error code, but I can't imagine the difficulty
> in doing that...

I don't think it's a good idea to change programs for this normally,
most wouldn't anyways. Even kernel programmers have trouble with
memory suddenly going bad, for user space programmers it would
be pure voodoo.

The only special case is the new fancy SIGBUS, that was mainly done
for forwarding proper machine checks to KVM guests. In theory clever
programs could take advance of that.

> > We actually had a lot of grief with the error reporting; a lot of
> > code does "report error once then clear from mapping", which
> > broke all the tests for that in the test suite. IMHO that's a shady
> > area in the kernel.
> 
> Yeah, it's annoying. I ran over this problem when auditing some
> data integrity problems in the kernel recently. IIRC even a
> misplaced sync from another process can come and suck up the IO
> error that your DBMS was expecting to get from fsync.
> 
> We kind of need another type of syscall to tell the kernel whether
> it can discard errors for a given file/range. But this is not the
> problem for your patch.

Yes, I decided to not try to address that.

> > I don't think the switch would be particularly simple. Also I like
> > tables.
> > 
> > > 
> > > And seeing as you are doing a lot of checking for various page flags anyway,
> > > (eg. in your prepare function). Just seems like needless complexity.
> > 
> > Yes that grew over time unfortunately. Originally there was very little
> > explicit flag checking.
> > 
> > I still think the table is a good approach. 
> 
> Just seems overengineered. We could rewrite any if/switch statement like
> that (and actually the compiler probably will if it is beneficial).

The reason I like it is that it separates the functions cleanly,
without that there would be a dispatcher from hell. Yes it's a bit
ugly that there is a lot of manual bit checking around now too,
but as you go into all the corner cases originally clean code
always tends to get more ugly (and this is a really ugly problem)

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
