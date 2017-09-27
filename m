Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D74256B025E
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 13:45:12 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id d6so16811306wrd.7
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 10:45:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 31si511535eds.41.2017.09.27.10.45.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 10:45:10 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8RHhxsG072204
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 13:45:09 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2d8gdgrvvy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 13:45:09 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 27 Sep 2017 18:45:07 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH 1/3] lsmem/chmem: add memory zone awareness
Date: Wed, 27 Sep 2017 19:44:44 +0200
In-Reply-To: <20170927174446.20459-1-gerald.schaefer@de.ibm.com>
References: <20170927174446.20459-1-gerald.schaefer@de.ibm.com>
Message-Id: <20170927174446.20459-2-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: util-linux@vger.kernel.org, Karel Zak <kzak@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andre Wild <wild@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

With this patch, valid memory zones can be shown with lsmem, and chmem can
set memory online/offline in a specific memory zone, if allowed by the
kernel. The valid memory zones are read from the "valid_zones" sysfs
attribute, and setting memory online to a specific zone is done by
echoing "online_kernel" or "online_movable" to the "state" sysfs
attribute, in addition to the previous "online".

This patch also changes the default behavior of chmem, when setting memory
online without specifying a memory zone. If valid, memory will be set
online to the zone Movable. This zone is preferable for memory hotplug, as
it makes memory offline much more likely to succeed.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 sys-utils/chmem.8 |  19 ++++++++
 sys-utils/chmem.c | 136 ++++++++++++++++++++++++++++++++++++++++++++++++++----
 sys-utils/lsmem.1 |   4 +-
 sys-utils/lsmem.c |  98 ++++++++++++++++++++++++++++++++++++++-
 4 files changed, 246 insertions(+), 11 deletions(-)

diff --git a/sys-utils/chmem.8 b/sys-utils/chmem.8
index a116bc9e7a4b..dae7413d4899 100644
--- a/sys-utils/chmem.8
+++ b/sys-utils/chmem.8
@@ -5,6 +5,7 @@ chmem \- configure memory
 .B chmem
 .RB [ \-h "] [" \-V "] [" \-v "] [" \-e | \-d "]"
 [\fISIZE\fP|\fIRANGE\fP|\fB\-b\fP \fIBLOCKRANGE\fP]
+[-z ZONE]
 .SH DESCRIPTION
 The chmem command sets a particular size or range of memory online or offline.
 .
@@ -25,6 +26,19 @@ and <last> is the number of the last memory block in the memory
 range. Alternatively a single block can be specified. \fIBLOCKRANGE\fP requires
 the \fB--blocks\fP option.
 .
+.IP "\(hy" 2
+Specify \fIZONE\fP as the name of a memory zone, as shown in the output of the
+\fBlsmem -o +ZONES\fP command. The output shows one or more valid memory zones
+for each memory range. If multiple zones are shown, then the memory range
+currently belongs to the first zone. By default, chmem will set memory online
+to the zone Movable, if this is among the valid zones. This default can be
+changed by specifying the \fB--zone\fP option with another valid zone.
+For memory ballooning, it is recommended to select the zone Movable for memory
+online and offline, if possible. Memory in this zone is much more likely to be
+able to be offlined again, but it cannot be used for arbitrary kernel
+allocations, only for migratable pages (e.g. anonymous and page cache pages).
+Use the \fB\-\-help\fR option to see all available zones.
+.
 .PP
 \fISIZE\fP and \fIRANGE\fP must be aligned to the Linux memory block size, as
 shown in the output of the \fBlsmem\fP command.
@@ -51,6 +65,11 @@ Set the specified \fIRANGE\fP, \fISIZE\fP, or \fIBLOCKRANGE\fP of memory offline
 .BR \-e ", " \-\-enable
 Set the specified \fIRANGE\fP, \fISIZE\fP, or \fIBLOCKRANGE\fP of memory online.
 .TP
+.BR \-z ", " \-\-zone
+Select the memory \fIZONE\fP where to set the specified \fIRANGE\fP, \fISIZE\fP,
+or \fIBLOCKRANGE\fP of memory online or offline. By default, memory will be set
+online to the zone Movable, if possible.
+.TP
 .BR \-h ", " \-\-help
 Print a short help text, then exit.
 .TP
diff --git a/sys-utils/chmem.c b/sys-utils/chmem.c
index d9bc95cc191a..2f0680de8750 100644
--- a/sys-utils/chmem.c
+++ b/sys-utils/chmem.c
@@ -49,6 +49,7 @@ struct chmem_desc {
 	unsigned int	use_blocks : 1;
 	unsigned int	is_size	   : 1;
 	unsigned int	verbose	   : 1;
+	unsigned int	have_zones : 1;
 };
 
 enum {
@@ -57,6 +58,38 @@ enum {
 	CMD_NONE
 };
 
+enum zone_id {
+	ZONE_DMA = 0,
+	ZONE_DMA32,
+	ZONE_NORMAL,
+	ZONE_HIGHMEM,
+	ZONE_MOVABLE,
+	ZONE_DEVICE,
+};
+
+static char *zone_names[] = {
+	[ZONE_DMA]	= "DMA",
+	[ZONE_DMA32]	= "DMA32",
+	[ZONE_NORMAL]	= "Normal",
+	[ZONE_HIGHMEM]	= "Highmem",
+	[ZONE_MOVABLE]	= "Movable",
+	[ZONE_DEVICE]	= "Device",
+};
+
+/*
+ * name must be null-terminated
+ */
+static int zone_name_to_id(const char *name)
+{
+	size_t i;
+
+	for (i = 0; i < ARRAY_SIZE(zone_names); i++) {
+		if (!strcasecmp(name, zone_names[i]))
+			return i;
+	}
+	return -1;
+}
+
 static void idxtostr(struct chmem_desc *desc, uint64_t idx, char *buf, size_t bufsz)
 {
 	uint64_t start, end;
@@ -68,22 +101,49 @@ static void idxtostr(struct chmem_desc *desc, uint64_t idx, char *buf, size_t bu
 		 idx, start, end);
 }
 
-static int chmem_size(struct chmem_desc *desc, int enable)
+static int chmem_size(struct chmem_desc *desc, int enable, int zone_id)
 {
 	char *name, *onoff, line[BUFSIZ], str[BUFSIZ];
 	uint64_t size, index;
+	const char *zn;
 	int i, rc;
 
 	size = desc->size;
 	onoff = enable ? "online" : "offline";
 	i = enable ? 0 : desc->ndirs - 1;
 
+	if (enable && zone_id >= 0) {
+		if (zone_id == ZONE_MOVABLE)
+			onoff = "online_movable";
+		else
+			onoff = "online_kernel";
+	}
+
 	for (; i >= 0 && i < desc->ndirs && size; i += enable ? 1 : -1) {
 		name = desc->dirs[i]->d_name;
 		index = strtou64_or_err(name + 6, _("Failed to parse index"));
 		path_read_str(line, sizeof(line), _PATH_SYS_MEMORY "/%s/state", name);
-		if (strcmp(onoff, line) == 0)
+		if (strncmp(onoff, line, 6) == 0)
 			continue;
+
+		if (desc->have_zones) {
+			path_read_str(line, sizeof(line),
+				      _PATH_SYS_MEMORY "/%s/valid_zones", name);
+			if (zone_id >= 0) {
+				zn = zone_names[zone_id];
+				if (enable && !strcasestr(line, zn))
+					continue;
+				if (!enable && strncasecmp(line, zn, strlen(zn)))
+					continue;
+			} else if (enable) {
+				/* By default, use zone Movable for online, if valid */
+				if (strcasestr(line, zone_names[ZONE_MOVABLE]))
+					onoff = "online_movable";
+				else
+					onoff = "online";
+			}
+		}
+
 		idxtostr(desc, index, str, sizeof(str));
 		rc = path_write_str(onoff, _PATH_SYS_MEMORY"/%s/state", name);
 		if (rc == -1 && desc->verbose) {
@@ -115,15 +175,23 @@ static int chmem_size(struct chmem_desc *desc, int enable)
 	return size == 0 ? 0 : size == desc->size ? -1 : 1;
 }
 
-static int chmem_range(struct chmem_desc *desc, int enable)
+static int chmem_range(struct chmem_desc *desc, int enable, int zone_id)
 {
 	char *name, *onoff, line[BUFSIZ], str[BUFSIZ];
 	uint64_t index, todo;
+	const char *zn;
 	int i, rc;
 
 	todo = desc->end - desc->start + 1;
 	onoff = enable ? "online" : "offline";
 
+	if (enable && zone_id >= 0) {
+		if (zone_id == ZONE_MOVABLE)
+			onoff = "online_movable";
+		else
+			onoff = "online_kernel";
+	}
+
 	for (i = 0; i < desc->ndirs; i++) {
 		name = desc->dirs[i]->d_name;
 		index = strtou64_or_err(name + 6, _("Failed to parse index"));
@@ -133,7 +201,7 @@ static int chmem_range(struct chmem_desc *desc, int enable)
 			break;
 		idxtostr(desc, index, str, sizeof(str));
 		path_read_str(line, sizeof(line), _PATH_SYS_MEMORY "/%s/state", name);
-		if (strcmp(onoff, line) == 0) {
+		if (strncmp(onoff, line, 6) == 0) {
 			if (desc->verbose && enable)
 				fprintf(stdout, _("%s already enabled\n"), str);
 			else if (desc->verbose && !enable)
@@ -141,6 +209,29 @@ static int chmem_range(struct chmem_desc *desc, int enable)
 			todo--;
 			continue;
 		}
+
+		if (desc->have_zones) {
+			path_read_str(line, sizeof(line),
+				      _PATH_SYS_MEMORY "/%s/valid_zones", name);
+			if (zone_id >= 0) {
+				zn = zone_names[zone_id];
+				if (enable && !strcasestr(line, zn)) {
+					warnx(_("%s enable failed: Zone mismatch"), str);
+					continue;
+				}
+				if (!enable && strncasecmp(line, zn, strlen(zn))) {
+					warnx(_("%s disable failed: Zone mismatch"), str);
+					continue;
+				}
+			} else if (enable) {
+				/* By default, use zone Movable for online, if valid */
+				if (strcasestr(line, zone_names[ZONE_MOVABLE]))
+					onoff = "online_movable";
+				else
+					onoff = "online";
+			}
+		}
+
 		rc = path_write_str(onoff, _PATH_SYS_MEMORY"/%s/state", name);
 		if (rc == -1) {
 			if (enable)
@@ -237,6 +328,8 @@ static void parse_parameter(struct chmem_desc *desc, char *param)
 static void __attribute__((__noreturn__)) usage(void)
 {
 	FILE *out = stdout;
+	unsigned int i;
+
 	fputs(USAGE_HEADER, out);
 	fprintf(out, _(" %s [options] [SIZE|RANGE|BLOCKRANGE]\n"), program_invocation_short_name);
 
@@ -247,6 +340,14 @@ static void __attribute__((__noreturn__)) usage(void)
 	fputs(_(" -e, --enable   enable memory\n"), out);
 	fputs(_(" -d, --disable  disable memory\n"), out);
 	fputs(_(" -b, --blocks   use memory blocks\n"), out);
+	fputs(_(" -z, --zone     select memory zone ("), out);
+	for (i = 0; i < ARRAY_SIZE(zone_names); i++) {
+		fputs(zone_names[i], out);
+		if (i < ARRAY_SIZE(zone_names) - 1)
+			fputc('|', out);
+	}
+	fputs(")\n", out);
+
 	fputs(_(" -v, --verbose  verbose output\n"), out);
 	fputs(USAGE_SEPARATOR, out);
 	printf(USAGE_HELP_OPTIONS(16));
@@ -259,7 +360,8 @@ static void __attribute__((__noreturn__)) usage(void)
 int main(int argc, char **argv)
 {
 	struct chmem_desc _desc = { }, *desc = &_desc;
-	int cmd = CMD_NONE;
+	int cmd = CMD_NONE, zone_id = -1;
+	char *zone = NULL;
 	int c, rc;
 
 	static const struct option longopts[] = {
@@ -269,6 +371,7 @@ int main(int argc, char **argv)
 		{"help",	no_argument,		NULL, 'h'},
 		{"verbose",	no_argument,		NULL, 'v'},
 		{"version",	no_argument,		NULL, 'V'},
+		{"zone",	required_argument,	NULL, 'z'},
 		{NULL,		0,			NULL, 0}
 	};
 
@@ -285,7 +388,7 @@ int main(int argc, char **argv)
 
 	read_info(desc);
 
-	while ((c = getopt_long(argc, argv, "bdehvV", longopts, NULL)) != -1) {
+	while ((c = getopt_long(argc, argv, "bdehvVz:", longopts, NULL)) != -1) {
 
 		err_exclusive_options(c, longopts, excl, excl_st);
 
@@ -308,6 +411,9 @@ int main(int argc, char **argv)
 		case 'V':
 			printf(UTIL_LINUX_VERSION);
 			return EXIT_SUCCESS;
+		case 'z':
+			zone = xstrdup(optarg);
+			break;
 		default:
 			errtryhelp(EXIT_FAILURE);
 		}
@@ -320,10 +426,24 @@ int main(int argc, char **argv)
 
 	parse_parameter(desc, argv[optind]);
 
+	/* The valid_zones sysfs attribute was introduced with kernel 3.18 */
+	if (path_exist(_PATH_SYS_MEMORY "/memory0/valid_zones"))
+		desc->have_zones = 1;
+	else if (zone)
+		warnx(_("zone ignored, no valid_zones sysfs attribute present"));
+
+	if (zone && desc->have_zones) {
+		zone_id = zone_name_to_id(zone);
+		if (zone_id == -1) {
+			warnx(_("unknown memory zone: %s"), zone);
+			errtryhelp(EXIT_FAILURE);
+		}
+	}
+
 	if (desc->is_size)
-		rc = chmem_size(desc, cmd == CMD_MEMORY_ENABLE ? 1 : 0);
+		rc = chmem_size(desc, cmd == CMD_MEMORY_ENABLE ? 1 : 0, zone_id);
 	else
-		rc = chmem_range(desc, cmd == CMD_MEMORY_ENABLE ? 1 : 0);
+		rc = chmem_range(desc, cmd == CMD_MEMORY_ENABLE ? 1 : 0, zone_id);
 
 	return rc == 0 ? EXIT_SUCCESS :
 		rc < 0 ? EXIT_FAILURE : CHMEM_EXIT_SOMEOK;
diff --git a/sys-utils/lsmem.1 b/sys-utils/lsmem.1
index be2862d9476a..e7df50a4ebff 100644
--- a/sys-utils/lsmem.1
+++ b/sys-utils/lsmem.1
@@ -41,12 +41,12 @@ Do not print a header line.
 .BR \-o , " \-\-output " \fIlist\fP
 Specify which output columns to print.  Use \fB\-\-help\fR
 to get a list of all supported columns.
+The default list of columns may be extended if \fIlist\fP is
+specified in the format \fB+\fIlist\fP (e.g. \fBlsmem \-o +NODE\fP).
 .TP
 .BR \-P , " \-\-pairs"
 Produce output in the form of key="value" pairs.
 All potentially unsafe characters are hex-escaped (\\x<code>).
-The default list of columns may be extended if \fIlist\fP is
-specified in the format \fB+\fIlist\fP (e.g. \fBlsmem \-o +NODE\fP).
 .TP
 .BR \-r , " \-\-raw"
 Produce output in raw format.  All potentially unsafe characters are hex-escaped
diff --git a/sys-utils/lsmem.c b/sys-utils/lsmem.c
index aeffd29dd9f8..1d26579fd4c5 100644
--- a/sys-utils/lsmem.c
+++ b/sys-utils/lsmem.c
@@ -42,11 +42,25 @@
 #define MEMORY_STATE_GOING_OFFLINE	2
 #define MEMORY_STATE_UNKNOWN		3
 
+enum zone_id {
+	ZONE_DMA = 0,
+	ZONE_DMA32,
+	ZONE_NORMAL,
+	ZONE_HIGHMEM,
+	ZONE_MOVABLE,
+	ZONE_DEVICE,
+	ZONE_NONE,
+	ZONE_UNKNOWN,
+	MAX_NR_ZONES,
+};
+
 struct memory_block {
 	uint64_t	index;
 	uint64_t	count;
 	int		state;
 	int		node;
+	int		nr_zones;
+	int		zones[MAX_NR_ZONES];
 	unsigned int	removable:1;
 };
 
@@ -72,7 +86,9 @@ struct lsmem {
 				want_state : 1,
 				want_removable : 1,
 				want_summary : 1,
-				want_table : 1;
+				want_table : 1,
+				want_zones : 1,
+				have_zones : 1;
 };
 
 enum {
@@ -82,6 +98,18 @@ enum {
 	COL_REMOVABLE,
 	COL_BLOCK,
 	COL_NODE,
+	COL_ZONES,
+};
+
+static char *zone_names[] = {
+	[ZONE_DMA]	= "DMA",
+	[ZONE_DMA32]	= "DMA32",
+	[ZONE_NORMAL]	= "Normal",
+	[ZONE_HIGHMEM]	= "Highmem",
+	[ZONE_MOVABLE]	= "Movable",
+	[ZONE_DEVICE]	= "Device",
+	[ZONE_NONE]	= "None",	/* block contains more than one zone, can't be offlined */
+	[ZONE_UNKNOWN]	= "Unknown",
 };
 
 /* column names */
@@ -102,6 +130,7 @@ static struct coldesc coldescs[] = {
 	[COL_REMOVABLE]	= { "REMOVABLE", 0, SCOLS_FL_RIGHT, N_("memory is removable")},
 	[COL_BLOCK]	= { "BLOCK", 0, SCOLS_FL_RIGHT, N_("memory block number or blocks range")},
 	[COL_NODE]	= { "NODE", 0, SCOLS_FL_RIGHT, N_("numa node of memory")},
+	[COL_ZONES]	= { "ZONES", 0, SCOLS_FL_RIGHT, N_("valid zones for the memory range")},
 };
 
 /* columns[] array specifies all currently wanted output column. The columns
@@ -120,6 +149,20 @@ static inline size_t err_columns_index(size_t arysz, size_t idx)
 	return idx;
 }
 
+/*
+ * name must be null-terminated
+ */
+static int zone_name_to_id(const char *name)
+{
+	size_t i;
+
+	for (i = 0; i < ARRAY_SIZE(zone_names); i++) {
+		if (!strcasecmp(name, zone_names[i]))
+			return i;
+	}
+	return ZONE_UNKNOWN;
+}
+
 #define add_column(ary, n, id)	\
 		((ary)[ err_columns_index(ARRAY_SIZE(ary), (n)) ] = (id))
 
@@ -214,6 +257,25 @@ static void add_scols_line(struct lsmem *lsmem, struct memory_block *blk)
 			else
 				str = xstrdup("-");
 			break;
+		case COL_ZONES:
+			if (lsmem->have_zones) {
+				char valid_zones[BUFSIZ];
+				int j, zone_id;
+
+				valid_zones[0] = '\0';
+				for (j = 0; j < blk->nr_zones; j++) {
+					zone_id = blk->zones[j];
+					if (strlen(valid_zones) +
+					    strlen(zone_names[zone_id]) > BUFSIZ - 2)
+						break;
+					strcat(valid_zones, zone_names[zone_id]);
+					if (j + 1 < blk->nr_zones)
+						strcat(valid_zones, "/");
+				}
+				str = xstrdup(valid_zones);
+			} else
+				str = xstrdup("-");
+			break;
 		}
 
 		if (str && scols_line_refer_data(line, i, str) != 0)
@@ -272,7 +334,9 @@ static int memory_block_get_node(char *name)
 static void memory_block_read_attrs(struct lsmem *lsmem, char *name,
 				    struct memory_block *blk)
 {
+	char *token = NULL;
 	char line[BUFSIZ];
+	int i;
 
 	blk->count = 1;
 	blk->index = strtoumax(name + 6, NULL, 10); /* get <num> of "memory<num>" */
@@ -287,11 +351,26 @@ static void memory_block_read_attrs(struct lsmem *lsmem, char *name,
 		blk->state = MEMORY_STATE_GOING_OFFLINE;
 	if (lsmem->have_nodes)
 		blk->node = memory_block_get_node(name);
+
+	blk->nr_zones = 0;
+	if (lsmem->have_zones) {
+		path_read_str(line, sizeof(line), _PATH_SYS_MEMORY"/%s/%s", name,
+			      "valid_zones");
+		token = strtok(line, " ");
+	}
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		if (token) {
+			blk->zones[i] = zone_name_to_id(token);
+			blk->nr_zones++;
+			token = strtok(NULL, " ");
+		}
+	}
 }
 
 static int is_mergeable(struct lsmem *lsmem, struct memory_block *blk)
 {
 	struct memory_block *curr;
+	int i;
 
 	if (!lsmem->nblocks)
 		return 0;
@@ -308,6 +387,15 @@ static int is_mergeable(struct lsmem *lsmem, struct memory_block *blk)
 		if (curr->node != blk->node)
 			return 0;
 	}
+	if (lsmem->want_zones && lsmem->have_zones) {
+		if (curr->nr_zones != blk->nr_zones)
+			return 0;
+		for (i = 0; i < curr->nr_zones; i++) {
+			if (curr->zones[i] == ZONE_UNKNOWN ||
+			    curr->zones[i] != blk->zones[i])
+				return 0;
+		}
+	}
 	return 1;
 }
 
@@ -362,6 +450,12 @@ static void read_basic_info(struct lsmem *lsmem)
 
 	if (memory_block_get_node(lsmem->dirs[0]->d_name) != -1)
 		lsmem->have_nodes = 1;
+
+	/* The valid_zones sysfs attribute was introduced with kernel 3.18 */
+	if (path_exist(_PATH_SYS_MEMORY "/memory0/valid_zones"))
+		lsmem->have_zones = 1;
+	else if (lsmem->want_zones)
+		warnx(_("Cannot read zones, no valid_zones sysfs attribute present"));
 }
 
 static void __attribute__((__noreturn__)) usage(void)
@@ -553,6 +647,8 @@ int main(int argc, char **argv)
 		lsmem->want_node = 1;
 	if (has_column(COL_REMOVABLE))
 		lsmem->want_removable = 1;
+	if (has_column(COL_ZONES))
+		lsmem->want_zones = 1;
 
 	/*
 	 * Read data and print output
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
