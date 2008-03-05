Received: by wx-out-0506.google.com with SMTP id h31so1293801wxd.11
        for <linux-mm@kvack.org>; Tue, 04 Mar 2008 16:41:29 -0800 (PST)
Message-ID: <47CDE925.9090503@gmail.com>
Date: Wed, 05 Mar 2008 09:28:21 +0900
MIME-Version: 1.0
Subject: Re: [patch 16/20] non-reclaimable mlocked pages
References: <20080304225157.573336066@redhat.com> <20080304225227.780021971@redhat.com>
In-Reply-To: <20080304225227.780021971@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
From: minchan Kim <minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi, Rik.

There is a some trivial mistake.
It can cause compile error.

 >@@ -665,7 +677,12 @@ static int prep_new_page(struct page *pa
 >
 > 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_readahead |
 > 			1 << PG_referenced | 1 << PG_arch_1 |
 >-			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk);
 >+			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk |
 >+#ifdef CONFIG_NORECLAIM_MLOCK
 >+//TODO take care of it here, for now.
 >+			1 << PG_mlocked
 >+#endif
 >+			);
 > 	set_page_private(page, 0);
 > 	set_page_refcounted(page);

we need to fix it.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 78c3f94..f6d535f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -677,10 +677,10 @@ static int prep_new_page(struct page *page, int 
order, gfp_t gfp_flags)

   page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_readahead |
       1 << PG_referenced | 1 << PG_arch_1 |
-     1 << PG_owner_priv_1 | 1 << PG_mappedtodisk |
+     1 << PG_owner_priv_1 | 1 << PG_mappedtodisk
  #ifdef CONFIG_NORECLAIM_MLOCK
  //TODO take care of it here, for now.
-     1 << PG_mlocked
+     | 1 << PG_mlocked
  #endif
       );
   set_page_private(page, 0);

Thanks,
barrios.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
