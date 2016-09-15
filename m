Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC4556B0038
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:42:36 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v67so89670717pfv.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:42:36 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id r12si3926056pag.107.2016.09.15.04.42.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 04:42:35 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id vz6so2054830pab.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:42:35 -0700 (PDT)
Date: Thu, 15 Sep 2016 21:42:22 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160915214222.505f4888@roar.ozlabs.ibm.com>
In-Reply-To: <20160915103210.GT22388@dastard>
References: <20160912052703.GA1897@infradead.org>
	<CAOSf1CHaW=szD+YEjV6vcUG0KKr=aXv8RXomw9xAgknh_9NBFQ@mail.gmail.com>
	<20160912075128.GB21474@infradead.org>
	<20160912180507.533b3549@roar.ozlabs.ibm.com>
	<20160912213435.GD30497@dastard>
	<20160913115311.509101b0@roar.ozlabs.ibm.com>
	<20160914073902.GQ22388@dastard>
	<20160914201936.08315277@roar.ozlabs.ibm.com>
	<20160915023133.GR22388@dastard>
	<20160915134945.0aaa4f5a@roar.ozlabs.ibm.com>
	<20160915103210.GT22388@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, Oliver O'Halloran <oohall@gmail.com>, Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KVM list <kvm@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>

On Thu, 15 Sep 2016 20:32:10 +1000
Dave Chinner <david@fromorbit.com> wrote:

> On Thu, Sep 15, 2016 at 01:49:45PM +1000, Nicholas Piggin wrote:
> > On Thu, 15 Sep 2016 12:31:33 +1000
> > Dave Chinner <david@fromorbit.com> wrote:
> >   
> > > On Wed, Sep 14, 2016 at 08:19:36PM +1000, Nicholas Piggin wrote:  
> > > > On Wed, 14 Sep 2016 17:39:02 +1000  
> > > Sure, but one first has to describe the feature desired before all  
> > 
> > The DAX people have been.  
> 
> Hmmmm. the only "DAX people" I know of are kernel developers who
> have been working on implementing DAX in the kernel - Willy, Ross,
> Dan, Jan, Christoph, Kirill, myelf and a few others around the
> fringes.
> 
> > They want to be able to get mappings
> > that can be synced without doing fsync.  
> 
> Oh, ok, the Intel Userspace PMEM library requirement. I though you
> had something more that this - whatever extra problem the per-block
> no fsync flag would solve?

Only the PMEM really. I don't want to add more complexity than
required.

> > The *exact* extent of
> > those capabilities and what the API exactly looks like is up for
> > discussion.  
> 
> Yup.
> 
> > Well you said it was impossible already and Christoph told them
> > they were smoking crack :)  
> 
> I have not said that. I have said bad things about bad
> proposals and called the PMEM library model broken, but I most
> definitely have not said that solving the problem is impossible.
>
> > > That's not an answer to the questions I asked about about the "no
> > > sync" flag you were proposing. You've redirected to the a different
> > > solution, one that ....  
> > 
> > No sync flag would do the same thing exactly in terms of consistency.
> > It would just do the no-sync sequence by default rather than being
> > asked for it. More of an API detail than implementation.  
> 
> You still haven't described anything about what a per-block flag
> design is supposed to look like.... :/

For the API, or implementation? I'm not quite sure what you mean
here. For implementation it's possible to carefully ensure metadata
is persistent when allocating blocks in page fault but before
mapping pages. Truncate or hole punch or such things can be made to
work by invalidating all such mappings and holding them off until
you can cope with them again. Not necessarily for a filesystem with
*all* capabilities of XFS -- I don't know -- but for a complete basic
one.

> > > > Filesystem will
> > > > invalidate all such mappings before it does buffered IOs or hole punch,
> > > > and will sync metadata after allocating a new block but before returning
> > > > from a fault.    
> > > 
> > > ... requires synchronous metadata updates from page fault context,
> > > which we already know is not a good solution.  I'll quote one of
> > > Christoph's previous replies to save me the trouble:
> > > 
> > > 	"You could write all metadata synchronously from the page
> > > 	fault handler, but that's basically asking for all kinds of
> > > 	deadlocks."
> > > So, let's redirect back to the "no sync" flag you were talking about
> > > - can you answer the questions I asked above? It would be especially
> > > important to highlight how the proposed feature would avoid requiring
> > > synchronous metadata updates in page fault contexts....  
> > 
> > Right. So what deadlocks are you concerned about?  
> 
> It basically puts the entire journal checkpoint path under a page
> fault context. i.e. a whole new global locking context problem is

Yes there are potentially some new lock orderings created if you
do that, depending on what locks the filesystem does.

> created as this path can now be run both inside and outside the
> mmap_sem. Nothing ever good comes from running filesystem locking
> code both inside and outside the mmap_sem.

You mean that some cases journal checkpoint runs with mmap_sem
held, and others without mmap_sem held? Not that mmap_sem is taken
inside journal checkpoint. Then I don't really see why that's a
problem. I mean performance could suffer a bit, but with fault
retry you can almost always do the syncing outside mmap_sem in
practice.

Yes, I'll preemptively agree with you -- We don't want to add any
such burden if it is not needed and well justified.

> FWIW, We've never executed synchronous transactions inside page
> faults in XFS, and I think ext4 is in the same boat - it may be even
> worse because of the way it does ordered data dispatch through the
> journal. I don't really even want to think about the level of hurt
> this might put btrfs or other COW/log structured filesystems under.
> I'm sure Christoph can reel off a bunch more issues off the top of
> his head....

I asked him, we'll see what he thinks. I don't beleive there is
anything fundamental about mm or fs core layers that cause deadlocks
though.

> 
> > There could be a scale of capabilities here, for different filesystems
> > that do things differently.   
> 
> Why do we need such complexity to be defined?
> 
> I'm tending towards just adding new fallocate() operation that sets
> up a fully allocated and zeroed file of fixed length that has
> immutable metadata once created. Single syscall, with well dfined
> semantics, and it doesn't dictate the implementation any filesystem
> must use. All it dictates is that the data region can be written
> safely on dax-enabled storage without needing fsync() to be issued.
> 
> i.e. the implementation can be filesystem specific, and it is simple
> to implement the basic functionality and constraints in both XFS and
> ext4 right away, and as othe filesystems come along they can
> implement it in the way that best suits them. e.g. btrfs would need
> to add the "no COW" flag to the file as well.
> 
> If someone wants to implement a per-block no-fsync flag, and  do
> sycnhronous metadata updates in the page fault path, then they are
> welcome to do so. But we don't /need/ such complexity to implement
> the functionality that pmem programming model requires.

Sure. That's about what I meant by scale of capabilities. And beyond
that I would be as happy as you if that was sufficient. It raises
the bar for justifying more complexity, which is always good.


> > Some filesystems could require fsync for metadata, but allow fdatasync
> > to be skipped. Users would need to have some knowledge of block size
> > or do preallocation and sync.  
> 
> Not sure what you mean here -  avoiding the need for using fsync()
> by using fsync() seems a little circular to me.  :/

I meant if blocks are already preallocated and metadata unchanging,
basically like your above proposal.

> 
> > That might put more burden on libraries/applications if there are
> > concurrent operations, but that might be something they can deal with
> > -- fdatasync already requires some knowledge of concurrent operations
> > (or lack thereof).  
> 
> Additional userspace complexity is something we should avoid.
> 
> 
> > You and Christoph know a huge amount about vfs and filesystems.
> > But sometimes you shut people down prematurely.  
> 
> Appearances can be deceiving.  I don't shut discussions down unless
> my time is being wasted, and that's pretty rare.
> 
> [You probably know most of what I'm about to write, but I'm not
> actually writing it for you.... ]
> 
> > It can be very
> > intimidating for someone who might not know *exactly* what they
> > are asking for or have not considered some difficult locking case
> > in a filesystem.  
> 
> Yup, most kernel developers are aware that this is how the mailing
> list discussions appear from the outside.

[...]

Point taken and I don't want to harp on about it. You guys can
still be intimidating to good kernel programmers who otherwise
don't know vfs and several filesystems inside out, that's all.


> > That said, I don't want to derail their thread any further with
> > this. So I apologise for my tone to you, Dave.  
> 
> Accepted. Let's start over, eh?

That would be good.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
