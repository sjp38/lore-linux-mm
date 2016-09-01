Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B7CD6B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 11:29:48 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id le9so164605826pab.0
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 08:29:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id ry5si6096334pab.179.2016.09.01.08.29.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 08:29:47 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u81FONqk080353
	for <linux-mm@kvack.org>; Thu, 1 Sep 2016 11:29:47 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0a-001b2d01.pphosted.com with ESMTP id 256b6b6ffn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Sep 2016 11:29:46 -0400
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Thu, 1 Sep 2016 11:29:44 -0400
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH v3] memory-hotplug: fix store_mem_state() return value
Date: Thu,  1 Sep 2016 10:29:37 -0500
Message-Id: <1472743777-24266-1-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dan Williams <dan.j.williams@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, David Vrabel <david.vrabel@citrix.com>, Chen Yucong <slaoub@gmail.com>, Andrew Banman <abanman@sgi.com>, Seth Jennings <sjenning@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If store_mem_state() is called to online memory which is already online,
it will return 1, the value it got from device_online().

This is wrong because store_mem_state() is a device_attribute .store
function. Thus a non-negative return value represents input bytes read.

Set the return value to -EINVAL in this case.

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
v2 -> v3:
* David Rientjes pointed out that the backwards-compatible return 
  value in this situation is -EINVAL, not success. I had mistakenly
  thought the behavior should be the same as online_store().

 drivers/base/memory.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 1cea0ba..bb69e58 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -359,8 +359,11 @@ store_mem_state(struct device *dev,
 err:
 	unlock_device_hotplug();
 
-	if (ret)
+	if (ret < 0)
 		return ret;
+	if (ret)
+		return -EINVAL;
+
 	return count;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
