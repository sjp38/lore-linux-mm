Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 031076B025F
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 17:51:23 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id t77so2166389pfe.10
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 14:51:22 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y16si10191760pgv.751.2017.11.21.14.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 14:51:21 -0800 (PST)
Subject: [PATCH 2/2] device-dax: implement ->split() to catch invalid munmap
 attempts
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 21 Nov 2017 14:43:06 -0800
Message-ID: <151130418681.4029.7118245855057952010.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151130417573.4029.6745923267963684469.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151130417573.4029.6745923267963684469.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, stable@vger.kernel.org, linux-nvdimm@lists.01.org

Similar to how device-dax enforces that the 'address', 'offset', and
'len' parameters to mmap() be aligned to the device's fundamental
alignment, the same constraints apply to munmap(). Implement ->split()
to fail munmap calls that violate the alignment constraint. Otherwise,
we later fail VM_BUG_ON checks in the unmap_page_range() path with crash
signatures of the form:

    vma ffff8800b60c8a88 start 00007f88c0000000 end 00007f88c0e00000
    next           (null) prev           (null) mm ffff8800b61150c0
    prot 8000000000000027 anon_vma           (null) vm_ops ffffffffa0091240
    pgoff 0 file ffff8800b638ef80 private_data           (null)
    flags: 0x380000fb(read|write|shared|mayread|maywrite|mayexec|mayshare|softdirty|mixedmap|hugepage)
    ------------[ cut here ]------------
    kernel BUG at mm/huge_memory.c:2014!
    [..]
    RIP: 0010:__split_huge_pud+0x12a/0x180
    [..]
    Call Trace:
     unmap_page_range+0x245/0xa40
     ? __vma_adjust+0x301/0x990
     unmap_vmas+0x4c/0xa0
     unmap_region+0xae/0x120
     ? __vma_rb_erase+0x11a/0x230
     do_munmap+0x276/0x410
     vm_munmap+0x6a/0xa0
     SyS_munmap+0x1d/0x30

Cc: <stable@vger.kernel.org>
Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
Reported-by: Jeff Moyer <jmoyer@redhat.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/device.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index 6833ada237ab..7b0bf825c4e7 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -428,9 +428,21 @@ static int dev_dax_fault(struct vm_fault *vmf)
 	return dev_dax_huge_fault(vmf, PE_SIZE_PTE);
 }
 
+static int dev_dax_split(struct vm_area_struct *vma, unsigned long addr)
+{
+	struct file *filp = vma->vm_file;
+	struct dev_dax *dev_dax = filp->private_data;
+	struct dax_region *dax_region = dev_dax->region;
+
+	if (!IS_ALIGNED(addr, dax_region->align))
+		return -EINVAL;
+	return 0;
+}
+
 static const struct vm_operations_struct dax_vm_ops = {
 	.fault = dev_dax_fault,
 	.huge_fault = dev_dax_huge_fault,
+	.split = dev_dax_split,
 };
 
 static int dax_mmap(struct file *filp, struct vm_area_struct *vma)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
