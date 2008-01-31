From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: [patch 0/3] [RFC] MMU Notifiers V4
Date: Wed, 30 Jan 2008 20:57:50 -0800
Message-ID: <20080131045750.855008281@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Andrea Arcangeli <andrea-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, steiner-sJ/iWh9BUns@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, daniel.blueman-xqY44rlHlBpWk0Htik3J/w@public.gmane.org, Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
List-Id: linux-mm.kvack.org

I hope this is finally a release that covers all the requirements. Locking
description is at the top of the core patch.

This is a patchset implementing MMU notifier callbacks based on Andrea's
earlier work. These are needed if Linux pages are referenced from something
else than tracked by the rmaps of the kernel. The known immediate users are

KVM (establishes a refcount to the page. External references called spte)
	(Refcount seems to be not necessary)

GRU (simple TLB shootdown without refcount. Has its own pagetable/tlb)

XPmem (uses its own reverse mappings. Remote ptes, Needs
	to sleep when sending messages)
	XPmem could defer freeing pages if a callback with atomic=1 occurs.

Pending:

- Feedback from users of the callbacks for KVM, RDMA, XPmem and GRU
  (Early tests with the GRU were successful).

Known issues:

- RCU quiescent periods are required on registering
  notifiers to guarantee visibility to other processors.

Andrea's mmu_notifier #4 -> RFC V1

- Merge subsystem rmap based with Linux rmap based approach
- Move Linux rmap based notifiers out of macro
- Try to account for what locks are held while the notifiers are
  called.
- Develop a patch sequence that separates out the different types of
  hooks so that we can review their use.
- Avoid adding include to linux/mm_types.h
- Integrate RCU logic suggested by Peter.

V1->V2:
- Improve RCU support
- Use mmap_sem for mmu_notifier register / unregister
- Drop invalidate_page from COW, mm/fremap.c and mm/rmap.c since we
  already have invalidate_range() callbacks there.
- Clean compile for !MMU_NOTIFIER
- Isolate filemap_xip strangeness into its own diff
- Pass a the flag to invalidate_range to indicate if a spinlock
  is held.
- Add invalidate_all()

V2->V3:
- Further RCU fixes
- Fixes from Andrea to fixup aging and move invalidate_range() in do_wp_page
  and sys_remap_file_pages() after the pte clearing.

V3->V4:
- Drop locking and synchronize_rcu() on ->release since we know on release that
  we are the only executing thread. This is also true for invalidate_all() so
  we could drop off the mmu_notifier there early. Use hlist_del_init instead
  of hlist_del_rcu.
- Do the invalidation as begin/end pairs with the requirement that the driver
  holds off new references in between.
- Fixup filemap_xip.c
- Figure out a potential way in which XPmem can deal with locks that are held.
- Robin's patches to make the mmu_notifier logic manage the PageRmapExported bit.
- Strip cc list down a bit.
- Drop Peters new rcu list macro
- Add description to the core patch

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
