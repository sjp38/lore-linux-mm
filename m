Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 183C96B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 09:57:03 -0400 (EDT)
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Tue, 9 Jul 2013 14:51:16 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2E5161B08074
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 14:56:59 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r69DulPq31719572
	for <linux-mm@kvack.org>; Tue, 9 Jul 2013 13:56:47 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r69Duv0e015664
	for <linux-mm@kvack.org>; Tue, 9 Jul 2013 07:56:58 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH v3 0/4] Enable async page faults on s390 
Date: Tue,  9 Jul 2013 15:56:43 +0200
Message-Id: <1373378207-10451-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Alexander Graf <agraf@suse.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dominik Dingel <dingel@linux.vnet.ibm.com>

Gleb, Paolo, 

based on the work from Martin and Carsten, this implementation enables async page faults.
To the guest it will provide the pfault interface, but internally it uses the
async page fault common code. 

The inital submission and it's discussion can be followed on http://www.mail-archive.com/kvm@vger.kernel.org/msg63359.html . 

There is a slight modification for common code to move from a pull to a push based approch on s390. 
As s390 we don't want to wait till we leave the guest state to queue the notification interrupts.

To use this feature the controlling userspace hase to enable the capability.
With that knob we can later on disable this feature for live migration.

v2 -> v3
 - Reworked the architecture specific parts, to only provide on addtional
   implementation
 - Renamed function to kvm_async_page_present_(sync|async)
 - Fixing KVM_HVA_ERR_BAD handling

v1 -> v2:
 - Adding other architecture backends
 - Adding documentation for the ioctl
 - Improving the overall error handling
 - Reducing the needed modifications on the common code


Dominik Dingel (4):
  PF: Add FAULT_FLAG_RETRY_NOWAIT for guest fault
  PF: Make KVM_HVA_ERR_BAD usable on s390
  PF: Provide additional direct page notification
  PF: Async page fault support on s390

 Documentation/s390/kvm.txt        |  24 +++++++++
 arch/s390/include/asm/kvm_host.h  |  22 ++++++++
 arch/s390/include/asm/pgtable.h   |   2 +
 arch/s390/include/asm/processor.h |   1 +
 arch/s390/include/uapi/asm/kvm.h  |  10 ++++
 arch/s390/kvm/Kconfig             |   2 +
 arch/s390/kvm/Makefile            |   2 +-
 arch/s390/kvm/diag.c              |  57 ++++++++++++++++++++
 arch/s390/kvm/interrupt.c         |  38 ++++++++++---
 arch/s390/kvm/kvm-s390.c          | 111 ++++++++++++++++++++++++++++++++++++++
 arch/s390/kvm/kvm-s390.h          |   4 ++
 arch/s390/kvm/sigp.c              |   2 +
 arch/s390/mm/fault.c              |  26 +++++++--
 arch/x86/kvm/mmu.c                |   2 +-
 include/linux/kvm_host.h          |  16 +++++-
 include/uapi/linux/kvm.h          |   2 +
 virt/kvm/Kconfig                  |   4 ++
 virt/kvm/async_pf.c               |  22 ++++++--
 18 files changed, 330 insertions(+), 17 deletions(-)

-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
