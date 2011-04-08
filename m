Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 622998D003B
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 21:26:03 -0400 (EDT)
Date: Fri, 8 Apr 2011 11:25:56 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Lsf] IO less throttling and cgroup aware writeback
Message-ID: <20110408012556.GU31057@dastard>
References: <20110401214947.GE6957@dastard>
 <20110405131359.GA14239@redhat.com>
 <20110405225639.GB31057@dastard>
 <BANLkTikDPHcpjmb-EAiX+MQcu7hfE730DQ@mail.gmail.com>
 <20110406153954.GB18777@redhat.com>
 <xr937hb7568t.fsf@gthelen.mtv.corp.google.com>
 <20110406233602.GK31057@dastard>
 <20110407192424.GE27778@redhat.com>
 <20110407234249.GE30279@dastard>
 <xr93ei5dzhfs.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <xr93ei5dzhfs.fsf@gthelen.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Curt Wohlgemuth <curtw@google.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, lsf@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Apr 07, 2011 at 05:59:35PM -0700, Greg Thelen wrote:
> cc: linux-mm
> 
> Dave Chinner <david@fromorbit.com> writes:
> 
> > On Thu, Apr 07, 2011 at 03:24:24PM -0400, Vivek Goyal wrote:
> >> On Thu, Apr 07, 2011 at 09:36:02AM +1000, Dave Chinner wrote:
> > [...]
> >> > > When I_DIRTY is cleared, remove inode from bdi_memcg->b_dirty.  Delete bdi_memcg
> >> > > if the list is now empty.
> >> > > 
> >> > > balance_dirty_pages() calls mem_cgroup_balance_dirty_pages(memcg, bdi)
> >> > >    if over bg limit, then
> >> > >        set bdi_memcg->b_over_limit
> >> > >            If there is no bdi_memcg (because all inodes of currenta??s
> >> > >            memcg dirty pages where first dirtied by other memcg) then
> >> > >            memcg lru to find inode and call writeback_single_inode().
> >> > >            This is to handle uncommon sharing.
> >> > 
> >> > We don't want to introduce any new IO sources into
> >> > balance_dirty_pages(). This needs to trigger memcg-LRU based bdi
> >> > flusher writeback, not try to write back inodes itself.
> >> 
> >> Will we not enjoy more sequtial IO traffic once we find an inode by
> >> traversing memcg->lru list? So isn't that better than pure LRU based
> >> flushing?
> >
> > Sorry, I wasn't particularly clear there, What I meant was that we
> > ask the bdi-flusher thread to select the inode to write back from
> > the LRU, not do it directly from balance_dirty_pages(). i.e.
> > bdp stays IO-less.
> >
> >> > Alternatively, this problem won't exist if you transfer page N?ache
> >> > state from one memcg to another when you move the inode from one
> >> > memcg to another.
> >> 
> >> But in case of shared inode problem still remains. inode is being written
> >> from two cgroups and it can't be in both the groups as per the exisiting
> >> design.
> >
> > But we've already determined that there is no use case for this
> > shared inode behaviour, so we aren't going to explictly support it,
> > right?
> 
> I am thinking that we should avoid ever scanning the memcg lru for dirty
> pages or corresponding dirty inodes previously associated with other
> memcg.  I think the only reason we considered scanning the lru was to
> handle the unexpected shared inode case.  When such inode sharing occurs
> the sharing memcg will not be confined to the memcg's dirty limit.
> There's always the memcg hard limit to cap memcg usage.

Yup, fair enough.


> I'd like to add a counter (or at least tracepoint) to record when such
> unsupported usage is detected.

Definitely. Very good idea.

> 1. memcg_1/process_a, writes to /var/log/messages and closes the file.
>    This marks the inode in the bdi_memcg for memcg_1.
> 
> 2. memcg_2/process_b, continually writes to /var/log/messages.  This
>    drives up memcg_2 dirty memory usage to the memcg_2 background
>    threshold.  mem_cgroup_balance_dirty_pages() would normally mark the
>    corresponding bdi_memcg as over-bg-limit and kick the bdi_flusher and
>    then return to the dirtying process.  However, there is no bdi_memcg
>    because there are no dirty inodes for memcg_2.  So the bdi flusher
>    sees no bdi_memcg as marked over-limit, so bdi flusher writes nothing
>    (assuming we're still below system background threshold).
> 
> 3. memcg_2/process_b, continues writing to /var/log/messages hitting the
>    memcg_2 dirty memory foreground threshold.  Using IO-less
>    balance_dirty_pages(), normally mem_cgroup_balance_dirty_pages()
>    would block waiting for the previously kicked bdi flusher to clean
>    some memcg_2 pages.  In this case mem_cgroup_balance_dirty_pages()
>    sees no bdi_memcg and concludes that bdi flusher will not be lowering
>    memcg dirty memory usage.  This is the unsupported sharing case, so
>    mem_cgroup_balance_dirty_pages() fires a tracepoint and just returns
>    allowing memcg_2 dirty memory to exceed its foreground limit growing
>    upwards to the memcg_2 memory limit_in_bytes.  Once limit_in_bytes is
>    hit it will use per memcg direct reclaim to recycle memcg_2 pages,
>    including the previously written memcg_2 /var/log/messages dirty
>    pages.

Thanks for the good, simple  example.

> By cutting out lru scanning the code should be simpler and still
> handle the common case well.

Agreed.

> If we later find that this supposed uncommon shared inode case is
> important then we can either implement the previously described lru
> scanning in mem_cgroup_balance_dirty_pages() or consider extending the
> bdi/memcg/inode data structures (perhaps with a memcg_mapping) to
> describe such sharing.

Hmm, another idea I just had. What we're trying to avoid is needing
to a) track inodes in multiple lists, and b) scanning to find
something appropriate to write back.

Rather than tracking at page or inode granularity, how about
tracking "associated" memcgs at the memcg level? i.e. when we detect
an inode is already dirty in another memcg, link the current memcg
to the one that contains the inode. Hence if we get a situation
where a memcg is throttling with no dirty inodes, it can quickly
find and start writeback in an "associated" memcg that it _knows_
contain shared dirty inodes. Once we've triggered writeback on an
associated memcg, it is removed from the list....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
