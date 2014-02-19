Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 861F16B0036
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:17:23 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id i13so1816779qae.27
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 15:17:23 -0800 (PST)
Received: from e9.ny.us.ibm.com (e9.ny.us.ibm.com. [32.97.182.139])
        by mx.google.com with ESMTPS id 9si1468528qgl.24.2014.02.19.15.17.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 15:17:23 -0800 (PST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 19 Feb 2014 18:17:22 -0500
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 5C3BB6E803A
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:17:15 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23032.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1JNHKQJ6291822
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 23:17:20 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1JNHIdh020942
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:17:19 -0500
Date: Wed, 19 Feb 2014 15:17:14 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: [PATCH 1/3] mm: return NUMA_NO_NODE in local_memory_node if
 zonelists are not setup
Message-ID: <20140219231714.GB413@linux.vnet.ibm.com>
References: <20140219231641.GA413@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140219231641.GA413@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, Anton Blanchard <anton@samba.org>, linuxppc-dev@lists.ozlabs.org

We can call local_memory_node() before the zonelists are setup. In that
case, first_zones_zonelist() will not set zone and the reference to
zone->node will Oops. Catch this case, and, since we presumably running
very early, just return that any node will do.

Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Ben Herrenschmidt <benh@kernel.crashing.org>
Cc: Anton Blanchard <anton@samba.org>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e3758a0..5de4337 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3650,6 +3650,8 @@ int local_memory_node(int node)
 				   gfp_zone(GFP_KERNEL),
 				   NULL,
 				   &zone);
+	if (!zone)
+		return NUMA_NO_NODE;
 	return zone->node;
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
