Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 9D6EB6B004D
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 07:58:15 -0400 (EDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 10/13] mm: PRAM: allow to ban arbitrary memory ranges
Date: Mon, 1 Jul 2013 15:57:45 +0400
Message-ID: <b7b246583fa36a83a61e7f98838b0b922bc375f2.1372582756.git.vdavydov@parallels.com>
In-Reply-To: <cover.1372582754.git.vdavydov@parallels.com>
References: <cover.1372582754.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com, khorenko@parallels.com

Banning for PRAM memory ranges that have been reserved at boot time is
not enough for avoiding all conflicts. The point is that kexec may load
the new kernel code to some address range that have never been reserved
possibly overwriting persistent data.

Fortunately, it is possible to specify a memory range kexec will load
the new kernel code into. Thus, to avoid kexec-vs-PRAM conflicts, it is
enough to disallow for PRAM some memory range large enough to load the
new kernel and make kexec load the new kernel code into that range.

For that purpose, This patch adds ability to specify arbitrary banned
ranges using the 'pram_banned' boot option.
---
 mm/pram.c |   45 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/mm/pram.c b/mm/pram.c
index 969ff3f..3ad769b 100644
--- a/mm/pram.c
+++ b/mm/pram.c
@@ -127,6 +127,15 @@ static bool __meminitdata pram_reservation_in_progress;
  * persistent data. Since the device configuration cannot change during kexec
  * and the newly booted kernel is likely to have a similar boot-time device
  * driver set, this hack should work in most cases.
+ *
+ * This solution has one exception. The point is that kexec may load the new
+ * kernel code to some address range that have never been reserved and thus
+ * banned for PRAM by the current kernel possibly overwriting persistent data.
+ * Fortunately, it is possible to specify an exact range kexec will load the
+ * new kernel code into. Thus, to avoid kexec-vs-PRAM conflicts, one should
+ * disallow for PRAM some memory range large enough to load the new kernel (see
+ * the 'pram_banned' boot param) and make kexec load the new kernel code into
+ * that range.
  */
 
 /*
@@ -378,6 +387,42 @@ out:
 }
 
 /*
+ * A comma separated list of memory regions that PRAM is not allowed to use.
+ */
+static int __init parse_pram_banned(char *arg)
+{
+	char *cur = arg, *tmp;
+	unsigned long long start, end;
+
+	do {
+		start = memparse(cur, &tmp);
+		if (cur == tmp) {
+			pr_warning("pram_banned: Memory value expected\n");
+			return -EINVAL;
+		}
+		cur = tmp;
+		if (*cur != '-') {
+			pr_warning("pram_banned: '-' expected\n");
+			return -EINVAL;
+		}
+		cur++;
+		end = memparse(cur, &tmp);
+		if (cur == tmp) {
+			pr_warning("pram_banned: Memory value expected\n");
+			return -EINVAL;
+		}
+		if (end <= start) {
+			pr_warning("pram_banned: end <= start\n");
+			return -EINVAL;
+		}
+		pram_ban_region(PFN_DOWN(start), PFN_UP(end) - 1);
+	} while (*cur++ == ',');
+
+	return 0;
+}
+early_param("pram_banned", parse_pram_banned);
+
+/*
  * Bans pfn range [start..end] (inclusive) for PRAM.
  */
 void __meminit pram_ban_region(unsigned long start, unsigned long end)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
