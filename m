Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7985C6B0078
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 15:21:30 -0500 (EST)
Subject: [PATCH v2 3/3] page-types: exit early when invoked with -d|--describe
From: Alex Chiang <achiang@hp.com>
Date: Thu, 05 Nov 2009 13:21:26 -0700
Message-ID: <20091105202126.25492.84269.stgit@bob.kio>
In-Reply-To: <20091105201846.25492.52935.stgit@bob.kio>
References: <20091105201846.25492.52935.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, fengguang.wu@intel.com
Cc: Haicheng Li <haicheng.li@intel.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On a system with large amount of memory (256GB), invoking page-types
can take quite a long time, which is unreasonable considering the user
only wants a description of the flags:

	# time ./page-types -d 0x10
	0x0000000000000010	____D_____________________________	dirty

	real	0m34.285s
	user	0m1.966s
	sys	0m32.313s

This is because we still walk the entire address range.

Exiting early seems like a reasonble solution:

# time ./page-types -d 0x10
	0x0000000000000010	____D_____________________________	dirty

	real	0m0.007s
	user	0m0.001s
	sys	0m0.005s

Cc: Andi Kleen <andi@firstfloor.org>
Cc: Haicheng Li <haicheng.li@intel.com>
Signed-off-by: Alex Chiang <achiang@hp.com>
---

 Documentation/vm/page-types.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/Documentation/vm/page-types.c b/Documentation/vm/page-types.c
index 9c09eb5..9cf50ab 100644
--- a/Documentation/vm/page-types.c
+++ b/Documentation/vm/page-types.c
@@ -940,9 +940,8 @@ int main(int argc, char *argv[])
 			parse_bits_mask(optarg);
 			break;
 		case 'd':
-			opt_no_summary = 1;
 			describe_flags(optarg);
-			break;
+			exit(0);
 		case 'l':
 			opt_list = 1;
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
