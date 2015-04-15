Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f46.google.com (mail-vn0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0BE886B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 03:27:43 -0400 (EDT)
Received: by vnbf190 with SMTP id f190so11951403vnb.1
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 00:27:42 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id y186si2304533oia.39.2015.04.15.00.27.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 00:27:42 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm/memory-failure: call shake_page() when error hits thp
 tail page
Date: Wed, 15 Apr 2015 07:25:46 +0000
Message-ID: <1429082714-26115-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dean Nelson <dnelson@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Jin Dongming <jin.dongming@np.css.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Currently memory_failure() calls shake_page() to sweep pages out from pcpli=
sts
only when the victim page is 4kB LRU page or thp head page. But we should d=
o
this for a thp tail page too.
Consider that a memory error hits a thp tail page whose head page is on a
pcplist when memory_failure() runs. Then, the current kernel skips shake_pa=
ges()
part, so hwpoison_user_mappings() returns without calling split_huge_page()=
 nor
try_to_unmap() because PageLRU of the thp head is still cleared due to the =
skip
of shake_page().
As a result, me_huge_page() runs for the thp, which is a broken behavior.

This patch fixes this problem by calling shake_page() for thp tail case.

Fixes: 385de35722c9 ("thp: allow a hwpoisoned head page to be put back to L=
RU")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: stable@vger.kernel.org  # v3.4+
---
 mm/memory-failure.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git v4.0.orig/mm/memory-failure.c v4.0/mm/memory-failure.c
index d487f8dc6d39..2cc1d578144b 100644
--- v4.0.orig/mm/memory-failure.c
+++ v4.0/mm/memory-failure.c
@@ -1141,10 +1141,10 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
 	 * The check (unnecessarily) ignores LRU pages being isolated and
 	 * walked by the page reclaim code, however that's not a big loss.
 	 */
-	if (!PageHuge(p) && !PageTransTail(p)) {
-		if (!PageLRU(p))
-			shake_page(p, 0);
-		if (!PageLRU(p)) {
+	if (!PageHuge(p)) {
+		if (!PageLRU(hpage))
+			shake_page(hpage, 0);
+		if (!PageLRU(hpage)) {
 			/*
 			 * shake_page could have turned it free.
 			 */
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
