Date: Fri, 25 Jan 2008 12:42:29 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 0/4] [RFC] MMU Notifiers V1
Message-ID: <20080125114229.GA7454@v2.random>
References: <20080125055606.102986685@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080125055606.102986685@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 24, 2008 at 09:56:06PM -0800, Christoph Lameter wrote:
> Andrea's mmu_notifier #4 -> RFC V1
> 
> - Merge subsystem rmap based with Linux rmap based approach
> - Move Linux rmap based notifiers out of macro
> - Try to account for what locks are held while the notifiers are
>   called.
> - Develop a patch sequence that separates out the different types of
>   hooks so that it is easier to review their use.
> - Avoid adding #include to linux/mm_types.h
> - Integrate RCU logic suggested by Peter.

I'm glad you're converging on something a bit saner and much much
closer to my code, plus perfectly usable by KVM optimal rmap design
too. It would have preferred if you would have sent me patches like
Peter did for review and merging etc... that would have made review
especially easier. Anyway I'm used to that on lkml so it's ok, I just
need this patch to be included in mainline, everything else is
irrelevant to me.

On a technical merit this still partially makes me sick and I think
it's the last issue to debate.

@@ -971,6 +974,9 @@ int try_to_unmap(struct page *page, int 
        else
                ret = try_to_unmap_file(page, migration);

+       if (unlikely(PageExternalRmap(page)))
+               mmu_rmap_notifier(invalidate_page, page);
+
        if (!page_mapped(page))
                ret = SWAP_SUCCESS;
        return ret;

I find the above hard to accept, because the moment you work with
physical pages and not "mm+address" I think you couldn't possibly care
if page_mapped is true or false, and I think the above notifier should
be called _outside_ try_to_unmap. Infact I'd call
mmu_rmap_notifier(invalidate_page, page); only if page_unmapped is
false and the linux pte is gone already (practically just before the
page_count == 2 check and after try_to_unmap).

I also think it's still worth to debate the rmap based on virtual or
physical index. By supporting both secondary-rmap designs at the same
time you seem to agree current KVM lightweight rmap implementation is
a superior design at least for KVM. But by insisting on your rmap
based on physical for your usage, you're implicitly telling us that is
a superior design for you. But we know very little of why you can't
exactly build rmap on virtual like KVM does! (especially now that you
implicitly admitted KVM rmap design is superior at least for KVM it'd
be interesting to know why you can't do the same exactly) You said
something on that, but I certainly don't have a clear picture of why
it can't work or why it would be less efficient.

Like you said by PM I'd also like comments from Hugh, Nick and others
about this issue.

Nevertheless I'm very glad we already fully converged on the
set_page_dirty, invalidate-page after ptep_clear_flush/young,
etc... and furthermore that you only made very minor modification to
my code to add a pair of hooks for the page-based rmap notifiers on
top of my patch. So from a functionality POV this is 100% workable
already from KVM side!

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
