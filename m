Date: Tue, 6 Nov 2007 18:40:46 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC PATCH 0/10] split anon and file LRUs
In-Reply-To: <20071106212305.6aa3a4fe@bree.surriel.com>
Message-ID: <Pine.LNX.4.64.0711061834340.5424@schroedinger.engr.sgi.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
 <Pine.LNX.4.64.0711061808460.5249@schroedinger.engr.sgi.com>
 <20071106212305.6aa3a4fe@bree.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Nov 2007, Rik van Riel wrote:

> Also, a factor 16 increase in page size is not going to help
> if memory sizes also increase by a factor 16, since we already 
> have trouble with today's memory sizes.

Note that a factor 16 increase usually goes hand in hand with
more processors. The synchronization of multiple processors becomes a 
concern. If you have an 8p and each of them tries to get the zone locks 
for reclaim then we are already in trouble. And given the immaturity
of the handling of cacheline contention in current commodity hardware this 
is likely to result in livelocks and/or starvation on some level.

> > I think that is the most urgent issue at hand. At least for us.
> 
> For some workloads this is the most urgent change, indeed.
> Since the patches for this already exist, integrating them
> is at the top of my list.  Expect this to be integrated into
> the split VM patch series by the end of this week.

Good to hear.
 
> > > - switch to SEQ replacement for the anon LRU lists, so the
> > >   worst case number of pages to scan is reduced greatly.
> > 
> > No idea what that is?
> 
> See http://linux-mm.org/PageReplacementDesign

A bit sparse but limiting the scanning if we cannot do much is certainly 
the right thing to do. The percentage of memory taken up by anonymous 
pages varies depending on the load. HPC applications may consume all of 
memory with anonymous pages. But there the pain is already so bad that 
many users go to huge pages already which bypasses the VM.

> > We do not have an accepted standard load. So how would we figure that one 
> > out?
> 
> The current worst case is where we need to scan all of memory, 
> just to find a few pages we can swap out.  With the effects of
> lock contention figured in, this can take hours on huge systems.

Right but I think this looks like a hopeless situation regardless of the 
algorithm if you have a couple of million pages and are trying to free 
one. Now image a series of processors going on the hunt for the few pages 
that can be reclaimed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
