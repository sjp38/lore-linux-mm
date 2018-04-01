Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 473406B0003
	for <linux-mm@kvack.org>; Sun,  1 Apr 2018 01:09:37 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id e4so11082491iof.7
        for <linux-mm@kvack.org>; Sat, 31 Mar 2018 22:09:37 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id k16-v6si5530868ita.82.2018.03.31.22.09.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 31 Mar 2018 22:09:36 -0700 (PDT)
From: rao.shoaib@oracle.com
Subject: [PATCH 1/1] MACRO_ARG_REUSE in checkpatch.pl is confused about * in typeof
Date: Sat, 31 Mar 2018 22:04:05 -0700
Message-Id: <1522559045-18105-1-git-send-email-rao.shoaib@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: paulmck@linux.vnet.ibm.com, joe@perches.com, willy@infradead.org, brouer@redhat.com, linux-mm@kvack.org, Rao Shoaib <rao.shoaib@oracle.com>

From: Rao Shoaib <rao.shoaib@oracle.com>

Example:

CHECK: Macro argument reuse 'ptr' - possible side-effects?
+#define kfree_rcu(ptr, rcu_name)       \
+       do {                            \
+               unsigned long __off = offsetof(typeof(*(ptr)), rcu_name); \
+               struct rcu_head *__rptr = (void *)ptr + __off; \
+               __kfree_rcu(__rptr, __off); \
+       } while (0)

Fix supplied by Joe Perches.

Signed-off-by: Rao Shoaib <rao.shoaib@oracle.com>
---
 scripts/checkpatch.pl | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 3d40403..def6bb2 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -4998,7 +4998,7 @@ sub process {
 			        next if ($arg =~ /\.\.\./);
 			        next if ($arg =~ /^type$/i);
 				my $tmp_stmt = $define_stmt;
-				$tmp_stmt =~ s/\b(typeof|__typeof__|__builtin\w+|typecheck\s*\(\s*$Type\s*,|\#+)\s*\(*\s*$arg\s*\)*\b//g;
+				$tmp_stmt =~ s/\b(?:typeof|__typeof__|__builtin\w+|typecheck\s*\(\s*$Type\s*,|\#+)\s*\(*(?:\s*\*\s*)*\s*\(*\s*$arg\s*\)*\b//g;
 				$tmp_stmt =~ s/\#+\s*$arg\b//g;
 				$tmp_stmt =~ s/\b$arg\s*\#\#//g;
 				my $use_cnt = $tmp_stmt =~ s/\b$arg\b//g;
-- 
2.7.4
