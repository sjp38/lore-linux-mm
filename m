Date: Wed, 16 Jan 2008 11:19:40 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v2
Message-ID: <20080116101939.GH7059@v2.random>
References: <20080113162418.GE8736@v2.random> <478DC7EC.1040101@inria.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <478DC7EC.1040101@inria.fr>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 16, 2008 at 10:01:32AM +0100, Brice Goglin wrote:
> One of the difference with my patch is that you attach the notifier list to 
> the mm_struct while my code attached it to vmas. But I now don't think it 
> was such a good idea since it probably didn't reduce the number of notifier 
> calls a lot.

Thanks for raising this topic.

Notably KVM also would be a bit more optimal with the notifier in the
vma and that was the original implementation too. It's not a sure
thing that it has to be in the mm.

The quadrics patch does a mixture, it attaches it to the mm but then
it pretends to pass the vma down to the method, and it's broken doing
so, like during munmap where it passes the first vma being unmapped
but not all the later ones in the munmap range.

If we want to attach it to the vma, I think the vma should be passed
as parameter instead of the mm. In some places like
apply_to_page_range the vma isn't even available and I found a little
dirty to run a find_vma inside a #ifdef CONFIG_MMU_NOTIFIER.

The only thing the vma could be interesting about are the protection
bits for things like update_range in the quadrics patch where they
prefetch their secondary tlb. But again if we want to do that, we need
to hook inside unmap_vmas and to pass all the different vmas and not
just the first one touched by unmap_vmas. unmap_vmas is _plural_ not
singular ;).

In the end attaching to mm avoided solving all the above troubles and
provided a strightforward implementation where I would need a single
call to mmu_notifier_register and other minor advantages like that and
not much downside.

But certainly the mm vs vma decision wasn't trivial (I switched back
and forth a few times from vma to mm and back) and if people thinks
this shall be in the vma I can try again but it won't be as a
strightforward patch as for the mm.

One benefit is for example is that it could go in the memslot and
effectively the notifier->memslot conversion would be just a
containerof instead of a "search" over the memslots. Locking aside.

> Also, one thing that I looked at in vmaspy was notifying fork. I am not 
> sure what happens on Copy-on-write with your code, but for sure C-o-w is 
> problematic for shadow page tables. I thought shadow pages should just be 
> invalidated when a fork happens and the caller would refill them after 
> forcing C-o-w or so. So adding a notifier call there too might be nice.

There can't be any cows right now in KVM VM backing store, that's why
it's enough to get full swapping working fine. For example I think
we'll need to add more notifiers to handle swapping of MAP_PRIVATE non
linear tmpfs shared pages properly (and it won't be an issue with
fork() but with after the fact sharing).

Right now I'm more interested in the interface, for the invalidates,
things like mm vs vma, the places where we hook under pte spinlock,
things like that, then the patch can hopefully be merged and extended
with more methods like ->change_protection_page/range and added to cow
etc...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
