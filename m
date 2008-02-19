From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 3/6] mmu_notifier: invalidate_page callbacks
Date: Tue, 19 Feb 2008 19:46:10 +1100
References: <20080215064859.384203497@sgi.com> <20080215193736.9d6e7da3.akpm@linux-foundation.org> <Pine.LNX.4.64.0802161121130.25573@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0802161121130.25573@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200802191946.10695.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Sunday 17 February 2008 06:22, Christoph Lameter wrote:
> On Fri, 15 Feb 2008, Andrew Morton wrote:

> > >  		flush_cache_page(vma, address, pte_pfn(*pte));
> > >  		entry = ptep_clear_flush(vma, address, pte);
> > > +		mmu_notifier(invalidate_page, mm, address);
> >
> > I just don't see how ths can be done if the callee has another thread in
> > the middle of establishing IO against this region of memory.
> > ->invalidate_page() _has_ to be able to block.  Confused.
>
> The page lock is held and that holds off I/O?

I think the actual answer is that "it doesn't matter".

ptes are not exactly the entity via which IO gets established, so
all we really care about here is that after the callback finishes,
we will not get any more reads or writes to the page via the
external mapping.

As far as holding off local IO goes, that is the job of the core
VM. (And no, page lock does not necessarily hold it off FYI -- it
can be writeback IO or even IO directly via buffers).

Holding off IO via the external references I guess is a job for
the notifier driver.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
