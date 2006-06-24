Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5O264KJ001163
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 22:06:04 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5O25be0275814
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 20:05:38 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5O263oI016287
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 20:06:04 -0600
Subject: [RFC] Patch [3/4] x86_64 sparsmem add - acpi added pages are not
	reserved?
From: keith mannthey <kmannth@us.ibm.com>
Reply-To: kmannth@us.ibm.com
Content-Type: multipart/mixed; boundary="=-rMlL5mMM9e7As5pYY4Zs"
Date: Fri, 23 Jun 2006 19:06:03 -0700
Message-Id: <1151114763.7094.52.camel@keithlap>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lhms-devel <lhms-devel@lists.sourceforge.net>
Cc: linux-mm <linux-mm@kvack.org>, dave hansen <haveblue@us.ibm.com>, kame <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

--=-rMlL5mMM9e7As5pYY4Zs
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I got everything in place to do a working hot-add with 2.6.17-mm1 and I
ran into another trouble spot.  

I added the memory just fine(new device is sysfs) but when I went to on-
line them in sysfs I tripped over the little section of code this patch
comments out.  I was get device not ready messages on my console and the
comment printed in my kernel log.   

  With hacked acpi drivers outside of -mm I don't run into the problem
so I think something is a little off in -mm. 

  The code is expecting the added but not on-lined code to be marked
reserved. This isn't happening for my ACPI hot-add on x86_64. I am not
sure who in this call path needs to reserve the pages or if the check
for reserve is a valid with this new hot-add code.    

Any ideas?

Signed-off-by:  Keith Mannthey <kmannth@us.ibm.com>

--=-rMlL5mMM9e7As5pYY4Zs
Content-Disposition: attachment; filename=patch-2.6.17-mm1-reservehack
Content-Type: text/x-patch; name=patch-2.6.17-mm1-reservehack; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -urN linux-2.6.17-mm1-orig/drivers/base/memory.c linux-2.6.17-mm1/drivers/base/memory.c
--- linux-2.6.17-mm1-orig/drivers/base/memory.c	2006-06-23 16:12:01.000000000 -0400
+++ linux-2.6.17-mm1/drivers/base/memory.c	2006-06-23 20:04:04.000000000 -0400
@@ -163,9 +163,9 @@
 	/*
 	 * The probe routines leave the pages reserved, just
 	 * as the bootmem code does.  Make sure they're still
-	 * that way.
+	 * that way.  UNLESS you do real hot add? 
 	 */
-	if (action == MEM_ONLINE) {
+/*	if (action == MEM_ONLINE) {
 		for (i = 0; i < PAGES_PER_SECTION; i++) {
 			if (PageReserved(first_page+i))
 				continue;
@@ -176,6 +176,7 @@
 			return -EBUSY;
 		}
 	}
+*/
 
 	switch (action) {
 		case MEM_ONLINE:

--=-rMlL5mMM9e7As5pYY4Zs--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
