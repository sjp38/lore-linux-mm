Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 64B0E6B025E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 22:49:54 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 4so13994322pfw.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 19:49:54 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id 12si1597677pfl.3.2016.05.02.19.49.51
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 19:49:53 -0700 (PDT)
Date: Tue, 3 May 2016 12:49:48 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Message-ID: <20160503024948.GT26977@dastard>
References: <1461434916.3695.7.camel@intel.com>
 <20160425083114.GA27556@infradead.org>
 <1461604476.3106.12.camel@intel.com>
 <20160425232552.GD18496@dastard>
 <1461628381.1421.24.camel@intel.com>
 <20160426004155.GF18496@dastard>
 <x49pot4ebeb.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4jfUVXoge5D+cBY1Ph=t60165sp6sF_QFZUbFv+cNcdHg@mail.gmail.com>
 <20160503004226.GR26977@dastard>
 <D26BCF92-ED25-4ACA-9CC8-7B1C05A1D5FC@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <D26BCF92-ED25-4ACA-9CC8-7B1C05A1D5FC@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rudoff, Andy" <andy.rudoff@intel.com>
Cc: "Williams, Dan J" <dan.j.williams@intel.com>, "hch@infradead.org" <hch@infradead.org>, "jack@suse.cz" <jack@suse.cz>, "axboe@fb.com" <axboe@fb.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>

On Tue, May 03, 2016 at 01:26:46AM +0000, Rudoff, Andy wrote:
> 
> >> The takeaway is that msync() is 9-10x slower than userspace cache management.
> >
> >An alternative viewpoint: that flushing clean cachelines is
> >extremely expensive on Intel CPUs. ;)
> >
> >i.e. Same numbers, different analysis from a different PoV, and
> >that gives a *completely different conclusion*.
> >
> >Think about it for the moment. The hardware inefficiency being
> >demonstrated could be fixed/optimised in the next hardware product
> >cycle(s) and so will eventually go away. OTOH, we'll be stuck with
> >whatever programming model we come up with for the next 30-40 years,
> >and we'll never be able to fix flaws in it because applications will
> >be depending on them. Do we really want to be stuck with a pmem
> >model that is designed around the flaws and deficiencies of ~1st
> >generation hardware?
> 
> Hi Dave,
> 
> Not sure I agree with your completely different conclusion.  (Not sure
> I completely disagree either, but please let me raise some practical
> points.)
> 
> First of all, let's say you're completely right and flushing clean
> cache lines is extremely expensive.  So your solution is to wait for
> the chip to be fixed? 

No, I'm not saying that's the solution - I'm pointing out that if
clean cache line flushing overhead is less of a problem in future,
the optimisations made now will not be necessary. However, we'll be
still stuck with the API/model that has encoded those optimisations
as a necessary thing for applications to know about and do the
correct thing with. I.e. we end up with a library of applications
that are optimised for a problem that no longer exists...

> Remember the model we're putting forward (which
> we're working on documenting, because I fully agree with the lack of
> documentation point you keep raising) requires the application to ASK
> for the file system's permission before assuming flushing from user space
> to persistence is allowed.

And when the filesystem says no because the fs devs don't want to
have to deal with broken apps because app devs learn that "this is a
go fast knob" and data integrity be damned? It's "fsync is slow so I
won't use it" all over again...

> Anyway, I doubt that flushing a clean cache line is extremely expensive.
> Remember the code is building transactions to maintain a consistent
> in-memory data structure in the face of sudden failure like powerloss.
> So it is using the flushes to create store barriers, but not the block-
> based store barriers we're used to in the storage world, but cache-line-
> sized store barriers (usually multiples of cache lines, but most commonly
> smaller than 4k of them).  So I think when you turn a cache line flush
> into an msync(), you're seeing some dirty stuff get flushed before it
> is time to flush it.  I'm not sure though, but certainly we could spend
> more time testing & measuring.

Sure, but is that what Dan was testing? I don't know - he just
presented a bunch of numbers without a description of the workload,
posting the benchmark code, etc. hence I can only *make assumptions*
about what the numbers mean.

I'm somewhat tired of having to make assumptions because nobody is
describing what they are doing sufficiently and then getting called
out for it, or having to ask lots of questions because other people
have made assumptions about how they think something is going to
work without explaining how the dots connect together. It's a waste
of everyone's time to be playing this ass-u-me game...

The fact that nobody has been able to explain the how the overall
model is supposed to work from physical error all the way out to
userspace makes me think that this is all being made up on the spot.
There are big pieces of the picture missing, and nobody seems to be
able to communicate a clear vision of the architecture we are
supposed to be discussing, let alone implementing...

> More importantly, I think it is interesting to decide what we want the
> pmem programming model to be long-term.  I think we want applications to
> just map pmem, do normal stores to it, and assume they are persistent.
> This is quite different from the 30-year-old POSIX Model where msync()
> is required.

Yes, it's different, but we still have to co-ordinate multiple
layers of persistence (i.e. metadata that references the data).

> But I think it is cleaner, easier to understand, and less
> error-prone.  So why doesn't it work that way right now?  Because we're
> finding it impractical.  Using write-through caching for pmem simply
> doesn't perform well, and depending on the platform to flush the CPU
> caches on shutdown/powerfail is not practical yet.  But I think the day
> will come when it is practical.

Right - it's also simply not practical to intercept every userspace
store to ensure the referencing metadata is also persistent, so we
still need synchronisation mechanisms to ensure that such state is
acheived.  Either that, or the entire dynamic filesystem state needs
to be stored in write-through persistent memory as well. We're a
long, long way from that.

And, please keep in mind: many application developers will not
design for pmem because they also have to support traditional
storage backed by page cache. If they use msync(), the app will work
on any storage stack, but just be much, much faster on pmem+DAX. So,
really, we have to make the msync()-only model work efficiently, so
we may as well design for that in the first place....

> So given that long-term target, the idea is for an application to ask if
> the msync() calls are required, or if just flushing the CPU caches is
> sufficient for persistence.  Then, we're also adding an ACPI property
> that allows SW to discover if the caches are flushed automatically
> on shutdown/powerloss.  Initially that will only be true for custom
> platforms, but hopefully it can be available more broadly in the future.
> The result will be that the programming model gets simpler as more and
> more hardware requires less explicit flushing.

That's a different problem, and one that requires a filesystem to
also store all it's dynamic information in pmem. i.e. there's not
point flushing pmem caches if the powerloss loses dirty metadata
that is held in system RAM. We really need completely new
pmem-native filesystems to make this work - it's a completely
separate problem to whether msync() should be the API that provided
fundamental data integrity guarantees or not.

Which brings up another point: advanced new functionality
is going to require native pmem filesystems. These are unlikely to
be block device based, and instead will directly interface with the
low level CPU and pmem APIs. I don't expect these to use the DAX
infrastructure, either, because that assumes block device based
operations. The will, however, still have to have POSIX compatible
behaviour, and so we go full circle in expecting that an app
written for mmap+DAX on an existing block based filesystem will work
identically on funky new byte-addressable native pmem filesytems.

Encoding cache flushing for data integrity into the userspace
applications assumes that such future pmem-based storage will have
identical persistence requirements to the existing hardware. This,
to me, seems very unlikely to be the case (especially when
considering different platforms (e.g. power, ARM)) and so, again,
application developers are likely to have to fall back to using a
kernel provided data integrity primitive they know they can rely on
(i.e. msync()).....

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
