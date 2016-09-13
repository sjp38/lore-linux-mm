Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9979E6B0069
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 21:53:24 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ex14so226816762pac.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 18:53:24 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id q7si24555121pax.43.2016.09.12.18.53.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 18:53:23 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id 128so8859677pfb.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 18:53:23 -0700 (PDT)
Date: Tue, 13 Sep 2016 11:53:11 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160913115311.509101b0@roar.ozlabs.ibm.com>
In-Reply-To: <20160912213435.GD30497@dastard>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
	<20160908225636.GB15167@linux.intel.com>
	<20160912052703.GA1897@infradead.org>
	<CAOSf1CHaW=szD+YEjV6vcUG0KKr=aXv8RXomw9xAgknh_9NBFQ@mail.gmail.com>
	<20160912075128.GB21474@infradead.org>
	<20160912180507.533b3549@roar.ozlabs.ibm.com>
	<20160912213435.GD30497@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, Oliver O'Halloran <oohall@gmail.com>, Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KVM list <kvm@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>

On Tue, 13 Sep 2016 07:34:36 +1000
Dave Chinner <david@fromorbit.com> wrote:

> On Mon, Sep 12, 2016 at 06:05:07PM +1000, Nicholas Piggin wrote:
> > On Mon, 12 Sep 2016 00:51:28 -0700
> > Christoph Hellwig <hch@infradead.org> wrote:
> >   
> > > On Mon, Sep 12, 2016 at 05:25:15PM +1000, Oliver O'Halloran wrote:  
> > > > What are the problems here? Is this a matter of existing filesystems
> > > > being unable/unwilling to support this or is it just fundamentally
> > > > broken?    
> > > 
> > > It's a fundamentally broken model.  See Dave's post that actually was
> > > sent slightly earlier then mine for the list of required items, which
> > > is fairly unrealistic.  You could probably try to architect a file
> > > system for it, but I doubt it would gain much traction.  
> > 
> > It's not fundamentally broken, it just doesn't fit well existing
> > filesystems.
> > 
> > Dave's post of requirements is also wrong. A filesystem does not have
> > to guarantee all that, it only has to guarantee that is the case for
> > a given block after it has a mapping and page fault returns, other
> > operations can be supported by invalidating mappings, etc.  
> 
> Sure, but filesystems are completely unaware of what is mapped at
> any given time, or what constraints that mapping might have. Trying
> to make filesystems aware of per-page mapping constraints seems like

I'm not sure what you mean. The filesystem can hand out mappings
and fault them in itself. It can invalidate them.


> a fairly significant layering violation based on a flawed
> assumption. i.e. that operations on other parts of the file do not
> affect the block that requires immutable metadata.
> 
> e.g an extent operation in some other area of the file can cause a
> tip-to-root extent tree split or merge, and that moves the metadata
> that points to the mapped block that we've told userspace "doesn't
> need fsync".  We now need an fsync to ensure that the metadata is
> consistent on disk again, even though that block has not physically
> been moved.

You don't, because the filesystem can invalidate existing mappings
and do the right thing when they are faulted in again. That's the
big^Wmedium hammer approach that can cope with most problems.

But let me understand your example in the absence of that.

- Application mmaps a file, faults in block 0
- FS allocates block, creates mappings, syncs metadata, sets "no fsync"
  flag for that block, and completes the fault.
- Application writes some data to block 0, completes userspace flushes

* At this point, a crash must return with above data (or newer).

- Application starts writing more stuff into block 0
- Concurrently, fault in block 1
- FS starts to allocate, splits trees including mappings to block 0

* Crash

Is that right? How does your filesystem lose data before the sync
point?

> IOWs, the immutable data block updates are now not
> ordered correctly w.r.t. other updates done to the file, especially
> when we consider crash recovery....
> 
> All this will expose is an unfixable problem with ordering of stable
> data + metadata operations and their synchronisation. As such, it
> seems like nothing but a major cluster-fuck to try to do mapping
> specific, per-block immutable metadata - it adds major complexity
> and even more untractable problems.
> 
> Yes, we /could/ try to solve this but, quite frankly, it's far
> easier to change the broken PMEM programming model assumptions than
> it is to implement what you are suggesting. Or to do what Christoph
> suggested and just use a wrapper around something like device
> mapper to hand out chunks of unchanging, static pmem to
> applications...

If there is any huge complexity or unsolved problem, it is in XFS.
Conceptual problem is simple.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
