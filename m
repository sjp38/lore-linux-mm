Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7DDFF6B005C
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:48:46 -0400 (EDT)
Date: Fri, 12 Jun 2009 11:58:11 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v5
Message-ID: <20090612095811.GA25568@one.firstfloor.org>
References: <20090603846.816684333@firstfloor.org> <20090603184648.2E2131D028F@basil.firstfloor.org> <20090609100922.GF14820@wotan.suse.de> <Pine.LNX.4.64.0906091637430.13213@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906091637430.13213@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, riel@redhat.com, chris.mason@oracle.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 05:05:53PM +0100, Hugh Dickins wrote:
> To me, it's just another layer of complexity and maintenance burden
> that one special-interest group is imposing upon mm, and I can't
> keep up with it myself.

Thanks for the kind words.
> 
> However, if I'm interpreting these extracts correctly, the whole
> thing looks very misguided to me.  Are we really going to kill any
> process that has a cousin who might once have mapped the page that's
> been found hwpoisonous?  The hwpoison secret police are dangerously
> out of control, I'd say.

What do you mean with once? It's a not yet afaik?

The not yet was intentional for early kill mode -- the main reason
for that is KVM guests where it should mimic the hardware behaviour
that you report a future memory corruption, so that the guest
takes step to never access it. So even if the access
to the bad page is in the future as long as the process
has theoretical access it should be killed.

In late kill modus that's different of course.

> 
> The usual use of rmap lookup loops is to go on to look into the page
> table to see whether the page is actually mapped: I see no attempt
> at that here, just an assumption that anyone on the list is guilty
> of mapping the page and must be killed.  And even if it did go on

Yes that's intentional.

> 
> At least in the file's prio_tree case, we'll only be killing those
> who mmapped the range which happens to include the page.  But in the
> anon case, remember the anon_vma is just a bundle of "related" vmas
> outside of which the page will not be found; so if one process got a
> poisonous page through COW, all the other processes which happen to
> be sharing that anon_vma through fork or through adjacent merging,
> are going to get killed too.

You're right the COW case is a bit of a problem, we don't distingush
that.  Perhaps that can be easily checked, but even if we kill
a bit too much it's still better than killing too little. I don't think it's
as big a problem as you claim.

> I think a much more sensible approach would be to follow the page
> migration technique of replacing the page's ptes by a special swap-like
> entry, then do the killing from do_swap_page() if a process actually
> tries to access the page.

That's what late kill modus does (see the patch description/comment on
top of file), but it doesn't have the right semantics for KVM.
It's still used for a few cases by default, e.g. for the swap cache.


-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
