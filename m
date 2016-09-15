Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 71EA36B0069
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 18:35:05 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id wk8so116349769pab.3
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 15:35:05 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id n81si41527548pfb.192.2016.09.15.15.35.03
        for <linux-mm@kvack.org>;
        Thu, 15 Sep 2016 15:35:04 -0700 (PDT)
Date: Fri, 16 Sep 2016 08:33:50 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160915223350.GU22388@dastard>
References: <20160912075128.GB21474@infradead.org>
 <20160912180507.533b3549@roar.ozlabs.ibm.com>
 <20160912213435.GD30497@dastard>
 <20160913115311.509101b0@roar.ozlabs.ibm.com>
 <20160914073902.GQ22388@dastard>
 <20160914201936.08315277@roar.ozlabs.ibm.com>
 <20160915023133.GR22388@dastard>
 <20160915134945.0aaa4f5a@roar.ozlabs.ibm.com>
 <20160915103210.GT22388@dastard>
 <20160915214222.505f4888@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160915214222.505f4888@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Oliver O'Halloran <oohall@gmail.com>, Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KVM list <kvm@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>

On Thu, Sep 15, 2016 at 09:42:22PM +1000, Nicholas Piggin wrote:
> On Thu, 15 Sep 2016 20:32:10 +1000
> Dave Chinner <david@fromorbit.com> wrote:
> > 
> > You still haven't described anything about what a per-block flag
> > design is supposed to look like.... :/
> 
> For the API, or implementation? I'm not quite sure what you mean
> here. For implementation it's possible to carefully ensure metadata
> is persistent when allocating blocks in page fault but before
> mapping pages. Truncate or hole punch or such things can be made to
> work by invalidating all such mappings and holding them off until
> you can cope with them again. Not necessarily for a filesystem with
> *all* capabilities of XFS -- I don't know -- but for a complete basic
> one.

SO, essentially, it comes down to synchrnous metadta updates again.
but synchronous updates would be conditional on whether an extent
metadata with the "nofsync" flag asserted was updated? Where's the
nofsync flag kept? in memory at a generic layer, or in the
filesystem, potentially in an on-disk structure? How would the
application set it for a given range?

> > > > > Filesystem will
> > > > > invalidate all such mappings before it does buffered IOs or hole punch,
> > > > > and will sync metadata after allocating a new block but before returning
> > > > > from a fault.    
> > > > 
> > > > ... requires synchronous metadata updates from page fault context,
> > > > which we already know is not a good solution.  I'll quote one of
> > > > Christoph's previous replies to save me the trouble:
> > > > 
> > > > 	"You could write all metadata synchronously from the page
> > > > 	fault handler, but that's basically asking for all kinds of
> > > > 	deadlocks."
> > > > So, let's redirect back to the "no sync" flag you were talking about
> > > > - can you answer the questions I asked above? It would be especially
> > > > important to highlight how the proposed feature would avoid requiring
> > > > synchronous metadata updates in page fault contexts....  
> > > 
> > > Right. So what deadlocks are you concerned about?  
> > 
> > It basically puts the entire journal checkpoint path under a page
> > fault context. i.e. a whole new global locking context problem is
> 
> Yes there are potentially some new lock orderings created if you
> do that, depending on what locks the filesystem does.

Well, that's the whole issue.

> > created as this path can now be run both inside and outside the
> > mmap_sem. Nothing ever good comes from running filesystem locking
> > code both inside and outside the mmap_sem.
> 
> You mean that some cases journal checkpoint runs with mmap_sem
> held, and others without mmap_sem held? Not that mmap_sem is taken
> inside journal checkpoint.

Maybe not, but now we open up the potential for locks held inside
or outside mmap sem to interact with the journal locks that are now
held inside and outside mmap_sem. See below....

> Then I don't really see why that's a
> problem. I mean performance could suffer a bit, but with fault
> retry you can almost always do the syncing outside mmap_sem in
> practice.
> 
> Yes, I'll preemptively agree with you -- We don't want to add any
> such burden if it is not needed and well justified.
> 
> > FWIW, We've never executed synchronous transactions inside page
> > faults in XFS, and I think ext4 is in the same boat - it may be even
> > worse because of the way it does ordered data dispatch through the
> > journal. I don't really even want to think about the level of hurt
> > this might put btrfs or other COW/log structured filesystems under.
> > I'm sure Christoph can reel off a bunch more issues off the top of
> > his head....
> 
> I asked him, we'll see what he thinks. I don't beleive there is
> anything fundamental about mm or fs core layers that cause deadlocks
> though.

Spent 5 minutes looking at ext4 for an example: filesystems are
allowed to take page locks during transaction commit. e.g ext4
journal commit when using the default ordered data mode:

jbd2_journal_commit_transaction
  journal_submit_data_buffers()
    journal_submit_inode_data_buffers
      generic_writepages()
        ext4_writepages()
	  mpage_prepare_extent_to_map()
	    lock_page()

i.e. if we fault on the user buffer during a write() operation and
that user buffer is a mmapped DAX file that needs to be allocated
and we have synchronous metadata updates during page faults, we
deadlock on the page lock held above the page fault context...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
