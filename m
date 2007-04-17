Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3HIGhFf007654
	for <linux-mm@kvack.org>; Tue, 17 Apr 2007 14:16:55 -0400
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3HIGgtC004106
	for <linux-mm@kvack.org>; Tue, 17 Apr 2007 14:16:42 -0400
Received: from redhat.com (lwoodman.boston.redhat.com [172.16.80.79])
	by mail.boston.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id l3HIGfkN009638
	for <linux-mm@kvack.org>; Tue, 17 Apr 2007 14:16:41 -0400
Message-ID: <46250EB1.9010707@redhat.com>
Date: Tue, 17 Apr 2007 14:15:13 -0400
From: Larry Woodman <lwoodman@redhat.com>
MIME-Version: 1.0
Subject: sysctl_panic_on_oom broken
Content-Type: multipart/mixed;
 boundary="------------000506040109070807070405"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------000506040109070807070405
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

out_of_memory() does not panic when sysctl_panic_on_oom is set
if constrained_alloc() does not return CONSTRAINT_NONE.  Instead,
out_of_memory() kills the current process whenever constrained_alloc()
returns either CONSTRAINT_MEMORY_POLICY or CONSTRAINT_CPUSET.
This patch fixes this problem:




--------------000506040109070807070405
Content-Type: text/plain;
 name="panic_on_oom.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="panic_on_oom.patch"

--- linux-2.6.18.noarch/mm/oom_kill.c.orig
+++ linux-2.6.18.noarch/mm/oom_kill.c
@@ -431,6 +437,9 @@ void out_of_memory(struct zonelist *zone
 	cpuset_lock();
 	read_lock(&tasklist_lock);
 
+	/* check if we are going to panic before enything else... */
+	if (sysctl_panic_on_oom)
+		panic("out of memory. panic_on_oom is selected\n");
 	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
@@ -447,8 +456,6 @@ void out_of_memory(struct zonelist *zone
 		break;
 
 	case CONSTRAINT_NONE:
-		if (sysctl_panic_on_oom)
-			panic("out of memory. panic_on_oom is selected\n");
 retry:
 		/*
 		 * Rambo mode: Shoot down a process and hope it solves whatever

--------------000506040109070807070405--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
