Date: Tue, 22 Jan 2008 23:31:39 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
Message-ID: <20080122223139.GD15848@v2.random>
References: <20080116124256.44033d48@bree.surriel.com> <478E4356.7030303@qumranet.com> <20080117162302.GI7170@v2.random> <478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

Just a few early comments.

First it makes me optimistic this can be merged sooner than later to
see a second brand new implementation of this ;).

On Tue, Jan 22, 2008 at 12:34:46PM -0800, Christoph Lameter wrote:
> On Tue, 22 Jan 2008, Andrea Arcangeli wrote:
> 
> > This last update avoids the need to refresh the young bit in the linux
> > pte through follow_page and it allows tracking the accessed bits set
> > by the hardware in the sptes without requiring vmexits in certain
> > implementations.
> 
> The problem that I have with this is still that there is no way to sleep 
> while running the notifier. We need to invalidate mappings on a remote 
> instance of linux. This means sending out a message and waiting for reply 
> before the local page is unmapped. So I reworked Andrea's early patch and 
> came up with this one:

I guess you missed a problem in unmapping the secondary mmu before the
core linux pte is cleared with a zero-locking window in between the
two operations. The spte may be instantiated again by a
vmexit/secondary-pagefault in another cpu during the zero-locking
window (zero locking is zero locking, anything can run in the other
cpus, so not exactly sure how you plan to fix that nasty subtle spte
leak if you insist calling the mmu_notifier invalidates _before_
instead of _after_ ;). All spte invalidates should happen _after_
dropping the main linux pte not before, or you never know what else is
left mapped in the secondary mmu by the time the linux pte is finally
cleared.

With a non-present linux pte, the VM won't call into try_to_unmap
anymore and the page will remain pinned in ram forever without any
chance to free it anymore until the spte is freed for other reasons
(VM pressure not included in the other reasons :( ).

> Issues with mmu_ops #2
> 
> - Notifiers are called *after* we tore down ptes. At that point pages
>   may already have been freed and reused. [..]

Wait, you should always represent the external reference in the page
count just like we do every time we map the page in a linux pte! If
you worry about that, that's your fault I'm afraid.

>   [..] This means that there can
>   still be uses of the page by the user of mmu_ops after the OS has
>   dropped its mapping. IMHO the foreign entity needs to drop its
>   mappings first. That also ensures that the entities operated
>   upon continue to exist.
> 
> - anon_vma/inode and pte locks are held during callbacks.

In a previous email I asked what's wrong in offloading the event, and
instead of answering you did your own thing that apparently would leak
memory-pins in hardly fixable way. Chances are your latency in sending
the event won't be too low so if you cluster the invalidates in a
single packet perhaps you're a bit faster anyway. You've just to fix
your reference counting so you stop risking corrupting ram at the
first missing notifier (and you're missing some already, I know the
invalidate_page in do_wp_page for example is already used by the KVM
sharing code, and for you missing a single notifier means memory
corruption because you don't bump the page count to represent the
external reference).

> @@ -966,6 +973,9 @@ int try_to_unmap(struct page *page, int 
>  
>  	BUG_ON(!PageLocked(page));
>  
> +	if (unlikely(PageExported(page)))
> +		export_notifier(invalidate_page, page);
> +

Passing the page here will complicate things especially for shared
pages across different VM that are already working in KVM. For non
shared pages we could cache the userland mapping address in
page->private but it's a kludge only working for non-shared
pages. Walking twice the anon_vma lists when only a single walk is
needed sounds very backwards for KVM purposes. This at least as long
as keep a hva->multiple_gfn design which is quite elegant so far given
qemu has to access the ram in the memslots too.

>  	if (PageAnon(page))
>  		ret = try_to_unmap_anon(page, migration);
>  	else

Besides the pinned pages ram leak by having the zero locking window
above I'm curious how you are going to take care of the finegrined
aging that I'm doing with the accessed bit set by hardware in the spte
with your coarse export_notifier(invalidate_page) called
unconditionally before checking any young bit at all.

Look how clean it is to hook asm-generic/pgtable.h in my last patch
compared to the above leaking code expanded all over the place in the
mm/*.c, unnecessary mangling of atomic bitflags in the page struct,
etc...

> +config EXPORT_NOTIFIER
> +	def_bool y
> +	depends on 64BIT

?

> +	bool "Export Notifier for notifying subsystems about changes to page mappings"

The word "export notifier" isn't very insightful to me, it doesn't
even give an hint we're in the memory management area. If you don't
like mmu notifier name I don't mind changing it, but I doubt export
notifier is a vast naming improvement. Infact it looks one of those
names like RCU that don't tell much of what is really going on
(there's no copy 99% of time in RCU).

> +LIST_HEAD(export_notifier_list);

A global list is not ok IMHO, it's really bad to have a O(N) (N number
of mm in the system) complexity here when it's so trivial to go O(1)
like in my code. We want to swap 100% of the VM exactly so we can have
zillon of idle (or sigstopped) VM on the same system.

Infact initially I wondered for a quite long while if it was better to
register in the mm or the vma, now in kvm registering in the mm is a
lot simpler, even if perhaps it might be possible to save a few cycles
per page-invalidate with the mm. But it's definitely not a complexity
issue to have it in the mm at least for KVM (the number of memslots is
very limited and not in function of the VM size, furthermore it can be
made O(log(N)) quite easily if really interesting and it avoids
creating a 1:1 identity between post-vma-merges and memslots).

Thanks a lot!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
