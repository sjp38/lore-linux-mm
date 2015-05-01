Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id B63BC6B006C
	for <linux-mm@kvack.org>; Fri,  1 May 2015 05:21:17 -0400 (EDT)
Received: by wgso17 with SMTP id o17so86359961wgs.1
        for <linux-mm@kvack.org>; Fri, 01 May 2015 02:21:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y14si7047142wiv.47.2015.05.01.02.21.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 01 May 2015 02:21:16 -0700 (PDT)
Date: Fri, 1 May 2015 10:21:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: meminit: Initialise a subset of struct pages if
 CONFIG_DEFERRED_STRUCT_PAGE_INIT is set -fix
Message-ID: <20150501092113.GC2449@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
 <1430231830-7702-8-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1430231830-7702-8-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This is take 2 on describing why these section names exist. If accepted
then it should be considered a fix for the mmotm patch
mm-meminit-initialise-a-subset-of-struct-pages-if-config_deferred_struct_page_init-is-set.patch

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/internal.h | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 24314b671db1..85189fce7f61 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -386,10 +386,14 @@ static inline void mminit_verify_zonelist(void)
 #endif /* CONFIG_DEBUG_MEMORY_INIT */
 
 /*
- * Deferred struct page initialisation requires some early init functions that
- * are removed before kswapd is up and running. The feature depends on memory
- * hotplug so put the data and code required by deferred initialisation into
- * the __meminit section where they are preserved.
+ * Deferred struct page initialisation requires init functions that are freed
+ * before kswapd is available. Reuse the memory hotplug section annotation
+ * to mark the required code.
+ *
+ * __defermem_init is code that always exists but is annotated __meminit to
+ * 	avoid section warnings.
+ * __defer_init code gets marked __meminit when deferring struct page
+ *	initialistion but is otherwise in the init section.
  */
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 #define __defermem_init __meminit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
