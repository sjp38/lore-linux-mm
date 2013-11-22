Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2716B0035
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 18:45:08 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id g10so1906644pdj.15
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 15:45:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id hb3si20978549pac.7.2013.11.22.15.45.06
        for <linux-mm@kvack.org>;
        Fri, 22 Nov 2013 15:45:07 -0800 (PST)
Date: Fri, 22 Nov 2013 15:45:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: add strictlimit knob -v2
Message-Id: <20131122154505.3e686fcfc584534d555399e5@linux-foundation.org>
In-Reply-To: <20131106150515.25906.55017.stgit@dhcp-10-30-17-2.sw.ru>
References: <20131104140104.7936d263258a7a6753eb325e@linux-foundation.org>
	<20131106150515.25906.55017.stgit@dhcp-10-30-17-2.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Patlasov <MPatlasov@parallels.com>
Cc: karl.kiniger@med.ge.com, tytso@mit.edu, linux-kernel@vger.kernel.org, t.artem@lycos.com, linux-mm@kvack.org, mgorman@suse.de, jack@suse.cz, fengguang.wu@intel.com, torvalds@linux-foundation.org, mpatlasov@parallels.com

On Wed, 06 Nov 2013 19:05:57 +0400 Maxim Patlasov <MPatlasov@parallels.com> wrote:

> "strictlimit" feature was introduced to enforce per-bdi dirty limits for
> FUSE which sets bdi max_ratio to 1% by default:
> 
> http://article.gmane.org/gmane.linux.kernel.mm/105809
> 
> However the feature can be useful for other relatively slow or untrusted
> BDIs like USB flash drives and DVD+RW. The patch adds a knob to enable the
> feature:
> 
> echo 1 > /sys/class/bdi/X:Y/strictlimit
> 
> Being enabled, the feature enforces bdi max_ratio limit even if global (10%)
> dirty limit is not reached. Of course, the effect is not visible until
> /sys/class/bdi/X:Y/max_ratio is decreased to some reasonable value.
> 
> ...
>
> --- a/Documentation/ABI/testing/sysfs-class-bdi
> +++ b/Documentation/ABI/testing/sysfs-class-bdi
> @@ -53,3 +53,11 @@ stable_pages_required (read-only)
>  
>  	If set, the backing device requires that all pages comprising a write
>  	request must not be changed until writeout is complete.
> +
> +strictlimit (read-write)
> +
> +	Forces per-BDI checks for the share of given device in the write-back
> +	cache even before the global background dirty limit is reached. This
> +	is useful in situations where the global limit is much higher than
> +	affordable for given relatively slow (or untrusted) device. Turning
> +	strictlimit on has no visible effect if max_ratio is equal to 100%.
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index ce682f7..4ee1d64 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -234,11 +234,46 @@ static ssize_t stable_pages_required_show(struct device *dev,
>  }
>  static DEVICE_ATTR_RO(stable_pages_required);
>  
> +static ssize_t strictlimit_store(struct device *dev,
> +		struct device_attribute *attr, const char *buf, size_t count)
> +{
> +	struct backing_dev_info *bdi = dev_get_drvdata(dev);
> +	unsigned int val;
> +	ssize_t ret;
> +
> +	ret = kstrtouint(buf, 10, &val);
> +	if (ret < 0)
> +		return ret;
> +
> +	switch (val) {
> +	case 0:
> +		bdi->capabilities &= ~BDI_CAP_STRICTLIMIT;
> +		break;
> +	case 1:
> +		bdi->capabilities |= BDI_CAP_STRICTLIMIT;
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
> +
> +	return count;
> +}
> +static ssize_t strictlimit_show(struct device *dev,
> +		struct device_attribute *attr, char *page)
> +{
> +	struct backing_dev_info *bdi = dev_get_drvdata(dev);
> +
> +	return snprintf(page, PAGE_SIZE-1, "%d\n",
> +			!!(bdi->capabilities & BDI_CAP_STRICTLIMIT));
> +}
> +static DEVICE_ATTR_RW(strictlimit);
> +
>  static struct attribute *bdi_dev_attrs[] = {
>  	&dev_attr_read_ahead_kb.attr,
>  	&dev_attr_min_ratio.attr,
>  	&dev_attr_max_ratio.attr,
>  	&dev_attr_stable_pages_required.attr,
> +	&dev_attr_strictlimit.attr,
>  	NULL,

Well the patch is certainly simple and straightforward enough and
*seems* like it will be useful.  The main (and large!) downside is that
it adds to the user interface so we'll have to maintain this feature
and its functionality for ever.

Given this, my concern is that while potentially useful, the feature
might not be *sufficiently* useful to justify its inclusion.  So we'll
end up addressing these issues by other means, then we're left
maintaining this obsolete legacy feature.

So I'm thinking that unless someone can show that this is good and
complete and sufficient for a "large enough" set of issues, I'll take a
pass on the patch[1].  What do people think?


[1] Actually, I'll stick it in -mm and maintain it, so next time
someone reports an issue I can say "hey, try this".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
