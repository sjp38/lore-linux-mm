Received: from smtp3.akamai.com (vwall1.sanmateo.corp.akamai.com [172.23.1.71])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j0T372NZ005564
	for <linux-mm@kvack.org>; Fri, 28 Jan 2005 19:07:03 -0800 (PST)
Message-ID: <41FAFEF1.B13D59BA@akamai.com>
Date: Fri, 28 Jan 2005 19:11:46 -0800
From: Prasanna Meda <pmeda@akamai.com>
MIME-Version: 1.0
Subject: test_root reorder(Re: [patch] ext2: Apply Jack's ext3 speedups)
References: <200501270722.XAA10830@allur.sanmateo.akamai.com> <20050127205233.GB9225@thunk.org> <41FAED57.DFCF1D22@akamai.com>
Content-Type: multipart/mixed;
 boundary="------------87801D4273DB0252B559177E"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, akpm@osdl.org, jack@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------87801D4273DB0252B559177E
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Prasanna Meda wrote:

>   - Folded all three root checkings for 3,  5 and 7 into one loop.
>   -  Short cut the loop with 3**n < 5 **n < 7**n logic.
>   -  Even numbers can be ruled out.

Without going to that complicated path, the better performance
is achieved with just reordering  of the tests from 3,5,7 to 7,5.3, so
that average case becomes better. This is more simpler than
 folding  patch.


Thanks,
Prasanna.


--------------87801D4273DB0252B559177E
Content-Type: text/plain; charset=us-ascii;
 name="ext3_test_root_reorder.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ext3_test_root_reorder.patch"



 Reorder test_root testing from 3,5,7 to 7,5,3 so
 that average case becomes good. Even number check
 is added. 

 Signed-off-by: Prasanna Meda <pmeda@akamai.com>

--- a/fs/ext3/balloc.c	Fri Jan 28 22:21:45 2005
+++ b/fs/ext3/balloc.c	Sat Jan 29 02:51:39 2005
@@ -1451,8 +1451,10 @@
 {
 	if (group <= 1)
 		return 1;
-	return (test_root(group, 3) || test_root(group, 5) ||
-		test_root(group, 7));
+	if (!(group & 1))
+		return 0;
+	return (test_root(group, 7) || test_root(group, 5) ||
+		test_root(group, 3));
 }
 
 /**

--------------87801D4273DB0252B559177E--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
