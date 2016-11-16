Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 181A76B027B
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 12:29:56 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 3so159489103pgd.3
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 09:29:56 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id a84si5667342pfe.117.2016.11.16.09.29.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 09:29:55 -0800 (PST)
Subject: [PATCH] device-dax: fail all private mapping attempts
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 16 Nov 2016 09:26:53 -0800
Message-ID: <147931721349.37471.4835899844582504197.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Pawel Lebioda <pawel.lebioda@intel.com>

The device-dax implementation originally tried to be tricky and allow
private read-only mappings, but in the process allowed writable
MAP_PRIVATE + MAP_NORESERVE mappings.  For simplicity and predictability
just fail all private mapping attempts since device-dax memory is
statically allocated and will never support overcommit.

Cc: <stable@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
Reported-by: Pawel Lebioda <pawel.lebioda@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/dax.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/dax/dax.c b/drivers/dax/dax.c
index 0e499bfca41c..3d94ff20fdca 100644
--- a/drivers/dax/dax.c
+++ b/drivers/dax/dax.c
@@ -270,8 +270,8 @@ static int check_vma(struct dax_dev *dax_dev, struct vm_area_struct *vma,
 	if (!dax_dev->alive)
 		return -ENXIO;
 
-	/* prevent private / writable mappings from being established */
-	if ((vma->vm_flags & (VM_NORESERVE|VM_SHARED|VM_WRITE)) == VM_WRITE) {
+	/* prevent private mappings from being established */
+	if ((vma->vm_flags & VM_SHARED) != VM_SHARED) {
 		dev_info(dev, "%s: %s: fail, attempted private mapping\n",
 				current->comm, func);
 		return -EINVAL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
