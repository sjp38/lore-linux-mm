Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A35406B025E
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 20:09:31 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id f132so2624883wmf.6
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 17:09:31 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b190si2782764wmd.4.2017.12.06.17.09.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 17:09:30 -0800 (PST)
Date: Wed, 6 Dec 2017 17:09:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 15/15] mm: add strictlimit knob
Message-Id: <20171206170927.5d40106be6fdc6dc88354b65@linux-foundation.org>
In-Reply-To: <20171201122928.GD8365@quack2.suse.cz>
References: <5a20831e./7a6H+akjTcq4WCk%akpm@linux-foundation.org>
	<20171201122928.GD8365@quack2.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, MPatlasov@parallels.com, fengguang.wu@intel.com, hmh@hmh.eng.br, mel@csn.ul.ie, t.artem@lycos.com, tytso@mit.edu, Jens Axboe <axboe@kernel.dk>

On Fri, 1 Dec 2017 13:29:28 +0100 Jan Kara <jack@suse.cz> wrote:

> On Thu 30-11-17 14:15:58, Andrew Morton wrote:
> > From: Maxim Patlasov <MPatlasov@parallels.com>
> > Subject: mm: add strictlimit knob
> > 
> > The "strictlimit" feature was introduced to enforce per-bdi dirty limits
> > for FUSE which sets bdi max_ratio to 1% by default:
> > 
> > http://article.gmane.org/gmane.linux.kernel.mm/105809
> > 
> > However the feature can be useful for other relatively slow or untrusted
> > BDIs like USB flash drives and DVD+RW.  The patch adds a knob to enable
> > the feature:
> > 
> > echo 1 > /sys/class/bdi/X:Y/strictlimit
> > 
> > Being enabled, the feature enforces bdi max_ratio limit even if global
> > (10%) dirty limit is not reached.  Of course, the effect is not visible
> > until /sys/class/bdi/X:Y/max_ratio is decreased to some reasonable value.
> 
> In principle I have nothing against this and the usecase sounds reasonable
> (in fact I believe the lack of a feature like this is one of reasons why
> desktop automounters usually mount USB devices with 'sync' mount option).
> So feel free to add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> 

Cc Jens, who may be vaguely interested in plans to finally merge this
three-year-old patch?



From: Maxim Patlasov <MPatlasov@parallels.com>
Subject: mm: add strictlimit knob

The "strictlimit" feature was introduced to enforce per-bdi dirty limits
for FUSE which sets bdi max_ratio to 1% by default:

http://article.gmane.org/gmane.linux.kernel.mm/105809

However the feature can be useful for other relatively slow or untrusted
BDIs like USB flash drives and DVD+RW.  The patch adds a knob to enable
the feature:

echo 1 > /sys/class/bdi/X:Y/strictlimit

Being enabled, the feature enforces bdi max_ratio limit even if global
(10%) dirty limit is not reached.  Of course, the effect is not visible
until /sys/class/bdi/X:Y/max_ratio is decreased to some reasonable value.

Jan said:

: In principle I have nothing against this and the usecase sounds reasonable
: (in fact I believe the lack of a feature like this is one of reasons why
: desktop automounters usually mount USB devices with 'sync' mount option). 
: So feel free to add:

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: "Artem S. Tashkinov" <t.artem@lycos.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jens Axboe <axboe@kernel.dk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/ABI/testing/sysfs-class-bdi |    8 ++++
 mm/backing-dev.c                          |   35 ++++++++++++++++++++
 2 files changed, 43 insertions(+)

diff -puN Documentation/ABI/testing/sysfs-class-bdi~mm-add-strictlimit-knob-v2 Documentation/ABI/testing/sysfs-class-bdi
--- a/Documentation/ABI/testing/sysfs-class-bdi~mm-add-strictlimit-knob-v2
+++ a/Documentation/ABI/testing/sysfs-class-bdi
@@ -53,3 +53,11 @@ stable_pages_required (read-only)
 
 	If set, the backing device requires that all pages comprising a write
 	request must not be changed until writeout is complete.
+
+strictlimit (read-write)
+
+	Forces per-BDI checks for the share of given device in the write-back
+	cache even before the global background dirty limit is reached. This
+	is useful in situations where the global limit is much higher than
+	affordable for given relatively slow (or untrusted) device. Turning
+	strictlimit on has no visible effect if max_ratio is equal to 100%.
diff -puN mm/backing-dev.c~mm-add-strictlimit-knob-v2 mm/backing-dev.c
--- a/mm/backing-dev.c~mm-add-strictlimit-knob-v2
+++ a/mm/backing-dev.c
@@ -231,11 +231,46 @@ static ssize_t stable_pages_required_sho
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
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
