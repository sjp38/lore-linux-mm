Date: Thu, 21 Feb 2008 05:42:56 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] my mmu notifiers
Message-ID: <20080221044256.GA15215@wotan.suse.de>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080219234049.GA27856@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080219234049.GA27856@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2008 at 05:40:50PM -0600, Jack Steiner wrote:
> On Wed, Feb 20, 2008 at 12:11:57AM +0100, Nick Piggin wrote:
> > On Tue, Feb 19, 2008 at 02:58:51PM +0100, Andrea Arcangeli wrote:
> > > On Tue, Feb 19, 2008 at 09:43:57AM +0100, Nick Piggin wrote:
> > > > anything when changing the pte to be _more_ permissive, and I don't
> > > 
> > > Note that in my patch the invalidate_pages in mprotect can be
> > > trivially switched to a mprotect_pages with proper params. This will
> > > prevent page faults completely in the secondary MMU (there will only
> > > be tlb misses after the tlb flush just like for the core linux pte),
> > > and it'll allow all the secondary MMU pte blocks (512/1024 at time
> > > with my PT lock design) to be updated to have proper permissions
> > > matching the core linux pte.
> > 
> > Sorry, I realise I still didn't get this through my head yet (and also
> > have not seen your patch recently). So I don't know exactly what you
> > are doing...
> > 
> > But why does _anybody_ (why does Christoph's patches) need to invalidate
> > when they are going to be more permissive? This should be done lazily by
> > the driver, I would have thought.
> 
> 
> Agree. Although for most real applications, the performance difference
> is probably negligible.

But importantly, doing it that way means you share test coverage with
the CPU TLB flushing code, and you don't introduce a new concept to the
VM.

So, it _has_ to be lazy flushing, IMO (as there doesn't seem to be a
good reason otherwise). mprotect shouldn't really be a special case,
because it still has to flush the CPU tlbs as well when restricting
access.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
