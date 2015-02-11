Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id C86D26B0070
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 10:44:58 -0500 (EST)
Received: by mail-vc0-f172.google.com with SMTP id kv7so1427338vcb.3
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 07:44:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id cc4si544362vcb.22.2015.02.11.07.44.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 07:44:58 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH 2/3] memory_hotplug: add note about holding device_hotplug_lock and add_memory()
Date: Wed, 11 Feb 2015 16:44:21 +0100
Message-Id: <1423669462-30918-3-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1423669462-30918-1-git-send-email-vkuznets@redhat.com>
References: <1423669462-30918-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Fabian Frederick <fabf@skynet.be>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Wang Nan <wangnan0@huawei.com>
Cc: linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, linux-mm@kvack.org

add_memory() is supposed to be run with device_hotplug_lock grabbed, otherwise
it can race with e.g. device_online(). ACPI memory hotplug does that already
but e.g. Hyper-V ballooning driver doesn't.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 mm/memory_hotplug.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9fab107..41638eb 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1213,7 +1213,11 @@ int zone_for_memory(int nid, u64 start, u64 size, int zone_default)
 	return zone_default;
 }
 
-/* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
+/*
+ * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
+ * and online/offline operations before this call.
+ * We are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG.
+ */
 int __ref add_memory(int nid, u64 start, u64 size)
 {
 	pg_data_t *pgdat = NULL;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
