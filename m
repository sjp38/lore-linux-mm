Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 833EE6B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:06:59 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b82so7305574wmd.5
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:06:59 -0800 (PST)
Received: from mx02.buh.bitdefender.com (mx02.bbu.dsd.mx.bitdefender.com. [91.199.104.133])
        by mx.google.com with ESMTPS id z51si2856959wrc.174.2017.12.18.11.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 11:06:57 -0800 (PST)
From: =?UTF-8?q?Adalber=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v4 00/18] VM introspection
Date: Mon, 18 Dec 2017 21:06:24 +0200
Message-Id: <20171218190642.7790-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>, Adalbert Lazar <alazar@bitdefender.com>

From: Adalbert Lazar <alazar@bitdefender.com>

This patch series proposes a VM introspection subsystem for KVM (KVMI).

The previous RFC can be read here: https://marc.info/?l=kvm&m=150514457912721

These patches were tested on kvm/master,
commit 43aabca38aa9668eee3c3c1206207034614c0901 (Merge tag 'kvm-arm-fixes-for-v4.15-2' of git://git.kernel.org/pub/scm/linux/kernel/git/kvmarm/kvmarm into HEAD).

In this iteration we refactored the code based on the feedback received
from Paolo and others.

The handshake
-------------
We no longer listen on a vsock in kernel, accepting introspectors
to control all the other VM-s. Instead, QEMU (ie. every introspected
guest) initiates the connection with an introspection tool (running on
the same host, in another VM, etc.) and passes the control to KVM where
the in-kernel mechanism will take over.

The administrator has to choose which guests should be introspected, by
which introspectors, what commands and events are allowed and for which
guests. Currently, there is a bitmask for allowed commands/events, but
it seems to be too complicated. For example, being allowed to set page
accesses (eg. r--) and not being allowed to receive page fault events
(eg. -wx) doesn't make sense.

The memory maping
-----------------
Besides the read/write commands to access guest memory, for performance
reasons, we've implemented memory mapping for introspection tools running
in another guest (on the same host, like page sharing between guests,
but without copy-on-write): the KVMI_GET_TOKEN command is used to obtain
a token, which is passed with a hypercall from the introspecting guest
to the KVMI.

While this didn't had a high priority, somehow the stars aligned and we
have it.

Page tracking
-------------
The current page tracking mechanism from KVM has support to track write
accesses (after the write operation took place). We've extended it with
preread, prewrite and preexec tracking.

We also added a notification for when a new memory slot is being
created (see track_create_slot()).

Pause VM
--------
We've removed the commands to pause/resume VM. Having a "pause vCPU"
command and a "paused vCPU" event seems to be enough for now.

Not implemented yet
-------------------

There are a few things documented, but not implemented yet: virtualized
exceptions, single-stepping and EPT views.

We are also working on accomodating SPP (Sub Page Protection).

We hope to make public our repositories (kernel, QEMU,
userland/simple-introspector) in a couple of days and we're looking
forward to add unit tests.

Changes since v3:
  - move the accept/handshake worker to QEMU
  - extend and use the 'page_track' infrastructure to intercept page
    accesses during emulation
  - remove the 0x40000000-0x40001fff range from monitored MSR-s
  - make small changes to the wire protocol (error codes, padding, names)
  - simplify KVMI_PAUSE_VCPU
  - add new commands: KVMI_GET_MAP_TOKEN, KVMI_GET_XSAVE
  - add pat to KVMI_EVENT
  - document KVM_HC_MEM_MAP and KVM_HC_MEM_UNMAP hypercalls

Changes since v2:
  - make small changes to the wire protocol (eg. use kvmi_error_code
    with every command reply, a few renames, etc.)
  - removed '_x86' from x86 specific structure names. Architecture
    specific structures will have the same name.
  - drop KVMI_GET_MTRR_TYPE and KVMI_GET_MTRRS (use KVMI_SET_REGISTERS)
  - drop KVMI_EVENT_ACTION_SET_REGS (use KVMI_SET_REGISTERS)
  - remove KVMI_MAP_PHYSICAL_PAGE_TO_GUEST and KVMI_UNMAP_PHYSICAL_PAGE_FROM_GUEST
    (to be replaced by a token+hypercall pair)
  - extend KVMI_GET_VERSION with allowed commnd/event masks
  - replace KVMI_PAUSE_GUEST/KVMI_UNPAUSE_GUEST with KVMI_PAUSE_VCPU
  - replace KVMI_SHUTDOWN_GUEST with KVMI_EVENT_ACTION_CRASH
  - replace KVMI_GET_XSAVE_INFO with KVMI_GET_CPUID
  - merge KVMI_INJECT_PAGE_FAULT and KVMI_INJECT_BREAKPOINT
    in KVMI_INJECT_EXCEPTION
  - replace event reply flags with ALLOW/SKIP/RETRY/CRASH actions
  - make KVMI_SET_REGISTERS work with vCPU events only
  - add EPT view support in KVMI_GET_PAGE_ACCESS/KVMI_SET_PAGE_ACCESS
  - add support for multiple pages in KVMI_GET_PAGE_ACCESS/KVMI_SET_PAGE_ACCESS
  - add (back) KVMI_READ_PHYSICAL/KVMI_WRITE_PHYSICAL
  - add KVMI_CONTROL_VE
  - add cstar to KVMI_EVENT
  - add new events: KVMI_EVENT_VCPU_PAUSED, KVMI_EVENT_CREATE_VCPU, 
    KVMI_EVENT_DESCRIPTOR_ACCESS, KVMI_EVENT_SINGLESTEP
  - add new sections: "Introspection capabilities", "Live migrations",
    "Guest snapshots with memory", "Memory access safety"
  - document the hypercall used by the KVMI_EVENT_HYPERCALL command
    (was KVMI_EVENT_USER_CALL)

Changes since v1:
  - add documentation and ABI [Paolo, Jan]
  - drop all the other patches for now [Paolo]
  - remove KVMI_GET_GUESTS, KVMI_EVENT_GUEST_ON, KVMI_EVENT_GUEST_OFF,
    and let libvirt/qemu handle this [Stefan, Paolo]
  - change the license from LGPL to GPL [Jan]
  - remove KVMI_READ_PHYSICAL and KVMI_WRITE_PHYSICAL (not used anymore)
  - make the interface a little more consistent


Adalbert Lazar (18):
  kvm: add documentation and ABI/API headers for the VM introspection
    subsystem
  add memory map/unmap support for VM introspection on the guest side
  kvm: x86: add kvm_arch_msr_intercept()
  kvm: x86: add kvm_mmu_nested_guest_page_fault() and
    kvmi_mmu_fault_gla()
  kvm: x86: add kvm_arch_vcpu_set_regs()
  kvm: vmx: export the availability of EPT views
  kvm: page track: add support for preread, prewrite and preexec
  kvm: add the VM introspection subsystem
  kvm: hook in the VM introspection subsystem
  kvm: x86: handle the new vCPU request (KVM_REQ_INTROSPECTION)
  kvm: x86: hook in the page tracking
  kvm: x86: hook in kvmi_breakpoint_event()
  kvm: x86: hook in kvmi_descriptor_event()
  kvm: x86: hook in kvmi_cr_event()
  kvm: x86: hook in kvmi_xsetbv_event()
  kvm: x86: hook in kvmi_msr_event()
  kvm: x86: handle the introspection hypercalls
  kvm: x86: hook in kvmi_trap_event()

 Documentation/virtual/kvm/00-INDEX       |    2 +
 Documentation/virtual/kvm/hypercalls.txt |   66 ++
 Documentation/virtual/kvm/kvmi.rst       | 1323 ++++++++++++++++++++++++++++
 arch/x86/Kconfig                         |    9 +
 arch/x86/include/asm/kvm_emulate.h       |    1 +
 arch/x86/include/asm/kvm_host.h          |   13 +
 arch/x86/include/asm/kvm_page_track.h    |   24 +-
 arch/x86/include/asm/kvmi_guest.h        |   10 +
 arch/x86/include/asm/vmx.h               |    2 +
 arch/x86/include/uapi/asm/kvmi.h         |  213 +++++
 arch/x86/kernel/Makefile                 |    1 +
 arch/x86/kernel/kvmi_mem_guest.c         |   26 +
 arch/x86/kvm/Makefile                    |    1 +
 arch/x86/kvm/emulate.c                   |    9 +-
 arch/x86/kvm/mmu.c                       |  156 +++-
 arch/x86/kvm/mmu.h                       |    4 +
 arch/x86/kvm/page_track.c                |  129 ++-
 arch/x86/kvm/svm.c                       |   66 ++
 arch/x86/kvm/vmx.c                       |  109 ++-
 arch/x86/kvm/x86.c                       |  141 ++-
 include/linux/kvm_host.h                 |    5 +
 include/linux/kvmi.h                     |   32 +
 include/linux/mm.h                       |    3 +
 include/trace/events/kvmi.h              |  174 ++++
 include/uapi/linux/kvm.h                 |    8 +
 include/uapi/linux/kvm_para.h            |   10 +-
 include/uapi/linux/kvmi.h                |  150 ++++
 mm/internal.h                            |    5 -
 virt/kvm/kvm_main.c                      |   19 +
 virt/kvm/kvmi.c                          | 1410 ++++++++++++++++++++++++++++++
 virt/kvm/kvmi_int.h                      |  121 +++
 virt/kvm/kvmi_mem.c                      |  730 ++++++++++++++++
 virt/kvm/kvmi_mem_guest.c                |  379 ++++++++
 virt/kvm/kvmi_msg.c                      | 1134 ++++++++++++++++++++++++
 34 files changed, 6438 insertions(+), 47 deletions(-)
 create mode 100644 Documentation/virtual/kvm/kvmi.rst
 create mode 100644 arch/x86/include/asm/kvmi_guest.h
 create mode 100644 arch/x86/include/uapi/asm/kvmi.h
 create mode 100644 arch/x86/kernel/kvmi_mem_guest.c
 create mode 100644 include/linux/kvmi.h
 create mode 100644 include/trace/events/kvmi.h
 create mode 100644 include/uapi/linux/kvmi.h
 create mode 100644 virt/kvm/kvmi.c
 create mode 100644 virt/kvm/kvmi_int.h
 create mode 100644 virt/kvm/kvmi_mem.c
 create mode 100644 virt/kvm/kvmi_mem_guest.c
 create mode 100644 virt/kvm/kvmi_msg.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
