Date: Fri, 25 Jan 2008 10:31:22 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/4] [RFC] MMU Notifiers V1
In-Reply-To: <20080125114229.GA7454@v2.random>
Message-ID: <Pine.LNX.4.64.0801251024060.672@schroedinger.engr.sgi.com>
References: <20080125055606.102986685@sgi.com> <20080125114229.GA7454@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jan 2008, Andrea Arcangeli wrote:

> On a technical merit this still partially makes me sick and I think
> it's the last issue to debate.
> 
> @@ -971,6 +974,9 @@ int try_to_unmap(struct page *page, int 
>         else
>                 ret = try_to_unmap_file(page, migration);
> 
> +       if (unlikely(PageExternalRmap(page)))
> +               mmu_rmap_notifier(invalidate_page, page);
> +
>         if (!page_mapped(page))
>                 ret = SWAP_SUCCESS;
>         return ret;
> 
> I find the above hard to accept, because the moment you work with
> physical pages and not "mm+address" I think you couldn't possibly care
> if page_mapped is true or false, and I think the above notifier should
> be called _outside_ try_to_unmap. Infact I'd call
> mmu_rmap_notifier(invalidate_page, page); only if page_unmapped is
> false and the linux pte is gone already (practically just before the
> page_count == 2 check and after try_to_unmap).

try_to_unmap is called from multiple places. The placement here
also covers f.e. page migration.

We also need to do this in the page_mkclean case because the permissions
on an external pte are restricted there. So we need a refault to update
the pte.

> I also think it's still worth to debate the rmap based on virtual or
> physical index. By supporting both secondary-rmap designs at the same
> time you seem to agree current KVM lightweight rmap implementation is
> a superior design at least for KVM. But by insisting on your rmap
> based on physical for your usage, you're implicitly telling us that is
> a superior design for you. But we know very little of why you can't

We actually need both version. We have hardware that has a driver without 
rmap that does not sleep. On the other hand XPmem has rmap capability and 
needs to sleep for its notifications.

> Nevertheless I'm very glad we already fully converged on the
> set_page_dirty, invalidate-page after ptep_clear_flush/young,
> etc... and furthermore that you only made very minor modification to
> my code to add a pair of hooks for the page-based rmap notifiers on
> top of my patch. So from a functionality POV this is 100% workable
> already from KVM side!

Well we still have to review this stuff more and I have a vague feeling 
that not all the multiple hooks that came about because I took the 
mmu_notifier(invalidate_page, ...) out of the macro need to be kept 
because some of them are already covered by the range operations.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
