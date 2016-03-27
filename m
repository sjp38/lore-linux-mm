Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 97E286B0253
	for <linux-mm@kvack.org>; Sun, 27 Mar 2016 15:47:49 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id x3so121119167pfb.1
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 12:47:49 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 16si18201993pfo.244.2016.03.27.12.47.48
        for <linux-mm@kvack.org>;
        Sun, 27 Mar 2016 12:47:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/4] page-flags: make page flag helpers accept struct head_page
Date: Sun, 27 Mar 2016 22:47:39 +0300
Message-Id: <1459108060-69891-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459108060-69891-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20160327194649.GA9638@node.shutemov.name>
 <1459108060-69891-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch makes all generated page flag helpers to accept pointer to
struct head_page as well as struct page.

In case if pointer to struct head_page is passed, we assume that it's
head page and bypass policy constrain checks.

Note, to get get inteface consistent we would need to make non-generated
page flag helper to accept struct head_page as well.

Not-yet-signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 scripts/mkpageflags.sh | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/scripts/mkpageflags.sh b/scripts/mkpageflags.sh
index 29d46bccaea4..272aab4ad1a3 100755
--- a/scripts/mkpageflags.sh
+++ b/scripts/mkpageflags.sh
@@ -6,23 +6,23 @@ fatal() {
 }
 
 any() {
-	echo "(__p)"
+	echo "((struct page *)(__p))"
 }
 
 head() {
-	echo "compound_head(__p)"
+	echo "compound_head((struct page *)(__p))"
 }
 
 no_tail() {
 	local enforce="${1:+VM_BUG_ON_PGFLAGS(PageTail(__p), __p);}"
 
-	echo "({$enforce compound_head(__p);})"
+	echo "({$enforce compound_head((struct page *)(__p));})"
 }
 
 no_compound() {
 	local enforce="${1:+VM_BUG_ON_PGFLAGS(PageCompound(__p), __p);}"
 
-	echo "({$enforce __p;})"
+	echo "({$enforce ((struct page *)(__p));})"
 }
 
 generate_test() {
@@ -34,7 +34,9 @@ generate_test() {
 	cat <<EOF
 #define $uname(__p) ({								\\
 	int ret;								\\
-	if (__builtin_types_compatible_p(typeof(*(__p)), struct page))		\\
+	if (__builtin_types_compatible_p(typeof(*(__p)), struct head_page))	\\
+		ret = $op(PG_$lname, &((struct head_page *)(__p))->page.flags);	\\
+	else if (__builtin_types_compatible_p(typeof(*(__p)), struct page))	\\
 		ret = $op(PG_$lname, &$page->flags);				\\
 	else									\\
 		BUILD_BUG();							\\
@@ -52,7 +54,9 @@ generate_mod() {
 
 	cat <<EOF
 #define $uname(__p) do {							\\
-	if (__builtin_types_compatible_p(typeof(*(__p)), struct page))		\\
+	if (__builtin_types_compatible_p(typeof(*(__p)), struct head_page))	\\
+		$op(PG_$lname, &((struct head_page *)(__p))->page.flags);	\\
+	else if (__builtin_types_compatible_p(typeof(*(__p)), struct page))	\\
 		$op(PG_$lname, &$page->flags);					\\
 	else									\\
 		BUILD_BUG();							\\
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
