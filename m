Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A5BCC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 10:39:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8B3B2077B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 10:39:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8B3B2077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 791618E0070; Thu, 21 Feb 2019 05:39:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 742738E0002; Thu, 21 Feb 2019 05:39:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 62F3B8E0070; Thu, 21 Feb 2019 05:39:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0C78E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 05:39:33 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id y31so26201975qty.9
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 02:39:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=iJOM58uwIoB5Oyt56nGHR5WUvtcp20867frHv8L61Eo=;
        b=XOFHDvulZsCSsVcMOqawNZ23IK0sRLCcAJc3PxkgyEbNf4FMIg5trHE8MyhgibdvSv
         fyf2sml9X5ztCbySLjygT0R6CW+Uzfb81jxTXDZb1kJIMW12q+/4IxSRW2p/u16NsshW
         CvX/wWEto+DG7zn6mszcCG7jmVgX3Clr4SXcpsvn43AJZePZuh+sF0lTXLP7n86llBV1
         21mKGU1SA9wsfnvxKFWl2LyGYYVoFEAvYDDpK+LnCb5kfL5lXlpby/9g8aJQNQPirWWv
         TtsqF9ZKE1/kxSNft0LzgmHZiJ/pm9YnG1RpBOsMeC/910TSvcCWN7xMMb7+yff4+XBv
         VffA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubNQRo9H+9Li6dszSkstdMPVRg//53IZgFQ+wTKvQWB6o49wS4m
	lI05V9xUYS7J+UC1yTxAKWcbBcLV1ejKh/KvOqPpqY6IcTbEki8Yo6x7MrwT444o+0TK2rQEWA4
	r3rNVsSJKa4X3bg9P2+isplXcvDlKX98V9q8WIxIIVtaQxUTQGF3121idbrCJkRN1QA==
X-Received: by 2002:a37:a783:: with SMTP id q125mr22020745qke.264.1550745572953;
        Thu, 21 Feb 2019 02:39:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY2+B3yt6e5HIzrkoYiJvJVIZElCHZAuj0fyONMRzlRrs+oj6YcK1YiQuNwUUlVEVtdyy5p
X-Received: by 2002:a37:a783:: with SMTP id q125mr22020715qke.264.1550745572171;
        Thu, 21 Feb 2019 02:39:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550745572; cv=none;
        d=google.com; s=arc-20160816;
        b=eBuvXl0YAFux9mH+3hOPv9lRJsjuV8ltd0Dm8Tg+UmYGDe4CxTrXL2QdrKKmLLOate
         jMQnbfO7MPrOAX4KKu1aGWnaWRlPydjIFtYCGULFrrEIPFsqxbJstTVK6W6gE56EZNk4
         gjlzLdW7SjdKi1jyRH313VSJC2emvkYGScDau8ofmEY2vJlRxLPsYCYLEl06zkUaY2Vh
         kwxVHduKCD/XMmY5MYpeoUSfzfLLfqhrxekObDUlXsbg1DCI7B71C68JophY/2Zv9y4n
         HmBeIVDSOMHfVgnEfgnDJZhc8+uAZxDPTc7jtdygc4ac2OXfxkJQJz7OoNNvHMjsXZAI
         4e/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=iJOM58uwIoB5Oyt56nGHR5WUvtcp20867frHv8L61Eo=;
        b=YAkvQoA0GAdQOwNCt7uX3rQPKGlcmuyD1yntwOhn0zHViQOjYete/WHszkl7X3u4sQ
         BqgSlcDZm8oOI0R5r6SplMbU1G1Byn8Pepa3/3A7GK7QQIQhOJWTmomWfrmn5F6OcX6r
         wDlFQ/UhL/+k9qVg/XVbRgx2NGAXIXRYgH/2o/P+4llqbW3bMiIffWmnU5w4gpLSYl04
         Zemx0nOaKRkcV6+Muel+ZgBJ0T9uerI0vuOBzX62QVigFxA2moNgS7EjZzPcixSMwNc+
         SC0gv0+TbTyKaZFBv74mXcxwWUUYozrmpSKX5QpANhyI6wdFLSZPQpjjlZ9QiMCnhlDb
         Y5YA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j18si5670690qth.388.2019.02.21.02.39.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 02:39:32 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 79BF730821B4;
	Thu, 21 Feb 2019 10:39:30 +0000 (UTC)
Received: from ming.t460p (ovpn-8-27.pek2.redhat.com [10.72.8.27])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 103C25C204;
	Thu, 21 Feb 2019 10:39:03 +0000 (UTC)
Date: Thu, 21 Feb 2019 18:38:57 +0800
From: Ming Lei <ming.lei@redhat.com>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>,
	Sagi Grimberg <sagi@grimberg.me>,
	Dave Chinner <dchinner@redhat.com>,
	Kent Overstreet <kent.overstreet@gmail.com>,
	Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org,
	David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>,
	Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org,
	Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org,
	Boaz Harrosh <ooo@electrozaur.com>,
	Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com,
	Ulf Hansson <ulf.hansson@linaro.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	'Linux Samsung SOC' <linux-samsung-soc@vger.kernel.org>,
	Krzysztof Kozlowski <krzk@kernel.org>,
	Adrian Hunter <adrian.hunter@intel.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH V15 14/18] block: enable multipage bvecs
Message-ID: <20190221103856.GC12448@ming.t460p>
References: <20190215111324.30129-1-ming.lei@redhat.com>
 <20190215111324.30129-15-ming.lei@redhat.com>
 <CGME20190221084301eucas1p11e8841a62b4b1da3cccca661b6f4c29d@eucas1p1.samsung.com>
 <6c9ae4de-c56f-a2b3-2542-da7d8b95601d@samsung.com>
 <20190221095733.GA12448@ming.t460p>
 <ba39138d-d65b-335d-d709-b95dbde1fd5c@samsung.com>
 <20190221101618.GB12448@ming.t460p>
 <9269fbbf-b5dd-6be1-682f-e791847ea00d@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9269fbbf-b5dd-6be1-682f-e791847ea00d@samsung.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 21 Feb 2019 10:39:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 11:22:39AM +0100, Marek Szyprowski wrote:
> Hi Ming,
> 
> On 2019-02-21 11:16, Ming Lei wrote:
> > On Thu, Feb 21, 2019 at 11:08:19AM +0100, Marek Szyprowski wrote:
> >> On 2019-02-21 10:57, Ming Lei wrote:
> >>> On Thu, Feb 21, 2019 at 09:42:59AM +0100, Marek Szyprowski wrote:
> >>>> On 2019-02-15 12:13, Ming Lei wrote:
> >>>>> This patch pulls the trigger for multi-page bvecs.
> >>>>>
> >>>>> Reviewed-by: Omar Sandoval <osandov@fb.com>
> >>>>> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> >>>> Since Linux next-20190218 I've observed problems with block layer on one
> >>>> of my test devices (Odroid U3 with EXT4 rootfs on SD card). Bisecting
> >>>> this issue led me to this change. This is also the first linux-next
> >>>> release with this change merged. The issue is fully reproducible and can
> >>>> be observed in the following kernel log:
> >>>>
> >>>> sdhci: Secure Digital Host Controller Interface driver
> >>>> sdhci: Copyright(c) Pierre Ossman
> >>>> s3c-sdhci 12530000.sdhci: clock source 2: mmc_busclk.2 (100000000 Hz)
> >>>> s3c-sdhci 12530000.sdhci: Got CD GPIO
> >>>> mmc0: SDHCI controller on samsung-hsmmc [12530000.sdhci] using ADMA
> >>>> mmc0: new high speed SDHC card at address aaaa
> >>>> mmcblk0: mmc0:aaaa SL16G 14.8 GiB
> >>>>
> >>>> ...
> >>>>
> >>>> EXT4-fs (mmcblk0p2): INFO: recovery required on readonly filesystem
> >>>> EXT4-fs (mmcblk0p2): write access will be enabled during recovery
> >>>> EXT4-fs (mmcblk0p2): recovery complete
> >>>> EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. Opts: (null)
> >>>> VFS: Mounted root (ext4 filesystem) readonly on device 179:2.
> >>>> devtmpfs: mounted
> >>>> Freeing unused kernel memory: 1024K
> >>>> hub 1-3:1.0: USB hub found
> >>>> Run /sbin/init as init process
> >>>> hub 1-3:1.0: 3 ports detected
> >>>> *** stack smashing detected ***: <unknown> terminated
> >>>> Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000004
> >>>> CPU: 1 PID: 1 Comm: init Not tainted 5.0.0-rc6-next-20190218 #1546
> >>>> Hardware name: SAMSUNG EXYNOS (Flattened Device Tree)
> >>>> [<c01118d0>] (unwind_backtrace) from [<c010d794>] (show_stack+0x10/0x14)
> >>>> [<c010d794>] (show_stack) from [<c09ff8a4>] (dump_stack+0x90/0xc8)
> >>>> [<c09ff8a4>] (dump_stack) from [<c0125944>] (panic+0xfc/0x304)
> >>>> [<c0125944>] (panic) from [<c012bc98>] (do_exit+0xabc/0xc6c)
> >>>> [<c012bc98>] (do_exit) from [<c012c100>] (do_group_exit+0x3c/0xbc)
> >>>> [<c012c100>] (do_group_exit) from [<c0138908>] (get_signal+0x130/0xbf4)
> >>>> [<c0138908>] (get_signal) from [<c010c7a0>] (do_work_pending+0x130/0x618)
> >>>> [<c010c7a0>] (do_work_pending) from [<c0101034>]
> >>>> (slow_work_pending+0xc/0x20)
> >>>> Exception stack(0xe88c3fb0 to 0xe88c3ff8)
> >>>> 3fa0:                                     00000000 bea7787c 00000005
> >>>> b6e8d0b8
> >>>> 3fc0: bea77a18 b6f92010 b6e8d0b8 00000001 b6e8d0c8 00000001 b6e8c000
> >>>> bea77b60
> >>>> 3fe0: 00000020 bea77998 ffffffff b6d52368 60000050 ffffffff
> >>>> CPU3: stopping
> >>>>
> >>>> I would like to help debugging and fixing this issue, but I don't really
> >>>> have idea where to start. Here are some more detailed information about
> >>>> my test system:
> >>>>
> >>>> 1. Board: ARM 32bit Samsung Exynos4412-based Odroid U3 (device tree
> >>>> source: arch/arm/boot/dts/exynos4412-odroidu3.dts)
> >>>>
> >>>> 2. Block device: MMC/SDHCI/SDHCI-S3C with SD card
> >>>> (drivers/mmc/host/sdhci-s3c.c driver, sdhci_2 device node in the device
> >>>> tree)
> >>>>
> >>>> 3. Rootfs: Ext4
> >>>>
> >>>> 4. Kernel config: arch/arm/configs/exynos_defconfig
> >>>>
> >>>> I can gather more logs if needed, just let me which kernel option to
> >>>> enable. Reverting this commit on top of next-20190218 as well as current
> >>>> linux-next (tested with next-20190221) fixes this issue and makes the
> >>>> system bootable again.
> >>> Could you test the patch in following link and see if it can make a difference?
> >>>
> >>> https://marc.info/?l=linux-aio&m=155070355614541&w=2
> >> I've tested that patch, but it doesn't make any difference on the test
> >> system. In the log I see no warning added by it.
> > I guess it might be related with memory corruption, could you enable the
> > following debug options and post the dmesg log?
> >
> > CONFIG_DEBUG_STACKOVERFLOW=y
> > CONFIG_KASAN=y
> 
> It won't be that easy as none of the above options is available on ARM
> 32bit. I will try to apply some ARM KASAN patches floating on the net
> and let you know the result.

Hi Marek,

Could you test the following patch?

diff --git a/block/bounce.c b/block/bounce.c
index add085e28b1d..0c618c0b3cf8 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -295,7 +295,6 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	bool bounce = false;
 	int sectors = 0;
 	bool passthrough = bio_is_passthrough(*bio_orig);
-	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment(from, *bio_orig, iter) {
 		if (i++ < BIO_MAX_PAGES)
@@ -315,7 +314,8 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	bio = bounce_clone_bio(*bio_orig, GFP_NOIO, passthrough ? NULL :
 			&bounce_bio_set);
 
-	bio_for_each_segment_all(to, bio, i, iter_all) {
+	/* bio won't be multi-page bvec, so operate its bvec table directly */
+	for (i = 0, to = bio->bi_io_vec; i < bio->bi_vcnt; to++, i++) {
 		struct page *page = to->bv_page;
 
 		if (page_to_pfn(page) <= q->limits.bounce_pfn)

Thanks,
Ming

