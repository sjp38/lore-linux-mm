Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id E40936B0038
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 17:53:48 -0400 (EDT)
Received: by pdea3 with SMTP id a3so73281203pde.3
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 14:53:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xa1si5290830pac.47.2015.04.30.14.53.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Apr 2015 14:53:48 -0700 (PDT)
Date: Thu, 30 Apr 2015 14:53:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 06/13] mm: meminit: Inline some helper functions
Message-Id: <20150430145346.1069dd3292997611954e5ac0@linux-foundation.org>
In-Reply-To: <1430231830-7702-7-git-send-email-mgorman@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
	<1430231830-7702-7-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 28 Apr 2015 15:37:03 +0100 Mel Gorman <mgorman@suse.de> wrote:

> early_pfn_in_nid() and meminit_pfn_in_nid() are small functions that are
> unnecessarily visible outside memory initialisation. As well as unnecessary
> visibility, it's unnecessary function call overhead when initialising pages.
> This patch moves the helpers inline.

mm/page_alloc.c: In function 'memmap_init_zone':
mm/page_alloc.c:4287: error: implicit declaration of function 'early_pfn_in_nid'

--- a/mm/page_alloc.c~mm-meminit-inline-some-helper-functions-fix
+++ a/mm/page_alloc.c
@@ -950,8 +950,16 @@ static inline bool __meminit early_pfn_i
 {
 	return meminit_pfn_in_nid(pfn, node, &early_pfnnid_cache);
 }
+
+#else
+
+static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
+{
+	return true;
+}
 #endif
 
+
 #ifdef CONFIG_CMA
 /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
 void __init init_cma_reserved_pageblock(struct page *page)


allmodconfig.  It's odd that nobody else hit this...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
