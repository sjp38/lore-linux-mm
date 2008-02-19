Date: Tue, 19 Feb 2008 05:59:38 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch] my mmu notifiers
Message-ID: <20080219115938.GD11391@sgi.com>
References: <20080219084357.GA22249@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080219084357.GA22249@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2008 at 09:43:57AM +0100, Nick Piggin wrote:
> So I implemented mmu notifiers slightly differently. Andrea's mmu notifiers
> are rather similar. However I have tried to make a point of minimising the
> impact the the core mm/. I don't see why we need to invalidate or flush
> anything when changing the pte to be _more_ permissive, and I don't
> understand the need for invalidate_begin/invalidate_end pairs at all.
> What I have done is basically create it so that the notifiers get called
> basically in the same place as the normal TLB flushing is done, and nowhere
> else.

Because XPMEM needs to be able to sleep during its callout.  For that,
we need to move this outside of the page table lock and suddenly we
need the begin/end pair again.  There was considerable discussion about
this exact point numerous times.  We tried to develop the most inclusive
design possible.  Our design would even be extendable to IB, assuming they
made some very disruptive changes to their MPI and communication libraries.
IB would suffer the same problems XPMEM does in that the TLB entries
need to be removed on a remote host which is operating completely
independently.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
