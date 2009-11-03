Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0F1946B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 17:55:44 -0500 (EST)
Date: Tue, 3 Nov 2009 15:54:41 -0700
From: Alex Chiang <achiang@hp.com>
Subject: [PATCH] page-types: decode flags directly from command line
Message-ID: <20091103225441.GB4087@grease>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Teach page-types to decode page flags directly from the command
line.

Why is this useful? For instance, if you're using memory hotplug
and see this in /var/log/messages:

	kernel: removing from LRU failed 3836dd0/1/1e00000000000400

It would be nice to decode those page flags without staring at
the source.

Example usage and output:

linux-2.6/Documentation/vm$ ./page-types -d 0x1e00000000000400
             flags	page-count       MB  symbolic-flags			long-symbolic-flags
0x1e00000000000400	         1        0  __________B_______________________buddy
             total	         1        0

Signed-off-by: Alex Chiang <achiang@hp.com>
---
 page-types.c |   26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)
---
diff --git a/Documentation/vm/page-types.c b/Documentation/vm/page-types.c
index 3ec4f2a..a55c624 100644
--- a/Documentation/vm/page-types.c
+++ b/Documentation/vm/page-types.c
@@ -674,6 +674,7 @@ static void usage(void)
 	printf(
 "page-types [options]\n"
 "            -r|--raw                  Raw mode, for kernel developers\n"
+"            -d|--decode  flags        Decode a single page's flags\n"
 "            -a|--addr    addr-spec    Walk a range of pages\n"
 "            -b|--bits    bits-spec    Walk pages with specified bits\n"
 "            -p|--pid     pid          Walk process address space\n"
@@ -682,10 +683,12 @@ static void usage(void)
 #endif
 "            -l|--list                 Show page details in ranges\n"
 "            -L|--list-each            Show page details one by one\n"
-"            -N|--no-summary           Don't show summay info\n"
+"            -N|--no-summary           Don't show summary info\n"
 "            -X|--hwpoison             hwpoison pages\n"
 "            -x|--unpoison             unpoison pages\n"
 "            -h|--help                 Show this usage message\n"
+"flags:\n"
+"            0x0000000000000400        A single page's flags, e.g.\n"
 "addr-spec:\n"
 "            N                         one page at offset N (unit: pages)\n"
 "            N+M                       pages range from N to N+M-1\n"
@@ -884,12 +887,28 @@ static void parse_bits_mask(const char *optarg)
 	add_bits_filter(mask, bits);
 }
 
+static void decode_flags_and_exit(const char *optarg)
+{
+	uint64_t flags;
+
+	flags = parse_number(optarg);
+
+	opt_list = 0;
+	opt_hwpoison = 0;
+	opt_unpoison = 0;
+
+	add_page(0, 0, flags);
+	show_summary();
+
+	exit(0);
+}
 
 static struct option opts[] = {
 	{ "raw"       , 0, NULL, 'r' },
 	{ "pid"       , 1, NULL, 'p' },
 	{ "file"      , 1, NULL, 'f' },
 	{ "addr"      , 1, NULL, 'a' },
+	{ "decode"    , 1, NULL, 'd' },
 	{ "bits"      , 1, NULL, 'b' },
 	{ "list"      , 0, NULL, 'l' },
 	{ "list-each" , 0, NULL, 'L' },
@@ -907,7 +926,7 @@ int main(int argc, char *argv[])
 	page_size = getpagesize();
 
 	while ((c = getopt_long(argc, argv,
-				"rp:f:a:b:lLNXxh", opts, NULL)) != -1) {
+				"rp:f:a:b:d:lLNXxh", opts, NULL)) != -1) {
 		switch (c) {
 		case 'r':
 			opt_raw = 1;
@@ -924,6 +943,9 @@ int main(int argc, char *argv[])
 		case 'b':
 			parse_bits_mask(optarg);
 			break;
+		case 'd':
+			decode_flags_and_exit(optarg);
+			break;
 		case 'l':
 			opt_list = 1;
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
