Date: Fri, 29 Jun 2007 01:25:36 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
Message-ID: <20070628232535.GD7690@v2.random>
References: <8e38f7656968417dfee0.1181332979@v2.random> <466C36AE.3000101@redhat.com> <20070610181700.GC7443@v2.random> <46814829.8090808@redhat.com> <20070626105541.cd82c940.akpm@linux-foundation.org> <468439E8.4040606@redhat.com> <20070628155715.49d051c9.akpm@linux-foundation.org> <46843E65.3020008@redhat.com> <20070628161350.5ce20202.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070628161350.5ce20202.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 28, 2007 at 04:13:50PM -0700, Andrew Morton wrote:
> On Thu, 28 Jun 2007 19:04:05 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
> > > Sigh.  We had a workload (forget which, still unfixed) in which things
> > > would basically melt down in that linear anon_vma walk, walking 10,000 or
> > > more vma's.  I wonder if that's what's happening here?
> > 
> > That would be a large multi-threaded application that fills up
> > memory.  Customers are reproducing this with JVMs on some very
> > large systems.
> 
> So.... does that mean "yes, it's scanning a lot of vmas"?
> 
> If so, I expect there will still be failure modes, whatever we do outside
> of this.  A locked, linear walk of a list whose length is
> application-controlled is going to be a problem.  Could be that we'll need
> an O(n) -> O(log(n)) conversion, which will be tricky in there.

There's no swapping, so are we sure we need to scan the pte? This
might be as well the unmapping code being invoked too early despite
there's still clean cache to free. If I/O would start because swapping
is really needed, the O(N) walk wouldn't hog the cpu so much because
lots of time would be spent waiting for I/O too. Decreasing
DEF_PRIORITY should defer the invocation of the unmapping code too.

Conversion to O(log(N)) like for the filebacked mappings shouldn't be
a big problem but it'll waste more static memory for each vma and
anon_vma.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
