Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4ADEE6B025F
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:07:02 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r63so4379735wmb.9
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:07:02 -0800 (PST)
Received: from mx02.buh.bitdefender.com (mx02.bbu.dsd.mx.bitdefender.com. [91.199.104.133])
        by mx.google.com with ESMTPS id y8si10818944wrg.408.2017.12.18.11.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 11:06:57 -0800 (PST)
From: =?UTF-8?q?Adalber=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v4 01/18] kvm: add documentation and ABI/API headers for the VM introspection subsystem
Date: Mon, 18 Dec 2017 21:06:25 +0200
Message-Id: <20171218190642.7790-2-alazar@bitdefender.com>
In-Reply-To: <20171218190642.7790-1-alazar@bitdefender.com>
References: <20171218190642.7790-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>, Adalbert Lazar <alazar@bitdefender.com>

From: Adalbert Lazar <alazar@bitdefender.com>

This includes the new hypercalls and KVM_xxx return values.

Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
Signed-off-by: Adalbert LazA?r <alazar@bitdefender.com>
---
 Documentation/virtual/kvm/00-INDEX       |    2 +
 Documentation/virtual/kvm/hypercalls.txt |   66 ++
 Documentation/virtual/kvm/kvmi.rst       | 1323 ++++++++++++++++++++++++++++++
 arch/x86/include/uapi/asm/kvmi.h         |  213 +++++
 include/uapi/linux/kvm_para.h            |   10 +-
 include/uapi/linux/kvmi.h                |  150 ++++
 6 files changed, 1763 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/virtual/kvm/kvmi.rst
 create mode 100644 arch/x86/include/uapi/asm/kvmi.h
 create mode 100644 include/uapi/linux/kvmi.h

diff --git a/Documentation/virtual/kvm/00-INDEX b/Documentation/virtual/kvm/00-INDEX
index 69fe1a8b7ad1..49ea106ca86b 100644
--- a/Documentation/virtual/kvm/00-INDEX
+++ b/Documentation/virtual/kvm/00-INDEX
@@ -10,6 +10,8 @@ halt-polling.txt
 	- notes on halt-polling
 hypercalls.txt
 	- KVM hypercalls.
+kvmi.rst
+	- VM introspection.
 locking.txt
 	- notes on KVM locks.
 mmu.txt
diff --git a/Documentation/virtual/kvm/hypercalls.txt b/Documentation/virtual/kvm/hypercalls.txt
index a890529c63ed..e0454fcd058f 100644
--- a/Documentation/virtual/kvm/hypercalls.txt
+++ b/Documentation/virtual/kvm/hypercalls.txt
@@ -121,3 +121,69 @@ compute the CLOCK_REALTIME for its clock, at the same instant.
 
 Returns KVM_EOPNOTSUPP if the host does not use TSC clocksource,
 or if clock type is different than KVM_CLOCK_PAIRING_WALLCLOCK.
+
+7. KVM_HC_XEN_HVM_OP
+--------------------
+
+Architecture: x86
+Status: active
+Purpose: To enable communication between a guest agent and a VMI application
+Usage:
+
+An event will be sent to the VMI application (see kvmi.rst) if the following
+registers, which differ between 32bit and 64bit, have the following values:
+
+       32bit       64bit     value
+       ---------------------------
+       ebx (a0)    rdi       KVM_HC_XEN_HVM_OP_GUEST_REQUEST_VM_EVENT
+       ecx (a1)    rsi       0
+
+This specification copies Xen's { __HYPERVISOR_hvm_op,
+HVMOP_guest_request_vm_event } hypercall and can originate from kernel or
+userspace.
+
+It returns 0 if successful, or a negative POSIX.1 error code if it fails. The
+absence of an active VMI application is not signaled in any way.
+
+The following registers are clobbered:
+
+  * 32bit: edx, esi, edi, ebp
+  * 64bit: rdx, r10, r8, r9
+
+In particular, for KVM_HC_XEN_HVM_OP_GUEST_REQUEST_VM_EVENT, the last two
+registers can be poisoned deliberately and cannot be used for passing
+information.
+
+8. KVM_HC_MEM_MAP
+-----------------
+
+Architecture: x86
+Status: active
+Purpose: Map a guest physical page to another VM (the introspector).
+Usage:
+
+a0: pointer to a token obtained with a KVMI_GET_MAP_TOKEN command (see kvmi.rst)
+	struct kvmi_map_mem_token {
+		__u64 token[4];
+	};
+
+a1: guest physical address to be mapped
+
+a2: guest physical address from introspector that will be replaced
+
+Both guest physical addresses will end up poiting to the same physical page.
+
+Returns KVM_EFAULT in case of an error.
+
+9. KVM_HC_MEM_UNMAP
+-------------------
+
+Architecture: x86
+Status: active
+Purpose: Unmap a previously mapped page.
+Usage:
+
+a0: guest physical address from introspector
+
+The address will stop pointing to the introspected page and a new physical
+page is allocated for this gpa.
diff --git a/Documentation/virtual/kvm/kvmi.rst b/Documentation/virtual/kvm/kvmi.rst
new file mode 100644
index 000000000000..e11435f33fe2
--- /dev/null
+++ b/Documentation/virtual/kvm/kvmi.rst
@@ -0,0 +1,1323 @@
+=========================================================
+KVMI - The kernel virtual machine introspection subsystem
+=========================================================
+
+The KVM introspection subsystem provides a facility for applications running
+on the host or in a separate VM, to control the execution of other VM-s
+(pause, resume, shutdown), query the state of the vCPUs (GPRs, MSRs etc.),
+alter the page access bits in the shadow page tables (only for the hardware
+backed ones, eg. Intel's EPT) and receive notifications when events of
+interest have taken place (shadow page table level faults, key MSR writes,
+hypercalls etc.). Some notifications can be responded to with an action
+(like preventing an MSR from being written), others are mere informative
+(like breakpoint events which can be used for execution tracing).
+With few exceptions, all events are optional. An application using this
+subsystem will explicitly register for them.
+
+The use case that gave way for the creation of this subsystem is to monitor
+the guest OS and as such the ABI/API is highly influenced by how the guest
+software (kernel, applications) sees the world. For example, some events
+provide information specific for the host CPU architecture
+(eg. MSR_IA32_SYSENTER_EIP) merely because its leveraged by guest software
+to implement a critical feature (fast system calls).
+
+At the moment, the target audience for KVMI are security software authors
+that wish to perform forensics on newly discovered threats (exploits) or
+to implement another layer of security like preventing a large set of
+kernel rootkits simply by "locking" the kernel image in the shadow page
+tables (ie. enforce .text r-x, .rodata rw- etc.). It's the latter case that
+made KVMI a separate subsystem, even though many of these features are
+available in the device manager (eg. QEMU). The ability to build a security
+application that does not interfere (in terms of performance) with the
+guest software asks for a specialized interface that is designed for minimum
+overhead.
+
+API/ABI
+=======
+
+This chapter describes the VMI interface used to monitor and control local
+guests from an user application.
+
+Overview
+--------
+
+The interface is socket based, one connection for every VM. One end is in the
+host kernel while the other is held by the user application (introspection
+tool).
+
+The initial connection is established by an application running on the host
+(eg. QEMU) that connects to the introspection tool and after a handshake the
+socket is passed to the host kernel making all further communication take
+place between it and the introspection tool. The initiating party (QEMU) can
+close its end so that any potential exploits cannot take a hold of it.
+
+The socket protocol allows for commands and events to be multiplexed over
+the same connection. As such, it is possible for the introspection tool to
+receive an event while waiting for the result of a command. Also, it can
+send a command while the host kernel is waiting for a reply to an event.
+
+The kernel side of the socket communication is blocking and will wait for
+an answer from its peer indefinitely or until the guest is powered off
+(killed) at which point it will wake up and properly cleanup. If the peer
+goes away, KVM will exit to user space and the device manager will try and
+reconnect. If it fails, the device manager will inform KVM to cleanup and
+continue normal guest execution as if the introspection subsystem has never
+been used on that guest. Obviously, whether the guest can really continue
+normal execution depends on whether the introspection tool has made any
+modifications that require an active KVMI channel.
+
+All messages (commands or events) have a common header::
+
+	struct kvmi_msg_hdr {
+		__u16 id;
+		__u16 size;
+		__u32 seq;
+	};
+
+and all need a reply with the same kind of header, having the same
+sequence number (``seq``) and the same message id (``id``).
+
+Because events from different vCPU threads can send messages at the same
+time and the replies can come in any order, the receiver loop uses the
+sequence number (seq) to identify which reply belongs to which vCPU, in
+order to dispatch the message to the right thread waiting for it.
+
+After ``kvmi_msg_hdr``, ``id`` specific data of ``size`` bytes will
+follow.
+
+The message header and its data must be sent with one ``sendmsg()`` call
+to the socket. This simplifies the receiver loop and avoids
+the reconstruction of messages on the other side.
+
+The wire protocol uses the host native byte-order. The introspection tool
+must check this during the handshake and do the necessary conversion.
+
+A command reply begins with::
+
+	struct kvmi_error_code {
+		__s32 err;
+		__u32 padding;
+	}
+
+followed by the command specific data if the error code ``err`` is zero.
+
+The error code -KVM_ENOSYS (packed in a ``kvmi_error_code``) is returned for
+unsupported commands.
+
+The error code is related to the message processing. For all the other
+errors (socket errors, incomplete messages, wrong sequence numbers
+etc.) the socket must be closed. The device manager will be notified
+and it will reconnect.
+
+While all commands will have a reply as soon as possible, the replies
+to events will probably be delayed until a set of (new) commands will
+complete::
+
+   Host kernel               Tool
+   -----------               ----
+   event 1 ->
+                             <- command 1
+   command 1 reply ->
+                             <- command 2
+   command 2 reply ->
+                             <- event 1 reply
+
+If both ends send a message at the same time::
+
+   Host kernel               Tool
+   -----------               ----
+   event X ->                <- command X
+
+the host kernel will reply to 'command X', regardless of the receive time
+(before or after the 'event X' was sent).
+
+As it can be seen below, the wire protocol specifies occasional padding. This
+is to permit working with the data by directly using C structures or to round
+the structure size to a multiple of 8 bytes (64bit) to improve the copy
+operations that happen during ``recvmsg()`` or ``sendmsg()``. The members
+should have the native alignment of the host (4 bytes on x86). All padding
+must be initialized with zero otherwise the respective commands will fail
+with -KVM_EINVAL.
+
+To describe the commands/events, we reuse some conventions from api.txt:
+
+  - Architectures: which instruction set architectures provide this command/event
+
+  - Versions: which versions provide this command/event
+
+  - Parameters: incoming message data
+
+  - Returns: outgoing/reply message data
+
+Handshake
+---------
+
+Although this falls out of the scope of the introspection subsystem, below
+is a proposal of a handshake that can be used by implementors.
+
+Based on the system administration policies, the management tool
+(eg. libvirt) starts device managers (eg. QEMU) with some extra arguments:
+what introspector could monitor/control that specific guest (and how to
+connect to) and what introspection commands/events are allowed.
+
+The device manager will connect to the introspection tool and wait for a
+cryptographic hash of a cookie that should be known by both peers. If the
+hash is correct (the destination has been "authenticated"), the device
+manager will send another cryptographic hash and random salt. The peer
+recomputes the hash of the cookie bytes including the salt and if they match,
+the device manager has been "authenticated" too. This is a rather crude
+system that makes it difficult for device manager exploits to trick the
+introspection tool into believing its working OK.
+
+The cookie would normally be generated by a management tool (eg. libvirt)
+and make it available to the device manager and to a properly authenticated
+client. It is the job of a third party to retrieve the cookie from the
+management application and pass it over a secure channel to the introspection
+tool.
+
+Once the basic "authentication" has taken place, the introspection tool
+can receive information on the guest (its UUID) and other flags (endianness
+or features supported by the host kernel).
+
+In the end, the device manager will pass the file handle (plus the allowed
+commands/events) to KVM, and forget about it. It will be notified by
+KVM when the introspection tool closes the the file handle (in case of
+errors), and should reinitiate the handshake.
+
+Once the file handle reaches KVM, the introspection tool should use
+the *KVMI_GET_VERSION* command to get the API version, the commands and
+the events (see *KVMI_CONTROL_EVENTS*) which are allowed for this
+guest. The error code -KVM_EPERM will be returned if the introspection tool
+uses a command or enables an event which is not allowed.
+
+Live migrations
+---------------
+
+During a VMI session it is possible for the guest to be patched and for
+some of these patches to "talk" with the introspection tool. It thus becomes
+necessary to remove them before a live migration takes place.
+
+A live migration is normally performed by the device manager and such it is
+the best source for migration notifications. In the case of QEMU, an
+introspector tool can use the same facility as the QEMU Guest Agent to be
+notified when a migration is about to begin. QEMU will need to wait for a
+limited amount of time (a few seconds) for a confirmation that is OK to
+proceed. It does this only if a KVMI channel is active.
+
+The QEMU instance on the receiving end, if configured for KVMI, will need to
+establish a connection to the introspection tool after the migration has
+completed.
+
+Obviously, this creates a window in which the guest is not introspected. The
+user will need to be aware of this detail. Future introspection
+technologies can choose not to disconnect and instead transfer the necessary
+context to the introspection tool at the migration destination via a separate
+channel.
+
+Guest snapshots with memory
+---------------------------
+
+Just as for live migrations, before taking a snapshot with memory, the
+introspector might need to disconnect and reconnect after the snapshot
+operation has completed. This is because such snapshots can be restored long
+after the introspection tool was stopped or on a host that does not have KVMI
+enabled. Thus, if during the KVMI session the guest memory was patched, these
+changes will likely need to be undone.
+
+The same communication channel as QEMU Guest Agent can be used for the
+purpose of notifying a guest application when a memory snapshot is about to
+be created and also when the operation has completed.
+
+Memory access safety
+--------------------
+
+The KVMI API gives access to the entire guest physical address space but
+provides no information on which parts of it are system RAM and which are
+device-specific memory (DMA, emulated MMIO, reserved by a passthrough
+device etc.). It is up to the user to determine, using the guest operating
+system data structures, the areas that are safe to access (code, stack, heap
+etc.).
+
+Commands
+--------
+
+The following C structures are meant to be used directly when communicating
+over the wire. The peer that detects any size mismatch should simply close
+the connection and report the error.
+
+0. KVMI_GET_VERSION
+-------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters: none
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	struct kvmi_get_version_reply {
+		__u32 version;
+		__u32 commands;
+		__u32 events;
+		__u32 padding;
+	};
+
+Returns the introspection API version, the bit mask with allowed commands
+and the bit mask with allowed events (see *KVMI_CONTROL_EVENTS*).
+
+These two masks represent all the features allowed by the management tool
+(see **Handshake**) or supported by the host, with some exceptions: this command
+and the *KVMI_EVENT_PAUSE_VCPU* event.
+
+The host kernel and the userland can use the macros bellow to check if
+a command/event is allowed for a guest::
+
+	KVMI_ALLOWED_COMMAND(cmd_id, cmd_mask)
+	KVMI_ALLOWED_EVENT(event_id, event_mask)
+
+This command is always successful.
+
+1. KVMI_GET_GUEST_INFO
+----------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_get_guest_info {
+		__u16 vcpu;
+		__u16 padding[3];
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	struct kvmi_get_guest_info_reply {
+		__u16 vcpu_count;
+		__u16 padding[3];
+		__u64 tsc_speed;
+	};
+
+Returns the number of online vCPUs and the TSC frequency (in HZ)
+if available.
+
+The parameter ``vcpu`` must be zero. It is required for consistency with
+all other commands and in the future it might be used to return true
+vCPU-specific information.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_EBUSY - the selected vCPU has another queued command
+
+2. KVMI_PAUSE_VCPU
+------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_pause_vcpu {
+		__u16 vcpu;
+		__u16 padding[3]; /* multiple of 8 bytes */
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code
+
+Requests a pause for the specified vCPU. The vCPU thread will issue a
+*KVMI_EVENT_PAUSE_VCPU* event to let the introspection tool know it has
+enter the 'paused' state.
+
+If the command is issued while the vCPU was about to send an event, the
+*KVMI_EVENT_PAUSE_VCPU* event will be delayed until after the vCPU has
+received a response for its pending guest event.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_EBUSY - the selected vCPU has another queued command
+* -KVM_EBUSY - the vCPU thread has a pending pause request
+
+3. KVMI_GET_REGISTERS
+---------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_get_registers {
+		__u16 vcpu;
+		__u16 nmsrs;
+		__u16 padding[2];
+		__u32 msrs_idx[0];
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	struct kvmi_get_registers_reply {
+		__u32 mode;
+		__u32 padding;
+		struct kvm_regs regs;
+		struct kvm_sregs sregs;
+		struct kvm_msrs msrs;
+	};
+
+For the given vCPU and the ``nmsrs`` sized array of MSRs registers,
+returns the current vCPU mode (in bytes: 2, 4 or 8), the general purpose
+registers, the special registers and the requested set of MSRs.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EINVAL - one of the indicated MSR-s is invalid
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_EBUSY - the selected vCPU has another queued command
+* -KVM_ENOMEM - not enough memory to allocate the reply
+
+4. KVMI_SET_REGISTERS
+---------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_set_registers {
+		__u16 vcpu;
+		__u16 padding[3];
+		struct kvm_regs regs;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code
+
+Sets the general purpose registers for the given vCPU. The changes become
+visible to other threads accessing the KVM vCPU structure after the event
+currently being handled is replied to.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_EBUSY - the selected vCPU has another queued command
+
+5. KVMI_GET_CPUID
+-----------------
+
+:Architectures: x86
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_get_cpuid {
+		__u16 vcpu;
+		__u16 padding[3];
+		__u32 function;
+		__u32 index;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	struct kvmi_get_cpuid_reply {
+		__u32 eax;
+		__u32 ebx;
+		__u32 ecx;
+		__u32 edx;
+	};
+
+Returns a CPUID leaf (as seen by the guest OS).
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_EBUSY - the selected vCPU has another queued command
+* -KVM_ENOENT - the selected leaf is not present or is invalid
+
+6. KVMI_GET_PAGE_ACCESS
+-----------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_get_page_access {
+		__u16 vcpu;
+		__u16 count;
+		__u16 view;
+		__u16 padding;
+		__u64 gpa[0];
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	struct kvmi_get_page_access_reply {
+		__u8 access[0];
+	};
+
+Returns the spte access bits (rwx) for the specified vCPU and for an array of
+``count`` guest physical addresses.
+
+The valid access bits for *KVMI_GET_PAGE_ACCESS* and *KVMI_SET_PAGE_ACCESS*
+are::
+
+	KVMI_PAGE_ACCESS_R
+	KVMI_PAGE_ACCESS_W
+	KVMI_PAGE_ACCESS_X
+
+On Intel hardware with multiple EPT views, the ``view`` argument selects the
+EPT view (0 is primary). On all other hardware it must be zero.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EINVAL - the selected SPT view is invalid
+* -KVM_EINVAL - one of the specified gpa-s is invalid
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_EBUSY - the selected vCPU has another queued command
+* -KVM_ENOSYS - an SPT view was selected but the hardware has no support for
+  it
+* -KVM_ENOMEM - not enough memory to allocate the reply
+
+7. KVMI_SET_PAGE_ACCESS
+-----------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_page_access_entry {
+		__u64 gpa;
+		__u8 access;
+		__u8 padding[7];
+	};
+
+	struct kvmi_set_page_access {
+		__u16 vcpu;
+		__u16 count;
+		__u16 view;
+		__u16 padding;
+		struct kvmi_page_access_entry entries[0];
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code
+
+Sets the spte access bits (rwx) for an array of ``count`` guest physical
+addresses;
+
+The command will fail with -KVM_EINVAL if any of the specified combination
+of access bits is not supported.
+
+The command will make the changes in order and it will not stop on errors. The
+introspector tool should handle the rollback.
+
+In order to 'forget' an address, all the access bits ('rwx') must be set.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EINVAL - the specified access bits combination is invalid
+* -KVM_EINVAL - one of the specified gpa-s is invalid
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_EBUSY - the selected vCPU has another queued command
+* -KVM_ENOSYS - a SPT view was selected but the hardware has no support for
+   it
+* -KVM_ENOMEM - not enough memory to add the page tracking structures
+
+8. KVMI_INJECT_EXCEPTION
+------------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_inject_exception {
+		__u16 vcpu;
+		__u8 nr;
+		__u8 has_error;
+		__u16 error_code;
+		__u16 padding;
+		__u64 address;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code
+
+Injects a vCPU exception with or without an error code. In case of page fault
+exception, the guest virtual address has to be specified.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EINVAL - the specified exception number is invalid
+* -KVM_EINVAL - the specified address is invalid
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_EBUSY - the selected vCPU has another queued command
+
+9. KVMI_READ_PHYSICAL
+---------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_read_physical {
+		__u64 gpa;
+		__u64 size;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	__u8 data[0];
+
+Reads from the guest memory.
+
+Currently, the size must be non-zero and the read must be restricted to
+one page (offset + size <= PAGE_SIZE).
+
+:Errors:
+
+* -KVM_EINVAL - the specified gpa is invalid
+
+10. KVMI_WRITE_PHYSICAL
+-----------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_write_physical {
+		__u64 gpa;
+		__u64 size;
+		__u8  data[0];
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code
+
+Writes into the guest memory.
+
+Currently, the size must be non-zero and the write must be restricted to
+one page (offset + size <= PAGE_SIZE).
+
+:Errors:
+
+* -KVM_EINVAL - the specified gpa is invalid
+
+11. KVMI_CONTROL_EVENTS
+-----------------------
+
+:Architectures: all
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_control_events {
+		__u16 vcpu;
+		__u16 padding;
+		__u32 events;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code
+
+Enables/disables vCPU introspection events, by setting or clearing one or
+more of the following bits::
+
+	KVMI_EVENT_CR
+	KVMI_EVENT_MSR
+	KVMI_EVENT_XSETBV
+	KVMI_EVENT_BREAKPOINT
+	KVMI_EVENT_HYPERCALL
+	KVMI_EVENT_PAGE_FAULT
+	KVMI_EVENT_TRAP
+	KVMI_EVENT_SINGLESTEP
+	KVMI_EVENT_DESCRIPTOR
+
+For example:
+
+	``events = KVMI_EVENT_BREAKPOINT | KVMI_EVENT_PAGE_FAULT``
+
+it will disable all events but breakpoints and page faults.
+
+When an event is enabled, the introspection tool is notified and it
+must return a reply: allow, skip, etc. (see 'Events' below).
+
+The *KVMI_EVENT_PAUSE_VCPU* event is always allowed.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EINVAL - the specified mask of events is invalid
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_EBUSY - the selected vCPU has another queued command
+* -KVM_EPERM - access to one or more events specified in the events mask is
+  restricted by the host
+
+12. KVMI_CONTROL_CR
+-------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_control_cr {
+		__u16 vcpu;
+		__u8 enable;
+		__u8 padding;
+		__u32 cr;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code
+
+Enables/disables introspection for a specific control register and must
+be used in addition to *KVMI_CONTROL_EVENTS* with the *KVMI_EVENT_CR* bit
+set.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EINVAL - the specified control register is not part of the CR0, CR3
+   or CR4 set
+* -KVM_EBUSY - the selected vCPU has another queued command
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+
+13. KVMI_CONTROL_MSR
+--------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_control_msr {
+		__u16 vcpu;
+		__u8 enable;
+		__u8 padding;
+		__u32 msr;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code
+
+Enables/disables introspection for a specific MSR and must be used
+in addition to *KVMI_CONTROL_EVENTS* with the *KVMI_EVENT_MSR* bit set.
+
+Currently, only MSRs within the following two ranges are supported. Trying
+to control events for any other register will fail with -KVM_EINVAL::
+
+	0          ... 0x00001fff
+	0xc0000000 ... 0xc0001fff
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EINVAL - the specified MSR is invalid
+* -KVM_EBUSY - the selected vCPU has another queued command
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+
+14. KVMI_CONTROL_VE
+-------------------
+
+:Architecture: x86
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_control_ve {
+		__u16 vcpu;
+		__u16 count;
+		__u8 enable;
+		__u8 padding[3];
+		__u64 gpa[0]
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code
+
+On hardware supporting virtualized exceptions, this command can control
+the #VE bit for the listed guest physical addresses. If #VE is not
+supported the command returns -KVM_ENOSYS.
+
+Check the bitmask obtained with *KVMI_GET_VERSION* to see ahead if the
+command is supported.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EINVAL - one of the specified gpa-s is invalid
+* -KVM_EBUSY - the selected vCPU has another queued command
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_ENOSYS - the hardware does not support #VE
+
+.. note::
+
+  Virtualized exceptions are designed such that they can be controlled by
+  the guest itself and used for (among others) accelerate network
+  operations. Since this will obviously interfere with VMI, the guest
+  is denied access to VE while the introspection channel is active.
+
+15. KVMI_GET_MAP_TOKEN
+----------------------
+
+:Architecture: all
+:Versions: >= 1
+:Parameters: none
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	struct kvmi_get_map_token_reply {
+		struct kvmi_map_mem_token token;
+	};
+
+Where::
+
+	struct kvmi_map_mem_token {
+		__u64 token[4];
+	};
+
+Requests a token for a memory map operation.
+
+On this command, the host generates a random token to be used (once)
+to map a physical page from the introspected guest. The introspector
+could use the token with the KVM_INTRO_MEM_MAP ioctl (on /dev/kvmmem)
+to map a guest physical page to one of its memory pages. The ioctl,
+in turn, will use the KVM_HC_MEM_MAP hypercall (see hypercalls.txt).
+
+The guest kernel exposing /dev/kvmmem keeps a list with all the mappings
+(to all the guests introspected by the tool) in order to unmap them
+(using the KVM_HC_MEM_UNMAP hypercall) when /dev/kvmmem is closed or on
+demand (using the KVM_INTRO_MEM_UNMAP ioctl).
+
+:Errors:
+
+* -KVM_ENOMEM - not enough memory to allocate the token
+
+16. KVMI_GET_XSAVE
+------------------
+
+:Architecture: x86
+:Versions: >= 1
+:Parameters:
+
+::
+
+	struct kvmi_get_xsave {
+		__u16 vcpu;
+		__u16 padding[3];
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_error_code;
+	struct kvmi_get_xsave_reply {
+		__u32 region[0];
+	};
+
+Returns a buffer containing the XSAVE area. Currently, the size of
+``kvm_xsave`` is used, but it could change. The userspace should get
+the buffer size from the message size.
+
+:Errors:
+
+* -KVM_EINVAL - the selected vCPU is invalid
+* -KVM_EAGAIN - the selected vCPU can't be introspected yet
+* -KVM_EBUSY - the selected vCPU has another queued command
+* -KVM_ENOMEM - not enough memory to allocate the reply
+
+Events
+======
+
+All vCPU events are sent using the *KVMI_EVENT* message id. No event
+will be sent (except for *KVMI_EVENT_PAUSE_VCPU*) unless enabled
+with a *KVMI_CONTROL_EVENTS* command.
+
+The message data begins with a common structure, having the vCPU id,
+its mode (in bytes: 2, 4 and 8) and the event::
+
+	struct kvmi_event {
+		__u32 event;
+		__u16 vcpu;
+		__u8 mode;
+		__u8 padding;
+		/* arch specific data */
+	}
+
+On x86 the structure looks like this::
+
+	struct kvmi_event {
+		__u32 event;
+		__u16 vcpu;
+		__u8 mode;
+		__u8 padding;
+		struct kvm_regs regs;
+		struct kvm_sregs sregs;
+		struct {
+			__u64 sysenter_cs;
+			__u64 sysenter_esp;
+			__u64 sysenter_eip;
+			__u64 efer;
+			__u64 star;
+			__u64 lstar;
+			__u64 cstar;
+			__u64 pat;
+		} msrs;
+	};
+
+If contains information about the vCPU state at the time of the event.
+
+The replies to events have the *KVMI_EVENT_REPLY* message id and begin
+with a common structure::
+
+	struct kvmi_event_reply {
+		__u32 action;
+		__u32 padding;
+	};
+
+
+All events accept the KVMI_EVENT_ACTION_CRASH action, which stops the
+guest ungracefully but as soon as possible.
+
+Most of the events accept the KVMI_EVENT_ACTION_CONTINUE action, which
+lets the instruction that caused the event to continue (unless specified
+otherwise).
+
+Some of the events accept the KVMI_EVENT_ACTION_RETRY action, to continue
+by re-entering the quest.
+
+Specific data can follow these common structures.
+
+0. KVMI_EVENT_PAUSE_VCPU
+------------------------
+
+:Architectures: all
+:Versions: >= 1
+:Actions: CRASH, RETRY
+:Parameters:
+
+::
+
+	struct kvmi_event
+
+:Returns:
+
+::
+
+	struct kvmi_event_reply
+
+This event is sent in response to a *KVMI_PAUSE_VCPU* command, unless it
+is canceled by another *KVMI_PAUSE_VCPU* command (with ``cancel`` set to 1).
+
+This event cannot be disabled via *KVMI_CONTROL_EVENTS*.
+
+1. KVMI_EVENT_CR
+----------------
+
+:Architectures: x86
+:Versions: >= 1
+:Actions: CONTINUE, CRASH
+:Parameters:
+
+::
+
+	struct kvmi_event;
+	struct kvmi_event_cr {
+		__u16 cr;
+		__u16 padding[3];
+		__u64 old_value;
+		__u64 new_value;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_event_reply;
+	struct kvmi_event_cr_reply {
+		__u64 new_val;
+	};
+
+This event is sent when a control register is going to be changed and the
+introspection has been enabled for this event and for this specific
+register (see *KVMI_CONTROL_EVENTS* and *KVMI_CONTROL_CR*).
+
+``kvmi_event``, the control register number, the old value and the new value
+are sent to the introspector. The *CONTINUE* action will set the ``new_val``.
+
+2. KVMI_EVENT_MSR
+-----------------
+
+:Architectures: x86
+:Versions: >= 1
+:Actions: CONTINUE, CRASH
+:Parameters:
+
+::
+
+	struct kvmi_event;
+	struct kvmi_event_msr {
+		__u32 msr;
+		__u32 padding;
+		__u64 old_value;
+		__u64 new_value;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_event_reply;
+	struct kvmi_event_msr_reply {
+		__u64 new_val;
+	};
+
+This event is sent when a model specific register is going to be changed
+and the introspection has been enabled for this event and for this specific
+register (see *KVMI_CONTROL_EVENTS* and *KVMI_CONTROL_MSR*).
+
+``kvmi_event``, the MSR number, the old value and the new value are
+sent to the introspector. The *CONTINUE* action will set the ``new_val``.
+
+3. KVMI_EVENT_XSETBV
+--------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Actions: CONTINUE, CRASH
+:Parameters:
+
+::
+
+	struct kvmi_event;
+
+:Returns:
+
+::
+
+	struct kvmi_event_reply;
+
+This event is sent when the extended control register XCR0 was
+modified and the introspection has been enabled for this event
+(see *KVMI_CONTROL_EVENTS*).
+
+``kvmi_event`` is sent to the introspector.
+
+4. KVMI_EVENT_BREAKPOINT
+------------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Actions: CONTINUE, CRASH, RETRY
+:Parameters:
+
+::
+
+	struct kvmi_event;
+	struct kvmi_event_breakpoint {
+		__u64 gpa;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_event_reply;
+
+This event is sent when a breakpoint was reached and the introspection has
+been enabled for this event (see *KVMI_CONTROL_EVENTS*).
+
+Some of these breakpoints could have been injected by the introspector,
+placed in the slack space of various functions and used as notification
+for when the OS or an application has reached a certain state or is
+trying to perform a certain operation (like creating a process).
+
+``kvmi_event`` and the guest physical address are sent to the introspector.
+
+The *RETRY* action is used by the introspector for its own breakpoints.
+
+5. KVMI_EVENT_HYPERCALL
+-----------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Actions: CONTINUE, CRASH
+:Parameters:
+
+::
+
+	struct kvmi_event
+
+:Returns:
+
+::
+
+	struct kvmi_event_reply
+
+This event is sent on a specific user hypercall when the introspection has
+been enabled for this event (see *KVMI_CONTROL_EVENTS*).
+
+The hypercall number must be ``KVM_HC_XEN_HVM_OP`` with the
+``KVM_HC_XEN_HVM_OP_GUEST_REQUEST_VM_EVENT`` sub-function
+(see hypercalls.txt).
+
+It is used by the code residing inside the introspected guest to call the
+introspection tool and to report certain details about its operation. For
+example, a classic antimalware remediation tool can report what it has
+found during a scan.
+
+6. KVMI_EVENT_PAGE_FAULT
+------------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Actions: CONTINUE, CRASH, RETRY
+:Parameters:
+
+::
+
+	struct kvmi_event;
+	struct kvmi_event_page_fault {
+		__u64 gva;
+		__u64 gpa;
+		__u32 mode;
+		__u32 padding;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_event_reply;
+	struct kvmi_event_page_fault_reply {
+		__u8 trap_access;
+		__u8 padding[3];
+		__u32 ctx_size;
+		__u8 ctx_data[256];
+	};
+
+This event is sent when a hypervisor page fault occurs due to a failed
+permission check in the shadow page tables, the introspection has
+been enabled for this event (see *KVMI_CONTROL_EVENTS*) and the event was
+generated for a page in which the introspector has shown interest
+(ie. has previously touched it by adjusting the spte permissions).
+
+The shadow page tables can be used by the introspection tool to guarantee
+the purpose of code areas inside the guest (code, rodata, stack, heap
+etc.) Each attempt at an operation unfitting for a certain memory
+range (eg. execute code in heap) triggers a page fault and gives the
+introspection tool the chance to audit the code attempting the operation.
+
+``kvmi_event``, guest virtual address, guest physical address and the
+exit qualification (mode) are sent to the introspector.
+
+The *CONTINUE* action will continue the page fault handling via emulation
+(with custom input if ``ctx_size`` > 0). The use of custom input is
+to trick the guest software into believing it has read certain data,
+in order to hide the content of certain memory areas (eg. hide injected
+code from integrity checkers). If ``trap_access`` is not zero, the REP
+prefixed instruction should be emulated just once.
+
+7. KVMI_EVENT_TRAP
+------------------
+
+:Architectures: x86
+:Versions: >= 1
+:Actions: CONTINUE, CRASH
+:Parameters:
+
+::
+
+	struct kvmi_event;
+	struct kvmi_event_trap {
+		__u32 vector;
+		__u32 type;
+		__u32 error_code;
+		__u32 padding;
+		__u64 cr2;
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_event_reply;
+
+This event is sent if a trap will be delivered to the guest (page fault,
+breakpoint, etc.) and the introspection has been enabled for this event
+(see *KVMI_CONTROL_EVENTS*).
+
+It is used to inform the introspector of all pending traps giving
+it a chance to determine if it should try again later in case a
+previous *KVMI_INJECT_EXCEPTION* command or a breakpoint/retry (see
+*KVMI_EVENT_BREAKPOINT*) has been overwritten by an interrupt picked up
+during guest reentry.
+
+``kvmi_event``, exception/interrupt number (vector), exception/interrupt
+type, exception code (``error_code``) and CR2 are sent to the introspector.
+
+8. KVMI_EVENT_CREATE_VCPU
+-------------------------
+
+:Architectures: all
+:Versions: >= 1
+:Actions: CONTINUE, CRASH
+:Parameters:
+
+::
+
+	struct kvmi_event
+
+:Returns:
+
+::
+
+	struct kvmi_event_reply
+
+This event is sent when a new vCPU is created and the introspection has
+been enabled for this event (see *KVMI_CONTROL_EVENTS*).
+
+9. KVMI_EVENT_SINGLESTEP
+------------------------
+
+:Architecture: all
+:Versions: >= 1
+:Actions: CONTINUE, CRASH, RETRY
+:Parameters:
+
+::
+
+	struct kvmi_event
+
+:Returns:
+
+::
+
+	struct kvmi_event_reply
+
+This event is generated as a result of enabling guest single stepping (see
+*KVMI_CONTROL_EVENTS*).
+
+The *CONTINUE* action disables the single-stepping.
+
+10. KVMI_EVENT_DESCRIPTOR
+-------------------------
+
+:Architecture: x86
+:Versions: >= 1
+:Actions: CONTINUE, CRASH
+:Parameters:
+
+::
+
+	struct kvmi_event
+	struct kvmi_event_descriptor {
+		union {
+			struct {
+				__u32 instr_info;
+				__u32 padding;
+				__u64 exit_qualification;
+			} vmx;
+			struct {
+				__u64 exit_info;
+				__u64 padding;
+			} svm;
+		} arch;
+		__u8 descriptor;
+		__u8 write;
+		__u8 padding[6];
+	};
+
+:Returns:
+
+::
+
+	struct kvmi_event_reply
+
+This event is generated as a result of enabling descriptor access events
+(see *KVMI_CONTROL_EVENTS*).
+
+``kvmi_event_descriptor`` contains the relevant event information.
+
+``kvmi_event_descriptor.descriptor`` can be one of::
+
+	KVMI_DESC_IDTR
+	KVMI_DESC_GDTR
+	KVMI_DESC_LDTR
+	KVMI_DESC_TR
+
+``kvmi_event_descriptor.write`` is 1 if the descriptor was written, 0
+otherwise.
diff --git a/arch/x86/include/uapi/asm/kvmi.h b/arch/x86/include/uapi/asm/kvmi.h
new file mode 100644
index 000000000000..d7ae53c1f22f
--- /dev/null
+++ b/arch/x86/include/uapi/asm/kvmi.h
@@ -0,0 +1,213 @@
+/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
+#ifndef _ASM_X86_KVMI_H
+#define _ASM_X86_KVMI_H
+
+/*
+ * KVMI x86 specific structures and definitions
+ *
+ */
+
+#include <asm/kvm.h>
+#include <linux/types.h>
+
+#define KVMI_EVENT_CR          (1 << 1)	/* control register was modified */
+#define KVMI_EVENT_MSR         (1 << 2)	/* model specific reg. was modified */
+#define KVMI_EVENT_XSETBV      (1 << 3)	/* ext. control register was modified */
+#define KVMI_EVENT_BREAKPOINT  (1 << 4)	/* breakpoint was reached */
+#define KVMI_EVENT_HYPERCALL   (1 << 5)	/* user hypercall */
+#define KVMI_EVENT_PAGE_FAULT  (1 << 6)	/* hyp. page fault was encountered */
+#define KVMI_EVENT_TRAP        (1 << 7)	/* trap was injected */
+#define KVMI_EVENT_DESCRIPTOR  (1 << 8)	/* descriptor table access */
+#define KVMI_EVENT_CREATE_VCPU (1 << 9)
+#define KVMI_EVENT_PAUSE_VCPU  (1 << 10)
+
+/* TODO: find a way to split the events between common and arch dependent */
+
+#define KVMI_EVENT_ACTION_CONTINUE (1 << 0)
+#define KVMI_EVENT_ACTION_RETRY    (1 << 1)
+#define KVMI_EVENT_ACTION_CRASH    (1 << 2)
+
+#define KVMI_KNOWN_EVENTS (KVMI_EVENT_CR | \
+			   KVMI_EVENT_MSR | \
+			   KVMI_EVENT_XSETBV | \
+			   KVMI_EVENT_BREAKPOINT | \
+			   KVMI_EVENT_HYPERCALL | \
+			   KVMI_EVENT_PAGE_FAULT | \
+			   KVMI_EVENT_TRAP | \
+			   KVMI_EVENT_CREATE_VCPU | \
+			   KVMI_EVENT_PAUSE_VCPU | \
+			   KVMI_EVENT_DESCRIPTOR)
+
+#define KVMI_ALLOWED_EVENT(event_id, event_mask)                       \
+		((!(event_id)) || (                                    \
+			(event_id)                                     \
+				& ((event_mask) & KVMI_KNOWN_EVENTS)))
+
+#define KVMI_PAGE_ACCESS_R (1 << 0)
+#define KVMI_PAGE_ACCESS_W (1 << 1)
+#define KVMI_PAGE_ACCESS_X (1 << 2)
+
+struct kvmi_event_cr {
+	__u16 cr;
+	__u16 padding[3];
+	__u64 old_value;
+	__u64 new_value;
+};
+
+struct kvmi_event_msr {
+	__u32 msr;
+	__u32 padding;
+	__u64 old_value;
+	__u64 new_value;
+};
+
+struct kvmi_event_breakpoint {
+	__u64 gpa;
+};
+
+struct kvmi_event_page_fault {
+	__u64 gva;
+	__u64 gpa;
+	__u32 mode;
+	__u32 padding;
+};
+
+struct kvmi_event_trap {
+	__u32 vector;
+	__u32 type;
+	__u32 error_code;
+	__u32 padding;
+	__u64 cr2;
+};
+
+#define KVMI_DESC_IDTR	1
+#define KVMI_DESC_GDTR	2
+#define KVMI_DESC_LDTR	3
+#define KVMI_DESC_TR	4
+
+struct kvmi_event_descriptor {
+	union {
+		struct {
+			__u32 instr_info;
+			__u32 padding;
+			__u64 exit_qualification;
+		} vmx;
+		struct {
+			__u64 exit_info;
+			__u64 padding;
+		} svm;
+	} arch;
+	__u8 descriptor;
+	__u8 write;
+	__u8 padding[6];
+};
+
+struct kvmi_event {
+	__u32 event;
+	__u16 vcpu;
+	__u8 mode;		/* 2, 4 or 8 */
+	__u8 padding;
+	struct kvm_regs regs;
+	struct kvm_sregs sregs;
+	struct {
+		__u64 sysenter_cs;
+		__u64 sysenter_esp;
+		__u64 sysenter_eip;
+		__u64 efer;
+		__u64 star;
+		__u64 lstar;
+		__u64 cstar;
+		__u64 pat;
+	} msrs;
+};
+
+struct kvmi_event_cr_reply {
+	__u64 new_val;
+};
+
+struct kvmi_event_msr_reply {
+	__u64 new_val;
+};
+
+struct kvmi_event_page_fault_reply {
+	__u8 trap_access;
+	__u8 padding[3];
+	__u32 ctx_size;
+	__u8 ctx_data[256];
+};
+
+struct kvmi_control_cr {
+	__u16 vcpu;
+	__u8 enable;
+	__u8 padding;
+	__u32 cr;
+};
+
+struct kvmi_control_msr {
+	__u16 vcpu;
+	__u8 enable;
+	__u8 padding;
+	__u32 msr;
+};
+
+struct kvmi_guest_info {
+	__u16 vcpu_count;
+	__u16 padding1;
+	__u32 padding2;
+	__u64 tsc_speed;
+};
+
+struct kvmi_inject_exception {
+	__u16 vcpu;
+	__u8 nr;
+	__u8 has_error;
+	__u16 error_code;
+	__u16 padding;
+	__u64 address;
+};
+
+struct kvmi_get_registers {
+	__u16 vcpu;
+	__u16 nmsrs;
+	__u16 padding[2];
+	__u32 msrs_idx[0];
+};
+
+struct kvmi_get_registers_reply {
+	__u32 mode;
+	__u32 padding;
+	struct kvm_regs regs;
+	struct kvm_sregs sregs;
+	struct kvm_msrs msrs;
+};
+
+struct kvmi_set_registers {
+	__u16 vcpu;
+	__u16 padding[3];
+	struct kvm_regs regs;
+};
+
+struct kvmi_get_cpuid {
+	__u16 vcpu;
+	__u16 padding[3];
+	__u32 function;
+	__u32 index;
+};
+
+struct kvmi_get_cpuid_reply {
+	__u32 eax;
+	__u32 ebx;
+	__u32 ecx;
+	__u32 edx;
+};
+
+struct kvmi_get_xsave {
+	__u16 vcpu;
+	__u16 padding[3];
+};
+
+struct kvmi_get_xsave_reply {
+	__u32 region[0];
+};
+
+#endif /* _ASM_X86_KVMI_H */
diff --git a/include/uapi/linux/kvm_para.h b/include/uapi/linux/kvm_para.h
index dcf629dd2889..34fd3d3108c6 100644
--- a/include/uapi/linux/kvm_para.h
+++ b/include/uapi/linux/kvm_para.h
@@ -10,12 +10,17 @@
  * - kvm_para_available
  */
 
-/* Return values for hypercalls */
+/* Return values for hypercalls and VM introspection */
 #define KVM_ENOSYS		1000
 #define KVM_EFAULT		EFAULT
 #define KVM_E2BIG		E2BIG
 #define KVM_EPERM		EPERM
 #define KVM_EOPNOTSUPP		95
+#define KVM_EAGAIN		11
+#define KVM_EBUSY		EBUSY
+#define KVM_EINVAL		EINVAL
+#define KVM_ENOENT		ENOENT
+#define KVM_ENOMEM		ENOMEM
 
 #define KVM_HC_VAPIC_POLL_IRQ		1
 #define KVM_HC_MMU_OP			2
@@ -26,6 +31,9 @@
 #define KVM_HC_MIPS_EXIT_VM		7
 #define KVM_HC_MIPS_CONSOLE_OUTPUT	8
 #define KVM_HC_CLOCK_PAIRING		9
+#define KVM_HC_MEM_MAP			32
+#define KVM_HC_MEM_UNMAP		33
+#define KVM_HC_XEN_HVM_OP		34 /* Xen's __HYPERVISOR_hvm_op */
 
 /*
  * hypercalls use architecture specific
diff --git a/include/uapi/linux/kvmi.h b/include/uapi/linux/kvmi.h
new file mode 100644
index 000000000000..b1da800541ac
--- /dev/null
+++ b/include/uapi/linux/kvmi.h
@@ -0,0 +1,150 @@
+/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
+#ifndef __KVMI_H_INCLUDED__
+#define __KVMI_H_INCLUDED__
+
+/*
+ * KVMI specific structures and definitions
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <asm/kvmi.h>
+
+#define KVMI_VERSION 0x00000001
+
+#define KVMI_GET_VERSION                  1
+#define KVMI_PAUSE_VCPU                   2
+#define KVMI_GET_GUEST_INFO               3
+#define KVMI_GET_REGISTERS                6
+#define KVMI_SET_REGISTERS                7
+#define KVMI_GET_PAGE_ACCESS              10
+#define KVMI_SET_PAGE_ACCESS              11
+#define KVMI_INJECT_EXCEPTION             12
+#define KVMI_READ_PHYSICAL                13
+#define KVMI_WRITE_PHYSICAL               14
+#define KVMI_GET_MAP_TOKEN                15
+#define KVMI_CONTROL_EVENTS               17
+#define KVMI_CONTROL_CR                   18
+#define KVMI_CONTROL_MSR                  19
+#define KVMI_EVENT                        23
+#define KVMI_EVENT_REPLY                  24
+#define KVMI_GET_CPUID                    25
+#define KVMI_GET_XSAVE                    26
+
+/* TODO: find a way to split the commands between common and arch dependent */
+
+#define KVMI_KNOWN_COMMANDS (-1) /* TODO: fix me */
+
+#define KVMI_ALLOWED_COMMAND(cmd_id, cmd_mask)                         \
+		((!(cmd_id)) || (                                      \
+			(1 << ((cmd_id)-1))                            \
+				& ((cmd_mask) & KVMI_KNOWN_COMMANDS)))
+struct kvmi_msg_hdr {
+	__u16 id;
+	__u16 size;
+	__u32 seq;
+};
+
+#define KVMI_MAX_MSG_SIZE (sizeof(struct kvmi_msg_hdr) \
+			+ (1 << FIELD_SIZEOF(struct kvmi_msg_hdr, size)*8) \
+			- 1)
+
+struct kvmi_error_code {
+	__s32 err;
+	__u32 padding;
+};
+
+struct kvmi_get_version_reply {
+	__u32 version;
+	__u32 commands;
+	__u32 events;
+	__u32 padding;
+};
+
+struct kvmi_get_guest_info {
+	__u16 vcpu;
+	__u16 padding[3];
+};
+
+struct kvmi_get_guest_info_reply {
+	__u16 vcpu_count;
+	__u16 padding[3];
+	__u64 tsc_speed;
+};
+
+struct kvmi_pause_vcpu {
+	__u16 vcpu;
+	__u16 padding[3];
+};
+
+struct kvmi_event_reply {
+	__u32 action;
+	__u32 padding;
+};
+
+struct kvmi_control_events {
+	__u16 vcpu;
+	__u16 padding;
+	__u32 events;
+};
+
+struct kvmi_get_page_access {
+	__u16 vcpu;
+	__u16 count;
+	__u16 view;
+	__u16 padding;
+	__u64 gpa[0];
+};
+
+struct kvmi_get_page_access_reply {
+	__u8 access[0];
+};
+
+struct kvmi_page_access_entry {
+	__u64 gpa;
+	__u8 access;
+	__u8 padding[7];
+};
+
+struct kvmi_set_page_access {
+	__u16 vcpu;
+	__u16 count;
+	__u16 view;
+	__u16 padding;
+	struct kvmi_page_access_entry entries[0];
+};
+
+struct kvmi_read_physical {
+	__u64 gpa;
+	__u64 size;
+};
+
+struct kvmi_write_physical {
+	__u64 gpa;
+	__u64 size;
+	__u8  data[0];
+};
+
+struct kvmi_map_mem_token {
+	__u64 token[4];
+};
+
+struct kvmi_get_map_token_reply {
+	struct kvmi_map_mem_token token;
+};
+
+/* Map other guest's gpa to local gva */
+struct kvmi_mem_map {
+	struct kvmi_map_mem_token token;
+	__u64 gpa;
+	__u64 gva;
+};
+
+/*
+ * ioctls for /dev/kvmmem
+ */
+#define KVM_INTRO_MEM_MAP	_IOW('i', 0x01, struct kvmi_mem_map)
+#define KVM_INTRO_MEM_UNMAP	_IOW('i', 0x02, unsigned long)
+
+#endif /* __KVMI_H_INCLUDED__ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
