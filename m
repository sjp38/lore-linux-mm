Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAIJfJqq015228
	for <linux-mm@kvack.org>; Fri, 18 Nov 2005 14:41:19 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAIJgcLY067706
	for <linux-mm@kvack.org>; Fri, 18 Nov 2005 12:42:38 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAIJfJlu020170
	for <linux-mm@kvack.org>; Fri, 18 Nov 2005 12:41:19 -0700
Message-ID: <437E2E5D.1050300@us.ibm.com>
Date: Fri, 18 Nov 2005 11:41:17 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 4/8] Fix a bug in scsi_get_command
References: <437E2C69.4000708@us.ibm.com>
In-Reply-To: <437E2C69.4000708@us.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------070300010604030905020002"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070300010604030905020002
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Testing this patch series uncovered a small bug in scsi_get_command.  This
patch fixes that bug.

-Matt

--------------070300010604030905020002
Content-Type: text/x-patch;
 name="scsi_get_command-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="scsi_get_command-fix.patch"

scsi_get_command() attempts to write into a structure that may not have been
successfully allocated.  Move this write inside the if statement that ensures
we won't panic the kernel with a NULL pointer dereference.

Signed-off-by: Matthew Dobson <colpatch@us.ibm.com>

Index: linux-2.6.15-rc1+critical_pool/drivers/scsi/scsi.c
===================================================================
--- linux-2.6.15-rc1+critical_pool.orig/drivers/scsi/scsi.c	2005-11-15 13:45:38.000000000 -0800
+++ linux-2.6.15-rc1+critical_pool/drivers/scsi/scsi.c	2005-11-17 16:49:54.279656112 -0800
@@ -265,10 +265,10 @@ struct scsi_cmnd *scsi_get_command(struc
 		spin_lock_irqsave(&dev->list_lock, flags);
 		list_add_tail(&cmd->list, &dev->cmd_list);
 		spin_unlock_irqrestore(&dev->list_lock, flags);
+		cmd->jiffies_at_alloc = jiffies;
 	} else
 		put_device(&dev->sdev_gendev);
 
-	cmd->jiffies_at_alloc = jiffies;
 	return cmd;
 }				
 EXPORT_SYMBOL(scsi_get_command);

--------------070300010604030905020002--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
