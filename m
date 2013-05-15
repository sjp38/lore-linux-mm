Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 797976B003B
	for <linux-mm@kvack.org>; Wed, 15 May 2013 05:06:23 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 248CC3EE0BD
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:06:22 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 101D845DE4E
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:06:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E304745DE4D
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:06:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D11E91DB8044
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:06:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 738EF1DB803E
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:06:21 +0900 (JST)
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Subject: [PATCH v6 7/8] vmcore: calculate vmcore file size from buffer size
 and total size of vmcore objects
Date: Wed, 15 May 2013 18:06:20 +0900
Message-ID: <20130515090620.28109.68803.stgit@localhost6.localdomain6>
In-Reply-To: <20130515090507.28109.28956.stgit@localhost6.localdomain6>
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vgoyal@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

The previous patches newly added holes before each chunk of memory and
the holes need to be count in vmcore file size. There are two ways to
count file size in such a way:

1) supporse m as a poitner to the last vmcore object in vmcore_list.
, then file size is (m->offset + m->size), or

2) calculate sum of size of buffers for ELF header, program headers,
ELF note segments and objects in vmcore_list.

Although 1) is more direct and simpler than 2), 2) seems better in
that it reflects internal object structure of /proc/vmcore. Thus, this
patch changes get_vmcore_size_elf{64, 32} so that it calculates size
in the way of 2).

Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Acked-by: Vivek Goyal <vgoyal@redhat.com>
---

 fs/proc/vmcore.c |   40 ++++++++++++++++++----------------------
 1 files changed, 18 insertions(+), 22 deletions(-)

diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index 4e121fda..7f2041c 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -210,36 +210,28 @@ static struct vmcore* __init get_new_element(void)
 	return kzalloc(sizeof(struct vmcore), GFP_KERNEL);
 }
 
-static u64 __init get_vmcore_size_elf64(char *elfptr, size_t elfsz)
+static u64 __init get_vmcore_size_elf64(size_t elfsz, size_t elfnotesegsz,
+					struct list_head *vc_list)
 {
-	int i;
 	u64 size;
-	Elf64_Ehdr *ehdr_ptr;
-	Elf64_Phdr *phdr_ptr;
+	struct vmcore *m;
 
-	ehdr_ptr = (Elf64_Ehdr *)elfptr;
-	phdr_ptr = (Elf64_Phdr*)(elfptr + sizeof(Elf64_Ehdr));
-	size = elfsz;
-	for (i = 0; i < ehdr_ptr->e_phnum; i++) {
-		size += phdr_ptr->p_memsz;
-		phdr_ptr++;
+	size = elfsz + elfnotesegsz;
+	list_for_each_entry(m, vc_list, list) {
+		size += m->size;
 	}
 	return size;
 }
 
-static u64 __init get_vmcore_size_elf32(char *elfptr, size_t elfsz)
+static u64 __init get_vmcore_size_elf32(size_t elfsz, size_t elfnotesegsz,
+					struct list_head *vc_list)
 {
-	int i;
 	u64 size;
-	Elf32_Ehdr *ehdr_ptr;
-	Elf32_Phdr *phdr_ptr;
+	struct vmcore *m;
 
-	ehdr_ptr = (Elf32_Ehdr *)elfptr;
-	phdr_ptr = (Elf32_Phdr*)(elfptr + sizeof(Elf32_Ehdr));
-	size = elfsz;
-	for (i = 0; i < ehdr_ptr->e_phnum; i++) {
-		size += phdr_ptr->p_memsz;
-		phdr_ptr++;
+	size = elfsz + elfnotesegsz;
+	list_for_each_entry(m, vc_list, list) {
+		size += m->size;
 	}
 	return size;
 }
@@ -795,14 +787,18 @@ static int __init parse_crash_elf_headers(void)
 			return rc;
 
 		/* Determine vmcore size. */
-		vmcore_size = get_vmcore_size_elf64(elfcorebuf, elfcorebuf_sz);
+		vmcore_size = get_vmcore_size_elf64(elfcorebuf_sz,
+						    elfnotes_sz,
+						    &vmcore_list);
 	} else if (e_ident[EI_CLASS] == ELFCLASS32) {
 		rc = parse_crash_elf32_headers();
 		if (rc)
 			return rc;
 
 		/* Determine vmcore size. */
-		vmcore_size = get_vmcore_size_elf32(elfcorebuf, elfcorebuf_sz);
+		vmcore_size = get_vmcore_size_elf32(elfcorebuf_sz,
+						    elfnotes_sz,
+						    &vmcore_list);
 	} else {
 		pr_warn("Warning: Core image elf header is not sane\n");
 		return -EINVAL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
