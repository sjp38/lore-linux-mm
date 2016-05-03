Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E1E716B0263
	for <linux-mm@kvack.org>; Mon,  2 May 2016 20:45:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b203so9758988pfb.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 17:45:58 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id s70si975696pfa.185.2016.05.02.17.45.56
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 17:45:57 -0700 (PDT)
Date: Tue, 3 May 2016 10:42:26 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Message-ID: <20160503004226.GR26977@dastard>
References: <x49twj26edj.fsf@segfault.boston.devel.redhat.com>
 <20160420205923.GA24797@infradead.org>
 <1461434916.3695.7.camel@intel.com>
 <20160425083114.GA27556@infradead.org>
 <1461604476.3106.12.camel@intel.com>
 <20160425232552.GD18496@dastard>
 <1461628381.1421.24.camel@intel.com>
 <20160426004155.GF18496@dastard>
 <x49pot4ebeb.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4jfUVXoge5D+cBY1Ph=t60165sp6sF_QFZUbFv+cNcdHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jfUVXoge5D+cBY1Ph=t60165sp6sF_QFZUbFv+cNcdHg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "jack@suse.cz" <jack@suse.cz>

On Mon, May 02, 2016 at 10:53:25AM -0700, Dan Williams wrote:
> On Mon, May 2, 2016 at 8:18 AM, Jeff Moyer <jmoyer@redhat.com> wrote:
> > Dave Chinner <david@fromorbit.com> writes:
> [..]
> >> We need some form of redundancy and correction in the PMEM stack to
> >> prevent single sector errors from taking down services until an
> >> administrator can correct the problem. I'm trying to understand
> >> where this is supposed to fit into the picture - at this point I
> >> really don't think userspace applications are going to be able to do
> >> this reliably....
> >
> > Not all storage is configured into a RAID volume, and in some instances,
> > the application is better positioned to recover the data (gluster/ceph,
> > for example).  It really comes down to whether applications or libraries
> > will want to implement redundancy themselves in order to get a bump in
> > performance by not going through the kernel.  And I think I know what
> > your opinion is on that front.  :-)
> >
> > Speaking of which, did you see the numbers Dan shared at LSF on how much
> > overhead there is in calling into the kernel for syncing?  Dan, can/did
> > you publish that spreadsheet somewhere?
> 
> Here it is:
> 
> https://docs.google.com/spreadsheets/d/1pwr9psy6vtB9DOsc2bUdXevJRz5Guf6laZ4DaZlkhoo/edit?usp=sharing
> 
> On the "Filtered" tab I have some of the comparisons where:

Those numbers are really wacky - the inconsistent decimal place
representation makes it really, really hard to read the differences
in orders of magnitude, too. Let's take the first numbers - noop, 64
byte ops are:

threads		ops/s
1		 90M
2		310M
4		 65M
8		175M
16		426M

Why aren't these linear? And if the test is not running in an
environment where these are controlled and linear, how valid are the
rest of the tests and hence the comparison.

> noop => don't call msync and don't flush caches in userspace
> 
> persist => cache flushing only in userspace and only on individual cache lines

So these look a lot more linear than the no-op behaviour, so I'll
just ignore the no-op results for now.

> persist_4k => cache flushing only in userspace, but flushing is
> performed in 4K aligned units

Urg, your "vs persist" percentages are all wrong. You can't have a
"-1000%" difference, you have "persist 4k" running at 10% of the
speed of "persist".

So, with that in mind, the "persist_4k" speed is:

		 ops/s		single thread
Size		vs "persist"	4k flush rate
  64		 10%		 834k
 128		 13%		 849k
 256		 15%		 410k(one off variation?)
 512		 20%		 860k
1024		 25%		 850k
2048		 50%		 840k
4096		none		 836k
8192		none		 410k

What we see here is that the CPU(s) can flush the 4k pages at a rate
of roughly 850,000 flushes/s, whilst the 64 byte flush rate is
around 8.8M flushes/s.  This is clearly demonstrated in the numbers
- as the dirty object size approaches the cache flush granularity,
the speed approaches single cacheline flush granularity speed.

Comparing 4k vs 64b flushes, we have 63 clean cache line flushes
taking roughly the same time as 9 dirty cache line flushes. Nice
numbers - that means a clean cache line flush has ~14% of the
overhead of dirty cache line flush. Seems rather high - it's tens of
CPU cycles to determine that the flush is a no-op for that
cacheline.

Fixing this seems like a hardware optimisation issue to me, but I
still have to question how many applications are going to have such
fine-grained random synchronous memory writes that this actually
matters in practice? If we are doing such small writes across
multiple different 4k pages, then TLB overhead for all the page
faults is going to be as much of an issue as 4k cache flushes...

> msync => same granularity flushing as the 'persist' case, but the
> kernel internally promotes this to a 4K sized / aligned flush

So you're calling msync for every modification that is made? What
application needs to do that? Anyway, page flush rates paint an
interesting picture:

	single thread		 versus
Size	4k flush rate		persist_4k
  64	 655k			 78%
 128	 655k			 81%
 256	 670k			163%  (* persist 4k number low) 
 512	 681k			 79%
1024	 666k			 78%
2048	 650k			 77%
4096	 652k			 78%
8192	 390k			 95%

msync adds relatively little overhead (~20% extra overhead) compared
to the performance loss from the 4k flush granularity change. And
given this appears to be a worst case test scenario (and I'm sure
msync could be improved), I don't think this demonstrates a problem
with using msync.

IMO, these numbers don't support the argument that the *msync
model* for data integrity for DAX is flawed, unworkable, or too
slow. What I see is a performance problem resulting from the
overhead of flushing clean cachelines.  i.e. there's data here that
supports the argument for reducing the overhead of flushing clean
cachelines in the hardware and/or better tracking of dirty
cachelines within the kernel, but not data that says the msync()
based data integrity model is the source of the problem.

i.e. separate the programming model from the performance issue, and
we can see that the performance problem is not caused by the
programming model - it's caused by the kernel implementation of the
model.

> The takeaway is that msync() is 9-10x slower than userspace cache management.

An alternative viewpoint: that flushing clean cachelines is
extremely expensive on Intel CPUs. ;)

i.e. Same numbers, different analysis from a different PoV, and
that gives a *completely different conclusion*.

Think about it for the moment. The hardware inefficiency being
demonstrated could be fixed/optimised in the next hardware product
cycle(s) and so will eventually go away. OTOH, we'll be stuck with
whatever programming model we come up with for the next 30-40 years,
and we'll never be able to fix flaws in it because applications will
be depending on them. Do we really want to be stuck with a pmem
model that is designed around the flaws and deficiencies of ~1st
generation hardware?

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
