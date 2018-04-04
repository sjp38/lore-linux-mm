Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B07EF6B000A
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 04:29:39 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id n7so10856805wrb.0
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 01:29:39 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u17si1356262edf.290.2018.04.04.01.29.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 01:29:38 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w348T76Y004189
	for <linux-mm@kvack.org>; Wed, 4 Apr 2018 04:29:37 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h4swkbv3e-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Apr 2018 04:29:36 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Wed, 4 Apr 2018 09:29:34 +0100
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Subject: [PATCH v2 9/9] perf probe: Support SDT markers having reference counter (semaphore)
Date: Wed,  4 Apr 2018 14:01:10 +0530
In-Reply-To: <20180404083110.18647-1-ravi.bangoria@linux.vnet.ibm.com>
References: <20180404083110.18647-1-ravi.bangoria@linux.vnet.ibm.com>
Message-Id: <20180404083110.18647-10-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org
Cc: acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>

With this, perf buildid-cache will save SDT markers with reference
counter in probe cache. Perf probe will be able to probe markers
having reference counter. Ex,

  # readelf -n /tmp/tick | grep -A1 loop2
    Name: loop2
    ... Semaphore: 0x0000000010020036

  # ./perf buildid-cache --add /tmp/tick
  # ./perf probe sdt_tick:loop2
  # ./perf stat -e sdt_tick:loop2 /tmp/tick
    hi: 0
    hi: 1
    hi: 2
    ^C
     Performance counter stats for '/tmp/tick':
                 3      sdt_tick:loop2
       2.561851452 seconds time elapsed

Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
---
 tools/perf/util/probe-event.c | 18 ++++++++++++++---
 tools/perf/util/probe-event.h |  1 +
 tools/perf/util/probe-file.c  | 34 ++++++++++++++++++++++++++------
 tools/perf/util/probe-file.h  |  1 +
 tools/perf/util/symbol-elf.c  | 46 ++++++++++++++++++++++++++++++++-----------
 tools/perf/util/symbol.h      |  7 +++++++
 6 files changed, 86 insertions(+), 21 deletions(-)

diff --git a/tools/perf/util/probe-event.c b/tools/perf/util/probe-event.c
index e1dbc98..b3a1330 100644
--- a/tools/perf/util/probe-event.c
+++ b/tools/perf/util/probe-event.c
@@ -1832,6 +1832,12 @@ int parse_probe_trace_command(const char *cmd, struct probe_trace_event *tev)
 			tp->offset = strtoul(fmt2_str, NULL, 10);
 	}
 
+	if (tev->uprobes) {
+		fmt2_str = strchr(p, '(');
+		if (fmt2_str)
+			tp->ref_ctr_offset = strtoul(fmt2_str + 1, NULL, 0);
+	}
+
 	tev->nargs = argc - 2;
 	tev->args = zalloc(sizeof(struct probe_trace_arg) * tev->nargs);
 	if (tev->args == NULL) {
@@ -2054,15 +2060,21 @@ char *synthesize_probe_trace_command(struct probe_trace_event *tev)
 	}
 
 	/* Use the tp->address for uprobes */
-	if (tev->uprobes)
+	if (tev->uprobes) {
 		err = strbuf_addf(&buf, "%s:0x%lx", tp->module, tp->address);
-	else if (!strncmp(tp->symbol, "0x", 2))
+		if (uprobe_ref_ctr_is_supported() &&
+		    tp->ref_ctr_offset &&
+		    err >= 0)
+			err = strbuf_addf(&buf, "(0x%lx)", tp->ref_ctr_offset);
+	} else if (!strncmp(tp->symbol, "0x", 2)) {
 		/* Absolute address. See try_to_find_absolute_address() */
 		err = strbuf_addf(&buf, "%s%s0x%lx", tp->module ?: "",
 				  tp->module ? ":" : "", tp->address);
-	else
+	} else {
 		err = strbuf_addf(&buf, "%s%s%s+%lu", tp->module ?: "",
 				tp->module ? ":" : "", tp->symbol, tp->offset);
+	}
+
 	if (err)
 		goto error;
 
diff --git a/tools/perf/util/probe-event.h b/tools/perf/util/probe-event.h
index 45b14f0..15a98c3 100644
--- a/tools/perf/util/probe-event.h
+++ b/tools/perf/util/probe-event.h
@@ -27,6 +27,7 @@ struct probe_trace_point {
 	char		*symbol;	/* Base symbol */
 	char		*module;	/* Module name */
 	unsigned long	offset;		/* Offset from symbol */
+	unsigned long	ref_ctr_offset;	/* SDT reference counter offset */
 	unsigned long	address;	/* Actual address of the trace point */
 	bool		retprobe;	/* Return probe flag */
 };
diff --git a/tools/perf/util/probe-file.c b/tools/perf/util/probe-file.c
index 4ae1123..ca0e524 100644
--- a/tools/perf/util/probe-file.c
+++ b/tools/perf/util/probe-file.c
@@ -697,8 +697,16 @@ int probe_cache__add_entry(struct probe_cache *pcache,
 #ifdef HAVE_GELF_GETNOTE_SUPPORT
 static unsigned long long sdt_note__get_addr(struct sdt_note *note)
 {
-	return note->bit32 ? (unsigned long long)note->addr.a32[0]
-		 : (unsigned long long)note->addr.a64[0];
+	return note->bit32 ?
+		(unsigned long long)note->addr.a32[SDT_NOTE_IDX_LOC] :
+		(unsigned long long)note->addr.a64[SDT_NOTE_IDX_LOC];
+}
+
+static unsigned long long sdt_note__get_ref_ctr_offset(struct sdt_note *note)
+{
+	return note->bit32 ?
+		(unsigned long long)note->addr.a32[SDT_NOTE_IDX_REFCTR] :
+		(unsigned long long)note->addr.a64[SDT_NOTE_IDX_REFCTR];
 }
 
 static const char * const type_to_suffix[] = {
@@ -776,14 +784,21 @@ static char *synthesize_sdt_probe_command(struct sdt_note *note,
 {
 	struct strbuf buf;
 	char *ret = NULL, **args;
-	int i, args_count;
+	int i, args_count, err;
+	unsigned long long ref_ctr_offset;
 
 	if (strbuf_init(&buf, 32) < 0)
 		return NULL;
 
-	if (strbuf_addf(&buf, "p:%s/%s %s:0x%llx",
-				sdtgrp, note->name, pathname,
-				sdt_note__get_addr(note)) < 0)
+	err = strbuf_addf(&buf, "p:%s/%s %s:0x%llx",
+			sdtgrp, note->name, pathname,
+			sdt_note__get_addr(note));
+
+	ref_ctr_offset = sdt_note__get_ref_ctr_offset(note);
+	if (uprobe_ref_ctr_is_supported() && ref_ctr_offset && err >= 0)
+		err = strbuf_addf(&buf, "(0x%llx)", ref_ctr_offset);
+
+	if (err < 0)
 		goto error;
 
 	if (!note->args)
@@ -999,6 +1014,7 @@ int probe_cache__show_all_caches(struct strfilter *filter)
 enum ftrace_readme {
 	FTRACE_README_PROBE_TYPE_X = 0,
 	FTRACE_README_KRETPROBE_OFFSET,
+	FTRACE_README_UPROBE_REF_CTR,
 	FTRACE_README_END,
 };
 
@@ -1010,6 +1026,7 @@ enum ftrace_readme {
 	[idx] = {.pattern = pat, .avail = false}
 	DEFINE_TYPE(FTRACE_README_PROBE_TYPE_X, "*type: * x8/16/32/64,*"),
 	DEFINE_TYPE(FTRACE_README_KRETPROBE_OFFSET, "*place (kretprobe): *"),
+	DEFINE_TYPE(FTRACE_README_UPROBE_REF_CTR, "*ref_ctr_offset*"),
 };
 
 static bool scan_ftrace_readme(enum ftrace_readme type)
@@ -1065,3 +1082,8 @@ bool kretprobe_offset_is_supported(void)
 {
 	return scan_ftrace_readme(FTRACE_README_KRETPROBE_OFFSET);
 }
+
+bool uprobe_ref_ctr_is_supported(void)
+{
+	return scan_ftrace_readme(FTRACE_README_UPROBE_REF_CTR);
+}
diff --git a/tools/perf/util/probe-file.h b/tools/perf/util/probe-file.h
index 63f29b1..2a24918 100644
--- a/tools/perf/util/probe-file.h
+++ b/tools/perf/util/probe-file.h
@@ -69,6 +69,7 @@ struct probe_cache_entry *probe_cache__find_by_name(struct probe_cache *pcache,
 int probe_cache__show_all_caches(struct strfilter *filter);
 bool probe_type_is_available(enum probe_type type);
 bool kretprobe_offset_is_supported(void);
+bool uprobe_ref_ctr_is_supported(void);
 #else	/* ! HAVE_LIBELF_SUPPORT */
 static inline struct probe_cache *probe_cache__new(const char *tgt __maybe_unused, struct nsinfo *nsi __maybe_unused)
 {
diff --git a/tools/perf/util/symbol-elf.c b/tools/perf/util/symbol-elf.c
index 2de7705..45b7dba 100644
--- a/tools/perf/util/symbol-elf.c
+++ b/tools/perf/util/symbol-elf.c
@@ -1803,6 +1803,34 @@ void kcore_extract__delete(struct kcore_extract *kce)
 }
 
 #ifdef HAVE_GELF_GETNOTE_SUPPORT
+
+static void sdt_adjust_loc(struct sdt_note *tmp, GElf_Addr base_off)
+{
+	if (!base_off)
+		return;
+
+	if (tmp->bit32)
+		tmp->addr.a32[SDT_NOTE_IDX_LOC] =
+			tmp->addr.a32[SDT_NOTE_IDX_LOC] + base_off -
+			tmp->addr.a32[SDT_NOTE_IDX_BASE];
+	else
+		tmp->addr.a64[SDT_NOTE_IDX_LOC] =
+			tmp->addr.a64[SDT_NOTE_IDX_LOC] + base_off -
+			tmp->addr.a64[SDT_NOTE_IDX_BASE];
+}
+
+static void sdt_adjust_refctr(struct sdt_note *tmp, GElf_Addr base_addr,
+			      GElf_Addr base_off)
+{
+	if (!base_off)
+		return;
+
+	if (tmp->bit32)
+		tmp->addr.a32[SDT_NOTE_IDX_REFCTR] -= (base_addr - base_off);
+	else
+		tmp->addr.a64[SDT_NOTE_IDX_REFCTR] -= (base_addr - base_off);
+}
+
 /**
  * populate_sdt_note : Parse raw data and identify SDT note
  * @elf: elf of the opened file
@@ -1820,7 +1848,6 @@ static int populate_sdt_note(Elf **elf, const char *data, size_t len,
 	const char *provider, *name, *args;
 	struct sdt_note *tmp = NULL;
 	GElf_Ehdr ehdr;
-	GElf_Addr base_off = 0;
 	GElf_Shdr shdr;
 	int ret = -EINVAL;
 
@@ -1916,17 +1943,12 @@ static int populate_sdt_note(Elf **elf, const char *data, size_t len,
 	 * base address in the description of the SDT note. If its different,
 	 * then accordingly, adjust the note location.
 	 */
-	if (elf_section_by_name(*elf, &ehdr, &shdr, SDT_BASE_SCN, NULL)) {
-		base_off = shdr.sh_offset;
-		if (base_off) {
-			if (tmp->bit32)
-				tmp->addr.a32[0] = tmp->addr.a32[0] + base_off -
-					tmp->addr.a32[1];
-			else
-				tmp->addr.a64[0] = tmp->addr.a64[0] + base_off -
-					tmp->addr.a64[1];
-		}
-	}
+	if (elf_section_by_name(*elf, &ehdr, &shdr, SDT_BASE_SCN, NULL))
+		sdt_adjust_loc(tmp, shdr.sh_offset);
+
+	/* Adjust reference counter offset */
+	if (elf_section_by_name(*elf, &ehdr, &shdr, SDT_PROBES_SCN, NULL))
+		sdt_adjust_refctr(tmp, shdr.sh_addr, shdr.sh_offset);
 
 	list_add_tail(&tmp->note_list, sdt_notes);
 	return 0;
diff --git a/tools/perf/util/symbol.h b/tools/perf/util/symbol.h
index 70c16741..aa095bf 100644
--- a/tools/perf/util/symbol.h
+++ b/tools/perf/util/symbol.h
@@ -384,12 +384,19 @@ struct sdt_note {
 int cleanup_sdt_note_list(struct list_head *sdt_notes);
 int sdt_notes__get_count(struct list_head *start);
 
+#define SDT_PROBES_SCN ".probes"
 #define SDT_BASE_SCN ".stapsdt.base"
 #define SDT_NOTE_SCN  ".note.stapsdt"
 #define SDT_NOTE_TYPE 3
 #define SDT_NOTE_NAME "stapsdt"
 #define NR_ADDR 3
 
+enum {
+	SDT_NOTE_IDX_LOC = 0,
+	SDT_NOTE_IDX_BASE,
+	SDT_NOTE_IDX_REFCTR,
+};
+
 struct mem_info *mem_info__new(void);
 struct mem_info *mem_info__get(struct mem_info *mi);
 void   mem_info__put(struct mem_info *mi);
-- 
1.8.3.1
