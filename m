Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA2546B007E
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 19:33:10 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id dx6so140640212pad.0
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 16:33:10 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id ur6si11883909pab.11.2016.04.16.16.33.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Apr 2016 16:33:10 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id c20so68239843pfc.1
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 16:33:10 -0700 (PDT)
Date: Sat, 16 Apr 2016 16:33:07 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm 3/5] huge tmpfs recovery: tweak shmem_getpage_gfp to
 fill team fix
In-Reply-To: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604161629520.1907@eggly.anvils>
References: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Mika Penttila <mika.penttila@nextfour.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Please add this fix after my 27/31, your
huge-tmpfs-recovery-tweak-shmem_getpage_gfp-to-fill-team.patch
for later merging into it.  Great catch by Mika Penttila, a bug which
prevented some unusual cases from being recovered into huge pages as
intended: an initially sparse head would be set PageTeam only after
this check.  But the check is guarding against a racing disband, which
cannot happen before the head is published as PageTeam, plus we have
an additional reference on the head which keeps it safe throughout:
so very easily fixed.

Reported-by: Mika Penttila <mika.penttila@nextfour.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2938,7 +2938,7 @@ repeat:
 			page = *pagep;
 			lock_page(page);
 			head = page - (index & (HPAGE_PMD_NR-1));
-			if (!PageTeam(head)) {
+			if (!PageTeam(head) && page != head) {
 				error = -ENOENT;
 				goto decused;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
