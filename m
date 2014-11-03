Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id A8B036B00FD
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 11:57:57 -0500 (EST)
Received: by mail-lb0-f174.google.com with SMTP id z11so7816209lbi.33
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 08:57:56 -0800 (PST)
Received: from mail-la0-f73.google.com (mail-la0-f73.google.com. [209.85.215.73])
        by mx.google.com with ESMTPS id o1si33238589lbw.57.2014.11.03.08.57.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 08:57:56 -0800 (PST)
Received: by mail-la0-f73.google.com with SMTP id q1so907156lam.2
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 08:57:56 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: [PATCH] mm: alloc_contig_range: demote pages busy message from warn to info
Date: Mon,  3 Nov 2014 17:57:53 +0100
Message-Id: <1415033873-28569-1-git-send-email-mina86@mina86.com>
In-Reply-To: <2457604.k03RC2Mv4q@avalon>
References: <2457604.k03RC2Mv4q@avalon>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Peter Hurley <peter@hurleysoftware.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>

Having test_pages_isolated failure message as a warning confuses
users into thinking that it is more serious than it really is.  In
reality, if called via CMA, allocation will be retried so a single
test_pages_isolated failure does not prevent allocation from
succeeding.

Demote the warning message to an info message and reformat it such
that the text =E2=80=9Cfailed=E2=80=9D does not appear and instead a less=
 worrying
=E2=80=9CPFNS busy=E2=80=9D is used.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
---
 mm/page_alloc.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 372e3f3..e2731eb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6431,13 +6431,12 @@ int alloc_contig_range(unsigned long start, unsig=
ned long end,
=20
 	/* Make sure the range is really isolated. */
 	if (test_pages_isolated(outer_start, end, false)) {
-		pr_warn("alloc_contig_range test_pages_isolated(%lx, %lx) failed\n",
-		       outer_start, end);
+		pr_info("%s: [%lx, %lx) PFNs busy\n",
+			__func__, outer_start, end);
 		ret =3D -EBUSY;
 		goto done;
 	}
=20
-
 	/* Grab isolated pages from freelists. */
 	outer_end =3D isolate_freepages_range(&cc, outer_start, end);
 	if (!outer_end) {
--=20
2.1.0.rc2.206.gedb03e5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
