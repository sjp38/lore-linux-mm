Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6BC846B0062
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 15:21:20 -0500 (EST)
Subject: [PATCH v2 1/3] page-types: learn to describe flags directly from
	command line
From: Alex Chiang <achiang@hp.com>
Date: Thu, 05 Nov 2009 13:21:16 -0700
Message-ID: <20091105202116.25492.28878.stgit@bob.kio>
In-Reply-To: <20091105201846.25492.52935.stgit@bob.kio>
References: <20091105201846.25492.52935.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, fengguang.wu@intel.com
Cc: Haicheng Li <haicheng.li@intel.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Wu Fengguang <fengguang.wu@intel.com>

Teach page-types to describe page flags directly from the command
line.

Why is this useful? For instance, if you're using memory hotplug
and see this in /var/log/messages:

	kernel: removing from LRU failed 3836dd0/1/1e00000000000010

It would be nice to decode those page flags without staring at
the source.

Example usage and output:

# Documentation/vm/page-types -d 0x10
0x0000000000000010	____D_____________________________	dirty

# Documentation/vm/page-types -d anon
0x0000000000001000	____________a_____________________	anonymous

# Documentation/vm/page-types -d anon,0x10
0x0000000000001010	____D_______a_____________________	dirty,anonymous

[achiang@hp.com: documentation]
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Haicheng Li <haicheng.li@intel.com>
Signed-off-by: Alex Chiang <achiang@hp.com>
---

 Documentation/vm/page-types.c |   21 ++++++++++++++++++++-
 1 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/Documentation/vm/page-types.c b/Documentation/vm/page-types.c
index 3ec4f2a..a93c28e 100644
--- a/Documentation/vm/page-types.c
+++ b/Documentation/vm/page-types.c
@@ -674,6 +674,7 @@ static void usage(void)
 	printf(
 "page-types [options]\n"
 "            -r|--raw                  Raw mode, for kernel developers\n"
+"            -d|--describe flags        Describe flags\n"
 "            -a|--addr    addr-spec    Walk a range of pages\n"
 "            -b|--bits    bits-spec    Walk pages with specified bits\n"
 "            -p|--pid     pid          Walk process address space\n"
@@ -686,6 +687,10 @@ static void usage(void)
 "            -X|--hwpoison             hwpoison pages\n"
 "            -x|--unpoison             unpoison pages\n"
 "            -h|--help                 Show this usage message\n"
+"flags:\n"
+"            0x10                      bitfield format, e.g.\n"
+"            anon                      bit-name, e.g.\n"
+"            0x10,anon                 comma-separated list, e.g.\n"
 "addr-spec:\n"
 "            N                         one page at offset N (unit: pages)\n"
 "            N+M                       pages range from N to N+M-1\n"
@@ -884,12 +889,22 @@ static void parse_bits_mask(const char *optarg)
 	add_bits_filter(mask, bits);
 }
 
+static void describe_flags(const char *optarg)
+{
+	uint64_t flags = parse_flag_names(optarg, 0);
+
+	printf("0x%016llx\t%s\t%s\n",
+		(unsigned long long)flags,
+		page_flag_name(flags),
+		page_flag_longname(flags));
+}
 
 static struct option opts[] = {
 	{ "raw"       , 0, NULL, 'r' },
 	{ "pid"       , 1, NULL, 'p' },
 	{ "file"      , 1, NULL, 'f' },
 	{ "addr"      , 1, NULL, 'a' },
+	{ "describe"  , 1, NULL, 'd' },
 	{ "bits"      , 1, NULL, 'b' },
 	{ "list"      , 0, NULL, 'l' },
 	{ "list-each" , 0, NULL, 'L' },
@@ -907,7 +922,7 @@ int main(int argc, char *argv[])
 	page_size = getpagesize();
 
 	while ((c = getopt_long(argc, argv,
-				"rp:f:a:b:lLNXxh", opts, NULL)) != -1) {
+				"rp:f:a:b:d:lLNXxh", opts, NULL)) != -1) {
 		switch (c) {
 		case 'r':
 			opt_raw = 1;
@@ -924,6 +939,10 @@ int main(int argc, char *argv[])
 		case 'b':
 			parse_bits_mask(optarg);
 			break;
+		case 'd':
+			opt_no_summary = 1;
+			describe_flags(optarg);
+			break;
 		case 'l':
 			opt_list = 1;
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
