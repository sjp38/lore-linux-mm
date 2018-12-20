Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9018E0003
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 04:51:05 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 4so968505plc.5
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 01:51:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a72sor33589712pge.21.2018.12.20.01.51.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 01:51:03 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCHv2 0/3] mm: bugfix for NULL reference in mm on all archs
Date: Thu, 20 Dec 2018 17:50:36 +0800
Message-Id: <1545299439-31370-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>

This bug is original reported at https://lore.kernel.org/patchwork/patch/1020838/
In a short word, this bug should affect all archs, where a machine with a
numa-node having no memory, if nr_cpus prevents the instance of nodeA, and the
device on nodeA tries to allocate memory with device->numa_node info.
And node_zonelist(preferred_nid, gfp_mask) will panic due to uninstanced nodeA.

And there are two alternative methods to fix it.
-1st. Fix it in mm system
-2nd. Fix it in all archs independently, by online all possible nodes.

Originaly, I tries to fix it by the 1st method, while Michal suggests the 2nd one.
This series [1-2/3] tries to resolve some defect in v1, pointed out by Michal.
For discussion purpose, I send [3/3] in this thread, which tries to show e.g of
the 2nd method on powerpc platform.
For x86, I still help Michal to verify his patch on my test machine, please see:
https://lore.kernel.org/patchwork/comment/1208479/
https://lore.kernel.org/patchwork/comment/1210452/

It has already cost a little long time to find a solution, cc x86 and ppc mailing list
and hope their maintainers to give some suggestion to speed up the final solution.

Pingfan Liu (3):
  mm/numa: change the topo of build_zonelist_xx()
  mm/numa: build zonelist when alloc for device on offline node
  powerpc/numa: make all possible node be instanced against NULL
    reference in node_zonelist()

 arch/powerpc/mm/numa.c | 13 ++++++--
 include/linux/gfp.h    | 10 +++++-
 mm/page_alloc.c        | 85 ++++++++++++++++++++++++++++++++++++--------------
 3 files changed, 81 insertions(+), 27 deletions(-)

Cc: linuxppc-dev@lists.ozlabs.org
Cc: x86@kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
-- 
2.7.4
