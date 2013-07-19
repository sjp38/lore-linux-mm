Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id D92566B0070
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 04:01:07 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 10/21] earlycpio.c: Fix the confusing comment of find_cpio_data().
Date: Fri, 19 Jul 2013 15:59:23 +0800
Message-Id: <1374220774-29974-11-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

The comments of find_cpio_data() says:

  * @offset: When a matching file is found, this is the offset to the
  *          beginning of the cpio. ......

But according to the code,

  dptr = PTR_ALIGN(p + ch[C_NAMESIZE], 4);
  nptr = PTR_ALIGN(dptr + ch[C_FILESIZE], 4);
  ....
  *offset = (long)nptr - (long)data;	/* data is the cpio file */

@offset is the offset of the next file, not the matching file itself.
This is confused and may cause unnecessary waste of time to debug.
So fix it.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 lib/earlycpio.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/earlycpio.c b/lib/earlycpio.c
index 8078ef4..53ccbf7 100644
--- a/lib/earlycpio.c
+++ b/lib/earlycpio.c
@@ -52,9 +52,10 @@ enum cpio_fields {
  * @path:   The directory to search for, including a slash at the end
  * @data:   Pointer to the the cpio archive or a header inside
  * @len:    Remaining length of the cpio based on data pointer
- * @offset: When a matching file is found, this is the offset to the
- *          beginning of the cpio. It can be used to iterate through
- *          the cpio to find all files inside of a directory path
+ * @offset: When a matching file is found, this is the offset from the
+ *          beginning of the cpio to the beginning of the next file, not the
+ *          matching file itself. It can be used to iterate through the cpio
+ *          to find all files inside of a directory path
  *
  * @return: struct cpio_data containing the address, length and
  *          filename (with the directory path cut off) of the found file.
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
