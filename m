Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id E74F56B006E
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 10:47:44 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id a41so1816037yho.1
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 07:47:44 -0800 (PST)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id o44si5467593yhb.1.2015.01.19.07.47.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 07:47:41 -0800 (PST)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 2/2] mm: add 'foreign' alias for the 'pinned' page flag
Date: Mon, 19 Jan 2015 15:47:23 +0000
Message-ID: <1421682443-20509-3-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1421682443-20509-1-git-send-email-david.vrabel@citrix.com>
References: <1421682443-20509-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, Jenny
 Herbert <jennifer.herbert@citrix.com>

From: Jenny Herbert <jennifer.herbert@citrix.com>

The foreign page flag will be used by Xen guests to mark pages that
have grant mappings of frames from other (foreign) guests.

The foreign flag is an alias for the existing (Xen-specific) pinned
flag.  This is safe because pinned is only used on pages used for page
tables and these cannot also be foreign.

Signed-off-by: Jenny Herbert <jennifer.herbert@citrix.com>
Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 include/linux/page-flags.h |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e1f5fcd..5ed7bda 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -121,8 +121,12 @@ enum pageflags {
 	PG_fscache = PG_private_2,	/* page backed by cache */
 
 	/* XEN */
+	/* Pinned in Xen as a read-only pagetable page. */
 	PG_pinned = PG_owner_priv_1,
+	/* Pinned as part of domain save (see xen_mm_pin_all()). */
 	PG_savepinned = PG_dirty,
+	/* Has a grant mapping of another (foreign) domain's page. */
+	PG_foreign = PG_owner_priv_1,
 
 	/* SLOB */
 	PG_slob_free = PG_private,
@@ -215,6 +219,7 @@ __PAGEFLAG(Slab, slab)
 PAGEFLAG(Checked, checked)		/* Used by some filesystems */
 PAGEFLAG(Pinned, pinned) TESTSCFLAG(Pinned, pinned)	/* Xen */
 PAGEFLAG(SavePinned, savepinned);			/* Xen */
+PAGEFLAG(Foreign, foreign);				/* Xen */
 PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
 	__SETPAGEFLAG(SwapBacked, swapbacked)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
