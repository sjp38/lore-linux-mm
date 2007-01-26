Date: Fri, 26 Jan 2007 10:42:06 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] Track mlock()ed pages
Message-Id: <20070126104206.f0b45f74.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0701261021200.7848@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0701252141570.10629@schroedinger.engr.sgi.com>
	<45B9A00C.4040701@yahoo.com.au>
	<Pine.LNX.4.64.0701252234490.11230@schroedinger.engr.sgi.com>
	<20070126031300.59f75b06.akpm@osdl.org>
	<Pine.LNX.4.64.0701260742340.6141@schroedinger.engr.sgi.com>
	<20070126101027.90bf3e63.akpm@osdl.org>
	<Pine.LNX.4.64.0701261021200.7848@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007 10:23:44 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 26 Jan 2007, Andrew Morton wrote:
> 
> > > Large amounts of mlocked pages may be a problem for 
> > > 
> > > 1. Reclaim behavior.
> > > 
> > > 2. Defragmentation
> > > 
> > 
> > We know that.  What has that to do with this patch?
> 
> Knowing how much mlocked pages are where is necessary to solve these 
> issues.

If we continue this dialogue for long enough, we'll actually have a changlog.

> > > > You could perhaps go for a walk across all the other vmas which presently
> > > > map this page.  If any of them have VM_LOCKED, don't increment the counter.
> > > > Similar on removal: only decrement the counter when the final mlocked VMA
> > > > is dropping the pte.
> > > 
> > > For that we would need an additional refcount for vmlocked maps in the 
> > > page struct.
> > 
> > No you don't.  The refcount is already there.  It is "the sum of the VM_LOCKED
> > VMAs which map this page".
> > 
> > It might be impractical or expensive to calculate it, but it's there.
> 
> Correct. Its so expensive that it cannot be used to build vm stats for 
> mlocked pages. F.e. Determination of the final mlocked VMA dropping the 
> page would require a scan over all vmas mapping the page.

Of course it would.  But how do you know it is "too expensive"?  We "scan
all the vmas mapping a page" as a matter of course in the page scanner -
millions of times a minute.  If that's "too expensive" then ouch.

That, plus if we have so many vmas mapping a page for this effect to
matter, then your change as proposed will be so inaccurate as to be
useless, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
