Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 170F56B00EA
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:24:40 -0400 (EDT)
From: Venkatraman S <svenkatr@ti.com>
Subject: [PATCH v2 12/16] mmc: sysfs: Add sysfs entry for tuning preempt_time_threshold
Date: Thu, 3 May 2012 19:53:11 +0530
Message-ID: <1336054995-22988-13-git-send-email-svenkatr@ti.com>
In-Reply-To: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk, Venkatraman S <svenkatr@ti.com>

When High Priority Interrupt (HPI) is enabled, ongoing requests
might be preempted. It is worthwhile to not preempt some requests
which have progressed in the underlying driver for some time.

The threshold of elapsed time after which HPI is not useful can
be tuned on a per-device basis, using the hpi_time_threshold
sysfs entry.

Signed-off-by: Venkatraman S <svenkatr@ti.com>
---
 drivers/mmc/core/mmc.c   |   25 +++++++++++++++++++++++++
 include/linux/mmc/card.h |    1 +
 2 files changed, 26 insertions(+)

diff --git a/drivers/mmc/core/mmc.c b/drivers/mmc/core/mmc.c
index 54df5ad..b7dbea1 100644
--- a/drivers/mmc/core/mmc.c
+++ b/drivers/mmc/core/mmc.c
@@ -624,6 +624,30 @@ MMC_DEV_ATTR(enhanced_area_offset, "%llu\n",
 		card->ext_csd.enhanced_area_offset);
 MMC_DEV_ATTR(enhanced_area_size, "%u\n", card->ext_csd.enhanced_area_size);
 
+static ssize_t mmc_hpi_threhold_show(struct device *dev,
+	struct device_attribute *attr, char *buf)
+{
+	struct mmc_card *card = mmc_dev_to_card(dev);
+	return sprintf(buf, "%d\n", card->preempt_time_threshold);
+}
+
+static ssize_t mmc_hpi_threshold_store(struct device *dev,
+	struct device_attribute *attr,
+	const char *buf, size_t count)
+{
+	unsigned long threshold;
+	struct mmc_card *card = mmc_dev_to_card(dev);
+
+	if (kstrtoul(buf, 0, &threshold))
+		return -EINVAL;
+	if (threshold)
+		card->preempt_time_threshold = threshold;
+	return count;
+}
+
+DEVICE_ATTR(hpi_time_threshold, S_IRWXU, mmc_hpi_threhold_show,
+	mmc_hpi_threshold_store);
+
 static struct attribute *mmc_std_attrs[] = {
 	&dev_attr_cid.attr,
 	&dev_attr_csd.attr,
@@ -638,6 +662,7 @@ static struct attribute *mmc_std_attrs[] = {
 	&dev_attr_serial.attr,
 	&dev_attr_enhanced_area_offset.attr,
 	&dev_attr_enhanced_area_size.attr,
+	&dev_attr_hpi_time_threshold.attr,
 	NULL,
 };
 
diff --git a/include/linux/mmc/card.h b/include/linux/mmc/card.h
index 629b823..2a0da29 100644
--- a/include/linux/mmc/card.h
+++ b/include/linux/mmc/card.h
@@ -245,6 +245,7 @@ struct mmc_card {
  	unsigned int		erase_shift;	/* if erase unit is power 2 */
  	unsigned int		pref_erase;	/* in sectors */
  	u8			erased_byte;	/* value of erased bytes */
+	unsigned int preempt_time_threshold;    /* ms for checking hpi usage */
 
 	u32			raw_cid[4];	/* raw card CID */
 	u32			raw_csd[4];	/* raw card CSD */
-- 
1.7.10.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
