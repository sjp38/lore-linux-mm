Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.5) with ESMTP id kA9JkfFC159780
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 06:46:41 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kA9JdAdT230548
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 06:39:20 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kA9JZihY012573
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 06:35:44 +1100
From: Balbir Singh <balbir@in.ibm.com>
Date: Fri, 10 Nov 2006 01:05:32 +0530
Message-Id: <20061109193532.21437.66303.sendpatchset@balbir.in.ibm.com>
In-Reply-To: <20061109193523.21437.86224.sendpatchset@balbir.in.ibm.com>
References: <20061109193523.21437.86224.sendpatchset@balbir.in.ibm.com>
Subject: [RFC][PATCH 1/8] Fix resource groups parsing, while assigning shares
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: dev@openvz.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ckrm-tech@lists.sourceforge.net, haveblue@us.ibm.com, rohitseth@google.com, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>


echo adds a "\n" to the end of a string. When this string is copied from
user space, we need to remove it, so that match_token() can parse
the user space string correctly

Signed-off-by: Balbir Singh <balbir@in.ibm.com>
---

 kernel/res_group/rgcs.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff -puN kernel/res_group/rgcs.c~container-res-groups-fix-parsing kernel/res_group/rgcs.c
--- linux-2.6.19-rc2/kernel/res_group/rgcs.c~container-res-groups-fix-parsing	2006-11-09 23:08:10.000000000 +0530
+++ linux-2.6.19-rc2-balbir/kernel/res_group/rgcs.c	2006-11-09 23:08:10.000000000 +0530
@@ -241,6 +241,12 @@ ssize_t res_group_file_write(struct cont
 	}
 	buf[nbytes] = 0;	/* nul-terminate */
 
+	/*
+	 * Ignore "\n". It might come in from echo(1)
+	 */
+	if (buf[nbytes - 1] == '\n')
+		buf[nbytes - 1] = 0;
+
 	container_manage_lock();
 
 	if (container_is_removed(cont)) {
_

-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
