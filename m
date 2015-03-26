Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id EE9FD6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 13:38:02 -0400 (EDT)
Received: by wibbg6 with SMTP id bg6so73495792wib.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 10:38:02 -0700 (PDT)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id ln14si11798782wic.10.2015.03.26.10.38.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 10:38:01 -0700 (PDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 26 Mar 2015 17:38:00 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 8669B17D8056
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 17:38:23 +0000 (GMT)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2QHbtbJ3866896
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 17:37:55 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2QHbsbU032124
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 11:37:55 -0600
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v4 0/2] Tracking user space vDSO remaping
Date: Thu, 26 Mar 2015 18:37:51 +0100
Message-Id: <cover.1427390952.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <20150326141730.GA23060@gmail.com>
References: <20150326141730.GA23060@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: cov@codeaurora.org, criu@openvz.org

CRIU is recreating the process memory layout by remapping the checkpointee
memory area on top of the current process (criu). This includes remapping
the vDSO to the place it has at checkpoint time.

However some architectures like powerpc are keeping a reference to the vDSO
base address to build the signal return stack frame by calling the vDSO
sigreturn service. So once the vDSO has been moved, this reference is no
more valid and the signal frame built later are not usable.

This patch serie is introducing a new mm hook 'arch_remap' which is called
when mremap is done and the mm lock still hold. The next patch is adding the
vDSO remap and unmap tracking to the powerpc architecture.

Changes in v4:
--------------
- Reviewing the PowerPC part of the patch to handle partial unmap and remap
  of the vDSO.

Changes in v3:
--------------
- Fixed grammatical error in a comment of the second patch. 
  Thanks again, Ingo.

Changes in v2:
--------------
- Following the Ingo Molnar's advice, enabling the call to arch_remap through
  the __HAVE_ARCH_REMAP macro. This reduces considerably the first patch.

Laurent Dufour (2):
  mm: Introducing arch_remap hook
  powerpc/mm: Tracking vDSO remap

 arch/powerpc/include/asm/mmu_context.h | 32 +++++++++++++++++++++++++++-
 arch/powerpc/kernel/vdso.c             | 39 ++++++++++++++++++++++++++++++++++
 mm/mremap.c                            | 11 ++++++++--
 3 files changed, 79 insertions(+), 3 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
