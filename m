Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8233F8D0039
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 01:45:21 -0400 (EDT)
From: Ben Hutchings <ben@decadent.org.uk>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 22 Mar 2011 05:45:11 +0000
Message-ID: <1300772711.26693.473.camel@localhost>
Mime-Version: 1.0
Subject: [PATCH] mm/thp: Use conventional format for boolean attributes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

The conventional format for boolean attributes in sysfs is numeric
("0" or "1" followed by new-line).  Any boolean attribute can then be
read and written using a generic function.  Using the strings
"yes [no]", "[yes] no" (read), "yes" and "no" (write) will frustrate
this.

Cc'd to stable in order to change this before many scripts depend on
the current strings.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Cc: stable@kernel.org [2.6.38]
---
 mm/huge_memory.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 113e35c..dc0b3f0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -244,24 +244,25 @@ static ssize_t single_flag_show(struct kobject *kobj,
 				struct kobj_attribute *attr, char *buf,
 				enum transparent_hugepage_flag flag)
 {
-	if (test_bit(flag, &transparent_hugepage_flags))
-		return sprintf(buf, "[yes] no\n");
-	else
-		return sprintf(buf, "yes [no]\n");
+	return sprintf(buf, "%d\n",
+		       test_bit(flag, &transparent_hugepage_flags));
 }
 static ssize_t single_flag_store(struct kobject *kobj,
 				 struct kobj_attribute *attr,
 				 const char *buf, size_t count,
 				 enum transparent_hugepage_flag flag)
 {
-	if (!memcmp("yes", buf,
-		    min(sizeof("yes")-1, count))) {
+	unsigned long value;
+	char *endp;
+
+	value =3D simple_strtoul(buf, &endp, 0);
+	if (endp =3D=3D buf || value > 1)
+		return -EINVAL;
+
+	if (value)
 		set_bit(flag, &transparent_hugepage_flags);
-	} else if (!memcmp("no", buf,
-			   min(sizeof("no")-1, count))) {
+	else
 		clear_bit(flag, &transparent_hugepage_flags);
-	} else
-		return -EINVAL;
=20
 	return count;
 }
--=20
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
