Date: Fri, 9 Nov 2007 10:09:33 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: bug #5493
Message-ID: <20071109100933.18ad7a58@bree.surriel.com>
In-Reply-To: <20071108202707.d7efed57.akpm@linux-foundation.org>
References: <32209efe0711071800v4bc0c62er7bc462f1891c9dcd@mail.gmail.com>
	<20071107191247.04d74241.akpm@linux-foundation.org>
	<20071108165320.GA23882@skynet.ie>
	<20071108095704.f98905ec.akpm@linux-foundation.org>
	<20071108131518.5408931d@bree.surriel.com>
	<20071108105659.3ca01b00.akpm@linux-foundation.org>
	<20071108200041.1a739bc5@bree.surriel.com>
	<20071108202707.d7efed57.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mel@skynet.ie, protasnb@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Nov 2007 20:27:07 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> > On Thu, 8 Nov 2007 20:00:41 -0500 Rik van Riel <riel@redhat.com> wrote:
> > On Thu, 8 Nov 2007 10:56:59 -0800
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> > > > On Thu, 8 Nov 2007 13:15:18 -0500 Rik van Riel <riel@redhat.com> wrote:
> > > > On Thu, 8 Nov 2007 09:57:04 -0800
> > 
> > > > > No, it was due to linear traversal of very long reverse-mapping lists
> > > > > (thousands of elements, irrc).
> > > > 
> > > > Traversal at pageout time, or at mprotect time?
> > > > 
> > > 
> > > pageout, iirc.  For each page we were walking a linear list of I think
> > > ~10,000 elements.
> > 
> > Pageout scan complexity in this workload is O(P*M), where
> > P is the number of pages scanned and M is the number of
> > mappings.
> > 
> > My code will, in the next iteration, reduce P by a fair
> > amount for larger amounts of memory, but M is still very
> > large...
> 
> That's yet to be proven - for the vast majority of workloads your P is
> already very small.

For the vast majority of workloads, yes.

However, all anonymous pages (which this workload fills
memory with) start out as referenced.

We will not start clearing those referenced bits until
all of memory fills up and we're reaching some level of
distress.

At that point, we clear the referenced bits of all of
memory before swapping out a single page, due to the
way referenced pages go back to the other end of the
active list.

That hurts a little on a 1GB system, but is deadly on
a 256GB system.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
