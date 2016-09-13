Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBD5A6B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 05:06:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g202so416866625pfb.3
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 02:06:17 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id b74si4132953pfc.187.2016.09.13.02.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 02:06:16 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id x24so9342163pfa.3
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 02:06:16 -0700 (PDT)
Date: Tue, 13 Sep 2016 19:06:04 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160913190604.10f523b0@roar.ozlabs.ibm.com>
In-Reply-To: <20160913071732.GA19433@infradead.org>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
	<20160908225636.GB15167@linux.intel.com>
	<20160912052703.GA1897@infradead.org>
	<CAOSf1CHaW=szD+YEjV6vcUG0KKr=aXv8RXomw9xAgknh_9NBFQ@mail.gmail.com>
	<20160912075128.GB21474@infradead.org>
	<20160912180507.533b3549@roar.ozlabs.ibm.com>
	<20160912213435.GD30497@dastard>
	<20160913115311.509101b0@roar.ozlabs.ibm.com>
	<20160913071732.GA19433@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Oliver O'Halloran <oohall@gmail.com>, Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KVM list <kvm@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>

On Tue, 13 Sep 2016 00:17:32 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Tue, Sep 13, 2016 at 11:53:11AM +1000, Nicholas Piggin wrote:
> > - Application mmaps a file, faults in block 0
> > - FS allocates block, creates mappings, syncs metadata, sets "no fsync"
> >   flag for that block, and completes the fault.
> > - Application writes some data to block 0, completes userspace flushes
> > 
> > * At this point, a crash must return with above data (or newer).
> > 
> > - Application starts writing more stuff into block 0
> > - Concurrently, fault in block 1
> > - FS starts to allocate, splits trees including mappings to block 0
> > 
> > * Crash
> > 
> > Is that right? How does your filesystem lose data before the sync
> > point?  
> 
> Witht all current file systems chances are your metadata hasn't been
> flushed out.  You could write all metadata synchronously from the

Yes, that's a possibility. Another would be an advise call to
request the capability for a given region.


> page fault handler, but that's basically asking for all kinds of
> deadlocks.

Such as?


> > If there is any huge complexity or unsolved problem, it is in XFS.
> > Conceptual problem is simple.  
> 
> Good to have you back and make all the hard thing simple :)

Thanks...? :)

I don't mean to say it's simple to add it to any filesystem or
that vfs and mm doesn't need any changes at all.

If we can agree on something, no new APIs should be added without
careful thought and justification and users. I only suggest not to
dismiss it out of hand.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
