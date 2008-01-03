Subject: Re: [patch 00/19] VM pageout scalability improvements
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080103120000.1768f220@cuia.boston.redhat.com>
References: <20080102224144.885671949@redhat.com>
	 <1199379128.5295.21.camel@localhost>
	 <20080103120000.1768f220@cuia.boston.redhat.com>
Content-Type: text/plain
Date: Thu, 03 Jan 2008 12:13:32 -0500
Message-Id: <1199380412.5295.29.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-01-03 at 12:00 -0500, Rik van Riel wrote:
> On Thu, 03 Jan 2008 11:52:08 -0500
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> 
> > Also, I should point out that the full noreclaim series includes a
> > couple of other patches NOT posted here by Rik:
> > 
> > 1) treat swap backed pages as nonreclaimable when no swap space is
> > available.  This addresses a problem we've seen in real life, with
> > vmscan spending a lot of time trying to reclaim anon/shmem/tmpfs/...
> > pages only to find that there is no swap space--add_to_swap() fails.
> > Maybe not a problem with Rik's new anon page handling.
> 
> If there is no swap space, my VM code will not bother scanning
> any anon pages.  This has the same effect as moving the pages
> to the no-reclaim list, with the extra benefit of being able to
> resume scanning the anon lists once swap space is freed.
> 
> > 2) treat anon pages with "excessively long" anon_vma lists as
> > nonreclaimable.   "excessively long" here is a sysctl tunable parameter.
> > This also addresses problems we've seen with benchmarks and stress
> > tests--all cpus spinning on some anon_vma lock.  In "real life", we've
> > seen this behavior with file backed pages--spinning on the
> > i_mmap_lock--running Oracle workloads with user counts in the few
> > thousands.  Again, something we may not need with Rik's vmscan rework.
> > If we did want to do this, we'd probably want to address file backed
> > pages and add support to bring the pages back from the noreclaim list
> > when the number of "mappers" drops below the threshold.  My current
> > patch leaves anon pages as non-reclaimable until they're freed, or
> > manually scanned via the mechanism introduced by patch 12.
> 
> I can see some issues with that patch.  Specifically, if the threshold
> is set too high no pages will be affected, and if the threshold is too
> low all pages will become non-reclaimable, leading to a false OOM kill.
> 
> Not only is it a very big hammer, it's also a rather awkward one...

Yes, but the problem, when it occurs, is very awkward.  The system just
hangs for hours/days spinning on the reverse mapping locks--in both
page_referenced() and try_to_unmap().  No pages get reclaimed and NO OOM
kill occurs because we never get that far.  So, I'm not sure I'd call
any OOM kills resulting from this patch as "false".  The memory is
effectively nonreclaimable.   Now, I think that your anon pages SEQ
patch will eliminate the contention in page_referenced[_anon](), but we
could still hang in try_to_unmap().  And we have the issue with file
back pages and the i_mmap_lock.  I'll see if this issue comes up in
testings with the current series.  If not, cool!  If so, we just have
more work to do.

Later,
Lee
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
