Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id AE58E6B0032
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 08:03:57 -0400 (EDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Mon, 10 Jun 2013 13:00:06 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id AE90F17D805C
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 13:05:12 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5AC3fmJ50725080
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 12:03:41 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r5AC3pqx028078
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 06:03:51 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [RFC PATCH 0/4] Enable async page faults on s390 
Date: Mon, 10 Jun 2013 14:03:44 +0200
Message-Id: <1370865828-2053-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dominik Dingel <dingel@linux.vnet.ibm.com>

Gleb, Paolo, 

based on the work from Martin and Carsten, this implementation enables async page faults.
To the guest it will provide the pfault interface, but internally it uses the
async page fault common code. 

The inital submission and it's discussion can be followed on http://www.mail-archive.com/kvm@vger.kernel.org/msg63359.html .

There is a slight modification for common code to move from a pull to a push based approch on s390. 
As s390 we don't want to wait till we leave the guest state to queue the notification interrupts.

To use this feature the controlling userspace hase to enable the capability.
With that knob we can later on disable this feature for live migration.

Dominik Dingel (4):
  PF: Add FAULT_FLAG_RETRY_NOWAIT for guest fault
  PF: Move architecture specifics to the backends
  PF: Additional flag for direct page fault inject
  PF: Intial async page fault support on s390x

 arch/s390/include/asm/kvm_host.h  |  34 +++++++++++++
 arch/s390/include/asm/processor.h |   7 +++
 arch/s390/include/uapi/asm/kvm.h  |  10 ++++
 arch/s390/kvm/Kconfig             |   1 +
 arch/s390/kvm/Makefile            |   2 +-
 arch/s390/kvm/diag.c              |  46 +++++++++++++++++
 arch/s390/kvm/interrupt.c         |  40 ++++++++++++---
 arch/s390/kvm/kvm-s390.c          | 101 ++++++++++++++++++++++++++++++++++++++
 arch/s390/kvm/kvm-s390.h          |   4 ++
 arch/s390/mm/fault.c              |  29 +++++++++--
 arch/s390/mm/pgtable.c            |   1 +
 arch/x86/include/asm/kvm_host.h   |   8 +++
 arch/x86/kvm/mmu.c                |   2 +-
 include/linux/kvm_host.h          |  11 +----
 include/uapi/linux/kvm.h          |   2 +
 virt/kvm/async_pf.c               |  33 ++++++++++---
 16 files changed, 303 insertions(+), 28 deletions(-)

-- 
1.8.1.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
