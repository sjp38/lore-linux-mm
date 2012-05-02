Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id E2E746B004D
	for <linux-mm@kvack.org>; Wed,  2 May 2012 03:05:17 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <prashanth@linux.vnet.ibm.com>;
	Wed, 2 May 2012 01:05:17 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id ED67219D804E
	for <linux-mm@kvack.org>; Wed,  2 May 2012 01:02:59 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4272WCd124612
	for <linux-mm@kvack.org>; Wed, 2 May 2012 01:02:48 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4272G0L012737
	for <linux-mm@kvack.org>; Wed, 2 May 2012 01:02:17 -0600
Message-ID: <4FA0DBEE.3040909@linux.vnet.ibm.com>
Date: Wed, 02 May 2012 12:32:06 +0530
From: Prashanth Nageshappa <prashanth@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH-V2] perf symbols: fix symbol offset breakage with separated
 debug info
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@elte.hu
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, ananth@in.ibm.com, jkenisto@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, oleg@redhat.com, andi@firstfloor.org, hch@infradead.org, rostedt@goodmis.org, acme@infradead.org, masami.hiramatsu.pt@hitachi.com, tglx@linutronix.de, anton@redhat.com, srikar@linux.vnet.ibm.com, dave.martin@linaro.org, linux-perf-users@vger.kernel.org

From: Dave Martin <dave.martin@linaro.org>

perf resolves symbols to wrong offsets when debug info is separated
from the lib/executable.

This patch is based on Dave Martin's initial work first published at
https://lkml.org/lkml/2010/11/22/137

This patch loads the ELF section headers from a separate file if
necessary, to avoid getting confused by the different section file
offsets seen in debug images.  Invalid section headers are detected by
checking for the presence of non-writable SHT_NOBITS sections, which
don't make sense under normal circumstances.

In particular, this allows symbols in ET_EXEC images to get fixed up
correctly in the presence of separated debug images.

v2 addresses review comments (to remove asserts) from Dave Martin.

Signed-off-by: Dave Martin <dave.martin@linaro.org>
Signed-off-by: Prashanth Nageshappa <prashanth@linux.vnet.ibm.com>
---

 tools/perf/util/symbol.c |  168 +++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 164 insertions(+), 4 deletions(-)

diff --git a/tools/perf/util/symbol.c b/tools/perf/util/symbol.c
index caaf75a..a6ad4b1 100644
--- a/tools/perf/util/symbol.c
+++ b/tools/perf/util/symbol.c
@@ -1158,8 +1158,105 @@ static size_t elf_addr_to_index(Elf *elf, GElf_Addr addr)
 	return -1;
 }
 
+/**
+ * Read all section headers, copying them into a separate array so they survive
+ * elf_end.
+ *
+ * @elf: the libelf instance to operate on.
+ * @ehdr: the elf header: this must already have been read with gelf_getehdr().
+ * @count: the number of headers read is assigned to *count on successful
+ *	return.  count must not be NULL.
+ *
+ * Returns a pointer to the allocated headers, which should be deallocated with
+ * free() when no longer needed.
+ */
+static GElf_Shdr *elf_get_all_shdrs(Elf *elf, GElf_Ehdr const *ehdr,
+				    unsigned *count)
+{
+	GElf_Shdr *shdrs;
+	Elf_Scn *scn;
+	unsigned max_index = 0;
+	unsigned i;
+
+	shdrs = malloc(ehdr->e_shnum * sizeof *shdrs);
+	if (!shdrs)
+		return NULL;
+
+	for (i = 0; i < ehdr->e_shnum; i++)
+		shdrs[i].sh_type = SHT_NULL;
+
+	for (scn = NULL; (scn = elf_nextscn(elf, scn)); ) {
+		size_t j;
+
+		/*
+		 * Just assuming we get section 0, 1, ... in sequence may lead
+		 * to wrong section indices.  Check the index explicitly:
+		 */
+		j = elf_ndxscn(scn);
+		if (j > max_index)
+			max_index = j;
+
+		if (!gelf_getshdr(scn, &shdrs[j]))
+			goto error;
+	}
+
+	*count = max_index + 1;
+	return shdrs;
+
+error:
+	free(shdrs);
+	return NULL;
+}
+
+/**
+ * Check that the section headers @shdrs reflect accurately the file data
+ * layout of the image that was loaded during perf record.  This is generally
+ * not true for separated debug images generated with e.g.,
+ * objcopy --only-keep-debug.
+ *
+ * We identify invalid files by checking for non-empty sections which are
+ * declared as having no file data (SHT_NOBITS) but are not writable.
+ *
+ * @shdrs: the full set of section headers, as loaded by elf_get_all_shdrs().
+ * @count: the number of headers present in @shdrs.
+ *
+ * Returns 1 for valid headers, 0 otherwise.
+ */
+static int elf_check_shdrs_valid(GElf_Shdr const *shdrs, unsigned count)
+{
+	unsigned i;
+
+	for (i = 0; i < count; i++) {
+		if (shdrs[i].sh_type == SHT_NOBITS &&
+		    !(shdrs[i].sh_flags & SHF_WRITE) &&
+		    shdrs[i].sh_size != 0)
+			return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Notes:
+ *
+ * If saved_shdrs is non-NULL, the section headers will be read if found, and
+ * will be used for address fixups.  saved_shdrs_count must also be non-NULL in
+ * this case.  This may be needed for separated debug images, since the section
+ * headers and symbols may need to come from separate images in that case.
+ *
+ * Note: irrespective of whether this function returns successfully,
+ * *saved_shdrs may get initialised if saved_shdrs is non-NULL.  It is the
+ * caller's responsibility to free() it when non longer needed.
+ *
+ * If want_symtab == 1, this function will only load symbols from .symtab
+ * sections.  Otherwise (want_symtab == 0), .dynsym or .symtab symbols are
+ * loaded.  This feature is used by dso__load() to search for the best image
+ * to load.
+ */
+
 static int dso__load_sym(struct dso *dso, struct map *map, const char *name,
 			 int fd, symbol_filter_t filter, int kmodule,
+			 GElf_Shdr **saved_shdrs, unsigned *saved_shdrs_count,
 			 int want_symtab)
 {
 	struct kmap *kmap = dso->kernel ? map__kmap(map) : NULL;
@@ -1178,6 +1275,17 @@ static int dso__load_sym(struct dso *dso, struct map *map, const char *name,
 	int nr = 0;
 	size_t opdidx = 0;
 
+	if (saved_shdrs != NULL && saved_shdrs_count == NULL) {
+		/*
+		 * If you trigger this check, you're calling this function
+		 * incorrectly.  Refer to the notes above for details.
+		 */
+		pr_debug("%s: warning: saved_shdrs_count == NULL: "
+			 "ignoring the saved section headers.\n",
+			 __func__);
+		saved_shdrs = NULL;
+	}
+
 	elf = elf_begin(fd, PERF_ELF_C_READ_MMAP, NULL);
 	if (elf == NULL) {
 		pr_debug("%s: cannot read %s ELF file.\n", __func__, name);
@@ -1200,6 +1308,36 @@ static int dso__load_sym(struct dso *dso, struct map *map, const char *name,
 			goto out_elf_end;
 	}
 
+	/*
+	 * Copy all section headers from the image if requested and if not
+	 * already loaded.
+	 */
+	if (saved_shdrs != NULL && *saved_shdrs == NULL) {
+		GElf_Shdr *shdrs;
+		unsigned count;
+
+		shdrs = elf_get_all_shdrs(elf, &ehdr, &count);
+		if (shdrs == NULL)
+			goto out_elf_end;
+
+		/*
+		 * Only keep the headers if they reflect the actual run-time
+		 * image's file layout:
+		 */
+		if (elf_check_shdrs_valid(shdrs, count)) {
+			*saved_shdrs = shdrs;
+			*saved_shdrs_count = count;
+		} else
+			free(shdrs);
+	}
+
+	/*
+	 * If no genuine ELF headers are available yet, give up: we can't
+	 * adjust symbols correctly in that case:
+	 */
+	if (saved_shdrs != NULL && *saved_shdrs == NULL)
+		goto out_elf_end;
+
 	sec = elf_section_by_name(elf, &ehdr, &shdr, ".symtab", NULL);
 	if (sec == NULL) {
 		if (want_symtab)
@@ -1344,12 +1482,25 @@ static int dso__load_sym(struct dso *dso, struct map *map, const char *name,
 			goto new_symbol;
 		}
 
+		/*
+		 * Currently, symbols for shared objects and PIE executables
+		 * (i.e., ET_DYN) do not seem to get adjusted.  This might need
+		 * to change if file offset == virtual address is not actually
+		 * guaranteed for these images.  ELF doesn't provide this
+		 * guarantee natively.
+		 */
 		if (curr_dso->adjust_symbols) {
 			pr_debug4("%s: adjusting symbol: st_value: %#" PRIx64 " "
 				  "sh_addr: %#" PRIx64 " sh_offset: %#" PRIx64 "\n", __func__,
 				  (u64)sym.st_value, (u64)shdr.sh_addr,
 				  (u64)shdr.sh_offset);
-			sym.st_value -= shdr.sh_addr - shdr.sh_offset;
+			if (saved_shdrs && *saved_shdrs &&
+			    sym.st_shndx < *saved_shdrs_count)
+				sym.st_value -=
+					(*saved_shdrs)[sym.st_shndx].sh_addr -
+					(*saved_shdrs)[sym.st_shndx].sh_offset;
+			else
+				sym.st_value -= shdr.sh_addr - shdr.sh_offset;
 		}
 		/*
 		 * We need to figure out if the object was created from C++ sources
@@ -1590,6 +1741,8 @@ int dso__load(struct dso *dso, struct map *map, symbol_filter_t filter)
 	struct machine *machine;
 	const char *root_dir;
 	int want_symtab;
+	GElf_Shdr *saved_shdrs = NULL;
+	unsigned saved_shdrs_count;
 
 	dso__set_loaded(dso, map->type);
 
@@ -1692,6 +1845,7 @@ restart:
 			continue;
 
 		ret = dso__load_sym(dso, map, name, fd, filter, 0,
+				    &saved_shdrs, &saved_shdrs_count,
 				    want_symtab);
 		close(fd);
 
@@ -1713,14 +1867,19 @@ restart:
 
 	/*
 	 * If we wanted a full symtab but no image had one,
-	 * relax our requirements and repeat the search.
+	 * relax our requirements and repeat the search,
+	 * provided we saw some valid section headers:
 	 */
-	if (ret <= 0 && want_symtab) {
+	if (ret <= 0 && want_symtab && saved_shdrs != NULL) {
 		want_symtab = 0;
 		goto restart;
 	}
 
 	free(name);
+
+	if (saved_shdrs)
+		free(saved_shdrs);
+
 	if (ret < 0 && strstr(dso->name, " (deleted)") != NULL)
 		return 0;
 	return ret;
@@ -1989,7 +2148,8 @@ int dso__load_vmlinux(struct dso *dso, struct map *map,
 
 	dso__set_long_name(dso, (char *)vmlinux);
 	dso__set_loaded(dso, map->type);
-	err = dso__load_sym(dso, map, symfs_vmlinux, fd, filter, 0, 0);
+	err = dso__load_sym(dso, map, symfs_vmlinux, fd, filter, 0,
+			    NULL, NULL, 0);
 	close(fd);
 
 	if (err > 0)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
