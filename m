Date: Mon, 27 Feb 2006 18:21:37 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: unuse_pte: set pte dirty if the page is dirty
Message-Id: <20060227182137.3106a4cf.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0602271755070.14367@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0602271731410.14242@schroedinger.engr.sgi.com>
	<20060227175324.229860ca.akpm@osdl.org>
	<Pine.LNX.4.64.0602271755070.14367@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: hugh@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> On Mon, 27 Feb 2006, Andrew Morton wrote:
> 
> > Are we sure this is race-free?  Say, someone is in the process of cleaning
> > the page?  munmap, conceivably swapout?  We end up with a dirty pte
> > pointing at a now-clean page.  The page will later become dirty again.  Is
> > that a problem?  It would generate a surprise if the vma had ben set
> > read-only in the interim, for example.
> 
> munmap sets the dirty bit in pages rather than clearing the dirty bits.
> 
> If we would set a dirty bit in a pte pointing to a now clean page then 
> unmapping (or the swaper) will mark the page dirty again and its going to 
> be rewritten again.

Precisely.

And will that crash the kernel, corrupt swapspace, or any other such
exciting things?

There are cases (eg, mprotect) in which a subsequent page-dirtying is
"impossible".  Only we've now gone and made it possible.  The worst part of
it is that we're made it possible in exceedingly rare circumstances.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
