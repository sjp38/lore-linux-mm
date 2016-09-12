Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 964EB6B0069
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 17:34:41 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e1so301110483itb.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 14:34:41 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id h201si5883034ioe.128.2016.09.12.14.34.39
        for <linux-mm@kvack.org>;
        Mon, 12 Sep 2016 14:34:40 -0700 (PDT)
Date: Tue, 13 Sep 2016 07:34:36 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160912213435.GD30497@dastard>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
 <20160908225636.GB15167@linux.intel.com>
 <20160912052703.GA1897@infradead.org>
 <CAOSf1CHaW=szD+YEjV6vcUG0KKr=aXv8RXomw9xAgknh_9NBFQ@mail.gmail.com>
 <20160912075128.GB21474@infradead.org>
 <20160912180507.533b3549@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160912180507.533b3549@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Oliver O'Halloran <oohall@gmail.com>, Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KVM list <kvm@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>

On Mon, Sep 12, 2016 at 06:05:07PM +1000, Nicholas Piggin wrote:
> On Mon, 12 Sep 2016 00:51:28 -0700
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > On Mon, Sep 12, 2016 at 05:25:15PM +1000, Oliver O'Halloran wrote:
> > > What are the problems here? Is this a matter of existing filesystems
> > > being unable/unwilling to support this or is it just fundamentally
> > > broken?  
> > 
> > It's a fundamentally broken model.  See Dave's post that actually was
> > sent slightly earlier then mine for the list of required items, which
> > is fairly unrealistic.  You could probably try to architect a file
> > system for it, but I doubt it would gain much traction.
> 
> It's not fundamentally broken, it just doesn't fit well existing
> filesystems.
> 
> Dave's post of requirements is also wrong. A filesystem does not have
> to guarantee all that, it only has to guarantee that is the case for
> a given block after it has a mapping and page fault returns, other
> operations can be supported by invalidating mappings, etc.

Sure, but filesystems are completely unaware of what is mapped at
any given time, or what constraints that mapping might have. Trying
to make filesystems aware of per-page mapping constraints seems like
a fairly significant layering violation based on a flawed
assumption. i.e. that operations on other parts of the file do not
affect the block that requires immutable metadata.

e.g an extent operation in some other area of the file can cause a
tip-to-root extent tree split or merge, and that moves the metadata
that points to the mapped block that we've told userspace "doesn't
need fsync".  We now need an fsync to ensure that the metadata is
consistent on disk again, even though that block has not physically
been moved. IOWs, the immutable data block updates are now not
ordered correctly w.r.t. other updates done to the file, especially
when we consider crash recovery....

All this will expose is an unfixable problem with ordering of stable
data + metadata operations and their synchronisation. As such, it
seems like nothing but a major cluster-fuck to try to do mapping
specific, per-block immutable metadata - it adds major complexity
and even more untractable problems.

Yes, we /could/ try to solve this but, quite frankly, it's far
easier to change the broken PMEM programming model assumptions than
it is to implement what you are suggesting. Or to do what Christoph
suggested and just use a wrapper around something like device
mapper to hand out chunks of unchanging, static pmem to
applications...

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
