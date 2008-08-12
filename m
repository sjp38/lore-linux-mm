Subject: Re: [rfc][patch] mm: dirty page accounting hole
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0808121210250.31744@blonde.site>
References: <200808121558.40130.nickpiggin@yahoo.com.au>
	 <Pine.LNX.4.64.0808121210250.31744@blonde.site>
Content-Type: text/plain
Date: Tue, 12 Aug 2008 13:30:56 +0200
Message-Id: <1218540656.10800.188.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-08-12 at 12:15 +0100, Hugh Dickins wrote:
> On Tue, 12 Aug 2008, Nick Piggin wrote:
> > 
> > I think I'm running into a hole in dirty page accounting...
> > 
> > What seems to be happening is that a page gets written to via a
> > VM_SHARED vma. We then set the pte dirty, then mark the page dirty.
> > Next, mprotect changes the vma so it is no longer writeable so it
> > is no longer VM_SHARED. The pte is still dirty.
> 
> I don't think you've got that right yet.
> 
> mprotect can of course change vma->vm_flags to take VM_WRITE off,
> making vma no longer writeable; but it shouldn't be touching
> VM_SHARED.  And a quick check with debugger confirms that.
> 
> It's precisely because of mprotect that page_mkclean_one tests
> VM_SHARED not VM_WRITE.  Changing that to VM_MAYSHARE, as in your
> patch below, should make no difference to correctness; but would
> potentially make its loop less efficient (it would also go off to
> check MAP_SHARED, PROT_READ, fd readonly mappings unnecessarily).
> 
> Perhaps there's somewhere else that clears VM_SHARED by mistake?
> Or another path through mprotect which does so?  I haven't checked
> further, hoping this will jolt you into a different realization.

You are right, I cannot find a path through mprotect that unsets
VM_SHARED either.

Something which I failed to validate this morning.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
