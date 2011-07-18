Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 791D46B0109
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 17:36:08 -0400 (EDT)
Message-ID: <4E24A6F5.2080706@bx.jp.nec.com>
Date: Mon, 18 Jul 2011 17:34:45 -0400
From: Keiichi KII <k-keiichi@bx.jp.nec.com>
MIME-Version: 1.0
Subject: [RFC PATCH -tip 2/5] tracing/mm: add header event for object collections
References: <4E24A61D.4060702@bx.jp.nec.com>
In-Reply-To: <4E24A61D.4060702@bx.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Keiichi KII <k-keiichi@bx.jp.nec.com>, Ingo Molnar <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tom Zanussi <tzanussi@gmail.com>, "riel@redhat.com" <riel@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Fr??d??ric Weisbecker <fweisbec@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, "BA, Moussa" <Moussa.BA@numonyx.com>

From: Keiichi Kii <k-keiichi@bx.jp.nec.com>

We can use this "dump_header" event to separate trace data
for the object collections.

Usage and Sample output:

zsh  2815 [001]  8819.880776: dump_header: object=mm/pages/walk-fs input=/
zsh  2815 [001]  8819.880786: dump_inode: ino=139161 size=507416 cached=507904 age=29 dirty=7 dev=254:0 file=strchr
zsh  2815 [001]  8819.880790: dump_pagecache_range: index=0 len=1 flags=4000000000000878 count=2 mapcount=0
zsh  2815 [001]  8819.880793: dump_pagecache_range: index=1 len=18 flags=400000000000087c count=2 mapcount=0
zsh  2815 [001]  8819.880795: dump_pagecache_range: index=19 len=1 flags=400000000000083c count=2 mapcount=0
zsh  2815 [001]  8819.880796: dump_pagecache_range: index=20 len=2 flags=400000000000087c count=2 mapcount=0
...
zsh  2816 [001]  8820.XXXXXX: dump_header: object=mm/pages/walk-fs input=/
...

Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
---

 include/trace/events/mm.h |   19 +++++++++++++++++++
 kernel/trace/trace_mm.c   |    9 +++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)


diff --git a/include/trace/events/mm.h b/include/trace/events/mm.h
index e625b49..05bd35a 100644
--- a/include/trace/events/mm.h
+++ b/include/trace/events/mm.h
@@ -111,6 +111,25 @@ TRACE_EVENT(dump_inode,
 		  strchr(__get_str(file), '\n') ? "?" : __get_str(file))
 );
 
+TRACE_EVENT(dump_header,
+
+	TP_PROTO(char *object_name, char *input_data),
+
+	TP_ARGS(object_name, input_data),
+
+	TP_STRUCT__entry(
+		__string(	object_name,	object_name	)
+		__string(	input_data,	input_data	)
+	),
+
+	TP_fast_assign(
+		__assign_str(object_name, object_name);
+		__assign_str(input_data, input_data);
+	),
+
+	TP_printk("object=%s input=%s",
+		__get_str(object_name), __get_str(input_data))
+);
 
 #endif /*  _TRACE_MM_H */
 
diff --git a/kernel/trace/trace_mm.c b/kernel/trace/trace_mm.c
index 0d77dfd..fa9ab7c 100644
--- a/kernel/trace/trace_mm.c
+++ b/kernel/trace/trace_mm.c
@@ -72,6 +72,8 @@ trace_mm_dump_range_write(struct file *filp, const char __user *ubuf, size_t cnt
 	if (tracing_update_buffers() < 0)
 		return -ENOMEM;
 
+	if (trace_set_clr_event("mm", "dump_header", 1))
+		return -EINVAL;
 	if (trace_set_clr_event("mm", "dump_pages", 1))
 		return -EINVAL;
 
@@ -87,6 +89,7 @@ trace_mm_dump_range_write(struct file *filp, const char __user *ubuf, size_t cnt
 	else
 		end = start + val;
 
+	trace_dump_header("mm/pages/dump_range", buf);
 	trace_read_page_frames(start, end, trace_do_dump_pages);
 
 	*ppos += cnt;
@@ -270,6 +273,10 @@ trace_pagecache_write(struct file *filp, const char __user *ubuf, size_t count,
 		err = -ENOMEM;
 		goto out;
 	}
+	if (trace_set_clr_event("mm", "dump_header", 1)) {
+		err = -EINVAL;
+		goto out;
+	}
 	if (trace_set_clr_event("mm", "dump_pagecache_range", 1)) {
 		err = -EINVAL;
 		goto out;
@@ -280,8 +287,10 @@ trace_pagecache_write(struct file *filp, const char __user *ubuf, size_t count,
 	}
 
 	if (filp->f_path.dentry->d_inode->i_private) {
+		trace_dump_header("mm/pages/walk-fs", name);
 		dump_fs_pagecache(file->f_path.dentry->d_sb, file->f_path.mnt);
 	} else {
+		trace_dump_header("mm/pages/walk-file", name);
 		dump_pagecache(file->f_mapping);
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
