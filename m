Date: Mon, 17 Sep 2007 14:11:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: VM/VFS bug with large amount of memory and file systems?
Message-Id: <20070917141127.ab2ae148.akpm@linux-foundation.org>
In-Reply-To: <46EEE7B7.1070206@redhat.com>
References: <C2A8AED2-363F-4131-863C-918465C1F4E1@cam.ac.uk>
	<1189850897.21778.301.camel@twins>
	<20070915035228.8b8a7d6d.akpm@linux-foundation.org>
	<13126578-A4F8-43EA-9B0D-A3BCBFB41FEC@cam.ac.uk>
	<20070917163257.331c7605@twins>
	<46EEB532.3060804@redhat.com>
	<20070917131526.e8db80fe.akpm@linux-foundation.org>
	<46EEE7B7.1070206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Anton Altaparmakov <aia21@cam.ac.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, marc.smith@esmail.mcc.edu
List-ID: <linux-mm.kvack.org>

On Mon, 17 Sep 2007 16:46:47 -0400
Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> > On Mon, 17 Sep 2007 13:11:14 -0400
> > Rik van Riel <riel@redhat.com> wrote:
> 
> >> IIRC I simply kept a list of all buffer heads and walked
> >> that to reclaim pages when the number of buffer heads is
> >> too high (and we need memory).  This list can be maintained
> >> in places where we already hold the lock for the buffer head
> >> freelist, so there should be no additional locking overhead
> >> (again, IIRC).
> > 
> > Christoph's slab defragmentation code should permit us to fix this:
> > grab a page of buffer_heads off the slab lists, trylock the page,
> > strip the buffer_heads.  I think that would be a better approach
> > if we can get it going because it's more general.
> 
> Is the slab defragmentation code in -mm or upstream already
> or can I find it on the mailing list?

Is on lkml and linux-mm: http://lkml.org/lkml/2007/8/31/329

> I've implemented code like you describe already, just give me
> a few days to become familiar with the slab defragmentation
> code and I'll get you a patch.

The patchset does buffer_heads: http://lkml.org/lkml/2007/8/31/348

I think the whole approach is reasonable.  It's mainly a matter of going
through it all with a toothcomb and getting it all merged up, tested and
integrated.  There's considerable potential for nasty and rarely-occurring
surprises in this stuff because it tends to approach locking in the
reversed order.

<checks the archives>

There were a few desultory comments, but I see no sign that the bulk of
the patches have had any serious review and testing from anyone yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
