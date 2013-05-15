Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 8098C6B003A
	for <linux-mm@kvack.org>; Wed, 15 May 2013 05:06:17 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 28C213EE0AE
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:06:16 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1482745DE52
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:06:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EDF9F45DE4D
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:06:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D94C21DB802C
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:06:15 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 892F61DB8038
	for <linux-mm@kvack.org>; Wed, 15 May 2013 18:06:15 +0900 (JST)
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Subject: [PATCH v6 6/8] vmcore: allocate ELF note segment in the 2nd kernel
 vmalloc memory
Date: Wed, 15 May 2013 18:06:14 +0900
Message-ID: <20130515090614.28109.26492.stgit@localhost6.localdomain6>
In-Reply-To: <20130515090507.28109.28956.stgit@localhost6.localdomain6>
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vgoyal@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

The reasons why we don't allocate ELF note segment in the 1st kernel
(old memory) on page boundary is to keep backward compatibility for
old kernels, and that if doing so, we waste not a little memory due to
round-up operation to fit the memory to page boundary since most of
the buffers are in per-cpu area.

ELF notes are per-cpu, so total size of ELF note segments depends on
number of CPUs. The current maximum number of CPUs on x86_64 is 5192,
and there's already system with 4192 CPUs in SGI, where total size
amounts to 1MB. This can be larger in the near future or possibly even
now on another architecture that has larger size of note per a single
cpu. Thus, to avoid the case where memory allocation for large block
fails, we allocate vmcore objects on vmalloc memory.

This patch adds elfnotes_buf and elfnotes_sz variables to keep pointer
to the ELF note segment buffer and its size. There's no longer the
vmcore object that corresponds to the ELF note segment in
vmcore_list. Accordingly, read_vmcore() has new case for ELF note
segment and set_vmcore_list_offsets_elf{64,32}() and other helper
functions starts calculating offset from sum of size of ELF headers
and size of ELF note segment.

Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
---

 fs/proc/vmcore.c |  273 +++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 209 insertions(+), 64 deletions(-)

diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index 6cf7fbd..4e121fda 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -34,6 +34,9 @@ static char *elfcorebuf;
 static size_t elfcorebuf_sz;
 static size_t elfcorebuf_sz_orig;
 
+static char *elfnotes_buf;
+static size_t elfnotes_sz;
+
 /* Total size of vmcore file. */
 static u64 vmcore_size;
 
@@ -154,6 +157,26 @@ static ssize_t read_vmcore(struct file *file, char __user *buffer,
 			return acc;
 	}
 
+	/* Read Elf note segment */
+	if (*fpos < elfcorebuf_sz + elfnotes_sz) {
+		void *kaddr;
+
+		tsz = elfcorebuf_sz + elfnotes_sz - *fpos;
+		if (buflen < tsz)
+			tsz = buflen;
+		kaddr = elfnotes_buf + *fpos - elfcorebuf_sz;
+		if (copy_to_user(buffer, kaddr, tsz))
+			return -EFAULT;
+		buflen -= tsz;
+		*fpos += tsz;
+		buffer += tsz;
+		acc += tsz;
+
+		/* leave now if filled buffer already */
+		if (buflen == 0)
+			return acc;
+	}
+
 	list_for_each_entry(m, &vmcore_list, list) {
 		if (*fpos < m->offset + m->size) {
 			tsz = m->offset + m->size - *fpos;
@@ -221,23 +244,33 @@ static u64 __init get_vmcore_size_elf32(char *elfptr, size_t elfsz)
 	return size;
 }
 
-/* Merges all the PT_NOTE headers into one. */
-static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
-						struct list_head *vc_list)
+/**
+ * process_note_headers_elf64 - Perform a variety of processing on ELF
+ * note segments according to the combination of function arguments.
+ *
+ * @ehdr_ptr  - ELF header buffer
+ * @nr_notes  - the number of program header entries of PT_NOTE type
+ * @notes_sz  - total size of ELF note segment
+ * @notes_buf - buffer into which ELF note segment is copied
+ *
+ * Assume @ehdr_ptr is always not NULL. If @nr_notes is not NULL, then
+ * the number of program header entries of PT_NOTE type is assigned to
+ * @nr_notes. If @notes_sz is not NULL, then total size of ELF note
+ * segment, header part plus data part, is assigned to @notes_sz. If
+ * @notes_buf is not NULL, then ELF note segment is copied into
+ * @notes_buf.
+ */
+static int __init process_note_headers_elf64(const Elf64_Ehdr *ehdr_ptr,
+					     int *nr_notes, u64 *notes_sz,
+					     char *notes_buf)
 {
 	int i, nr_ptnote=0, rc=0;
-	char *tmp;
-	Elf64_Ehdr *ehdr_ptr;
-	Elf64_Phdr phdr, *phdr_ptr;
+	Elf64_Phdr *phdr_ptr = (Elf64_Phdr*)(ehdr_ptr + 1);
 	Elf64_Nhdr *nhdr_ptr;
-	u64 phdr_sz = 0, note_off;
+	u64 phdr_sz = 0;
 
-	ehdr_ptr = (Elf64_Ehdr *)elfptr;
-	phdr_ptr = (Elf64_Phdr*)(elfptr + sizeof(Elf64_Ehdr));
 	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
-		int j;
 		void *notes_section;
-		struct vmcore *new;
 		u64 offset, max_sz, sz, real_sz = 0;
 		if (phdr_ptr->p_type != PT_NOTE)
 			continue;
@@ -253,7 +286,7 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
 			return rc;
 		}
 		nhdr_ptr = notes_section;
-		for (j = 0; j < max_sz; j += sz) {
+		while (real_sz < max_sz) {
 			if (nhdr_ptr->n_namesz == 0)
 				break;
 			sz = sizeof(Elf64_Nhdr) +
@@ -262,20 +295,68 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
 			real_sz += sz;
 			nhdr_ptr = (Elf64_Nhdr*)((char*)nhdr_ptr + sz);
 		}
-
-		/* Add this contiguous chunk of notes section to vmcore list.*/
-		new = get_new_element();
-		if (!new) {
-			kfree(notes_section);
-			return -ENOMEM;
+		if (notes_buf) {
+			offset = phdr_ptr->p_offset;
+			rc = read_from_oldmem(notes_buf + phdr_sz, real_sz,
+					      &offset, 0);
+			if (rc < 0) {
+				kfree(notes_section);
+				return rc;
+			}
 		}
-		new->paddr = phdr_ptr->p_offset;
-		new->size = real_sz;
-		list_add_tail(&new->list, vc_list);
 		phdr_sz += real_sz;
 		kfree(notes_section);
 	}
 
+	if (nr_notes)
+		*nr_notes = nr_ptnote;
+	if (notes_sz)
+		*notes_sz = phdr_sz;
+
+	return 0;
+}
+
+static int __init get_note_number_and_size_elf64(const Elf64_Ehdr *ehdr_ptr,
+						 int *nr_ptnote, u64 *phdr_sz)
+{
+	return process_note_headers_elf64(ehdr_ptr, nr_ptnote, phdr_sz, NULL);
+}
+
+static int __init copy_notes_elf64(const Elf64_Ehdr *ehdr_ptr, char *notes_buf)
+{
+	return process_note_headers_elf64(ehdr_ptr, NULL, NULL, notes_buf);
+}
+
+/* Merges all the PT_NOTE headers into one. */
+static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
+					   char **notes_buf, size_t *notes_sz)
+{
+	int i, nr_ptnote=0, rc=0;
+	char *tmp;
+	Elf64_Ehdr *ehdr_ptr;
+	Elf64_Phdr phdr;
+	u64 phdr_sz = 0, note_off;
+	struct vm_struct *vm;
+
+	ehdr_ptr = (Elf64_Ehdr *)elfptr;
+
+	rc = get_note_number_and_size_elf64(ehdr_ptr, &nr_ptnote, &phdr_sz);
+	if (rc < 0)
+		return rc;
+
+	*notes_sz = roundup(phdr_sz, PAGE_SIZE);
+	*notes_buf = vzalloc(*notes_sz);
+	if (!*notes_buf)
+		return -ENOMEM;
+
+	vm = find_vm_area(*notes_buf);
+	BUG_ON(!vm);
+	vm->flags |= VM_USERMAP;
+
+	rc = copy_notes_elf64(ehdr_ptr, *notes_buf);
+	if (rc < 0)
+		return rc;
+
 	/* Prepare merged PT_NOTE program header. */
 	phdr.p_type    = PT_NOTE;
 	phdr.p_flags   = 0;
@@ -304,23 +385,33 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
 	return 0;
 }
 
-/* Merges all the PT_NOTE headers into one. */
-static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
-						struct list_head *vc_list)
+/**
+ * process_note_headers_elf32 - Perform a variety of processing on ELF
+ * note segments according to the combination of function arguments.
+ *
+ * @ehdr_ptr  - ELF header buffer
+ * @nr_notes  - the number of program header entries of PT_NOTE type
+ * @notes_sz  - total size of ELF note segment
+ * @notes_buf - buffer into which ELF note segment is copied
+ *
+ * Assume @ehdr_ptr is always not NULL. If @nr_notes is not NULL, then
+ * the number of program header entries of PT_NOTE type is assigned to
+ * @nr_notes. If @notes_sz is not NULL, then total size of ELF note
+ * segment, header part plus data part, is assigned to @notes_sz. If
+ * @notes_buf is not NULL, then ELF note segment is copied into
+ * @notes_buf.
+ */
+static int __init process_note_headers_elf32(const Elf32_Ehdr *ehdr_ptr,
+					     int *nr_notes, u64 *notes_sz,
+					     char *notes_buf)
 {
 	int i, nr_ptnote=0, rc=0;
-	char *tmp;
-	Elf32_Ehdr *ehdr_ptr;
-	Elf32_Phdr phdr, *phdr_ptr;
+	Elf32_Phdr *phdr_ptr = (Elf32_Phdr*)(ehdr_ptr + 1);
 	Elf32_Nhdr *nhdr_ptr;
-	u64 phdr_sz = 0, note_off;
+	u64 phdr_sz = 0;
 
-	ehdr_ptr = (Elf32_Ehdr *)elfptr;
-	phdr_ptr = (Elf32_Phdr*)(elfptr + sizeof(Elf32_Ehdr));
 	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
-		int j;
 		void *notes_section;
-		struct vmcore *new;
 		u64 offset, max_sz, sz, real_sz = 0;
 		if (phdr_ptr->p_type != PT_NOTE)
 			continue;
@@ -336,7 +427,7 @@ static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
 			return rc;
 		}
 		nhdr_ptr = notes_section;
-		for (j = 0; j < max_sz; j += sz) {
+		while (real_sz < max_sz) {
 			if (nhdr_ptr->n_namesz == 0)
 				break;
 			sz = sizeof(Elf32_Nhdr) +
@@ -345,20 +436,68 @@ static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
 			real_sz += sz;
 			nhdr_ptr = (Elf32_Nhdr*)((char*)nhdr_ptr + sz);
 		}
-
-		/* Add this contiguous chunk of notes section to vmcore list.*/
-		new = get_new_element();
-		if (!new) {
-			kfree(notes_section);
-			return -ENOMEM;
+		if (notes_buf) {
+			offset = phdr_ptr->p_offset;
+			rc = read_from_oldmem(notes_buf + phdr_sz, real_sz,
+					      &offset, 0);
+			if (rc < 0) {
+				kfree(notes_section);
+				return rc;
+			}
 		}
-		new->paddr = phdr_ptr->p_offset;
-		new->size = real_sz;
-		list_add_tail(&new->list, vc_list);
 		phdr_sz += real_sz;
 		kfree(notes_section);
 	}
 
+	if (nr_notes)
+		*nr_notes = nr_ptnote;
+	if (notes_sz)
+		*notes_sz = phdr_sz;
+
+	return 0;
+}
+
+static int __init get_note_number_and_size_elf32(const Elf32_Ehdr *ehdr_ptr,
+						 int *nr_ptnote, u64 *phdr_sz)
+{
+	return process_note_headers_elf32(ehdr_ptr, nr_ptnote, phdr_sz, NULL);
+}
+
+static int __init copy_notes_elf32(const Elf32_Ehdr *ehdr_ptr, char *notes_buf)
+{
+	return process_note_headers_elf32(ehdr_ptr, NULL, NULL, notes_buf);
+}
+
+/* Merges all the PT_NOTE headers into one. */
+static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
+					   char **notes_buf, size_t *notes_sz)
+{
+	int i, nr_ptnote=0, rc=0;
+	char *tmp;
+	Elf32_Ehdr *ehdr_ptr;
+	Elf32_Phdr phdr;
+	u64 phdr_sz = 0, note_off;
+	struct vm_struct *vm;
+
+	ehdr_ptr = (Elf32_Ehdr *)elfptr;
+
+	rc = get_note_number_and_size_elf32(ehdr_ptr, &nr_ptnote, &phdr_sz);
+	if (rc < 0)
+		return rc;
+
+	*notes_sz = roundup(phdr_sz, PAGE_SIZE);
+	*notes_buf = vzalloc(*notes_sz);
+	if (!*notes_buf)
+		return -ENOMEM;
+
+	vm = find_vm_area(*notes_buf);
+	BUG_ON(!vm);
+	vm->flags |= VM_USERMAP;
+
+	rc = copy_notes_elf32(ehdr_ptr, *notes_buf);
+	if (rc < 0)
+		return rc;
+
 	/* Prepare merged PT_NOTE program header. */
 	phdr.p_type    = PT_NOTE;
 	phdr.p_flags   = 0;
@@ -391,6 +530,7 @@ static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
  * the new offset fields of exported program headers. */
 static int __init process_ptload_program_headers_elf64(char *elfptr,
 						size_t elfsz,
+						size_t elfnotes_sz,
 						struct list_head *vc_list)
 {
 	int i;
@@ -402,8 +542,8 @@ static int __init process_ptload_program_headers_elf64(char *elfptr,
 	ehdr_ptr = (Elf64_Ehdr *)elfptr;
 	phdr_ptr = (Elf64_Phdr*)(elfptr + sizeof(Elf64_Ehdr)); /* PT_NOTE hdr */
 
-	/* First program header is PT_NOTE header. */
-	vmcore_off = elfsz + roundup(phdr_ptr->p_memsz, PAGE_SIZE);
+	/* Skip Elf header, program headers and Elf note segment. */
+	vmcore_off = elfsz + elfnotes_sz;
 
 	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
 		u64 paddr, start, end, size;
@@ -433,6 +573,7 @@ static int __init process_ptload_program_headers_elf64(char *elfptr,
 
 static int __init process_ptload_program_headers_elf32(char *elfptr,
 						size_t elfsz,
+						size_t elfnotes_sz,
 						struct list_head *vc_list)
 {
 	int i;
@@ -444,8 +585,8 @@ static int __init process_ptload_program_headers_elf32(char *elfptr,
 	ehdr_ptr = (Elf32_Ehdr *)elfptr;
 	phdr_ptr = (Elf32_Phdr*)(elfptr + sizeof(Elf32_Ehdr)); /* PT_NOTE hdr */
 
-	/* First program header is PT_NOTE header. */
-	vmcore_off = elfsz + roundup(phdr_ptr->p_memsz, PAGE_SIZE);
+	/* Skip Elf header, program headers and Elf note segment. */
+	vmcore_off = elfsz + elfnotes_sz;
 
 	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
 		u64 paddr, start, end, size;
@@ -474,17 +615,15 @@ static int __init process_ptload_program_headers_elf32(char *elfptr,
 }
 
 /* Sets offset fields of vmcore elements. */
-static void __init set_vmcore_list_offsets_elf64(char *elfptr, size_t elfsz,
+static void __init set_vmcore_list_offsets_elf64(size_t elfsz,
+						size_t elfnotes_sz,
 						struct list_head *vc_list)
 {
 	loff_t vmcore_off;
-	Elf64_Ehdr *ehdr_ptr;
 	struct vmcore *m;
 
-	ehdr_ptr = (Elf64_Ehdr *)elfptr;
-
-	/* Skip Elf header and program headers. */
-	vmcore_off = elfsz;
+	/* Skip Elf header, program headers and Elf note segment. */
+	vmcore_off = elfsz + elfnotes_sz;
 
 	list_for_each_entry(m, vc_list, list) {
 		m->offset = vmcore_off;
@@ -493,17 +632,15 @@ static void __init set_vmcore_list_offsets_elf64(char *elfptr, size_t elfsz,
 }
 
 /* Sets offset fields of vmcore elements. */
-static void __init set_vmcore_list_offsets_elf32(char *elfptr, size_t elfsz,
+static void __init set_vmcore_list_offsets_elf32(size_t elfsz,
+						size_t elfnotes_sz,
 						struct list_head *vc_list)
 {
 	loff_t vmcore_off;
-	Elf32_Ehdr *ehdr_ptr;
 	struct vmcore *m;
 
-	ehdr_ptr = (Elf32_Ehdr *)elfptr;
-
-	/* Skip Elf header and program headers. */
-	vmcore_off = elfsz;
+	/* Skip Elf header, program headers and Elf note segment. */
+	vmcore_off = elfsz + elfnotes_sz;
 
 	list_for_each_entry(m, vc_list, list) {
 		m->offset = vmcore_off;
@@ -554,20 +691,23 @@ static int __init parse_crash_elf64_headers(void)
 	}
 
 	/* Merge all PT_NOTE headers into one. */
-	rc = merge_note_headers_elf64(elfcorebuf, &elfcorebuf_sz, &vmcore_list);
+	rc = merge_note_headers_elf64(elfcorebuf, &elfcorebuf_sz,
+				      &elfnotes_buf, &elfnotes_sz);
 	if (rc) {
 		free_pages((unsigned long)elfcorebuf,
 			   get_order(elfcorebuf_sz_orig));
 		return rc;
 	}
 	rc = process_ptload_program_headers_elf64(elfcorebuf, elfcorebuf_sz,
-							&vmcore_list);
+						  elfnotes_sz,
+						  &vmcore_list);
 	if (rc) {
 		free_pages((unsigned long)elfcorebuf,
 			   get_order(elfcorebuf_sz_orig));
 		return rc;
 	}
-	set_vmcore_list_offsets_elf64(elfcorebuf, elfcorebuf_sz, &vmcore_list);
+	set_vmcore_list_offsets_elf64(elfcorebuf_sz, elfnotes_sz,
+				      &vmcore_list);
 	return 0;
 }
 
@@ -614,20 +754,23 @@ static int __init parse_crash_elf32_headers(void)
 	}
 
 	/* Merge all PT_NOTE headers into one. */
-	rc = merge_note_headers_elf32(elfcorebuf, &elfcorebuf_sz, &vmcore_list);
+	rc = merge_note_headers_elf32(elfcorebuf, &elfcorebuf_sz,
+				      &elfnotes_buf, &elfnotes_sz);
 	if (rc) {
 		free_pages((unsigned long)elfcorebuf,
 			   get_order(elfcorebuf_sz_orig));
 		return rc;
 	}
 	rc = process_ptload_program_headers_elf32(elfcorebuf, elfcorebuf_sz,
-								&vmcore_list);
+						  elfnotes_sz,
+						  &vmcore_list);
 	if (rc) {
 		free_pages((unsigned long)elfcorebuf,
 			   get_order(elfcorebuf_sz_orig));
 		return rc;
 	}
-	set_vmcore_list_offsets_elf32(elfcorebuf, elfcorebuf_sz, &vmcore_list);
+	set_vmcore_list_offsets_elf32(elfcorebuf_sz, elfnotes_sz,
+				      &vmcore_list);
 	return 0;
 }
 
@@ -706,6 +849,8 @@ void vmcore_cleanup(void)
 		list_del(&m->list);
 		kfree(m);
 	}
+	vfree(elfnotes_buf);
+	elfnotes_buf = NULL;
 	free_pages((unsigned long)elfcorebuf,
 		   get_order(elfcorebuf_sz_orig));
 	elfcorebuf = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
