Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E6CFC6B025E
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 10:27:38 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i64so43610046ith.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 07:27:38 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id 86si8770408iok.173.2016.08.12.07.27.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 07:27:38 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id cf3so1563673pad.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 07:27:38 -0700 (PDT)
From: Ronit Halder <ronit.crj@gmail.com>
Subject: [RFC 4/4] Enable memory allocation through sysfs interface
Date: Fri, 12 Aug 2016 19:56:52 +0530
Message-Id: <20160812142652.6299-1-ronit.crj@gmail.com>
In-Reply-To: <20160812141838.5973-1-ronit.crj@gmail.com>
References: <20160812141838.5973-1-ronit.crj@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, dyoung@redhat.com, jroedel@suse.de, krzysiek@podlesie.net, msalter@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org, bhe@redhat.com, vgoyal@redhat.com, mnfhuang@gmail.com, kexec@lists.infradead.org, kirill.shutemov@linux.intel.com, mchehab@osg.samsung.com, aarcange@redhat.com, vdavydov@parallels.com, dan.j.williams@intel.com, jack@suse.cz, linux-mm@kvack.org, Ronit Halder <ronit.crj@gmail.com>

Modify the sysfs entry "kernel/kexec_crash_size" to allocate or
release memory at run time. The memory size will be written to
the entry in MB. If the user uses high memory (in x86_64). Then
size will be only set for high memory. The low memory will be
allocated automatically. If the size set is zero, the both the
allocated region in low and high memory will be released.

Signed-off-by: Ronit Halder <ronit.crj@gmail.com>

---
 kernel/ksysfs.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/kernel/ksysfs.c b/kernel/ksysfs.c
index e83b264..4cc286d 100644
--- a/kernel/ksysfs.c
+++ b/kernel/ksysfs.c
@@ -116,10 +116,31 @@ static ssize_t kexec_crash_size_store(struct kobject *kobj,
 {
 	unsigned long cnt;
 	int ret;
+	int size;
 
 	if (kstrtoul(buf, 0, &cnt))
 		return -EINVAL;
-
+#ifdef CONFIG_KEXEC_CMA
+#ifdef CONFIG_X86
+	size = cnt << 20;
+	if (cnt == 0) {
+		crash_free_memory_low();
+		ret = crash_free_memory(crash_get_memory_size());
+	} else if (cnt > 0) {
+		if (!crash_get_memory_size_low() && crash_alloc_memory_low())
+			return -ENOMEM;
+		ret = crash_free_memory(crash_get_memory_size());
+		if (ret)
+			return ret;
+		ret = crash_alloc_memory(size);
+		if (ret)
+			return ret;
+	} else {
+		return -EINVAL;
+	}
+	return count;
+#endif
+#endif
 	ret = crash_shrink_memory(cnt);
 	return ret < 0 ? ret : count;
 }
-- 
2.9.0.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
