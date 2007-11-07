Date: Tue, 6 Nov 2007 21:23:05 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC PATCH 0/10] split anon and file LRUs
Message-ID: <20071106212305.6aa3a4fe@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0711061808460.5249@schroedinger.engr.sgi.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
	<Pine.LNX.4.64.0711061808460.5249@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Nov 2007 18:11:39 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Sat, 3 Nov 2007, Rik van Riel wrote:
> 
> > The current version only has the infrastructure.  Large changes to
> > the page replacement policy will follow later.
> 
> Hmmmm.. I'd rather see where we are going.

http://linux-mm.org/PageReplacementDesign

> One other way of addressing many of these issues is to allow large page sizes
> on the LRU which will reduce the number of entities that have to be managed.

Linus seems to have vetoed that (unless I am mistaken), so the
chances of that happening soon are probably not very large.

Also, a factor 16 increase in page size is not going to help
if memory sizes also increase by a factor 16, since we already 
have trouble with today's memory sizes.

> Both approaches actually would work in tandem.
 
Hence, this patch series.

> > TODO:
> > - have any mlocked and ramfs pages live off of the LRU list,
> >   so we do not need to scan these pages
> 
> I think that is the most urgent issue at hand. At least for us.

For some workloads this is the most urgent change, indeed.
Since the patches for this already exist, integrating them
is at the top of my list.  Expect this to be integrated into
the split VM patch series by the end of this week.

> > - switch to SEQ replacement for the anon LRU lists, so the
> >   worst case number of pages to scan is reduced greatly.
> 
> No idea what that is?

See http://linux-mm.org/PageReplacementDesign

> > - figure out if the file LRU lists need page replacement
> >   changes to help with worst case scenarios
> 
> We do not have an accepted standard load. So how would we figure that one 
> out?

The current worst case is where we need to scan all of memory, 
just to find a few pages we can swap out.  With the effects of
lock contention figured in, this can take hours on huge systems.

In order to make the VM more scalable, we need to find acceptable
pages to swap out with low complexity in the VM.  The "worst case"
above refers to the upper bound on how much work the VM needs to
do in order to get something evicted from the page cache or swapped
out.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
