Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 782A06B0069
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 21:31:41 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ex14so225977176pac.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 18:31:41 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id f67si24498833pff.200.2016.09.12.18.31.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 18:31:40 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id g202so8850472pfb.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 18:31:39 -0700 (PDT)
Date: Tue, 13 Sep 2016 11:31:28 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160913113128.4eae792e@roar.ozlabs.ibm.com>
In-Reply-To: <20160912150148.GA10039@infradead.org>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
	<20160908225636.GB15167@linux.intel.com>
	<20160912052703.GA1897@infradead.org>
	<CAOSf1CHaW=szD+YEjV6vcUG0KKr=aXv8RXomw9xAgknh_9NBFQ@mail.gmail.com>
	<20160912075128.GB21474@infradead.org>
	<20160912180507.533b3549@roar.ozlabs.ibm.com>
	<20160912150148.GA10039@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Oliver O'Halloran <oohall@gmail.com>, Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KVM list <kvm@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>

On Mon, 12 Sep 2016 08:01:48 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Sep 12, 2016 at 06:05:07PM +1000, Nicholas Piggin wrote:
> > It's not fundamentally broken, it just doesn't fit well existing
> > filesystems.  
> 
> Or the existing file system architecture for that matter.  Which makes
> it a fundamentally broken model.

Not really. A few reasonable changes can be made to improve things.
Until just now you thought it was fundamentally impossible to make a
reasonable implementation due to Dave's "constraints".

> 
> > Dave's post of requirements is also wrong. A filesystem does not have
> > to guarantee all that, it only has to guarantee that is the case for
> > a given block after it has a mapping and page fault returns, other
> > operations can be supported by invalidating mappings, etc.  
> 
> Which doesn't really matter if your use case is manipulating
> fully mapped files.

Nothing that says you have to use them fully mapped always and not
use other APIs on them.


> But back to the point: if you want to use a full blown Linux or Unix
> filesystem you will always have to fsync (or variants of it like msync),
> period.

That's circular logic. First you said that should not be done
because of your imagined constraints.

In fact, it's not unreasonable to describe some additional semantics
of the storage that is unavailable with traditional filesystems.

That said, a noop system call is on the order of 100 cycles nowadays,
so rushing to implement these APIs without seeing good numbers and
actual users ready to go seems premature. *This* is the real reason
not to implement new APIs yet.


> If you want a volume manager on stereoids that hands out large chunks
> of storage memory that can't ever be moved, truncated, shared, allocated
> on demand, etc - implement it in your library on top of a device file.

Those constraints don't exist either. I've written a filesystem
that avoids them. It isn't rocket science.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
