Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B90E6C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 12:17:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C4DB20879
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 12:17:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C4DB20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0EAE6B0003; Mon, 25 Mar 2019 08:17:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC0216B0005; Mon, 25 Mar 2019 08:17:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AEE06B0007; Mon, 25 Mar 2019 08:17:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1256B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 08:17:06 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t5so9539892pfh.18
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 05:17:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=F8xGoAIbcv0N4+AZF7fYdh+mrUKOAEi4hBwwXjXRGrU=;
        b=b+SV1lJbonZt10q9St7TSyDIotJ22Rvg06Pu5LrLp89qQQ91opAY4qIbc3sznenOsO
         zq/5eeFgSqfZ9sit69qDE09gGtyhAzY9MMHlDA7tpjaMaynjD8nZdNWYF+nQ0RgnVMVy
         JblveF2ocDbMWAKflrdfoHuoNBnE4H8oJiSNzIFVntcd7Y+2V+SdK/HOjl3D1R8IQ9/U
         sd4l0IUNvsFl9rZECANKJgPLpK8Ncuvff4uAR72AIBrZNNlQc6pvdeqiCssYjsdoUjyf
         cQInJLOuTI1tC9pazsQ1jhHu+yR5crlcmr1fgsVGYGOHI1MzbU1kCKSySiONqwLDTuaD
         kHpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU2sUpemP0HBqfdBaIH7vOimXB6Dos9Cx+LhTpTBD9pOPrKG02J
	/zHgciaqA4ABU8CWlntP7gz4Yog9Sq3Yebo2Nzahvzy6y8hVDbKpovDn7yYvetkrYqMtYVmmDo2
	91oq3OvDPsvYgdFyfZUPDkUCkhnSHhG1Fn7Fd/MpRI2VINfWLRjoOcNLK/uYeUPJXpg==
X-Received: by 2002:a62:304:: with SMTP id 4mr3804271pfd.99.1553516225950;
        Mon, 25 Mar 2019 05:17:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxo1gA5L+J5C85AJZEj8jNPJocEuk8Bjz5ROMCYSaCMvcaR0oW+p7C0O1MhB4mfPhSyKuUR
X-Received: by 2002:a62:304:: with SMTP id 4mr3804195pfd.99.1553516224800;
        Mon, 25 Mar 2019 05:17:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553516224; cv=none;
        d=google.com; s=arc-20160816;
        b=fIeWDMmO9sMG5EdpjtN3C02Vq6tNBBnkwgClA0cG86SqlN6t+1bX1jgxpCT8UWudxK
         YvN9HjzoDohDC5I/xHs0lEpb2vpuv1ZiZyEzo03Imrh9+F2nBeDU7WYueoMlSkmV0Bah
         QMfi8wcXIBpGWTHYmVeLz5S/M1+wO1uOoQS3J9fGGF6SuoZRvb2PJIcA/XdPw3UaQEtt
         +AZn7W+7IMAd+uUaeaP7e7WW1LrXaFo6MSenJMfsegaDssyC3iB8HFaQz4Ehnv/fL+Tz
         wj5/zMk5Tc0KGewKo+j0IGn7hOaIV3D+N4ImY1s2nXaGkzopVEVBHs0CIHzJgsswk+bJ
         IwBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=F8xGoAIbcv0N4+AZF7fYdh+mrUKOAEi4hBwwXjXRGrU=;
        b=asPod4g2roeUTWxVp7cYGlZfcYdtyDJLft/DUTkXl35SmdXQDsz54aQorzw0oQDsT2
         YTx1pHBF7w/O3ad2P7YcPLJUsIJayQKvj+3gfDeVlQT6hoJ2b1/WMalspEFMvxRVuRk3
         j0w0MkRVP/dVbTbJrIQnTQWXLsAjyPaom1ECDdHOFodvZlYvGADdBsS8mrrWYmmMzrDC
         4VVKb+WqOsL0bCtOg1dPCDUnMASAQqlRhsqwTDf4VAa1Y4MvIptyB/d9e/0WytC3ih4S
         8r3loEAgtRVofB4+xtbHO99CIcL/fCuRyubo/w0/Wa8gSgcJ21l1f89fxqDD02iEVxai
         lebA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id t9si5768130plo.98.2019.03.25.05.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 05:17:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Mar 2019 05:17:03 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,256,1549958400"; 
   d="scan'208";a="137074353"
Received: from zliu7-mobl2.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.212.116])
  by orsmga003.jf.intel.com with ESMTP; 25 Mar 2019 05:16:57 -0700
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1h8OWi-0006jG-QW; Mon, 25 Mar 2019 20:16:28 +0800
Date: Mon, 25 Mar 2019 20:16:28 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Martin Liu <liumartin@google.com>
Cc: akpm@linux-foundation.org, axboe@kernel.dk, dchinner@redhat.com,
	jenhaochen@google.com, salyzyn@google.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-block@vger.kernel.org
Subject: Re: [RFC PATCH] mm: readahead: add readahead_shift into backing
 device
Message-ID: <20190325121628.zxlogz52go6k36on@wfg-t540p.sh.intel.com>
References: <20190322154610.164564-1-liumartin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190322154610.164564-1-liumartin@google.com>
User-Agent: NeoMutt/20170609 (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Martin,

On Fri, Mar 22, 2019 at 11:46:11PM +0800, Martin Liu wrote:
>As the discussion https://lore.kernel.org/patchwork/patch/334982/
>We know an open file's ra_pages might run out of sync from
>bdi.ra_pages since sequential, random or error read. Current design
>is we have to ask users to reopen the file or use fdavise system
>call to get it sync. However, we might have some cases to change
>system wide file ra_pages to enhance system performance such as
>enhance the boot time by increasing the ra_pages or decrease it to

Do you have examples that some distro making use of larger ra_pages
for boot time optimization?

There are fadvise() based readahead/preload tools that can be more
efficient for such purpose.

>mitigate the trashing under memory pressure. Those are the cases

Suppose N read streams with equal read speed. The thrash-free memory
requirement would be (N * 2 * ra_pages).

If N=1000 and ra_pages=1MB, it'd require 2GB memory. Which looks
affordable in mainstream servers.

Also we have try_context_readahead() that's good at estimating the
thrashing free readahead size -- as long as the system load and
read speed remains stable, and node/zone reclaims are balanced.

For normal systems w/o huge number slow read streams, e.g. desktop,
reducing ra_pages may save a little memory by reducing readahead
misses, especially on mmap() read-around. Though at the risk of more
number of IOs. So I'd imagine desktops with 1GB or fewer memory
to really need worry about conservative readahead size.

>we need to globally and immediately change this value. However,

Such requirement should be rare enough?

OTOH, the current Linux behavior of "changing ra_pages only changes
future file opens" does seem not a typical end user would expect and
understand.

>from the discussion, we know bdi readahead tend to be an optimal
>value to be a physical property of the storage and doesn't tend to
>change dynamically. Thus we'd like to purpose readahead_shift into
>backing device. This value is used as a shift bit number with bdi
>readahead value to come out the readahead value and the negative
>value means the division effect in the fixup function. The fixup
>would only take effect when shift value is not zero;otherwise,
>it returns file's ra_pages directly. Thus, an administrator could
>use this value to control the amount readahead referred to
>its backing device to achieve its goal.

Sorry but it sounds like introducing an unnecessarily twisted new
interface. I'm afraid it fixes the pain for 0.001% users while
bringing more puzzle to the majority others.

If we make up mind to fix the problem, it'd be more acceptable to
limit to an internal per-file data structure change, like this:

--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -884,7 +884,7 @@ struct file_ra_state {
        unsigned int async_size;        /* do asynchronous readahead when
                                           there are only # of pages ahead */

-       unsigned int ra_pages;          /* Maximum readahead window */
+       unsigned int ra_pages_shift;
        unsigned int mmap_miss;         /* Cache miss stat for mmap accesses */
        loff_t prev_pos;                /* Cache last read() position */
 };

Then let fadvise() and shrink_readahead_size_eio() adjust that
per-file ra_pages_shift.

Cheers,
Fengguang

>Signed-off-by: Martin Liu <liumartin@google.com>
>---
>I'd like to get some feedback about the patch. If you have any
>concern, please let me know. Thanks.
>---
> block/blk-sysfs.c                | 28 ++++++++++++++++++++++++++++
> include/linux/backing-dev-defs.h |  1 +
> include/linux/backing-dev.h      | 10 ++++++++++
> mm/backing-dev.c                 | 27 +++++++++++++++++++++++++++
> mm/filemap.c                     |  8 +++++---
> mm/readahead.c                   |  2 +-
> 6 files changed, 72 insertions(+), 4 deletions(-)
>
>diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
>index 59685918167e..f48b68e05d0e 100644
>--- a/block/blk-sysfs.c
>+++ b/block/blk-sysfs.c
>@@ -107,6 +107,27 @@ queue_ra_store(struct request_queue *q, const char *page, size_t count)
> 	return ret;
> }
>
>+static ssize_t queue_ra_shift_show(struct request_queue *q, char *page)
>+{
>+	int ra_shift = q->backing_dev_info->read_ahead_shift;
>+
>+	return scnprintf(page, PAGE_SIZE - 1, "%d\n", ra_shift);
>+}
>+
>+static ssize_t queue_ra_shift_store(struct request_queue *q, const char *page,
>+				    size_t count)
>+{
>+	s8 ra_shift;
>+	ssize_t ret = kstrtos8(page, 10, &ra_shift);
>+
>+	if (ret)
>+		return ret;
>+
>+	q->backing_dev_info->read_ahead_shift = ra_shift;
>+
>+	return count;
>+}
>+
> static ssize_t queue_max_sectors_show(struct request_queue *q, char *page)
> {
> 	int max_sectors_kb = queue_max_sectors(q) >> 1;
>@@ -540,6 +561,12 @@ static struct queue_sysfs_entry queue_ra_entry = {
> 	.store = queue_ra_store,
> };
>
>+static struct queue_sysfs_entry queue_ra_shift_entry = {
>+	.attr = {.name = "read_ahead_shift", .mode = 0644 },
>+	.show = queue_ra_shift_show,
>+	.store = queue_ra_shift_store,
>+};
>+
> static struct queue_sysfs_entry queue_max_sectors_entry = {
> 	.attr = {.name = "max_sectors_kb", .mode = 0644 },
> 	.show = queue_max_sectors_show,
>@@ -729,6 +756,7 @@ static struct queue_sysfs_entry throtl_sample_time_entry = {
> static struct attribute *default_attrs[] = {
> 	&queue_requests_entry.attr,
> 	&queue_ra_entry.attr,
>+	&queue_ra_shift_entry.attr,
> 	&queue_max_hw_sectors_entry.attr,
> 	&queue_max_sectors_entry.attr,
> 	&queue_max_segments_entry.attr,
>diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
>index 07e02d6df5ad..452002df5232 100644
>--- a/include/linux/backing-dev-defs.h
>+++ b/include/linux/backing-dev-defs.h
>@@ -167,6 +167,7 @@ struct bdi_writeback {
> struct backing_dev_info {
> 	struct list_head bdi_list;
> 	unsigned long ra_pages;	/* max readahead in PAGE_SIZE units */
>+	s8 read_ahead_shift; /* shift to ra_pages */
> 	unsigned long io_pages;	/* max allowed IO size */
> 	congested_fn *congested_fn; /* Function pointer if device is md/dm */
> 	void *congested_data;	/* Pointer to aux data for congested func */
>diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
>index f9b029180241..23f755fe386e 100644
>--- a/include/linux/backing-dev.h
>+++ b/include/linux/backing-dev.h
>@@ -221,6 +221,16 @@ static inline int bdi_sched_wait(void *word)
> 	return 0;
> }
>
>+static inline unsigned long read_ahead_fixup(struct file *file)
>+{
>+	unsigned long ra = file->f_ra.ra_pages;
>+	s8 shift = (inode_to_bdi(file->f_mapping->host))->read_ahead_shift;
>+
>+	ra = (shift >= 0) ? ra << shift : ra >> abs(shift);
>+
>+	return ra;
>+}
>+
> #ifdef CONFIG_CGROUP_WRITEBACK
>
> struct bdi_writeback_congested *
>diff --git a/mm/backing-dev.c b/mm/backing-dev.c
>index 72e6d0c55cfa..1b5163a5ead5 100644
>--- a/mm/backing-dev.c
>+++ b/mm/backing-dev.c
>@@ -172,6 +172,32 @@ static DEVICE_ATTR_RW(name);
>
> BDI_SHOW(read_ahead_kb, K(bdi->ra_pages))
>
>+static ssize_t read_ahead_shift_store(struct device *dev,
>+				      struct device_attribute *attr,
>+				      const char *buf, size_t count)
>+{
>+	struct backing_dev_info *bdi = dev_get_drvdata(dev);
>+	s8 read_ahead_shift;
>+	ssize_t ret = kstrtos8(buf, 10, &read_ahead_shift);
>+
>+	if (ret)
>+		return ret;
>+
>+	bdi->read_ahead_shift = read_ahead_shift;
>+
>+	return count;
>+}
>+
>+static ssize_t read_ahead_shift_show(struct device *dev,
>+				     struct device_attribute *attr, char *page)
>+{
>+	struct backing_dev_info *bdi = dev_get_drvdata(dev);
>+
>+	return scnprintf(page, PAGE_SIZE - 1, "%d\n", bdi->read_ahead_shift);
>+}
>+
>+static DEVICE_ATTR_RW(read_ahead_shift);
>+
> static ssize_t min_ratio_store(struct device *dev,
> 		struct device_attribute *attr, const char *buf, size_t count)
> {
>@@ -223,6 +249,7 @@ static DEVICE_ATTR_RO(stable_pages_required);
>
> static struct attribute *bdi_dev_attrs[] = {
> 	&dev_attr_read_ahead_kb.attr,
>+	&dev_attr_read_ahead_shift.attr,
> 	&dev_attr_min_ratio.attr,
> 	&dev_attr_max_ratio.attr,
> 	&dev_attr_stable_pages_required.attr,
>diff --git a/mm/filemap.c b/mm/filemap.c
>index d78f577baef2..cd8d0e00ff93 100644
>--- a/mm/filemap.c
>+++ b/mm/filemap.c
>@@ -2469,6 +2469,7 @@ static struct file *do_sync_mmap_readahead(struct vm_fault *vmf)
> 	struct address_space *mapping = file->f_mapping;
> 	struct file *fpin = NULL;
> 	pgoff_t offset = vmf->pgoff;
>+	unsigned long max;
>
> 	/* If we don't want any read-ahead, don't bother */
> 	if (vmf->vma->vm_flags & VM_RAND_READ)
>@@ -2498,9 +2499,10 @@ static struct file *do_sync_mmap_readahead(struct vm_fault *vmf)
> 	 * mmap read-around
> 	 */
> 	fpin = maybe_unlock_mmap_for_io(vmf, fpin);
>-	ra->start = max_t(long, 0, offset - ra->ra_pages / 2);
>-	ra->size = ra->ra_pages;
>-	ra->async_size = ra->ra_pages / 4;
>+	max = read_ahead_fixup(file);
>+	ra->start = max_t(long, 0, offset - max / 2);
>+	ra->size = max;
>+	ra->async_size = max / 4;
> 	ra_submit(ra, mapping, file);
> 	return fpin;
> }
>diff --git a/mm/readahead.c b/mm/readahead.c
>index a4593654a26c..546bf344fc4d 100644
>--- a/mm/readahead.c
>+++ b/mm/readahead.c
>@@ -384,7 +384,7 @@ ondemand_readahead(struct address_space *mapping,
> 		   unsigned long req_size)
> {
> 	struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
>-	unsigned long max_pages = ra->ra_pages;
>+	unsigned long max_pages = read_ahead_fixup(filp);
> 	unsigned long add_pages;
> 	pgoff_t prev_offset;
>
>-- 
>2.21.0.392.gf8f6787159e-goog
>

