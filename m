Date: Tue, 22 Jan 2008 14:53:12 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
In-Reply-To: <20080122223139.GD15848@v2.random>
Message-ID: <Pine.LNX.4.64.0801221433080.2271@schroedinger.engr.sgi.com>
References: <20080116124256.44033d48@bree.surriel.com> <478E4356.7030303@qumranet.com>
 <20080117162302.GI7170@v2.random> <478F9C9C.7070500@qumranet.com>
 <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random>
 <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random>
 <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com>
 <20080122223139.GD15848@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Jan 2008, Andrea Arcangeli wrote:

> First it makes me optimistic this can be merged sooner than later to
> see a second brand new implementation of this ;).

Brand new? Well this is borrowing as much as possible from you....

> > The problem that I have with this is still that there is no way to sleep 
> > while running the notifier. We need to invalidate mappings on a remote 
> > instance of linux. This means sending out a message and waiting for reply 
> > before the local page is unmapped. So I reworked Andrea's early patch and 
> > came up with this one:
> 
> I guess you missed a problem in unmapping the secondary mmu before the
> core linux pte is cleared with a zero-locking window in between the
> two operations. The spte may be instantiated again by a
> vmexit/secondary-pagefault in another cpu during the zero-locking
> window (zero locking is zero locking, anything can run in the other
> cpus, so not exactly sure how you plan to fix that nasty subtle spte
> leak if you insist calling the mmu_notifier invalidates _before_
> instead of _after_ ;). All spte invalidates should happen _after_
> dropping the main linux pte not before, or you never know what else is
> left mapped in the secondary mmu by the time the linux pte is finally
> cleared.

spte is the remote pte in my scheme right? The linux instance with the 
secondary mmu must call back to the exporting machine in order to 
reinstantiate the page. PageExported is cleared in invalidate_page() so 
the other linux instance will be told that the page is not available.

> > - Notifiers are called *after* we tore down ptes. At that point pages
> >   may already have been freed and reused. [..]
> 
> Wait, you should always represent the external reference in the page
> count just like we do every time we map the page in a linux pte! If
> you worry about that, that's your fault I'm afraid.

Ahhh. Good to hear. But we will still end in a situation where only
the remote ptes point to the page. Maybe the remote instance will dirty
the page at that point?

> > - anon_vma/inode and pte locks are held during callbacks.
> 
> In a previous email I asked what's wrong in offloading the event, and

We have internally discussed the possibility of offloading the event but 
that wont work with the existing callback since we would have to 
perform atomic allocation and there may be thousands of external 
references to a page.

> sharing code, and for you missing a single notifier means memory
> corruption because you don't bump the page count to represent the
> external reference).

The approach with the export notifier is page based not based on the 
mm_struct. We only need a single page count for a page that is exported to 
a number of remote instances of linux. The page count is dropped when all 
the remote instances have unmapped the page.

 
> > @@ -966,6 +973,9 @@ int try_to_unmap(struct page *page, int 
> >  
> >  	BUG_ON(!PageLocked(page));
> >  
> > +	if (unlikely(PageExported(page)))
> > +		export_notifier(invalidate_page, page);
> > +
> 
> Passing the page here will complicate things especially for shared
> pages across different VM that are already working in KVM. For non

How?

> shared pages we could cache the userland mapping address in
> page->private but it's a kludge only working for non-shared
> pages. Walking twice the anon_vma lists when only a single walk is

There is only the need to walk twice for pages that are marked Exported. 
And the double walk is only necessary if the exporter does not have its 
own rmap. The cross partition thing that we are doing has such an rmap and 
its a matter of walking the exporters rmap to clear out the external 
references and then we walk the local rmaps. All once.

> Besides the pinned pages ram leak by having the zero locking window
> above I'm curious how you are going to take care of the finegrined
> aging that I'm doing with the accessed bit set by hardware in the spte

I think I explained that above. Remote users effectively are forbidden to 
establish new references to the page by the clearing of the exported bit.

> with your coarse export_notifier(invalidate_page) called
> unconditionally before checking any young bit at all.

The export notifier is called only if the mm_struct or page bit for 
exporting is set. Maybe I missed to add a check somewhere?

> Look how clean it is to hook asm-generic/pgtable.h in my last patch
> compared to the above leaking code expanded all over the place in the
> mm/*.c, unnecessary mangling of atomic bitflags in the page struct,
> etc...

I think that hunk is particularly bad in your patch. A notification side 
event in a macro? You would want that explicitly in the code.

> > +	bool "Export Notifier for notifying subsystems about changes to page mappings"
> 
> The word "export notifier" isn't very insightful to me, it doesn't
> even give an hint we're in the memory management area. If you don't
> like mmu notifier name I don't mind changing it, but I doubt export
> notifier is a vast naming improvement. Infact it looks one of those
> names like RCU that don't tell much of what is really going on
> (there's no copy 99% of time in RCU).

What we are doing is effectively allowing external references to pages. 
This is outside of the regular VM operations. So export came up but we 
could call it something else. External? Its not really tied to the mmu 
now.

> 
> > +LIST_HEAD(export_notifier_list);
> 
> A global list is not ok IMHO, it's really bad to have a O(N) (N number
> of mm in the system) complexity here when it's so trivial to go O(1)
> like in my code. We want to swap 100% of the VM exactly so we can have
> zillon of idle (or sigstopped) VM on the same system.

There will only be one or two of those notifiers. There is no need to 
build long lists of mm_structs like in your patch.

The mm_struct is not available at the point of my callbacks. There is no 
way to do a callback that is mm_struct based if you are not scanning the 
reverse list. And scanning the reverse list requires taking locks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
