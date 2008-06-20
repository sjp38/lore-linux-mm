Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5KFJ2tM006943
	for <linux-mm@kvack.org>; Fri, 20 Jun 2008 11:19:02 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5KFJ2Hx117640
	for <linux-mm@kvack.org>; Fri, 20 Jun 2008 11:19:02 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5KFJ1Pt001440
	for <linux-mm@kvack.org>; Fri, 20 Jun 2008 11:19:02 -0400
Subject: Re: [patch 05/21] hugetlb: new sysfs interface
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080604113111.647714612@amd.local0.net>
References: <20080604112939.789444496@amd.local0.net>
	 <20080604113111.647714612@amd.local0.net>
Content-Type: text/plain
Date: Fri, 20 Jun 2008 08:18:58 -0700
Message-Id: <1213975138.7512.33.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, "Serge E. Hallyn" <serue@us.ibm.com>, kathys <kathys@au1.ibm.com>
List-ID: <linux-mm.kvack.org>

This one seems to be causing some compilation errors with SYSFS=n.

>> /scratch/kathys/containers/kernel_trees/upstream/mm/hugetlb.c: In  
>> function 'hugetlb_exit':
>> /scratch/kathys/containers/kernel_trees/upstream/mm/hugetlb.c:1234:  
>> error: 'hstate_kobjs' undeclared (first use in this function)
>> /scratch/kathys/containers/kernel_trees/upstream/mm/hugetlb.c:1234:  
>> error: (Each undeclared identifier is reported only once
>> /scratch/kathys/containers/kernel_trees/upstream/mm/hugetlb.c:1234:  
>> error: for each function it appears in.)
>> /scratch/kathys/containers/kernel_trees/upstream/mm/hugetlb.c:1237:  
>> error: 'hugepages_kobj' undeclared (first use in this function)
>> make[2]: *** [mm/hugetlb.o] Error 1
>> make[1]: *** [mm] Error 2
>> make: *** [sub-make] Error 2

Should we just move hugetlb_exit() inside the sysfs #ifdef with
everything else?

--- linux-2.6.git-mm//mm/hugetlb.c.orig	2008-06-20 08:07:39.000000000 -0700
+++ linux-2.6.git-mm//mm/hugetlb.c	2008-06-20 08:14:36.000000000 -0700
@@ -1193,6 +1193,19 @@
 								h->name);
 	}
 }
+
+static void __exit hugetlb_exit(void)
+{
+	struct hstate *h;
+
+	for_each_hstate(h) {
+		kobject_put(hstate_kobjs[h - hstates]);
+	}
+
+	kobject_put(hugepages_kobj);
+}
+module_exit(hugetlb_exit);
+
 #else
 static void __init hugetlb_sysfs_init(void)
 {
@@ -1226,18 +1239,6 @@
 }
 module_init(hugetlb_init);
 
-static void __exit hugetlb_exit(void)
-{
-	struct hstate *h;
-
-	for_each_hstate(h) {
-		kobject_put(hstate_kobjs[h - hstates]);
-	}
-
-	kobject_put(hugepages_kobj);
-}
-module_exit(hugetlb_exit);
-
 /* Should be called on processing a hugepagesz=... option */
 void __init hugetlb_add_hstate(unsigned order)
 {


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
