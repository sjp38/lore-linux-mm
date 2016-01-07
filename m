Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 29F21828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 17:47:45 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id q63so97424pfb.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 14:47:45 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id di6si44494294pad.172.2016.01.07.14.47.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 14:47:44 -0800 (PST)
Date: Thu, 7 Jan 2016 14:47:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] memory-hotplug: Fix kernel warning during memory
 hotplug on ppc64
Message-Id: <20160107144743.452a52299965027a27d7f66c@linux-foundation.org>
In-Reply-To: <568D9568.1010808@linux.vnet.ibm.com>
References: <568D9568.1010808@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Allen <jallen@linux.vnet.ibm.com>
Cc: gregkh@linuxfoundation.org, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>

On Wed, 6 Jan 2016 16:30:00 -0600 John Allen <jallen@linux.vnet.ibm.com> wrote:

> This patch fixes a bug where a kernel warning is triggered when performing
> a memory hotplug on ppc64. This warning may also occur on any architecture
> that uses the memory_probe_store interface.

(cc's added).

Dave, could you please review this?  Thanks.


From: John Allen <jallen@linux.vnet.ibm.com>
Subject: drivers/base/memory.c: fix kernel warning during memory hotplug on ppc64

Fix a bug where a kernel warning is triggered when performing a memory
hotplug on ppc64.  This warning may also occur on any architecture that
uses the memory_probe_store interface.

WARNING: at drivers/base/memory.c:200
CPU: 9 PID: 13042 Comm: systemd-udevd Not tainted 4.4.0-rc4-00113-g0bd0f1e-dirty #7
NIP [c00000000055e034] pages_correctly_reserved+0x134/0x1b0
LR [c00000000055e7f8] memory_subsys_online+0x68/0x140
Call Trace:
[c0000000fa9e7b50] [c0000000fa9e7b90] 0xc0000000fa9e7b90 (unreliable)
[c0000000fa9e7bb0] [c00000000055e7f8] memory_subsys_online+0x68/0x140
[c0000000fa9e7bf0] [c000000000540064] device_online+0xb4/0x120
[c0000000fa9e7c30] [c00000000055e6c0] store_mem_state+0xb0/0x180
[c0000000fa9e7c70] [c00000000053c5e4] dev_attr_store+0x34/0x60
[c0000000fa9e7c90] [c0000000002db0a4] sysfs_kf_write+0x64/0xa0
[c0000000fa9e7cb0] [c0000000002da0cc] kernfs_fop_write+0x17c/0x1e0
[c0000000fa9e7d00] [c0000000002481b0] __vfs_write+0x40/0x160
[c0000000fa9e7d90] [c000000000248ce8] vfs_write+0xb8/0x200
[c0000000fa9e7de0] [c000000000249b40] SyS_write+0x60/0x110
[c0000000fa9e7e30] [c000000000009260] system_call+0x38/0xd0

The warning is triggered because there is a udev rule that automatically
tries to online memory after it has been added.  The udev rule varies from
distro to distro, but will generally look something like:

SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline", ATTR{state}="online"

On any architecture that uses memory_probe_store to reserve memory, the
udev rule will be triggered after the first section of the block is
reserved and will subsequently attempt to online the entire block,
interrupting the memory reservation process and causing the warning.  This
patch modifies memory_probe_store to add a block of memory with a single
call to add_memory as opposed to looping through and adding each section
individually.  A single call to add_memory is protected by the mem_hotplug
mutex which will prevent the udev rule from onlining memory until the
reservation of the entire block is complete.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/base/memory.c |   16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff -puN drivers/base/memory.c~memory-hotplug-fix-kernel-warning-during-memory-hotplug-on-ppc64 drivers/base/memory.c
--- a/drivers/base/memory.c~memory-hotplug-fix-kernel-warning-during-memory-hotplug-on-ppc64
+++ a/drivers/base/memory.c
@@ -450,8 +450,7 @@ memory_probe_store(struct device *dev, s
 		   const char *buf, size_t count)
 {
 	u64 phys_addr;
-	int nid;
-	int i, ret;
+	int nid, ret;
 	unsigned long pages_per_block = PAGES_PER_SECTION * sections_per_block;
 
 	ret = kstrtoull(buf, 0, &phys_addr);
@@ -461,15 +460,12 @@ memory_probe_store(struct device *dev, s
 	if (phys_addr & ((pages_per_block << PAGE_SHIFT) - 1))
 		return -EINVAL;
 
-	for (i = 0; i < sections_per_block; i++) {
-		nid = memory_add_physaddr_to_nid(phys_addr);
-		ret = add_memory(nid, phys_addr,
-				 PAGES_PER_SECTION << PAGE_SHIFT);
-		if (ret)
-			goto out;
+	nid = memory_add_physaddr_to_nid(phys_addr);
+	ret = add_memory(nid, phys_addr,
+			 MIN_MEMORY_BLOCK_SIZE * sections_per_block);
 
-		phys_addr += MIN_MEMORY_BLOCK_SIZE;
-	}
+	if (ret)
+		goto out;
 
 	ret = count;
 out:
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
