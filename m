Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 8F5BE6B0038
	for <linux-mm@kvack.org>; Tue, 21 May 2013 22:56:09 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2A10E3EE0AE
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:56:08 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 13E2245DE53
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:56:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EDBBC45DE50
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:56:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D60D1E08003
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:56:07 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DDA61DB803B
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:56:07 +0900 (JST)
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Subject: [PATCH v7 6/8] vmcore: allocate ELF note segment in the 2nd kernel
 vmalloc memory
Date: Wed, 22 May 2013 11:56:06 +0900
Message-ID: <20130522025606.12215.36133.stgit@localhost6.localdomain6>
In-Reply-To: <20130522025410.12215.16793.stgit@localhost6.localdomain6>
References: <20130522025410.12215.16793.stgit@localhost6.localdomain6>
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

 fs/proc/vmcore.c |  335 ++++++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 275 insertions(+), 60 deletions(-)

diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index d33b04d..ca55343 100644
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
@@ -221,23 +244,31 @@ static u64 __init get_vmcore_size_elf32(char *elfptr, size_t elfsz)
 	return size;
 }
 
-/* Merges all the PT_NOTE headers into one. */
-static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
-						struct list_head *vc_list)
+/**
+ * get_note_number_and_size_elf64 - get the number of PT_NOTE program
+ * headers and sum of real size of their ELF note segment headers and
+ * data.
+ *
+ * @ehdr_ptr: ELF header
+ * @nr_ptnotep: buffer for the number of PT_NOTE program headers
+ * @phdr_szp: buffer for size of unique PT_NOTE program header
+ *
+ * This function is used to merge multiple PT_NOTE program headers
+ * into a unique single one. The resulting unique entry will have
+ * @phdr_szp in its phdr->p_mem.
+ */
+static int __init get_note_number_and_size_elf64(const Elf64_Ehdr *ehdr_ptr,
+						 int *nr_ptnotep, u64 *phdr_szp)
 {
 	int i, nr_ptnote=0, rc=0;
-	char *tmp;
-	Elf64_Ehdr *ehdr_ptr;
-	Elf64_Phdr phdr, *phdr_ptr;
+	Elf64_Phdr *phdr_ptr;
 	Elf64_Nhdr *nhdr_ptr;
-	u64 phdr_sz = 0, note_off;
+	u64 phdr_sz = 0;
 
-	ehdr_ptr = (Elf64_Ehdr *)elfptr;
-	phdr_ptr = (Elf64_Phdr*)(elfptr + sizeof(Elf64_Ehdr));
+	phdr_ptr = (Elf64_Phdr *)(ehdr_ptr + 1);
 	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
 		int j;
 		void *notes_section;
-		struct vmcore *new;
 		u64 offset, max_sz, sz, real_sz = 0;
 		if (phdr_ptr->p_type != PT_NOTE)
 			continue;
@@ -262,26 +293,112 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
 			real_sz += sz;
 			nhdr_ptr = (Elf64_Nhdr*)((char*)nhdr_ptr + sz);
 		}
+		phdr_sz += real_sz;
+		kfree(notes_section);
+	}
 
-		/* Add this contiguous chunk of notes section to vmcore list.*/
-		new = get_new_element();
-		if (!new) {
-			kfree(notes_section);
+	*nr_ptnotep = nr_ptnote;
+	*phdr_szp = phdr_sz;
+
+	return 0;
+}
+
+/**
+ * copy_notes_elf64 - copy ELF note segments in a given buffer
+ *
+ * @ehdr_ptr: ELF header
+ * @notes_buf: buffer into which ELF note segments are copied
+ *
+ * This function is used to copy ELF note segment in the 1st kernel
+ * into the buffer @notes_buf in the 2nd kernel. It is assumed that
+ * size of the buffer @notes_buf is equal to or larger than sum of the
+ * real ELF note segment headers and data.
+ */
+static int __init copy_notes_elf64(const Elf64_Ehdr *ehdr_ptr, char *notes_buf)
+{
+	int i, rc=0;
+	Elf64_Phdr *phdr_ptr;
+	Elf64_Nhdr *nhdr_ptr;
+	u64 phdr_sz = 0;
+
+	phdr_ptr = (Elf64_Phdr*)(ehdr_ptr + 1);
+
+	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
+		int j;
+		void *notes_section;
+		u64 offset, max_sz, sz, real_sz = 0;
+		if (phdr_ptr->p_type != PT_NOTE)
+			continue;
+		max_sz = phdr_ptr->p_memsz;
+		offset = phdr_ptr->p_offset;
+		notes_section = kmalloc(max_sz, GFP_KERNEL);
+		if (!notes_section)
 			return -ENOMEM;
+		rc = read_from_oldmem(notes_section, max_sz, &offset, 0);
+		if (rc < 0) {
+			kfree(notes_section);
+			return rc;
+		}
+		nhdr_ptr = notes_section;
+		for (j = 0; j < max_sz; j += sz) {
+			if (nhdr_ptr->n_namesz == 0)
+				break;
+			sz = sizeof(Elf64_Nhdr) +
+				((nhdr_ptr->n_namesz + 3) & ~3) +
+				((nhdr_ptr->n_descsz + 3) & ~3);
+			real_sz += sz;
+			nhdr_ptr = (Elf64_Nhdr*)((char*)nhdr_ptr + sz);
+		}
+		offset = phdr_ptr->p_offset;
+		rc = read_from_oldmem(notes_buf + phdr_sz, real_sz,
+				      &offset, 0);
+		if (rc < 0) {
+			kfree(notes_section);
+			return rc;
 		}
-		new->paddr = phdr_ptr->p_offset;
-		new->size = real_sz;
-		list_add_tail(&new->list, vc_list);
 		phdr_sz += real_sz;
 		kfree(notes_section);
 	}
 
+	return 0;
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
 	note_off = sizeof(Elf64_Ehdr) +
 			(ehdr_ptr->e_phnum - nr_ptnote +1) * sizeof(Elf64_Phdr);
-	phdr.p_offset  = note_off;
+	phdr.p_offset  = roundup(note_off, PAGE_SIZE);
 	phdr.p_vaddr   = phdr.p_paddr = 0;
 	phdr.p_filesz  = phdr.p_memsz = phdr_sz;
 	phdr.p_align   = 0;
@@ -304,23 +421,31 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
 	return 0;
 }
 
-/* Merges all the PT_NOTE headers into one. */
-static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
-						struct list_head *vc_list)
+/**
+ * get_note_number_and_size_elf32 - get the number of PT_NOTE program
+ * headers and sum of real size of their ELF note segment headers and
+ * data.
+ *
+ * @ehdr_ptr: ELF header
+ * @nr_ptnotep: buffer for the number of PT_NOTE program headers
+ * @phdr_szp: buffer for size of unique PT_NOTE program header
+ *
+ * This function is used to merge multiple PT_NOTE program headers
+ * into a unique single one. The resulting unique entry will have
+ * @phdr_szp in its phdr->p_mem.
+ */
+static int __init get_note_number_and_size_elf32(const Elf32_Ehdr *ehdr_ptr,
+						 int *nr_ptnotep, u64 *phdr_szp)
 {
 	int i, nr_ptnote=0, rc=0;
-	char *tmp;
-	Elf32_Ehdr *ehdr_ptr;
-	Elf32_Phdr phdr, *phdr_ptr;
+	Elf32_Phdr *phdr_ptr;
 	Elf32_Nhdr *nhdr_ptr;
-	u64 phdr_sz = 0, note_off;
+	u64 phdr_sz = 0;
 
-	ehdr_ptr = (Elf32_Ehdr *)elfptr;
-	phdr_ptr = (Elf32_Phdr*)(elfptr + sizeof(Elf32_Ehdr));
+	phdr_ptr = (Elf32_Phdr*)(ehdr_ptr + 1);
 	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
 		int j;
 		void *notes_section;
-		struct vmcore *new;
 		u64 offset, max_sz, sz, real_sz = 0;
 		if (phdr_ptr->p_type != PT_NOTE)
 			continue;
@@ -345,26 +470,112 @@ static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
 			real_sz += sz;
 			nhdr_ptr = (Elf32_Nhdr*)((char*)nhdr_ptr + sz);
 		}
+		phdr_sz += real_sz;
+		kfree(notes_section);
+	}
 
-		/* Add this contiguous chunk of notes section to vmcore list.*/
-		new = get_new_element();
-		if (!new) {
-			kfree(notes_section);
+	*nr_ptnotep = nr_ptnote;
+	*phdr_szp = phdr_sz;
+
+	return 0;
+}
+
+/**
+ * copy_notes_elf32 - copy ELF note segments in a given buffer
+ *
+ * @ehdr_ptr: ELF header
+ * @notes_buf: buffer into which ELF note segments are copied
+ *
+ * This function is used to copy ELF note segment in the 1st kernel
+ * into the buffer @notes_buf in the 2nd kernel. It is assumed that
+ * size of the buffer @notes_buf is equal to or larger than sum of the
+ * real ELF note segment headers and data.
+ */
+static int __init copy_notes_elf32(const Elf32_Ehdr *ehdr_ptr, char *notes_buf)
+{
+	int i, rc=0;
+	Elf32_Phdr *phdr_ptr;
+	Elf32_Nhdr *nhdr_ptr;
+	u64 phdr_sz = 0;
+
+	phdr_ptr = (Elf32_Phdr*)(ehdr_ptr + 1);
+
+	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
+		int j;
+		void *notes_section;
+		u64 offset, max_sz, sz, real_sz = 0;
+		if (phdr_ptr->p_type != PT_NOTE)
+			continue;
+		max_sz = phdr_ptr->p_memsz;
+		offset = phdr_ptr->p_offset;
+		notes_section = kmalloc(max_sz, GFP_KERNEL);
+		if (!notes_section)
 			return -ENOMEM;
+		rc = read_from_oldmem(notes_section, max_sz, &offset, 0);
+		if (rc < 0) {
+			kfree(notes_section);
+			return rc;
+		}
+		nhdr_ptr = notes_section;
+		for (j = 0; real_sz < max_sz; j += sz) {
+			if (nhdr_ptr->n_namesz == 0)
+				break;
+			sz = sizeof(Elf32_Nhdr) +
+				((nhdr_ptr->n_namesz + 3) & ~3) +
+				((nhdr_ptr->n_descsz + 3) & ~3);
+			real_sz += sz;
+			nhdr_ptr = (Elf32_Nhdr*)((char*)nhdr_ptr + sz);
+		}
+		offset = phdr_ptr->p_offset;
+		rc = read_from_oldmem(notes_buf + phdr_sz, real_sz,
+				      &offset, 0);
+		if (rc < 0) {
+			kfree(notes_section);
+			return rc;
 		}
-		new->paddr = phdr_ptr->p_offset;
-		new->size = real_sz;
-		list_add_tail(&new->list, vc_list);
 		phdr_sz += real_sz;
 		kfree(notes_section);
 	}
 
+	return 0;
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
 	note_off = sizeof(Elf32_Ehdr) +
 			(ehdr_ptr->e_phnum - nr_ptnote +1) * sizeof(Elf32_Phdr);
-	phdr.p_offset  = note_off;
+	phdr.p_offset  = roundup(note_off, PAGE_SIZE);
 	phdr.p_vaddr   = phdr.p_paddr = 0;
 	phdr.p_filesz  = phdr.p_memsz = phdr_sz;
 	phdr.p_align   = 0;
@@ -391,6 +602,7 @@ static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
  * the new offset fields of exported program headers. */
 static int __init process_ptload_program_headers_elf64(char *elfptr,
 						size_t elfsz,
+						size_t elfnotes_sz,
 						struct list_head *vc_list)
 {
 	int i;
@@ -402,9 +614,8 @@ static int __init process_ptload_program_headers_elf64(char *elfptr,
 	ehdr_ptr = (Elf64_Ehdr *)elfptr;
 	phdr_ptr = (Elf64_Phdr*)(elfptr + sizeof(Elf64_Ehdr)); /* PT_NOTE hdr */
 
-	/* First program header is PT_NOTE header. */
-	vmcore_off = elfsz +
-			phdr_ptr->p_memsz; /* Note sections */
+	/* Skip Elf header, program headers and Elf note segment. */
+	vmcore_off = elfsz + elfnotes_sz;
 
 	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
 		u64 paddr, start, end, size;
@@ -434,6 +645,7 @@ static int __init process_ptload_program_headers_elf64(char *elfptr,
 
 static int __init process_ptload_program_headers_elf32(char *elfptr,
 						size_t elfsz,
+						size_t elfnotes_sz,
 						struct list_head *vc_list)
 {
 	int i;
@@ -445,9 +657,8 @@ static int __init process_ptload_program_headers_elf32(char *elfptr,
 	ehdr_ptr = (Elf32_Ehdr *)elfptr;
 	phdr_ptr = (Elf32_Phdr*)(elfptr + sizeof(Elf32_Ehdr)); /* PT_NOTE hdr */
 
-	/* First program header is PT_NOTE header. */
-	vmcore_off = elfsz +
-			phdr_ptr->p_memsz; /* Note sections */
+	/* Skip Elf header, program headers and Elf note segment. */
+	vmcore_off = elfsz + elfnotes_sz;
 
 	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
 		u64 paddr, start, end, size;
@@ -476,17 +687,15 @@ static int __init process_ptload_program_headers_elf32(char *elfptr,
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
@@ -495,17 +704,15 @@ static void __init set_vmcore_list_offsets_elf64(char *elfptr, size_t elfsz,
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
@@ -556,20 +763,23 @@ static int __init parse_crash_elf64_headers(void)
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
 
@@ -616,20 +826,23 @@ static int __init parse_crash_elf32_headers(void)
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
 
@@ -708,6 +921,8 @@ void vmcore_cleanup(void)
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
