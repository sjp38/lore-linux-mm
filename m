Subject: [RFQ]  aic7xxx driver panics under heavy swap.
Message-ID: <OFFC1B2C1B.7F406B4A-ON85256A70.00564265@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Tue, 19 Jun 2001 11:46:02 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: gibbs@scsiguy.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Justin,
When free memory is low, I get a series of aic7xxx messages followed by
panic.
It appears to be a race condition in the code.  Should you panic?  I tried
the following
patch to not panic.  But I am not sure if it is functionally correct.
Bulent


scsi0: Temporary Resource Shortage
scsi0: Temporary Resource Shortage
scsi0: Temporary Resource Shortage
scsi0: Temporary Resource Shortage
scsi0: Temporary Resource Shortage
Kernel panic: running device on run list


--- aic7xxx_linux.c.save Mon Jun 18 20:25:35 2001
+++ aic7xxx_linux.c Mon Jun 18 20:26:29 2001
@@ -1552,12 +1552,14 @@
           * Get an scb to use.
           */
          if ((scb = ahc_get_scb(ahc)) == NULL) {
+              ahc->flags |= AHC_RESOURCE_SHORTAGE;
               if ((dev->flags & AHC_DEV_ON_RUN_LIST) != 0)
-                   panic("running device on run list");
+                   return;
+                   // panic("running device on run list");
               LIST_INSERT_HEAD(&ahc->platform_data->device_runq,
                          dev, links);
               dev->flags |= AHC_DEV_ON_RUN_LIST;
-              ahc->flags |= AHC_RESOURCE_SHORTAGE;
+              // ahc->flags |= AHC_RESOURCE_SHORTAGE;
               printf("%s: Temporary Resource Shortage\n",
                      ahc_name(ahc));
               return;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
