Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD08E6B007E
	for <linux-mm@kvack.org>; Tue,  3 May 2016 21:39:19 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id kj7so36000369igb.3
        for <linux-mm@kvack.org>; Tue, 03 May 2016 18:39:19 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id o191si1079632ite.10.2016.05.03.18.39.17
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 18:39:19 -0700 (PDT)
Date: Wed, 4 May 2016 11:36:57 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Message-ID: <20160504013657.GO18496@dastard>
References: <1461604476.3106.12.camel@intel.com>
 <20160425232552.GD18496@dastard>
 <1461628381.1421.24.camel@intel.com>
 <20160426004155.GF18496@dastard>
 <x49pot4ebeb.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4jfUVXoge5D+cBY1Ph=t60165sp6sF_QFZUbFv+cNcdHg@mail.gmail.com>
 <20160503004226.GR26977@dastard>
 <D26BCF92-ED25-4ACA-9CC8-7B1C05A1D5FC@intel.com>
 <20160503024948.GT26977@dastard>
 <FBB11841-7DFE-4223-9973-3457034260C2@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <FBB11841-7DFE-4223-9973-3457034260C2@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rudoff, Andy" <andy.rudoff@intel.com>
Cc: "Williams, Dan J" <dan.j.williams@intel.com>, "hch@infradead.org" <hch@infradead.org>, "jack@suse.cz" <jack@suse.cz>, "axboe@fb.com" <axboe@fb.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>

On Tue, May 03, 2016 at 06:30:04PM +0000, Rudoff, Andy wrote:
> >
> >And when the filesystem says no because the fs devs don't want to
> >have to deal with broken apps because app devs learn that "this is a
> >go fast knob" and data integrity be damned? It's "fsync is slow so I
> >won't use it" all over again...
> ...
> >
> >And, please keep in mind: many application developers will not
> >design for pmem because they also have to support traditional
> >storage backed by page cache. If they use msync(), the app will work
> >on any storage stack, but just be much, much faster on pmem+DAX. So,
> >really, we have to make the msync()-only model work efficiently, so
> >we may as well design for that in the first place....
> 
> Both of these snippets seem to be arguing that we should make msync/fsync
> more efficient.  But I don't think anyone is arguing the opposite.  Is
> someone saying we shouldn't make the msync()-only model work efficiently?

Not directly. The argument presented is "we need a flag to avoid
msync, because msync is inefficient", which is followed by "look,
here's numbers that show msync() being slow, so just give us the
flag already". Experience tells me that the moment a workaround is
in place, nobody will go back and try to fix the problem that the
workaround is mitigating.

Now we know that it's the page granularity cache flushing overhead
that causes the performance differential rather than it being caused
by using msync(), we should be looking at ways to reduce the cache
flushing overhead, not completely bypassing it.

> Said another way: the common case for DAX will be applications simply
> following the POSIX model.  open, mmap, msync...  That will work fine
> and of course we should optimize that path as much as possible.  Less
> common are latency-sensitive applications built to leverage to byte-
> addressable nature of pmem.  File systems supporting this model will
> indicate it using a new ioctl that says doing CPU cache flushes is
> sufficient to flush stores to persistence.

You keep saying this whilst ignoring the repeated comments about how
this can not be guaranteed by all filesystems, and hence apps will
not be able to depend on having such behaviour present. The only
guarantee for persistence that an app will be able to rely on is
msync().

> But I don't see how that
> direction is getting turned into an argument against msync() efficiency.

Promoting a model that works around inefficiency rather than solving
it is no different to saying you don't care about fixing the
inefficiency....

I've said my piece, I'm not going to waste any more time going
around this circle again.

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
