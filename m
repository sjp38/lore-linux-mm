Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 606F16B0036
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 10:31:52 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so4329358pbc.23
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 07:31:52 -0700 (PDT)
Received: from psmtp.com ([74.125.245.112])
        by mx.google.com with SMTP id hj4si5018658pac.242.2013.11.01.07.31.48
        for <linux-mm@kvack.org>;
        Fri, 01 Nov 2013 07:31:48 -0700 (PDT)
Subject: [PATCH] mm: add strictlimit knob
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Fri, 01 Nov 2013 18:31:40 +0400
Message-ID: <20131101142941.1161.40314.stgit@dhcp-10-30-17-2.sw.ru>
In-Reply-To: <20131031142612.GA28003@kipc2.localdomain>
References: <20131031142612.GA28003@kipc2.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: karl.kiniger@med.ge.com
Cc: jack@suse.cz, linux-kernel@vger.kernel.org, t.artem@lycos.com, linux-mm@kvack.org, mgorman@suse.de, tytso@mit.edu, akpm@linux-foundation.org, fengguang.wu@intel.com, torvalds@linux-foundation.org, mpatlasov@parallels.com

"strictlimit" feature was introduced to enforce per-bdi dirty limits for
FUSE which sets bdi max_ratio to 1% by default:

http://www.http.com//article.gmane.org/gmane.linux.kernel.mm/105809

However the feature can be useful for other relatively slow or untrusted
BDIs like USB flash drives and DVD+RW. The patch adds a knob to enable the
feature:

echo 1 > /sys/class/bdi/X:Y/strictlimit

Being enabled, the feature enforces bdi max_ratio limit even if global (10%)
dirty limit is not reached. Of course, the effect is not visible until
max_ratio is decreased to some reasonable value.

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
---
 mm/backing-dev.c |   35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index ce682f7..4ee1d64 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -234,11 +234,46 @@ static ssize_t stable_pages_required_show(struct device *dev,
 }
 static DEVICE_ATTR_RO(stable_pages_required);
 
+static ssize_t strictlimit_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct backing_dev_info *bdi = dev_get_drvdata(dev);
+	unsigned int val;
+	ssize_t ret;
+
+	ret = kstrtouint(buf, 10, &val);
+	if (ret < 0)
+		return ret;
+
+	switch (val) {
+	case 0:
+		bdi->capabilities &= ~BDI_CAP_STRICTLIMIT;
+		break;
+	case 1:
+		bdi->capabilities |= BDI_CAP_STRICTLIMIT;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return count;
+}
+static ssize_t strictlimit_show(struct device *dev,
+		struct device_attribute *attr, char *page)
+{
+	struct backing_dev_info *bdi = dev_get_drvdata(dev);
+
+	return snprintf(page, PAGE_SIZE-1, "%d\n",
+			!!(bdi->capabilities & BDI_CAP_STRICTLIMIT));
+}
+static DEVICE_ATTR_RW(strictlimit);
+
 static struct attribute *bdi_dev_attrs[] = {
 	&dev_attr_read_ahead_kb.attr,
 	&dev_attr_min_ratio.attr,
 	&dev_attr_max_ratio.attr,
 	&dev_attr_stable_pages_required.attr,
+	&dev_attr_strictlimit.attr,
 	NULL,
 };
 ATTRIBUTE_GROUPS(bdi_dev);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
