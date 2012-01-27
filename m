Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 9B8406B0068
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 18:01:57 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 4/6] pagemap: document KPF_THP and make page-types aware of it
Date: Fri, 27 Jan 2012 18:02:51 -0500
Message-Id: <1327705373-29395-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1327705373-29395-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1327705373-29395-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

page-types, which is a common user of pagemap, gets aware of thp
with this patch. This helps system admins and kernel hackers know
about how thp works.
Here is a sample output of page-types over a thp:

  $ page-types -p <pid> --raw --list

  voffset offset  len     flags
  ...
  7f9d40200       3f8400  1       ___U_lA____Ma_bH______t____________
  7f9d40201       3f8401  1ff     ________________T_____t____________

               flags      page-count       MB  symbolic-flags                     long-symbolic-flags
  0x0000000000410000             511        1  ________________T_____t____________        compound_tail,thp
  0x000000000040d868               1        0  ___U_lA____Ma_bH______t____________        uptodate,lru,active,mmap,anonymous,swapbacked,compound_head,thp

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Changes since v1:
  - fix misused word
---
 Documentation/vm/page-types.c |    2 ++
 Documentation/vm/pagemap.txt  |    4 ++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git 3.3-rc1.orig/Documentation/vm/page-types.c 3.3-rc1/Documentation/vm/page-types.c
index 7445caa..0b13f02 100644
--- 3.3-rc1.orig/Documentation/vm/page-types.c
+++ 3.3-rc1/Documentation/vm/page-types.c
@@ -98,6 +98,7 @@
 #define KPF_HWPOISON		19
 #define KPF_NOPAGE		20
 #define KPF_KSM			21
+#define KPF_THP			22
 
 /* [32-] kernel hacking assistances */
 #define KPF_RESERVED		32
@@ -147,6 +148,7 @@ static const char *page_flag_names[] = {
 	[KPF_HWPOISON]		= "X:hwpoison",
 	[KPF_NOPAGE]		= "n:nopage",
 	[KPF_KSM]		= "x:ksm",
+	[KPF_THP]		= "t:thp",
 
 	[KPF_RESERVED]		= "r:reserved",
 	[KPF_MLOCKED]		= "m:mlocked",
diff --git 3.3-rc1.orig/Documentation/vm/pagemap.txt 3.3-rc1/Documentation/vm/pagemap.txt
index df09b96..4600cbe 100644
--- 3.3-rc1.orig/Documentation/vm/pagemap.txt
+++ 3.3-rc1/Documentation/vm/pagemap.txt
@@ -60,6 +60,7 @@ There are three components to pagemap:
     19. HWPOISON
     20. NOPAGE
     21. KSM
+    22. THP
 
 Short descriptions to the page flags:
 
@@ -97,6 +98,9 @@ Short descriptions to the page flags:
 21. KSM
     identical memory pages dynamically shared between one or more processes
 
+22. THP
+    contiguous pages which construct transparent hugepages
+
     [IO related page flags]
  1. ERROR     IO error occurred
  3. UPTODATE  page has up-to-date data
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
