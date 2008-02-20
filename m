Date: Tue, 19 Feb 2008 20:49:44 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch] my mmu notifiers
Message-ID: <20080220024944.GB11364@sgi.com>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080219231157.GC18912@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrea Arcangeli <andrea@qumranet.com>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2008 at 12:11:57AM +0100, Nick Piggin wrote:
> On Tue, Feb 19, 2008 at 02:58:51PM +0100, Andrea Arcangeli wrote:
> > On Tue, Feb 19, 2008 at 09:43:57AM +0100, Nick Piggin wrote:
> > > anything when changing the pte to be _more_ permissive, and I don't
> > 
> > Note that in my patch the invalidate_pages in mprotect can be
> > trivially switched to a mprotect_pages with proper params. This will
> > prevent page faults completely in the secondary MMU (there will only
> > be tlb misses after the tlb flush just like for the core linux pte),
> > and it'll allow all the secondary MMU pte blocks (512/1024 at time
> > with my PT lock design) to be updated to have proper permissions
> > matching the core linux pte.
> 
> Sorry, I realise I still didn't get this through my head yet (and also
> have not seen your patch recently). So I don't know exactly what you
> are doing...
> 
> But why does _anybody_ (why does Christoph's patches) need to invalidate
> when they are going to be more permissive? This should be done lazily by
> the driver, I would have thought.

I don't believe it should, but it probably does right now.  I do know
the case where a write fault where there is no need for a COW does
not call out on the PTE change.  I see no reason the others should not
handle this as well.  Just off the top of my head, I can only think of
the mprotect case needing to special case the more permissive state and
I don't think that changes PTEs at all, merely updates the VMA.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
