Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAIJX1Fg004157
	for <linux-mm@kvack.org>; Fri, 18 Nov 2005 14:33:01 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAIJWjT9087340
	for <linux-mm@kvack.org>; Fri, 18 Nov 2005 12:32:45 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAIJX0mg023580
	for <linux-mm@kvack.org>; Fri, 18 Nov 2005 12:33:00 -0700
Message-ID: <437E2C69.4000708@us.ibm.com>
Date: Fri, 18 Nov 2005 11:32:57 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 0/8] Critical Page Pool
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

We have a clustering product that needs to be able to guarantee that the
networking system won't stop functioning in the case of OOM/low memory
condition.  The current mempool system is inadequate because to keep the
whole networking stack functioning, we need more than 1 or 2 slab caches to
be guaranteed.  We need to guarantee that any request made with a specific
flag will succeed, assuming of course that you've made your "critical page
pool" big enough.

The following patch series implements such a critical page pool.  It
creates 2 userspace triggers:

/proc/sys/vm/critical_pages: write the number of pages you want to reserve
for the critical pool into this file

/proc/sys/vm/in_emergency: write a non-zero value to tell the kernel that
the system is in an emergency state and authorize the kernel to dip into
the critical pool to satisfy critical allocations.

We mark critical allocations with the __GFP_CRITICAL flag, and when the
system is in an emergency state, we are allowed to delve into this pool to
satisfy __GFP_CRITICAL allocations that cannot be satisfied through the
normal means.

Feedback on our approach would be appreciated.

Thanks!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
