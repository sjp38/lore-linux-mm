Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 29D586B00F8
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:24:57 -0400 (EDT)
From: Venkatraman S <svenkatr@ti.com>
Subject: [PATCH v2 15/16] mmc: Update preempted request with CORRECTLY_PRG_SECTORS_NUM info
Date: Thu, 3 May 2012 19:53:14 +0530
Message-ID: <1336054995-22988-16-git-send-email-svenkatr@ti.com>
In-Reply-To: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk, Venkatraman S <svenkatr@ti.com>

Ongoing request that was preempted during 'programming' state is partially
completed. Number of correctly programmed sectors is available in the
ext_csd field CORRECTLY_PRG_SECTORS_NUM. Read this field to update
the bytes_xfered field of the request

Signed-off-by: Venkatraman S <svenkatr@ti.com>
---
 drivers/mmc/core/core.c |   26 ++++++++++++++++++++++++--
 include/linux/mmc/mmc.h |    4 ++++
 2 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/mmc/core/core.c b/drivers/mmc/core/core.c
index e6430f8..354dd7a 100644
--- a/drivers/mmc/core/core.c
+++ b/drivers/mmc/core/core.c
@@ -122,6 +122,23 @@ static inline void mmc_should_fail_request(struct mmc_host *host,
 
 #endif /* CONFIG_FAIL_MMC_REQUEST */
 
+static int mmc_get_programmed_sectors(struct mmc_card *card, int *nsectors)
+{
+	int err;
+	u8 ext_csd[512];
+
+	mmc_claim_host(card->host);
+	err = mmc_send_ext_csd(card, ext_csd);
+	mmc_release_host(card->host);
+	if (err)
+		return err;
+	*nsectors = ext_csd[EXT_CSD_C_PRG_SECTORS_NUM0] +
+			(ext_csd[EXT_CSD_C_PRG_SECTORS_NUM1] << 7) +
+			(ext_csd[EXT_CSD_C_PRG_SECTORS_NUM2] << 15) +
+			(ext_csd[EXT_CSD_C_PRG_SECTORS_NUM3] << 23);
+
+	return 0;
+}
 /**
  *	mmc_request_done - finish processing an MMC request
  *	@host: MMC host which completed request
@@ -470,6 +487,7 @@ int mmc_preempt_foreground_request(struct mmc_card *card,
 	struct mmc_request *req)
 {
 	int ret;
+	int nsectors;
 
 	ret = mmc_abort_req(card->host, req);
 	if (ret == -ENOSYS)
@@ -490,8 +508,12 @@ int mmc_preempt_foreground_request(struct mmc_card *card,
 	 */
 	if (req->data && req->data->error) {
 		mmc_interrupt_hpi(card);
-		/* TODO : Take out the CORRECTLY_PRG_SECTORS_NUM
-		 * from ext_csd and add it to the request */
+
+		ret = mmc_get_programmed_sectors(card, &nsectors);
+		if (ret)
+			req->data->bytes_xfered = 0;
+		else
+			req->data->bytes_xfered = nsectors * 512;
 	}
 
 	return 0;
diff --git a/include/linux/mmc/mmc.h b/include/linux/mmc/mmc.h
index ec2f195..4a3453f 100644
--- a/include/linux/mmc/mmc.h
+++ b/include/linux/mmc/mmc.h
@@ -315,6 +315,10 @@ struct _mmc_csd {
 #define EXT_CSD_PWR_CL_200_360		237	/* RO */
 #define EXT_CSD_PWR_CL_DDR_52_195	238	/* RO */
 #define EXT_CSD_PWR_CL_DDR_52_360	239	/* RO */
+#define EXT_CSD_C_PRG_SECTORS_NUM0	242	/* RO */
+#define EXT_CSD_C_PRG_SECTORS_NUM1	243	/* RO */
+#define EXT_CSD_C_PRG_SECTORS_NUM2	244	/* RO */
+#define EXT_CSD_C_PRG_SECTORS_NUM3	245	/* RO */
 #define EXT_CSD_POWER_OFF_LONG_TIME	247	/* RO */
 #define EXT_CSD_GENERIC_CMD6_TIME	248	/* RO */
 #define EXT_CSD_CACHE_SIZE		249	/* RO, 4 bytes */
-- 
1.7.10.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
