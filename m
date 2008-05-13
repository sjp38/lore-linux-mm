Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4DHKjDB015036
	for <linux-mm@kvack.org>; Tue, 13 May 2008 13:20:45 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4DHNwx5094764
	for <linux-mm@kvack.org>; Tue, 13 May 2008 11:23:59 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4DHNvK6031415
	for <linux-mm@kvack.org>; Tue, 13 May 2008 11:23:57 -0600
Message-ID: <4829CEAF.9020806@us.ibm.com>
Date: Tue, 13 May 2008 12:23:59 -0500
From: Jon Tollefson <kniht@us.ibm.com>
Reply-To: kniht@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: [PATCH 5/6 v2] check for overflow
References: <4829CAC3.30900@us.ibm.com>
In-Reply-To: <4829CAC3.30900@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@ozlabs.org>
Cc: Paul Mackerras <paulus@samba.org>, Nick Piggin <npiggin@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Adds a check for an overflow in the filesystem size so if someone is
checking with statfs() on a 16G hugetlbfs  in a 32bit binary that it
will report back EOVERFLOW instead of a size of 0.

Are other places that need a similar check?  I had tried a similar
check in put_compat_statfs64 too but it didn't seem to generate an
EOVERFLOW in my test case.


Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
---

 fs/compat.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)


diff --git a/fs/compat.c b/fs/compat.c
index 2ce4456..6eb6aad 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -196,8 +196,8 @@ static int put_compat_statfs(struct compat_statfs __user *ubuf, struct kstatfs *
 {
 	
 	if (sizeof ubuf->f_blocks == 4) {
-		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail) &
-		    0xffffffff00000000ULL)
+		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail |
+		     kbuf->f_bsize | kbuf->f_frsize) & 0xffffffff00000000ULL)
 			return -EOVERFLOW;
 		/* f_files and f_ffree may be -1; it's okay
 		 * to stuff that into 32 bits */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
