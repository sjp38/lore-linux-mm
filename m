From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070410032932.18967.89137.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070410032912.18967.67076.sendpatchset@schroedinger.engr.sgi.com>
References: <20070410032912.18967.67076.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 5/5] Update slabinfo.c
Date: Mon,  9 Apr 2007 20:29:32 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Update slabinfo

This adds a lot of new functionality including display of NUMA information,
tracking information, slab verification etc. Some of those will only be
supported in V7.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 Documentation/vm/slabinfo.c |  184 +++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 167 insertions(+), 17 deletions(-)

Index: linux-2.6.21-rc6-mm1/Documentation/vm/slabinfo.c
===================================================================
--- linux-2.6.21-rc6-mm1.orig/Documentation/vm/slabinfo.c	2007-04-09 20:11:01.000000000 -0700
+++ linux-2.6.21-rc6-mm1/Documentation/vm/slabinfo.c	2007-04-09 20:23:50.000000000 -0700
@@ -14,16 +14,23 @@
 #include <string.h>
 #include <unistd.h>
 #include <stdarg.h>
+#include <getopt.h>
+#include <regex.h>
 
-char buffer[200];
+char buffer[4096];
 
 int show_alias = 0;
-int show_slab = 1;
-int show_parameter = 0;
+int show_slab = 0;
+int show_parameters = 0;
 int skip_zero = 1;
+int show_numa = 0;
+int show_track = 0;
+int validate = 0;
 
 int page_size;
 
+regex_t pattern;
+
 void fatal(const char *x, ...)
 {
 	va_list ap;
@@ -34,23 +41,71 @@ void fatal(const char *x, ...)
 	exit(1);
 }
 
+void usage(void)
+{
+	printf("slabinfo [-ahnpvtsz] [slab-regexp]\n"
+		"-a|--aliases           Show aliases\n"
+		"-h|--help              Show usage information\n"
+		"-n|--numa              Show NUMA information\n"
+		"-p|--parameters        Show global parameters\n"
+		"-v|--validate          Validate slabs\n"
+		"-t|--tracking          Show alloc/free information\n"
+		"-s|--slabs             Show slabs\n"
+		"-z|--zero              Include empty slabs\n"
+	);
+}
+
+unsigned long read_obj(char *name)
+{
+	FILE *f = fopen(name, "r");
+
+	if (!f)
+		buffer[0] = 0;
+	else {
+		if (!fgets(buffer,sizeof(buffer), f))
+			buffer[0] = 0;
+		fclose(f);
+		if (buffer[strlen(buffer)] == '\n')
+			buffer[strlen(buffer)] = 0;
+	}
+	return strlen(buffer);
+}
+
+
 /*
  * Get the contents of an attribute
  */
 unsigned long get_obj(char *name)
 {
-	FILE *f = fopen(name, "r");
+	if (!read_obj(name))
+		return 0;
+
+	return atol(buffer);
+}
+
+unsigned long get_obj_and_str(char *name, char **x)
+{
 	unsigned long result = 0;
 
-	if (!f) {
-		getcwd(buffer, sizeof(buffer));
-		fatal("Cannot open file '%s/%s'\n", buffer, name);
+	if (!read_obj(name)) {
+		x = NULL;
+		return 0;
 	}
+	result = strtoul(buffer, x, 10);
+	while (**x == ' ')
+		(*x)++;
+	return result;
+}
+
+void set_obj(char *name, int n)
+{
+	FILE *f = fopen(name, "w");
 
-	if (fgets(buffer,sizeof(buffer), f))
-		result = atol(buffer);
+	if (!f)
+		fatal("Cannot write to %s\n", name);
+
+	fprintf(f, "%d\n", n);
 	fclose(f);
-	return result;
 }
 
 /*
@@ -90,12 +145,29 @@ int store_size(char *buffer, unsigned lo
 
 void alias(const char *name)
 {
-	char *target;
+	int count;
+	char *p;
 
 	if (!show_alias)
 		return;
-	/* Read link target */
-	printf("%20s -> %s", name, target);
+
+	count = readlink(name, buffer, sizeof(buffer));
+
+	if (count < 0)
+		return;
+
+	buffer[count] = 0;
+
+	p = buffer + count;
+
+	while (p > buffer && p[-1] != '/')
+		p--;
+	printf("%-20s -> %s\n", name, p);
+}
+
+void slab_validate(char *name)
+{
+	set_obj("validate", 1);
 }
 
 int line = 0;
@@ -120,9 +192,6 @@ void slab(const char *name)
 	if (!show_slab)
 		return;
 
-	if (chdir(name))
-		fatal("Unable to access slab %s\n", name);
-
 	aliases = get_obj("aliases");
 	align = get_obj("align");
 	cache_dma = get_obj("cache_dma");
@@ -144,7 +213,7 @@ void slab(const char *name)
 	trace = get_obj("trace");
 
 	if (skip_zero && !slabs)
-		goto out;
+		return;
 
 	store_size(size_str, slabs * page_size);
 	sprintf(dist_str,"%lu/%lu/%lu", slabs, partial, cpu_slabs);
@@ -172,41 +241,147 @@ void slab(const char *name)
 		*p++ = 'T';
 
 	*p = 0;
-	printf("%-20s %8ld %7d %8s %14s %3ld %1ld %3d %3d %s\n",
+	printf("%-20s %8ld %7ld %8s %14s %3ld %1ld %3ld %3ld %s\n",
 			name, objects, object_size, size_str, dist_str,
 			objs_per_slab, order,
 			slabs ? (partial * 100) / slabs : 100,
-			slabs ? (objects * object_size * 100) / (slabs * (page_size << order)) : 100,
+			slabs ? (objects * object_size * 100) /
+				(slabs * (page_size << order)) : 100,
 			flags);
-out:
-	chdir("..");
+}
+
+void slab_numa(const char *name)
+{
+	unsigned long slabs;
+	char *numainfo;
+
+	slabs = get_obj_and_str("slabs", &numainfo);
+
+	if (skip_zero && !slabs)
+		return;
+
+	printf("%-20s %s", name, numainfo);
 }
 
 void parameter(const char *name)
 {
-	if (!show_parameter)
+	if (!show_parameters)
 		return;
 }
 
+void show_tracking(const char *name)
+{
+	printf("\n%s: Calls to allocate a slab object\n", name);
+	printf("---------------------------------------------------\n");
+	if (read_obj("alloc_calls"))
+		printf(buffer);
+
+	printf("%s: Calls to free a slab object\n", name);
+	printf("-----------------------------------------------\n");
+	if (read_obj("free_calls"))
+		printf(buffer);
+
+}
+
+int slab_mismatch(char *slab)
+{
+	return regexec(&pattern, slab, 0, NULL, 0);
+}
+
+struct option opts[] = {
+	{ "aliases", 0, NULL, 'a' },
+	{ "slabs", 0, NULL, 's' },
+	{ "numa", 0, NULL, 'n' },
+	{ "parameters", 0, NULL, 'p' },
+	{ "zero", 0, NULL, 'z' },
+	{ "help", 0, NULL, 'h' },
+	{ "validate", 0, NULL, 'v' },
+	{ "track", 0, NULL, 't'},
+	{ NULL, 0, NULL, 0 }
+};
+
 int main(int argc, char *argv[])
 {
 	DIR *dir;
 	struct dirent *de;
+	int c;
+	int err;
+	char *pattern_source;
 
 	page_size = getpagesize();
 	if (chdir("/sys/slab"))
 		fatal("This kernel does not have SLUB support.\n");
 
+	while ((c = getopt_long(argc, argv, "ahtvnpsz", opts, NULL)) != -1)
+	switch(c) {
+		case 's':
+			show_slab = 1;
+			break;
+		case 'a':
+			show_alias = 1;
+			break;
+		case 'n':
+			show_numa = 1;
+			break;
+		case 'p':
+			show_parameters = 1;
+			break;
+		case 'z':
+			skip_zero = 0;
+			break;
+		case 't':
+			show_track = 1;
+			break;
+		case 'v':
+			validate = 1;
+			break;
+		case 'h':
+			usage();
+			return 0;
+
+		default:
+			fatal("%s: Invalid option '%c'\n", argv[0], optopt);
+
+	}
+
+	if (!show_slab && !show_alias && !show_parameters && !show_track
+		&& !validate)
+			show_slab = 1;
+
+	if (argc > optind)
+		pattern_source = argv[optind];
+	else
+		pattern_source = ".*";
+
+	err = regcomp(&pattern, pattern_source, REG_ICASE|REG_NOSUB);
+	if (err)
+		fatal("%s: Invalid pattern '%s' code %d\n",
+			argv[0], pattern_source, err);
+
 	dir = opendir(".");
 	while ((de = readdir(dir))) {
-		if (de->d_name[0] == '.')
+		if (de->d_name[0] == '.' ||
+				slab_mismatch(de->d_name))
 			continue;
 		switch (de->d_type) {
 		   case DT_LNK:
 			alias(de->d_name);
 			break;
 		   case DT_DIR:
-			slab(de->d_name);
+			if (chdir(de->d_name))
+				fatal("Unable to access slab %s\n", de->d_name);
+
+		   	if (show_numa)
+				slab_numa(de->d_name);
+			else
+			if (show_track)
+				show_tracking(de->d_name);
+			else
+		   	if (validate)
+				slab_validate(de->d_name);
+			else
+				slab(de->d_name);
+			chdir("..");
 			break;
 		   case DT_REG:
 			parameter(de->d_name);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
