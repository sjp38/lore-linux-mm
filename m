Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1DD6B0365
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 19:41:12 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id h30so152853497uaf.1
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 16:41:12 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 74si7921uaf.30.2016.12.20.16.41.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 16:41:11 -0800 (PST)
Date: Tue, 20 Dec 2016 16:40:32 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20161221004031.GF9865@birch.djwong.org>
References: <20160914201936.08315277@roar.ozlabs.ibm.com>
 <20160915023133.GR22388@dastard>
 <20160915134945.0aaa4f5a@roar.ozlabs.ibm.com>
 <20160915103210.GT22388@dastard>
 <20160915214222.505f4888@roar.ozlabs.ibm.com>
 <20160915223350.GU22388@dastard>
 <20160916155405.6b634bbc@roar.ozlabs.ibm.com>
 <20161219211149.GA12822@linux.intel.com>
 <20161220010936.GH7311@birch.djwong.org>
 <CAPcyv4g6LVTVrtGz+vdV2bLvskrYrCBss80qB-HtjAE+Sae=UA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4g6LVTVrtGz+vdV2bLvskrYrCBss80qB-HtjAE+Sae=UA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Moyer <jmoyer@redhat.com>, Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiaof Guangrong <guangrong.xiao@linux.intel.com>, KVM list <kvm@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, Linux MM <linux-mm@kvack.org>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Dec 19, 2016 at 05:18:40PM -0800, Dan Williams wrote:
> On Mon, Dec 19, 2016 at 5:09 PM, Darrick J. Wong
> <darrick.wong@oracle.com> wrote:
> > On Mon, Dec 19, 2016 at 02:11:49PM -0700, Ross Zwisler wrote:
> >> On Fri, Sep 16, 2016 at 03:54:05PM +1000, Nicholas Piggin wrote:
> >> <>
> >> > Definitely the first step would be your simple preallocated per
> >> > inode approach until it is shown to be insufficient.
> >>
> >> Reviving this thread a few months later...
> >>
> >> Dave, we're interested in taking a serious look at what it would take to get
> >> PMEM_IMMUTABLE working.  Do you still hold the opinion that this is (or could
> >> become, with some amount of work) a workable solution?
> >>
> >> We're happy to do the grunt work for this feature, but we will probably need
> >> guidance from someone with more XFS experience.  With you out on extended leave
> >> the first half of 2017, who would be the best person to ask for this guidance?
> >> Darrick?
> >
> > Yes, probably. :)
> >
> > I think where we left off with this (on the XFS side) is some sort of
> > fallocate mode that would allocate blocks, zero them, and then set the
> > DAX and PMEM_IMMUTABLE on-disk inode flags.  After that, you'd mmap the
> > file and thereby gain the ability to control write persistents behavior
> > without having to worry about fs metadata updates.  As an added plus, I
> > think zeroing the pmem also clears media errors, or something like that.
> >
> > <shrug> Is that a reasonable starting point?  My memory is a little foggy.
> >
> > Hmm, I see Dan just posted something about blockdev fallocate.  I'll go
> > read that.
> 
> That's for device-dax, which is basically a poor man's PMEM_IMMUTABLE
> via a character device interface. It's useful for cases where you want
> an entire nvdimm namespace/volume in "no fs-metadata to worry about"
> mode.  But, for sub-allocations of a namespace and support for
> existing tooling, PMEM_IMMUTABLE is much more usable.

Well sure... but otoh I was thinking that it'd be pretty neat if we
could use the same code regardless of whether the target file was a
dax-device or an xfs file:

fd = open("<some path>", O_RDWR);
fstat(fd, &statbuf):
fallocate(fd, FALLOC_FL_PMEM_IMMUTABLE, 0, statbuf.st_size);
p = mmap(NULL, statbuf.st_size, PROT_READ | PROT_WRITE, fd, 0);

*(p + 42) = 0xDEADBEEF;
asm { clflush; } /* or whatever */

...so perhaps it would be a good idea to design the fallocate primitive
around "prepare this fd for mmap-only pmem semantics" and let it the
backend do zeroing and inode flag changes as necessary to make it
happen.  We'd need to do some bikeshedding about what the other falloc
flags mean when we're dealing with pmem files and devices, but I think
we should try to keep the userland presentation the same unless there's
a really good reason not to.

--D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
