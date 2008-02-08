Date: Fri, 8 Feb 2008 14:23:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/6] MMU Notifiers V6
Message-Id: <20080208142315.7fe4b95e.akpm@linux-foundation.org>
In-Reply-To: <20080208220616.089936205@sgi.com>
References: <20080208220616.089936205@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: andrea@qumranet.com, holt@sgi.com, avi@qumranet.com, izike@qumranet.com, kvm-devel@lists.sourceforge.net, a.p.zijlstra@chello.nl, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

On Fri, 08 Feb 2008 14:06:16 -0800
Christoph Lameter <clameter@sgi.com> wrote:

> This is a patchset implementing MMU notifier callbacks based on Andrea's
> earlier work. These are needed if Linux pages are referenced from something
> else than tracked by the rmaps of the kernel (an external MMU). MMU
> notifiers allow us to get rid of the page pinning for RDMA and various
> other purposes. It gets rid of the broken use of mlock for page pinning.
> (mlock really does *not* pin pages....)
> 
> More information on the rationale and the technical details can be found in
> the first patch and the README provided by that patch in
> Documentation/mmu_notifiers.
> 
> The known immediate users are
> 
> KVM
> - Establishes a refcount to the page via get_user_pages().
> - External references are called spte.
> - Has page tables to track pages whose refcount was elevated but
>   no reverse maps.
> 
> GRU
> - Simple additional hardware TLB (possibly covering multiple instances of
>   Linux)
> - Needs TLB shootdown when the VM unmaps pages.
> - Determines page address via follow_page (from interrupt context) but can
>   fall back to get_user_pages().
> - No page reference possible since no page status is kept..
> 
> XPmem
> - Allows use of a processes memory by remote instances of Linux.
> - Provides its own reverse mappings to track remote pte.
> - Established refcounts on the exported pages.
> - Must sleep in order to wait for remote acks of ptes that are being
>   cleared.
> 

What about ib_umem_get()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
