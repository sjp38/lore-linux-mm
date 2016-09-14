Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2DEF16B0069
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 03:39:20 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 192so28196787itm.1
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 00:39:20 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id k134si3644636iok.119.2016.09.14.00.39.05
        for <linux-mm@kvack.org>;
        Wed, 14 Sep 2016 00:39:07 -0700 (PDT)
Date: Wed, 14 Sep 2016 17:39:02 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160914073902.GQ22388@dastard>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
 <20160908225636.GB15167@linux.intel.com>
 <20160912052703.GA1897@infradead.org>
 <CAOSf1CHaW=szD+YEjV6vcUG0KKr=aXv8RXomw9xAgknh_9NBFQ@mail.gmail.com>
 <20160912075128.GB21474@infradead.org>
 <20160912180507.533b3549@roar.ozlabs.ibm.com>
 <20160912213435.GD30497@dastard>
 <20160913115311.509101b0@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160913115311.509101b0@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Oliver O'Halloran <oohall@gmail.com>, Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KVM list <kvm@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>

On Tue, Sep 13, 2016 at 11:53:11AM +1000, Nicholas Piggin wrote:
> On Tue, 13 Sep 2016 07:34:36 +1000
> Dave Chinner <david@fromorbit.com> wrote:
> But let me understand your example in the absence of that.
> 
> - Application mmaps a file, faults in block 0
> - FS allocates block, creates mappings, syncs metadata, sets "no fsync"
>   flag for that block, and completes the fault.
> - Application writes some data to block 0, completes userspace flushes
> 
> * At this point, a crash must return with above data (or newer).
> 
> - Application starts writing more stuff into block 0
> - Concurrently, fault in block 1
> - FS starts to allocate, splits trees including mappings to block 0
> 
> * Crash
> 
> Is that right?

No.

- app write faults block 0, fs allocates
< time passes while app does stuff to block 0 mapping >
- fs syncs journal, block 0 metadata now persistent
< time passes while app does stuff to block 0 mapping >
- app structure grows, faults block 1, fs allocates
- app adds pointers to data in block 1 from block 0, does
  userspace pmem data sync.

*crash*

> How does your filesystem lose data before the sync
> point?

After recovery, file has a data in block 0, but no block 1 because
the allocation transaction for block 1 was not flushed to the
journal. Data in block 0 points to data in block 1, but block 1 does
not exist. IOWs, the application has corrupt data because it never
issued a data synchronisation request to the filesystem....

----

Ok, looking back over your example, you seem to be suggesting a new
page fault behaviour is required from filesystems that has not been
described or explained, and that behaviour is triggered
(persistently) somehow from userspace. You've also suggested
filesystems store a persistent per-block "no fsync" flag
in their extent map as part of the implementation. Right?

Reading between the lines, I'm guessing that the "no fsync" flag has
very specific update semantics, constraints and requirements.  Can
you outline how you expect this flag to be set and updated, how it's
used consistently between different applications (e.g. cp of a file
vs the app using the file), behavioural constraints it implies for
page faults vs non-mmap access to the data in the block, how
you'd expect filesystems to deal with things like a hole punch
landing in the middle of an extent marked with "no fsync", etc?

[snip]

> If there is any huge complexity or unsolved problem, it is in XFS.
> Conceptual problem is simple.

Play nice and be constructive, please?

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
