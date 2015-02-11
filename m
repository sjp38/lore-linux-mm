Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id B26376B006C
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 10:44:49 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id y19so4234491wgg.13
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 07:44:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id hd6si2047243wjc.59.2015.02.11.07.44.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 07:44:48 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH 1/3] driver core: export lock_device_hotplug/unlock_device_hotplug
Date: Wed, 11 Feb 2015 16:44:20 +0100
Message-Id: <1423669462-30918-2-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1423669462-30918-1-git-send-email-vkuznets@redhat.com>
References: <1423669462-30918-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Fabian Frederick <fabf@skynet.be>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Wang Nan <wangnan0@huawei.com>
Cc: linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, linux-mm@kvack.org

add_memory() is supposed to be run with device_hotplug_lock grabbed, otherwise
it can race with e.g. device_online(). Allow external modules (hv_balloon for
now) to lock device hotplug.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/base/core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 97e2baf..b3073af 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -55,11 +55,13 @@ void lock_device_hotplug(void)
 {
 	mutex_lock(&device_hotplug_lock);
 }
+EXPORT_SYMBOL_GPL(lock_device_hotplug);
 
 void unlock_device_hotplug(void)
 {
 	mutex_unlock(&device_hotplug_lock);
 }
+EXPORT_SYMBOL_GPL(unlock_device_hotplug);
 
 int lock_device_hotplug_sysfs(void)
 {
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
