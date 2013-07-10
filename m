Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 7323B6B0037
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 09:00:12 -0400 (EDT)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Wed, 10 Jul 2013 13:52:13 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3F6761B0805F
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 14:00:03 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6ACxp4153215288
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 12:59:51 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6AD0150007644
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 07:00:02 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH v4 0/4] Enable async page faults on s390 
Date: Wed, 10 Jul 2013 14:59:51 +0200
Message-Id: <1373461195-27628-1-git-send-email-dingel@linux.vnet.ibm.com>
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

v3 -> v4
 - Change "done" interrupts from local to floating
 - Add a comment for clarification
 - Change KVM_HAVE_ERR_BAD to move s390 implementation to s390 backend 

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

 Documentation/s390/kvm.txt        |  24 ++++++++
 arch/s390/include/asm/kvm_host.h  |  30 ++++++++++
 arch/s390/include/asm/pgtable.h   |   2 +
 arch/s390/include/asm/processor.h |   1 +
 arch/s390/include/uapi/asm/kvm.h  |  10 ++++
 arch/s390/kvm/Kconfig             |   2 +
 arch/s390/kvm/Makefile            |   2 +-
 arch/s390/kvm/diag.c              |  63 ++++++++++++++++++++
 arch/s390/kvm/interrupt.c         |  43 +++++++++++---
 arch/s390/kvm/kvm-s390.c          | 118 ++++++++++++++++++++++++++++++++++++++
 arch/s390/kvm/kvm-s390.h          |   4 ++
 arch/s390/kvm/sigp.c              |   6 ++
 arch/s390/mm/fault.c              |  26 +++++++--
 arch/x86/kvm/mmu.c                |   2 +-
 include/linux/kvm_host.h          |  10 +++-
 include/uapi/linux/kvm.h          |   2 +
 virt/kvm/Kconfig                  |   4 ++
 virt/kvm/async_pf.c               |  22 ++++++-
 18 files changed, 354 insertions(+), 17 deletions(-)

-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
