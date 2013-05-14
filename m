Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 60FA96B004D
	for <linux-mm@kvack.org>; Mon, 13 May 2013 21:57:21 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 640943EE0C3
	for <linux-mm@kvack.org>; Tue, 14 May 2013 10:57:19 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 514DF45DE52
	for <linux-mm@kvack.org>; Tue, 14 May 2013 10:57:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D90E45DD78
	for <linux-mm@kvack.org>; Tue, 14 May 2013 10:57:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FA481DB803C
	for <linux-mm@kvack.org>; Tue, 14 May 2013 10:57:19 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C9D9C1DB803E
	for <linux-mm@kvack.org>; Tue, 14 May 2013 10:57:18 +0900 (JST)
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Subject: [PATCH v5 2/8] vmcore: clean up read_vmcore()
Date: Tue, 14 May 2013 10:57:17 +0900
Message-ID: <20130514015717.18697.43144.stgit@localhost6.localdomain6>
In-Reply-To: <20130514015622.18697.77191.stgit@localhost6.localdomain6>
References: <20130514015622.18697.77191.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vgoyal@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org

Rewrite part of read_vmcore() that reads objects in vmcore_list in the
same way as part reading ELF headers, by which some duplicated and
redundant codes are removed.

Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
---

 fs/proc/vmcore.c |   68 ++++++++++++++++--------------------------------------
 1 files changed, 20 insertions(+), 48 deletions(-)

diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index 69e1198..48886e6 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -119,27 +119,6 @@ static ssize_t read_from_oldmem(char *buf, size_t count,
 	return read;
 }
 
-/* Maps vmcore file offset to respective physical address in memroy. */
-static u64 map_offset_to_paddr(loff_t offset, struct list_head *vc_list,
-					struct vmcore **m_ptr)
-{
-	struct vmcore *m;
-	u64 paddr;
-
-	list_for_each_entry(m, vc_list, list) {
-		u64 start, end;
-		start = m->offset;
-		end = m->offset + m->size - 1;
-		if (offset >= start && offset <= end) {
-			paddr = m->paddr + offset - start;
-			*m_ptr = m;
-			return paddr;
-		}
-	}
-	*m_ptr = NULL;
-	return 0;
-}
-
 /* Read from the ELF header and then the crash dump. On error, negative value is
  * returned otherwise number of bytes read are returned.
  */
@@ -148,8 +127,8 @@ static ssize_t read_vmcore(struct file *file, char __user *buffer,
 {
 	ssize_t acc = 0, tmp;
 	size_t tsz;
-	u64 start, nr_bytes;
-	struct vmcore *curr_m = NULL;
+	u64 start;
+	struct vmcore *m = NULL;
 
 	if (buflen == 0 || *fpos >= vmcore_size)
 		return 0;
@@ -175,33 +154,26 @@ static ssize_t read_vmcore(struct file *file, char __user *buffer,
 			return acc;
 	}
 
-	start = map_offset_to_paddr(*fpos, &vmcore_list, &curr_m);
-	if (!curr_m)
-        	return -EINVAL;
-
-	while (buflen) {
-		tsz = min_t(size_t, buflen, PAGE_SIZE - (start & ~PAGE_MASK));
-
-		/* Calculate left bytes in current memory segment. */
-		nr_bytes = (curr_m->size - (start - curr_m->paddr));
-		if (tsz > nr_bytes)
-			tsz = nr_bytes;
-
-		tmp = read_from_oldmem(buffer, tsz, &start, 1);
-		if (tmp < 0)
-			return tmp;
-		buflen -= tsz;
-		*fpos += tsz;
-		buffer += tsz;
-		acc += tsz;
-		if (start >= (curr_m->paddr + curr_m->size)) {
-			if (curr_m->list.next == &vmcore_list)
-				return acc;	/*EOF*/
-			curr_m = list_entry(curr_m->list.next,
-						struct vmcore, list);
-			start = curr_m->paddr;
+	list_for_each_entry(m, &vmcore_list, list) {
+		if (*fpos < m->offset + m->size) {
+			tsz = m->offset + m->size - *fpos;
+			if (buflen < tsz)
+				tsz = buflen;
+			start = m->paddr + *fpos - m->offset;
+			tmp = read_from_oldmem(buffer, tsz, &start, 1);
+			if (tmp < 0)
+				return tmp;
+			buflen -= tsz;
+			*fpos += tsz;
+			buffer += tsz;
+			acc += tsz;
+
+			/* leave now if filled buffer already */
+			if (buflen == 0)
+				return acc;
 		}
 	}
+
 	return acc;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
