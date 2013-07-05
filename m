Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 13D916B0038
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 16:56:08 -0400 (EDT)
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Fri, 5 Jul 2013 21:50:27 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 923212190056
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 21:59:50 +0100 (BST)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r65KtpQI51052596
	for <linux-mm@kvack.org>; Fri, 5 Jul 2013 20:55:52 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r65Ku2J3014124
	for <linux-mm@kvack.org>; Fri, 5 Jul 2013 16:56:02 -0400
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 0/4] Enable async page faults on s390 
Date: Fri,  5 Jul 2013 22:55:50 +0200
Message-Id: <1373057754-59225-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Alexander Graf <agraf@suse.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dominik Dingel <dingel@linux.vnet.ibm.com>

Gleb, Paolo, 

based on the work from Martin and Carsten, this implementation enables async page faults.
To the guest it will provide the pfault interface, but internally it uses the
async page fault common code. 

The inital submission and it's discussion can be followed on http://www.mail-archive.com/kvm@vger.kernel.org/msg63359.html .

There is a slight modification for common code to move from a pull to a push based approch on s390. 
As s390 we don't want to wait till we leave the guest state to queue the notification interrupts.

To use this feature the controlling userspace hase to enable the capability.
With that knob we can later on disable this feature for live migration.

v1 -> v2:
 - Adding other architecture backends
 - Adding documentation for the ioctl
 - Improving the overall error handling
 - Reducing the needed modifications on the common code

Dominik Dingel (4):
  PF: Add FAULT_FLAG_RETRY_NOWAIT for guest fault
  PF: Move architecture specifics to the backends
  PF: Provide additional direct page notification
  PF: Async page fault support on s390

 Documentation/s390/kvm.txt          |  24 ++++++++
 arch/arm/include/asm/kvm_host.h     |   8 +++
 arch/ia64/include/asm/kvm_host.h    |   3 +
 arch/mips/include/asm/kvm_host.h    |   6 ++
 arch/powerpc/include/asm/kvm_host.h |   8 +++
 arch/s390/include/asm/kvm_host.h    |  34 +++++++++++
 arch/s390/include/asm/pgtable.h     |   2 +
 arch/s390/include/asm/processor.h   |   1 +
 arch/s390/include/uapi/asm/kvm.h    |  10 ++++
 arch/s390/kvm/Kconfig               |   2 +
 arch/s390/kvm/Makefile              |   2 +-
 arch/s390/kvm/diag.c                |  57 ++++++++++++++++++
 arch/s390/kvm/interrupt.c           |  38 +++++++++---
 arch/s390/kvm/kvm-s390.c            | 111 ++++++++++++++++++++++++++++++++++++
 arch/s390/kvm/kvm-s390.h            |   4 ++
 arch/s390/kvm/sigp.c                |   2 +
 arch/s390/mm/fault.c                |  26 +++++++--
 arch/x86/include/asm/kvm_host.h     |   8 +++
 arch/x86/kvm/mmu.c                  |   2 +-
 include/linux/kvm_host.h            |  10 +---
 include/uapi/linux/kvm.h            |   2 +
 virt/kvm/Kconfig                    |   4 ++
 virt/kvm/async_pf.c                 |  22 ++++++-
 23 files changed, 361 insertions(+), 25 deletions(-)

-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
