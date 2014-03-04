Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9128F6B0039
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 17:13:51 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id x13so214090qcv.19
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 14:13:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id z2si137535qad.161.2014.03.04.14.13.50
        for <linux-mm@kvack.org>;
        Tue, 04 Mar 2014 14:13:50 -0800 (PST)
Date: Tue, 4 Mar 2014 17:13:47 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] slab_common: fix the check for duplicate slab names
Message-ID: <alpine.LRH.2.02.1403041711300.29476@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jonathan Brassow <jbrassow@redhat.com>, "Alasdair G. Kergon" <agk@redhat.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com

The patch 3e374919b314f20e2a04f641ebc1093d758f66a4 is supposed to fix the
problem where kmem_cache_create incorrectly reports duplicate cache name
and fails. The problem is described in the header of that patch.

However, the patch doesn't really fix the problem because of these
reasons:

* the logic to test for debugging is reversed. It was intended to perform
  the check only if slub debugging is enabled (which implies that caches
  with the same parameters are not merged). Therefore, there should be
  #if !defined(CONFIG_SLUB) || defined(CONFIG_SLUB_DEBUG_ON)
  The current code has the condition reversed and performs the test if
  debugging is disabled.

* slub debugging may be enabled or disabled based on kernel command line,
  CONFIG_SLUB_DEBUG_ON is just the default settings. Therefore the test
  based on definition of CONFIG_SLUB_DEBUG_ON is unreliable.

This patch fixes the problem by removing the test
"!defined(CONFIG_SLUB_DEBUG_ON)". Therefore, duplicate names are never
checked if the SLUB allocator is used.

Note to stable kernel maintainers: when backporint this patch, please
backport also the patch 3e374919b314f20e2a04f641ebc1093d758f66a4.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Cc: stable@vger.kernel.org	# 3.6+

---
 mm/slab_common.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-3.14-rc5/mm/slab_common.c
===================================================================
--- linux-3.14-rc5.orig/mm/slab_common.c	2014-03-04 22:47:02.000000000 +0100
+++ linux-3.14-rc5/mm/slab_common.c	2014-03-04 22:47:08.000000000 +0100
@@ -56,7 +56,7 @@ static int kmem_cache_sanity_check(struc
 			continue;
 		}
 
-#if !defined(CONFIG_SLUB) || !defined(CONFIG_SLUB_DEBUG_ON)
+#if !defined(CONFIG_SLUB)
 		/*
 		 * For simplicity, we won't check this in the list of memcg
 		 * caches. We have control over memcg naming, and if there

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
