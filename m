Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 37DB66B0033
	for <linux-mm@kvack.org>; Tue, 21 May 2013 22:55:47 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4EF1E3EE0BC
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:55:45 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FC6445DE53
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:55:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2626745DE4F
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:55:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 10888E08003
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:55:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 677511DB802F
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:55:44 +0900 (JST)
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Subject: [PATCH v7 2/8] vmcore: allocate buffer for ELF headers on page-size
 alignment
Date: Wed, 22 May 2013 11:55:43 +0900
Message-ID: <20130522025543.12215.27624.stgit@localhost6.localdomain6>
In-Reply-To: <20130522025410.12215.16793.stgit@localhost6.localdomain6>
References: <20130522025410.12215.16793.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vgoyal@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

Allocate ELF headers on page-size boundary using __get_free_pages()
instead of kmalloc().

Later patch will merge PT_NOTE entries into a single unique one and
decrease the buffer size actually used. Keep original buffer size in
variable elfcorebuf_sz_orig to kfree the buffer later and actually
used buffer size with rounded up to page-size boundary in variable
elfcorebuf_sz separately.

The size of part of the ELF buffer exported from /proc/vmcore is
elfcorebuf_sz.

The merged, removed PT_NOTE entries, i.e. the range [elfcorebuf_sz,
elfcorebuf_sz_orig], is filled with 0.

Use size of the ELF headers as an initial offset value in
set_vmcore_list_offsets_elf{64,32} and
process_ptload_program_headers_elf{64,32} in order to indicate that
the offset includes the holes towards the page boundary.

Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
---

 fs/proc/vmcore.c |   74 +++++++++++++++++++++++++++++++-----------------------
 1 files changed, 43 insertions(+), 31 deletions(-)

diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index ab0c92e..0651d98 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -32,6 +32,7 @@ static LIST_HEAD(vmcore_list);
 /* Stores the pointer to the buffer containing kernel elf core headers. */
 static char *elfcorebuf;
 static size_t elfcorebuf_sz;
+static size_t elfcorebuf_sz_orig;
 
 /* Total size of vmcore file. */
 static u64 vmcore_size;
@@ -186,7 +187,7 @@ static struct vmcore* __init get_new_element(void)
 	return kzalloc(sizeof(struct vmcore), GFP_KERNEL);
 }
 
-static u64 __init get_vmcore_size_elf64(char *elfptr)
+static u64 __init get_vmcore_size_elf64(char *elfptr, size_t elfsz)
 {
 	int i;
 	u64 size;
@@ -195,7 +196,7 @@ static u64 __init get_vmcore_size_elf64(char *elfptr)
 
 	ehdr_ptr = (Elf64_Ehdr *)elfptr;
 	phdr_ptr = (Elf64_Phdr*)(elfptr + sizeof(Elf64_Ehdr));
-	size = sizeof(Elf64_Ehdr) + ((ehdr_ptr->e_phnum) * sizeof(Elf64_Phdr));
+	size = elfsz;
 	for (i = 0; i < ehdr_ptr->e_phnum; i++) {
 		size += phdr_ptr->p_memsz;
 		phdr_ptr++;
@@ -203,7 +204,7 @@ static u64 __init get_vmcore_size_elf64(char *elfptr)
 	return size;
 }
 
-static u64 __init get_vmcore_size_elf32(char *elfptr)
+static u64 __init get_vmcore_size_elf32(char *elfptr, size_t elfsz)
 {
 	int i;
 	u64 size;
@@ -212,7 +213,7 @@ static u64 __init get_vmcore_size_elf32(char *elfptr)
 
 	ehdr_ptr = (Elf32_Ehdr *)elfptr;
 	phdr_ptr = (Elf32_Phdr*)(elfptr + sizeof(Elf32_Ehdr));
-	size = sizeof(Elf32_Ehdr) + ((ehdr_ptr->e_phnum) * sizeof(Elf32_Phdr));
+	size = elfsz;
 	for (i = 0; i < ehdr_ptr->e_phnum; i++) {
 		size += phdr_ptr->p_memsz;
 		phdr_ptr++;
@@ -294,6 +295,8 @@ static int __init merge_note_headers_elf64(char *elfptr, size_t *elfsz,
 	i = (nr_ptnote - 1) * sizeof(Elf64_Phdr);
 	*elfsz = *elfsz - i;
 	memmove(tmp, tmp+i, ((*elfsz)-sizeof(Elf64_Ehdr)-sizeof(Elf64_Phdr)));
+	memset(elfptr + *elfsz, 0, i);
+	*elfsz = roundup(*elfsz, PAGE_SIZE);
 
 	/* Modify e_phnum to reflect merged headers. */
 	ehdr_ptr->e_phnum = ehdr_ptr->e_phnum - nr_ptnote + 1;
@@ -375,6 +378,8 @@ static int __init merge_note_headers_elf32(char *elfptr, size_t *elfsz,
 	i = (nr_ptnote - 1) * sizeof(Elf32_Phdr);
 	*elfsz = *elfsz - i;
 	memmove(tmp, tmp+i, ((*elfsz)-sizeof(Elf32_Ehdr)-sizeof(Elf32_Phdr)));
+	memset(elfptr + *elfsz, 0, i);
+	*elfsz = roundup(*elfsz, PAGE_SIZE);
 
 	/* Modify e_phnum to reflect merged headers. */
 	ehdr_ptr->e_phnum = ehdr_ptr->e_phnum - nr_ptnote + 1;
@@ -398,8 +403,7 @@ static int __init process_ptload_program_headers_elf64(char *elfptr,
 	phdr_ptr = (Elf64_Phdr*)(elfptr + sizeof(Elf64_Ehdr)); /* PT_NOTE hdr */
 
 	/* First program header is PT_NOTE header. */
-	vmcore_off = sizeof(Elf64_Ehdr) +
-			(ehdr_ptr->e_phnum) * sizeof(Elf64_Phdr) +
+	vmcore_off = elfsz +
 			phdr_ptr->p_memsz; /* Note sections */
 
 	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
@@ -435,8 +439,7 @@ static int __init process_ptload_program_headers_elf32(char *elfptr,
 	phdr_ptr = (Elf32_Phdr*)(elfptr + sizeof(Elf32_Ehdr)); /* PT_NOTE hdr */
 
 	/* First program header is PT_NOTE header. */
-	vmcore_off = sizeof(Elf32_Ehdr) +
-			(ehdr_ptr->e_phnum) * sizeof(Elf32_Phdr) +
+	vmcore_off = elfsz +
 			phdr_ptr->p_memsz; /* Note sections */
 
 	for (i = 0; i < ehdr_ptr->e_phnum; i++, phdr_ptr++) {
@@ -459,7 +462,7 @@ static int __init process_ptload_program_headers_elf32(char *elfptr,
 }
 
 /* Sets offset fields of vmcore elements. */
-static void __init set_vmcore_list_offsets_elf64(char *elfptr,
+static void __init set_vmcore_list_offsets_elf64(char *elfptr, size_t elfsz,
 						struct list_head *vc_list)
 {
 	loff_t vmcore_off;
@@ -469,8 +472,7 @@ static void __init set_vmcore_list_offsets_elf64(char *elfptr,
 	ehdr_ptr = (Elf64_Ehdr *)elfptr;
 
 	/* Skip Elf header and program headers. */
-	vmcore_off = sizeof(Elf64_Ehdr) +
-			(ehdr_ptr->e_phnum) * sizeof(Elf64_Phdr);
+	vmcore_off = elfsz;
 
 	list_for_each_entry(m, vc_list, list) {
 		m->offset = vmcore_off;
@@ -479,7 +481,7 @@ static void __init set_vmcore_list_offsets_elf64(char *elfptr,
 }
 
 /* Sets offset fields of vmcore elements. */
-static void __init set_vmcore_list_offsets_elf32(char *elfptr,
+static void __init set_vmcore_list_offsets_elf32(char *elfptr, size_t elfsz,
 						struct list_head *vc_list)
 {
 	loff_t vmcore_off;
@@ -489,8 +491,7 @@ static void __init set_vmcore_list_offsets_elf32(char *elfptr,
 	ehdr_ptr = (Elf32_Ehdr *)elfptr;
 
 	/* Skip Elf header and program headers. */
-	vmcore_off = sizeof(Elf32_Ehdr) +
-			(ehdr_ptr->e_phnum) * sizeof(Elf32_Phdr);
+	vmcore_off = elfsz;
 
 	list_for_each_entry(m, vc_list, list) {
 		m->offset = vmcore_off;
@@ -526,30 +527,35 @@ static int __init parse_crash_elf64_headers(void)
 	}
 
 	/* Read in all elf headers. */
-	elfcorebuf_sz = sizeof(Elf64_Ehdr) + ehdr.e_phnum * sizeof(Elf64_Phdr);
-	elfcorebuf = kmalloc(elfcorebuf_sz, GFP_KERNEL);
+	elfcorebuf_sz_orig = sizeof(Elf64_Ehdr) + ehdr.e_phnum * sizeof(Elf64_Phdr);
+	elfcorebuf_sz = elfcorebuf_sz_orig;
+	elfcorebuf = (void *) __get_free_pages(GFP_KERNEL | __GFP_ZERO,
+					       get_order(elfcorebuf_sz_orig));
 	if (!elfcorebuf)
 		return -ENOMEM;
 	addr = elfcorehdr_addr;
-	rc = read_from_oldmem(elfcorebuf, elfcorebuf_sz, &addr, 0);
+	rc = read_from_oldmem(elfcorebuf, elfcorebuf_sz_orig, &addr, 0);
 	if (rc < 0) {
-		kfree(elfcorebuf);
+		free_pages((unsigned long)elfcorebuf,
+			   get_order(elfcorebuf_sz_orig));
 		return rc;
 	}
 
 	/* Merge all PT_NOTE headers into one. */
 	rc = merge_note_headers_elf64(elfcorebuf, &elfcorebuf_sz, &vmcore_list);
 	if (rc) {
-		kfree(elfcorebuf);
+		free_pages((unsigned long)elfcorebuf,
+			   get_order(elfcorebuf_sz_orig));
 		return rc;
 	}
 	rc = process_ptload_program_headers_elf64(elfcorebuf, elfcorebuf_sz,
 							&vmcore_list);
 	if (rc) {
-		kfree(elfcorebuf);
+		free_pages((unsigned long)elfcorebuf,
+			   get_order(elfcorebuf_sz_orig));
 		return rc;
 	}
-	set_vmcore_list_offsets_elf64(elfcorebuf, &vmcore_list);
+	set_vmcore_list_offsets_elf64(elfcorebuf, elfcorebuf_sz, &vmcore_list);
 	return 0;
 }
 
@@ -581,30 +587,35 @@ static int __init parse_crash_elf32_headers(void)
 	}
 
 	/* Read in all elf headers. */
-	elfcorebuf_sz = sizeof(Elf32_Ehdr) + ehdr.e_phnum * sizeof(Elf32_Phdr);
-	elfcorebuf = kmalloc(elfcorebuf_sz, GFP_KERNEL);
+	elfcorebuf_sz_orig = sizeof(Elf32_Ehdr) + ehdr.e_phnum * sizeof(Elf32_Phdr);
+	elfcorebuf_sz = elfcorebuf_sz_orig;
+	elfcorebuf = (void *) __get_free_pages(GFP_KERNEL | __GFP_ZERO,
+					       get_order(elfcorebuf_sz_orig));
 	if (!elfcorebuf)
 		return -ENOMEM;
 	addr = elfcorehdr_addr;
-	rc = read_from_oldmem(elfcorebuf, elfcorebuf_sz, &addr, 0);
+	rc = read_from_oldmem(elfcorebuf, elfcorebuf_sz_orig, &addr, 0);
 	if (rc < 0) {
-		kfree(elfcorebuf);
+		free_pages((unsigned long)elfcorebuf,
+			   get_order(elfcorebuf_sz_orig));
 		return rc;
 	}
 
 	/* Merge all PT_NOTE headers into one. */
 	rc = merge_note_headers_elf32(elfcorebuf, &elfcorebuf_sz, &vmcore_list);
 	if (rc) {
-		kfree(elfcorebuf);
+		free_pages((unsigned long)elfcorebuf,
+			   get_order(elfcorebuf_sz_orig));
 		return rc;
 	}
 	rc = process_ptload_program_headers_elf32(elfcorebuf, elfcorebuf_sz,
 								&vmcore_list);
 	if (rc) {
-		kfree(elfcorebuf);
+		free_pages((unsigned long)elfcorebuf,
+			   get_order(elfcorebuf_sz_orig));
 		return rc;
 	}
-	set_vmcore_list_offsets_elf32(elfcorebuf, &vmcore_list);
+	set_vmcore_list_offsets_elf32(elfcorebuf, elfcorebuf_sz, &vmcore_list);
 	return 0;
 }
 
@@ -629,14 +640,14 @@ static int __init parse_crash_elf_headers(void)
 			return rc;
 
 		/* Determine vmcore size. */
-		vmcore_size = get_vmcore_size_elf64(elfcorebuf);
+		vmcore_size = get_vmcore_size_elf64(elfcorebuf, elfcorebuf_sz);
 	} else if (e_ident[EI_CLASS] == ELFCLASS32) {
 		rc = parse_crash_elf32_headers();
 		if (rc)
 			return rc;
 
 		/* Determine vmcore size. */
-		vmcore_size = get_vmcore_size_elf32(elfcorebuf);
+		vmcore_size = get_vmcore_size_elf32(elfcorebuf, elfcorebuf_sz);
 	} else {
 		pr_warn("Warning: Core image elf header is not sane\n");
 		return -EINVAL;
@@ -683,7 +694,8 @@ void vmcore_cleanup(void)
 		list_del(&m->list);
 		kfree(m);
 	}
-	kfree(elfcorebuf);
+	free_pages((unsigned long)elfcorebuf,
+		   get_order(elfcorebuf_sz_orig));
 	elfcorebuf = NULL;
 }
 EXPORT_SYMBOL_GPL(vmcore_cleanup);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
