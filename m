Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 58BF46B0260
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 11:44:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w128so110984054pfd.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:44:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id sk5si468419pab.17.2016.08.31.08.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 08:44:11 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7VFh0gW048067
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 11:44:08 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 255rjvgh58-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 11:44:08 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 31 Aug 2016 11:44:07 -0400
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [RESEND PATCH v2] memory-hotplug: fix store_mem_state() return value
Date: Wed, 31 Aug 2016 10:44:01 -0500
In-Reply-To: <20160831150105.GB26702@kroah.com>
References: <20160831150105.GB26702@kroah.com>
Message-Id: <1472658241-32748-1-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dan Williams <dan.j.williams@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, David Vrabel <david.vrabel@citrix.com>, Chen Yucong <slaoub@gmail.com>, Andrew Banman <abanman@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Attempting to online memory which is already online will cause this:

1. store_mem_state() called with buf="online"
2. device_online() returns 1 because device is already online
3. store_mem_state() returns 1
4. calling code interprets this as 1-byte buffer read
5. store_mem_state() called again with buf="nline"
6. store_mem_state() returns -EINVAL

Example:

$ cat /sys/devices/system/memory/memory0/state
online
$ echo online > /sys/devices/system/memory/memory0/state
-bash: echo: write error: Invalid argument

Fix the return value of store_mem_state() so this doesn't happen.

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
Andrew et al, Greg asked that this come in through the -mm tree, as
you know this code better than him.

 drivers/base/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 1cea0ba..8e385ea 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -359,7 +359,7 @@ store_mem_state(struct device *dev,
 err:
 	unlock_device_hotplug();
 
-	if (ret)
+	if (ret < 0)
 		return ret;
 	return count;
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
