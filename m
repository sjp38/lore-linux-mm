Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id CDF2E6B0038
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 06:32:30 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 192so135575163itm.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 03:32:30 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id f187si2919756itf.83.2016.09.15.03.32.14
        for <linux-mm@kvack.org>;
        Thu, 15 Sep 2016 03:32:16 -0700 (PDT)
Date: Thu, 15 Sep 2016 20:32:10 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160915103210.GT22388@dastard>
References: <20160912052703.GA1897@infradead.org>
 <CAOSf1CHaW=szD+YEjV6vcUG0KKr=aXv8RXomw9xAgknh_9NBFQ@mail.gmail.com>
 <20160912075128.GB21474@infradead.org>
 <20160912180507.533b3549@roar.ozlabs.ibm.com>
 <20160912213435.GD30497@dastard>
 <20160913115311.509101b0@roar.ozlabs.ibm.com>
 <20160914073902.GQ22388@dastard>
 <20160914201936.08315277@roar.ozlabs.ibm.com>
 <20160915023133.GR22388@dastard>
 <20160915134945.0aaa4f5a@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160915134945.0aaa4f5a@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Oliver O'Halloran <oohall@gmail.com>, Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KVM list <kvm@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>

On Thu, Sep 15, 2016 at 01:49:45PM +1000, Nicholas Piggin wrote:
> On Thu, 15 Sep 2016 12:31:33 +1000
> Dave Chinner <david@fromorbit.com> wrote:
> 
> > On Wed, Sep 14, 2016 at 08:19:36PM +1000, Nicholas Piggin wrote:
> > > On Wed, 14 Sep 2016 17:39:02 +1000
> > Sure, but one first has to describe the feature desired before all
> 
> The DAX people have been.

Hmmmm. the only "DAX people" I know of are kernel developers who
have been working on implementing DAX in the kernel - Willy, Ross,
Dan, Jan, Christoph, Kirill, myelf and a few others around the
fringes.

> They want to be able to get mappings
> that can be synced without doing fsync.

Oh, ok, the Intel Userspace PMEM library requirement. I though you
had something more that this - whatever extra problem the per-block
no fsync flag would solve?

> The *exact* extent of
> those capabilities and what the API exactly looks like is up for
> discussion.

Yup.

> Well you said it was impossible already and Christoph told them
> they were smoking crack :)

I have not said that. I have said bad things about bad
proposals and called the PMEM library model broken, but I most
definitely have not said that solving the problem is impossible.

> > That's not an answer to the questions I asked about about the "no
> > sync" flag you were proposing. You've redirected to the a different
> > solution, one that ....
> 
> No sync flag would do the same thing exactly in terms of consistency.
> It would just do the no-sync sequence by default rather than being
> asked for it. More of an API detail than implementation.

You still haven't described anything about what a per-block flag
design is supposed to look like.... :/

> > > Filesystem will
> > > invalidate all such mappings before it does buffered IOs or hole punch,
> > > and will sync metadata after allocating a new block but before returning
> > > from a fault.  
> > 
> > ... requires synchronous metadata updates from page fault context,
> > which we already know is not a good solution.  I'll quote one of
> > Christoph's previous replies to save me the trouble:
> > 
> > 	"You could write all metadata synchronously from the page
> > 	fault handler, but that's basically asking for all kinds of
> > 	deadlocks."
> > So, let's redirect back to the "no sync" flag you were talking about
> > - can you answer the questions I asked above? It would be especially
> > important to highlight how the proposed feature would avoid requiring
> > synchronous metadata updates in page fault contexts....
> 
> Right. So what deadlocks are you concerned about?

It basically puts the entire journal checkpoint path under a page
fault context. i.e. a whole new global locking context problem is
created as this path can now be run both inside and outside the
mmap_sem. Nothing ever good comes from running filesystem locking
code both inside and outside the mmap_sem.

FWIW, We've never executed synchronous transactions inside page
faults in XFS, and I think ext4 is in the same boat - it may be even
worse because of the way it does ordered data dispatch through the
journal. I don't really even want to think about the level of hurt
this might put btrfs or other COW/log structured filesystems under.
I'm sure Christoph can reel off a bunch more issues off the top of
his head....

> There could be a scale of capabilities here, for different filesystems
> that do things differently. 

Why do we need such complexity to be defined?

I'm tending towards just adding new fallocate() operation that sets
up a fully allocated and zeroed file of fixed length that has
immutable metadata once created. Single syscall, with well dfined
semantics, and it doesn't dictate the implementation any filesystem
must use. All it dictates is that the data region can be written
safely on dax-enabled storage without needing fsync() to be issued.

i.e. the implementation can be filesystem specific, and it is simple
to implement the basic functionality and constraints in both XFS and
ext4 right away, and as othe filesystems come along they can
implement it in the way that best suits them. e.g. btrfs would need
to add the "no COW" flag to the file as well.

If someone wants to implement a per-block no-fsync flag, and  do
sycnhronous metadata updates in the page fault path, then they are
welcome to do so. But we don't /need/ such complexity to implement
the functionality that pmem programming model requires.

> Some filesystems could require fsync for metadata, but allow fdatasync
> to be skipped. Users would need to have some knowledge of block size
> or do preallocation and sync.

Not sure what you mean here -  avoiding the need for using fsync()
by using fsync() seems a little circular to me.  :/

> That might put more burden on libraries/applications if there are
> concurrent operations, but that might be something they can deal with
> -- fdatasync already requires some knowledge of concurrent operations
> (or lack thereof).

Additional userspace complexity is something we should avoid.


> You and Christoph know a huge amount about vfs and filesystems.
> But sometimes you shut people down prematurely.

Appearances can be deceiving.  I don't shut discussions down unless
my time is being wasted, and that's pretty rare.

[You probably know most of what I'm about to write, but I'm not
actually writing it for you.... ]

> It can be very
> intimidating for someone who might not know *exactly* what they
> are asking for or have not considered some difficult locking case
> in a filesystem.

Yup, most kernel developers are aware that this is how the mailing
list discussions appear from the outside.

Unfortunately, too many people think they have expert knowlege when
they don't (the Dunning-Kruger cognitive bias), and so they simply
can't understand an expert response that points out problems 5 or 6
steps further along the logic chain and assumes the reader knows
that chain intimately. They don't so
they think they've been shut down.  It's closer to the truth that
they've suddenly been made aware of how little they know about the
topic under discussion and they don't know how to react.  At this
point, we see a classic fight-or-flight reflex response, and then
the person either runs away scared or create heat and light....

Occasionally, someone comes back with "hey, I don't quite understand
that, can you explain it more/differently", then I will try to
explain it as best I can and have time to do so. History has proven
that most kernel developers react in this way, including Christoph.
And when this happens, we often end up with a new contributor....

As Confuscius says: "Real knowledge is to know the extent of one's
ignorance."

[ I talk about this whole issue in more detail mid-way through this
LCA 2015 presentation: https://www.youtube.com/watch?v=VpuVDfSXs-g ]

This is why we tend to ask people for their problem descriptions,
requirements and constraints, rather than expecting them to explain
the how they think their problem needs to be solved. We do not
expect anyone other than the regular kernel developers to understand
deep, dark details needed to craft a workable solution. If they do,
great.  if they don't, then don't get upset or angry about it.
Instead, while one may not like or fully understand the answer that
is given, accept the answers that are given and respect that there
is usually a very good reason that answer was given.

> I'm sure it's not intentional, but that's how it
> can come across.

Yup, and there's really very little we can do about it. It's one of
the consequences of having experts hang around in public....

> That said, I don't want to derail their thread any further with
> this. So I apologise for my tone to you, Dave.

Accepted. Let's start over, eh?

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
