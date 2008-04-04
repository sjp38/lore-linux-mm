From: Christoph Lameter <clameter@sgi.com>
Subject: [ofa-general] [patch 00/10] [RFC] EMM Notifier V3
Date: Fri, 04 Apr 2008 15:30:48 -0700
Message-ID: <20080404223048.374852899@sgi.com>
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org
List-Id: linux-mm.kvack.org

V2->V3:
- Fix rcu issues
- Fix emm_referenced handling
- Use Andrea's mm_lock/unlock to prevent registration races.
- Keep simple API since there does not seem to be a need to add additional
  callbacks (mm_lock does not require callbacks like emm_start/stop that
  I envisioned).
- Reduce CC list (the volume we are producing here must be annoying...).

V1->V2:
- Additional optimizations in the VM
- Convert vm spinlocks to rw sems.
- Add XPMEM driver (requires sleeping in callbacks)
- Add XPMEM example

This patch implements a simple callback for device drivers that establish
their own references to pages (KVM, GRU, XPmem, RDMA/Infiniband, DMA engines
etc). These references are unknown to the VM (therefore external).

With these callbacks it is possible for the device driver to release external
references when the VM requests it. This enables swapping, page migration and
allows support of remapping, permission changes etc etc for the externally
mapped memory.

With this functionality it becomes also possible to avoid pinning or mlocking
pages (commonly done to stop the VM from unmapping device mapped pages).

A device driver must subscribe to a process using

        emm_register_notifier(struct emm_notifier *, struct mm_struct *)


The VM will then perform callbacks for operations that unmap or change
permissions of pages in that address space. When the process terminates
the callback function is called with emm_release.

Callbacks are performed before and after the unmapping action of the VM.

        emm_invalidate_start    before

        emm_invalidate_end      after

The device driver must hold off establishing new references to pages
in the range specified between a callback with emm_invalidate_start and
the subsequent call with emm_invalidate_end set. This allows the VM to
ensure that no concurrent driver actions are performed on an address
range while performing remapping or unmapping operations.


This patchset contains additional modifications needed to ensure
that the callbacks can sleep. For that purpose two key locks in the vm
need to be converted to rw_sems. These patches are brand new, invasive
and need extensive discussion and evaluation.

The first patch alone may be applied if callbacks in atomic context are
sufficient for a device driver (likely the case for KVM and GRU and simple
DMA drivers).

Following the VM modifications is the XPMEM device driver that allows sharing
of memory between processes running on different instances of Linux. This is
also a prototype. It is known to run trivial sample programs included as the last
patch.


-- 
