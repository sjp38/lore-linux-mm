Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 231166B03D7
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 16:33:38 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id q197so408431824oic.7
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 13:33:38 -0800 (PST)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id j54si1962369ote.236.2016.12.21.13.33.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 13:33:37 -0800 (PST)
Received: by mail-oi0-x22c.google.com with SMTP id b126so223529806oia.2
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 13:33:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161221212412.GB4758@dastard>
References: <20160915134945.0aaa4f5a@roar.ozlabs.ibm.com> <20160915103210.GT22388@dastard>
 <20160915214222.505f4888@roar.ozlabs.ibm.com> <20160915223350.GU22388@dastard>
 <20160916155405.6b634bbc@roar.ozlabs.ibm.com> <20161219211149.GA12822@linux.intel.com>
 <20161220010936.GH7311@birch.djwong.org> <CAPcyv4g6LVTVrtGz+vdV2bLvskrYrCBss80qB-HtjAE+Sae=UA@mail.gmail.com>
 <20161221004031.GF9865@birch.djwong.org> <CAPcyv4g3sgQ=Lh99RP7V5g-okgdC=BaeW8oLtHRfwU1gmh07=A@mail.gmail.com>
 <20161221212412.GB4758@dastard>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 21 Dec 2016 13:33:36 -0800
Message-ID: <CAPcyv4i3xoNEe6VpVRCxZrhwEdVqHEAJGHFnHZS62OwFZJ9e3w@mail.gmail.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in /proc/self/smaps)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, Jan Kara <jack@suse.cz>, Jeff Moyer <jmoyer@redhat.com>, Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiaof Guangrong <guangrong.xiao@linux.intel.com>, KVM list <kvm@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, Linux MM <linux-mm@kvack.org>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Dec 21, 2016 at 1:24 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Wed, Dec 21, 2016 at 08:53:46AM -0800, Dan Williams wrote:
>> On Tue, Dec 20, 2016 at 4:40 PM, Darrick J. Wong
>> <darrick.wong@oracle.com> wrote:
>> > On Mon, Dec 19, 2016 at 05:18:40PM -0800, Dan Williams wrote:
>> >> On Mon, Dec 19, 2016 at 5:09 PM, Darrick J. Wong
>> >> <darrick.wong@oracle.com> wrote:
>> >> > On Mon, Dec 19, 2016 at 02:11:49PM -0700, Ross Zwisler wrote:
>> >> >> On Fri, Sep 16, 2016 at 03:54:05PM +1000, Nicholas Piggin wrote:
>> >> >> <>
>> >> >> > Definitely the first step would be your simple preallocated per
>> >> >> > inode approach until it is shown to be insufficient.
>> >> >>
>> >> >> Reviving this thread a few months later...
>> >> >>
>> >> >> Dave, we're interested in taking a serious look at what it would take to get
>> >> >> PMEM_IMMUTABLE working.  Do you still hold the opinion that this is (or could
>> >> >> become, with some amount of work) a workable solution?
>> >> >>
>> >> >> We're happy to do the grunt work for this feature, but we will probably need
>> >> >> guidance from someone with more XFS experience.  With you out on extended leave
>> >> >> the first half of 2017, who would be the best person to ask for this guidance?
>> >> >> Darrick?
>> >> >
>> >> > Yes, probably. :)
>> >> >
>> >> > I think where we left off with this (on the XFS side) is some sort of
>> >> > fallocate mode that would allocate blocks, zero them, and then set the
>> >> > DAX and PMEM_IMMUTABLE on-disk inode flags.  After that, you'd mmap the
>> >> > file and thereby gain the ability to control write persistents behavior
>> >> > without having to worry about fs metadata updates.  As an added plus, I
>> >> > think zeroing the pmem also clears media errors, or something like that.
>> >> >
>> >> > <shrug> Is that a reasonable starting point?  My memory is a little foggy.
>> >> >
>> >> > Hmm, I see Dan just posted something about blockdev fallocate.  I'll go
>> >> > read that.
>> >>
>> >> That's for device-dax, which is basically a poor man's PMEM_IMMUTABLE
>> >> via a character device interface. It's useful for cases where you want
>> >> an entire nvdimm namespace/volume in "no fs-metadata to worry about"
>> >> mode.  But, for sub-allocations of a namespace and support for
>> >> existing tooling, PMEM_IMMUTABLE is much more usable.
>> >
>> > Well sure... but otoh I was thinking that it'd be pretty neat if we
>> > could use the same code regardless of whether the target file was a
>> > dax-device or an xfs file:
>> >
>> > fd = open("<some path>", O_RDWR);
>> > fstat(fd, &statbuf):
>> > fallocate(fd, FALLOC_FL_PMEM_IMMUTABLE, 0, statbuf.st_size);
>> > p = mmap(NULL, statbuf.st_size, PROT_READ | PROT_WRITE, fd, 0);
>> >
>> > *(p + 42) = 0xDEADBEEF;
>> > asm { clflush; } /* or whatever */
>> >
>> > ...so perhaps it would be a good idea to design the fallocate primitive
>> > around "prepare this fd for mmap-only pmem semantics" and let it the
>> > backend do zeroing and inode flag changes as necessary to make it
>> > happen.  We'd need to do some bikeshedding about what the other falloc
>> > flags mean when we're dealing with pmem files and devices, but I think
>> > we should try to keep the userland presentation the same unless there's
>> > a really good reason not to.
>>
>> It would be interesting to use fallocate to size device-dax files...
>
> No. device-dax needs to die, not poison a bunch of existing file and
> block device APIs and behaviours with special snowflakes.  Get
> DAX-enabled filesystems to do what you need, and get rid of this
> ugly, nasty hack.
>

Right, Christoph already killed fallocate for device-dax.

What we're looking for now is the next level of detail on how to get
started on PMEM_IMMUTABLE, as Ross asked a few messages back in this
thread, so we have a reasonable replacement for device-dax.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
