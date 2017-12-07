Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9E56B0038
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 23:15:06 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j26so4488590pff.8
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 20:15:06 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id u131si2955682pgb.489.2017.12.06.20.15.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 20:15:04 -0800 (PST)
Date: Thu, 7 Dec 2017 12:14:59 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [patch 15/15] mm: add strictlimit knob
Message-ID: <20171207041459.64myz37qwmjkoxu5@wfg-t540p.sh.intel.com>
References: <5a20831e./7a6H+akjTcq4WCk%akpm@linux-foundation.org>
 <20171201122928.GD8365@quack2.suse.cz>
 <20171206170927.5d40106be6fdc6dc88354b65@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20171206170927.5d40106be6fdc6dc88354b65@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, MPatlasov@parallels.com, hmh@hmh.eng.br, mel@csn.ul.ie, t.artem@lycos.com, tytso@mit.edu, Jens Axboe <axboe@kernel.dk>, Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel@vger.kernel.org

CC fuse maintainer, too.

On Wed, Dec 06, 2017 at 05:09:27PM -0800, Andrew Morton wrote:
>On Fri, 1 Dec 2017 13:29:28 +0100 Jan Kara <jack@suse.cz> wrote:
>
>> On Thu 30-11-17 14:15:58, Andrew Morton wrote:
>> > From: Maxim Patlasov <MPatlasov@parallels.com>
>> > Subject: mm: add strictlimit knob
>> >
>> > The "strictlimit" feature was introduced to enforce per-bdi dirty limits
>> > for FUSE which sets bdi max_ratio to 1% by default:
>> >
>> > http://article.gmane.org/gmane.linux.kernel.mm/105809
>> >
>> > However the feature can be useful for other relatively slow or untrusted
>> > BDIs like USB flash drives and DVD+RW.  The patch adds a knob to enable
>> > the feature:
>> >
>> > echo 1 > /sys/class/bdi/X:Y/strictlimit
>> >
>> > Being enabled, the feature enforces bdi max_ratio limit even if global
>> > (10%) dirty limit is not reached.  Of course, the effect is not visible
>> > until /sys/class/bdi/X:Y/max_ratio is decreased to some reasonable value.
>>
>> In principle I have nothing against this and the usecase sounds reasonable
>> (in fact I believe the lack of a feature like this is one of reasons why
>> desktop automounters usually mount USB devices with 'sync' mount option).
>> So feel free to add:
>>
>> Reviewed-by: Jan Kara <jack@suse.cz>
>>
>
>Cc Jens, who may be vaguely interested in plans to finally merge this
>three-year-old patch?
>
>
>
>From: Maxim Patlasov <MPatlasov@parallels.com>
>Subject: mm: add strictlimit knob
>
>The "strictlimit" feature was introduced to enforce per-bdi dirty limits
>for FUSE which sets bdi max_ratio to 1% by default:
>
>http://article.gmane.org/gmane.linux.kernel.mm/105809

That link is invalid for now, possibly due to the gmane site rebuild.
I find an email thread here which looks relevant:

https://sourceforge.net/p/fuse/mailman/message/35254883/

Where Maxim has an interesting point:

        > Did any one try increasing the limit and did see any better/worse 
        > performance ?

        We've used 20% as default value in OpenVZ kernel for a long while (1% 
        was not enough to saturate our distributed parallel storage).

So the knob will also enable people to _disable_ the 1% fuse limit to
increase performance.

So people can use the exposed knob in 2 ways to fit their needs, which
is in general a good thing.

However the comment in wb_position_ratio() says

                        Without strictlimit feature, fuse writeback may
	 * consume arbitrary amount of RAM because it is accounted in
	 * NR_WRITEBACK_TEMP which is not involved in calculating "nr_dirty".

How dangerous would that be if some user disabled the 1% fuse limit
through the exposed knob? Will the NR_WRITEBACK_TEMP effect go far
beyond the user's expectation (20% max dirty limit)?

Looking at the fuse code, NR_WRITEBACK_TEMP will grow proportional to
WB_WRITEBACK, which should be throttled when bdi_write_congested().
The congested flag will be set on

        fuse_conn.num_background >= fuse_conn.congestion_threshold
        
So it looks NR_WRITEBACK_TEMP will somehow be throttled. Just that
it's not included in the 20% dirty limit.

Other than that concern, the patch looks good to me.

Thanks,
Fengguang

>However the feature can be useful for other relatively slow or untrusted
>BDIs like USB flash drives and DVD+RW.  The patch adds a knob to enable
>the feature:
>
>echo 1 > /sys/class/bdi/X:Y/strictlimit
>
>Being enabled, the feature enforces bdi max_ratio limit even if global
>(10%) dirty limit is not reached.  Of course, the effect is not visible
>until /sys/class/bdi/X:Y/max_ratio is decreased to some reasonable value.
>
>Jan said:
>
>: In principle I have nothing against this and the usecase sounds reasonable
>: (in fact I believe the lack of a feature like this is one of reasons why
>: desktop automounters usually mount USB devices with 'sync' mount option).
>: So feel free to add:
>
>Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
>Reviewed-by: Jan Kara <jack@suse.cz>
>Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
>Cc: Theodore Ts'o <tytso@mit.edu>
>Cc: "Artem S. Tashkinov" <t.artem@lycos.com>
>Cc: Mel Gorman <mel@csn.ul.ie>
>Cc: Jan Kara <jack@suse.cz>
>Cc: Wu Fengguang <fengguang.wu@intel.com>
>Cc: Jens Axboe <axboe@kernel.dk>
>Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>---
>
> Documentation/ABI/testing/sysfs-class-bdi |    8 ++++
> mm/backing-dev.c                          |   35 ++++++++++++++++++++
> 2 files changed, 43 insertions(+)
>
>diff -puN Documentation/ABI/testing/sysfs-class-bdi~mm-add-strictlimit-knob-v2 Documentation/ABI/testing/sysfs-class-bdi
>--- a/Documentation/ABI/testing/sysfs-class-bdi~mm-add-strictlimit-knob-v2
>+++ a/Documentation/ABI/testing/sysfs-class-bdi
>@@ -53,3 +53,11 @@ stable_pages_required (read-only)
>
> 	If set, the backing device requires that all pages comprising a write
> 	request must not be changed until writeout is complete.
>+
>+strictlimit (read-write)
>+
>+	Forces per-BDI checks for the share of given device in the write-back
>+	cache even before the global background dirty limit is reached. This
>+	is useful in situations where the global limit is much higher than
>+	affordable for given relatively slow (or untrusted) device. Turning
>+	strictlimit on has no visible effect if max_ratio is equal to 100%.
>diff -puN mm/backing-dev.c~mm-add-strictlimit-knob-v2 mm/backing-dev.c
>--- a/mm/backing-dev.c~mm-add-strictlimit-knob-v2
>+++ a/mm/backing-dev.c
>@@ -231,11 +231,46 @@ static ssize_t stable_pages_required_sho
> }
> static DEVICE_ATTR_RO(stable_pages_required);
>
>+static ssize_t strictlimit_store(struct device *dev,
>+		struct device_attribute *attr, const char *buf, size_t count)
>+{
>+	struct backing_dev_info *bdi = dev_get_drvdata(dev);
>+	unsigned int val;
>+	ssize_t ret;
>+
>+	ret = kstrtouint(buf, 10, &val);
>+	if (ret < 0)
>+		return ret;
>+
>+	switch (val) {
>+	case 0:
>+		bdi->capabilities &= ~BDI_CAP_STRICTLIMIT;
>+		break;
>+	case 1:
>+		bdi->capabilities |= BDI_CAP_STRICTLIMIT;
>+		break;
>+	default:
>+		return -EINVAL;
>+	}
>+
>+	return count;
>+}
>+static ssize_t strictlimit_show(struct device *dev,
>+		struct device_attribute *attr, char *page)
>+{
>+	struct backing_dev_info *bdi = dev_get_drvdata(dev);
>+
>+	return snprintf(page, PAGE_SIZE-1, "%d\n",
>+			!!(bdi->capabilities & BDI_CAP_STRICTLIMIT));
>+}
>+static DEVICE_ATTR_RW(strictlimit);
>+
> static struct attribute *bdi_dev_attrs[] = {
> 	&dev_attr_read_ahead_kb.attr,
> 	&dev_attr_min_ratio.attr,
> 	&dev_attr_max_ratio.attr,
> 	&dev_attr_stable_pages_required.attr,
>+	&dev_attr_strictlimit.attr,
> 	NULL,
> };
> ATTRIBUTE_GROUPS(bdi_dev);
>_
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
