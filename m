From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: [patch 0/6] MMU Notifiers V6
Date: Fri, 08 Feb 2008 14:06:16 -0800
Message-ID: <20080208220616.089936205@sgi.com>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: Andrea Arcangeli <andrea-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, steiner-sJ/iWh9BUns@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>, kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, daniel.blueman-xqY44rlHlBpWk0Htik3J/w@public.gmane.org, Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
List-Id: linux-mm.kvack.org

This is a patchset implementing MMU notifier callbacks based on Andrea's
earlier work. These are needed if Linux pages are referenced from something
else than tracked by the rmaps of the kernel (an external MMU). MMU
notifiers allow us to get rid of the page pinning for RDMA and various
other purposes. It gets rid of the broken use of mlock for page pinning.
(mlock really does *not* pin pages....)

More information on the rationale and the technical details can be found in
the first patch and the README provided by that patch in
Documentation/mmu_notifiers.

The known immediate users are

KVM
- Establishes a refcount to the page via get_user_pages().
- External references are called spte.
- Has page tables to track pages whose refcount was elevated but
  no reverse maps.

GRU
- Simple additional hardware TLB (possibly covering multiple instances of
  Linux)
- Needs TLB shootdown when the VM unmaps pages.
- Determines page address via follow_page (from interrupt context) but can
  fall back to get_user_pages().
- No page reference possible since no page status is kept..

XPmem
- Allows use of a processes memory by remote instances of Linux.
- Provides its own reverse mappings to track remote pte.
- Established refcounts on the exported pages.
- Must sleep in order to wait for remote acks of ptes that are being
  cleared.

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

V4->V5:
- Provide missing callouts for mremap.
- Provide missing callouts for copy_page_range.
- Reduce mm_struct space to zero if !MMU_NOTIFIER by #ifdeffing out
  structure contents.
- Get rid of the invalidate_all() callback by moving ->release in place
  of invalidate_all.
- Require holding mmap_sem on register/unregister instead of acquiring it
  ourselves. In some contexts where we want to register/unregister we are
  already holding mmap_sem.
- Split out the rmap support patch so that there is no need to apply
  all patches for KVM and GRU.

V5->V6:
- Provide missing range callouts for mprotect
- Fix do_wp_page control path sequencing
- Clarify locking conventions
- GRU and XPmem confirmed to work with this patchset.
- Provide skeleton code for GRU/KVM type callback and for XPmem type.
- Rework documentation and put it into Documentation/mmu_notifier.

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
