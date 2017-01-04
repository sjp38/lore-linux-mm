Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 342196B0266
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 21:42:10 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 127so462384143pfg.5
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 18:42:10 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id m11si70916293pla.161.2017.01.03.18.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 18:42:09 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id b1so35389562pgc.1
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 18:42:09 -0800 (PST)
Subject: [next PATCH v4 3/3] mm: Add documentation for page fragment APIs
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 03 Jan 2017 18:42:08 -0800
Message-ID: <20170104024157.13451.6758.stgit@localhost.localdomain>
In-Reply-To: <20170104023620.13451.80691.stgit@localhost.localdomain>
References: <20170104023620.13451.80691.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>

This is a first pass at trying to add documentation for the page_frag APIs.
They may still change over time but for now I thought I would try to get
these documented so that as more network drivers and stack calls make use
of them we have one central spot to document how they are meant to be used.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

v2,v3: No change

 Documentation/vm/page_frags |   42 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)
 create mode 100644 Documentation/vm/page_frags

diff --git a/Documentation/vm/page_frags b/Documentation/vm/page_frags
new file mode 100644
index 000000000000..a6714565dbf9
--- /dev/null
+++ b/Documentation/vm/page_frags
@@ -0,0 +1,42 @@
+Page fragments
+--------------
+
+A page fragment is an arbitrary-length arbitrary-offset area of memory
+which resides within a 0 or higher order compound page.  Multiple
+fragments within that page are individually refcounted, in the page's
+reference counter.
+
+The page_frag functions, page_frag_alloc and page_frag_free, provide a
+simple allocation framework for page fragments.  This is used by the
+network stack and network device drivers to provide a backing region of
+memory for use as either an sk_buff->head, or to be used in the "frags"
+portion of skb_shared_info.
+
+In order to make use of the page fragment APIs a backing page fragment
+cache is needed.  This provides a central point for the fragment allocation
+and tracks allows multiple calls to make use of a cached page.  The
+advantage to doing this is that multiple calls to get_page can be avoided
+which can be expensive at allocation time.  However due to the nature of
+this caching it is required that any calls to the cache be protected by
+either a per-cpu limitation, or a per-cpu limitation and forcing interrupts
+to be disabled when executing the fragment allocation.
+
+The network stack uses two separate caches per CPU to handle fragment
+allocation.  The netdev_alloc_cache is used by callers making use of the
+__netdev_alloc_frag and __netdev_alloc_skb calls.  The napi_alloc_cache is
+used by callers of the __napi_alloc_frag and __napi_alloc_skb calls.  The
+main difference between these two calls is the context in which they may be
+called.  The "netdev" prefixed functions are usable in any context as these
+functions will disable interrupts, while the "napi" prefixed functions are
+only usable within the softirq context.
+
+Many network device drivers use a similar methodology for allocating page
+fragments, but the page fragments are cached at the ring or descriptor
+level.  In order to enable these cases it is necessary to provide a generic
+way of tearing down a page cache.  For this reason __page_frag_cache_drain
+was implemented.  It allows for freeing multiple references from a single
+page via a single call.  The advantage to doing this is that it allows for
+cleaning up the multiple references that were added to a page in order to
+avoid calling get_page per allocation.
+
+Alexander Duyck, Nov 29, 2016.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
