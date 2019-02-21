Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD875C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 09:58:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A526120880
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 09:58:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A526120880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 457048E006B; Thu, 21 Feb 2019 04:58:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DE258E0002; Thu, 21 Feb 2019 04:58:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A8458E006B; Thu, 21 Feb 2019 04:58:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id F1A458E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 04:58:10 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id i3so14300286qtc.7
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 01:58:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=wiKYEi9Ez5kBJRHSyoINCduX/h9beNgSCwMBLqjiCis=;
        b=skSK2enLW9dmdbkwHER1OmSXwYn+Dw28v29M4K5A+jXhzPKRyrwSh60i72kP64C2Al
         yqkGM82e1qR+n8wMreqfrwBsh4AKCkRe5IMgEWJQSsXM1KKkFa39LWdr5BYF4xjODs6q
         K57p1EnDw+tjK8lGmtAoVPXy2iuzgV1vqPQnyzlSyJpho3B2DZjkwBj3sTGD7TFNi1Pn
         UJJGzb8QRZ7FFjr3Cyifvu1V4tQuWDBBbQlCADltC9Nw3g//RW1mVYbW5MYMubfbR+jb
         OeFgE3zBSu6k1B8lgXHJzzpK1cFclboeW2hxjPu3+zYOJOE5QtBHhty7gQO41A8NfZyj
         uhUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYtYOLlB5ekvbCJnJAR1ErGD6vZRme3hFyMarirtiRQprDyOok6
	u4CaYzHrQcGVKtZriEYBKWuXYmR9kkQKGO9wGZb7nvTBZdzpUSyb6r/AP3mMQdtrEiEuqgF3EPH
	fB7HfMVUAoS0UtlV7BJEymEKuXf8g6nhWkvlfZPPbRyxLLhic5O2dj+Ui9AZLoRDFQQ==
X-Received: by 2002:a37:c348:: with SMTP id a69mr26931279qkj.177.1550743090603;
        Thu, 21 Feb 2019 01:58:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib1iPmO7rKY0X4ruviwVgrAzSJz86q+HsRs6nBYdaFGsWXe/xSEhcmweYAJFJlG3dNuN9GU
X-Received: by 2002:a37:c348:: with SMTP id a69mr26931250qkj.177.1550743089794;
        Thu, 21 Feb 2019 01:58:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550743089; cv=none;
        d=google.com; s=arc-20160816;
        b=mixewGPi2lS/bdvkC2PqGVYbuMbsED/9ogElaRT1FpXUwhdebbldwHTk+0fSxCwdAC
         KoVs1hYZk0NPJu/0sLA7GGGGCDqb0YHjvMdJ05XUExBesrPboZm2iREL0zEnS7AP1XHx
         HyTIw5yQ1+minbfrj5U+fELssd2UZjke8mNic+6Ij3S9muuPUkpjXufMTY0Eq2uTCCVe
         EzoZEjtPEqZ49XEHlNvKxOCBL6ucX2JwxSC2IrYV/XDtcR3LsGB9eG2H4YIVZCCwsDff
         BI94F3jRXMR62FASPbf/WmsgOLu9h2bCAxtGc03YtQcIAWqMSMk5BigKGfaDQy8Ynh5J
         zDYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=wiKYEi9Ez5kBJRHSyoINCduX/h9beNgSCwMBLqjiCis=;
        b=ZcHhr+vhib8HVQhhOEYJNWsVhmRA9HtPecOKxB7w3E/FIu5QnbCVea1QNv9IR2B6qp
         KSK5cfueAvJWv2QDxugZDKcQ04Cyx1SzQ6f6hxGUXY8y9v78WKSiIrPnDWhIt2xQc1/T
         /N5XgepjxwHGALu4XIePcHd0+gacgIh3ZeZkjwEAOG3HX9xJ/mdjkIXDVMNqSuMIMsuC
         MiufZO3XQ0lxcZ7nNm7iCwCSI1j/qgRAdlPQWzoq8z34tuBK/9lR6KpIxR0AGWp/ziVt
         5bJ2/5arzKZkoxDhHB1f61/+Vev8bnEDAhvZdE4/36Rfg1Gz18A6MBEuzdrS76xtj179
         Weww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r9si1899649qte.193.2019.02.21.01.58.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 01:58:09 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 616343084298;
	Thu, 21 Feb 2019 09:58:08 +0000 (UTC)
Received: from ming.t460p (ovpn-8-27.pek2.redhat.com [10.72.8.27])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A375960933;
	Thu, 21 Feb 2019 09:57:39 +0000 (UTC)
Date: Thu, 21 Feb 2019 17:57:34 +0800
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
Message-ID: <20190221095733.GA12448@ming.t460p>
References: <20190215111324.30129-1-ming.lei@redhat.com>
 <20190215111324.30129-15-ming.lei@redhat.com>
 <CGME20190221084301eucas1p11e8841a62b4b1da3cccca661b6f4c29d@eucas1p1.samsung.com>
 <6c9ae4de-c56f-a2b3-2542-da7d8b95601d@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <6c9ae4de-c56f-a2b3-2542-da7d8b95601d@samsung.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Thu, 21 Feb 2019 09:58:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 09:42:59AM +0100, Marek Szyprowski wrote:
> Dear All,
> 
> On 2019-02-15 12:13, Ming Lei wrote:
> > This patch pulls the trigger for multi-page bvecs.
> >
> > Reviewed-by: Omar Sandoval <osandov@fb.com>
> > Signed-off-by: Ming Lei <ming.lei@redhat.com>
> 
> Since Linux next-20190218 I've observed problems with block layer on one
> of my test devices (Odroid U3 with EXT4 rootfs on SD card). Bisecting
> this issue led me to this change. This is also the first linux-next
> release with this change merged. The issue is fully reproducible and can
> be observed in the following kernel log:
> 
> sdhci: Secure Digital Host Controller Interface driver
> sdhci: Copyright(c) Pierre Ossman
> s3c-sdhci 12530000.sdhci: clock source 2: mmc_busclk.2 (100000000 Hz)
> s3c-sdhci 12530000.sdhci: Got CD GPIO
> mmc0: SDHCI controller on samsung-hsmmc [12530000.sdhci] using ADMA
> mmc0: new high speed SDHC card at address aaaa
> mmcblk0: mmc0:aaaa SL16G 14.8 GiB
> 
> ...
> 
> EXT4-fs (mmcblk0p2): INFO: recovery required on readonly filesystem
> EXT4-fs (mmcblk0p2): write access will be enabled during recovery
> EXT4-fs (mmcblk0p2): recovery complete
> EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. Opts: (null)
> VFS: Mounted root (ext4 filesystem) readonly on device 179:2.
> devtmpfs: mounted
> Freeing unused kernel memory: 1024K
> hub 1-3:1.0: USB hub found
> Run /sbin/init as init process
> hub 1-3:1.0: 3 ports detected
> *** stack smashing detected ***: <unknown> terminated
> Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000004
> CPU: 1 PID: 1 Comm: init Not tainted 5.0.0-rc6-next-20190218 #1546
> Hardware name: SAMSUNG EXYNOS (Flattened Device Tree)
> [<c01118d0>] (unwind_backtrace) from [<c010d794>] (show_stack+0x10/0x14)
> [<c010d794>] (show_stack) from [<c09ff8a4>] (dump_stack+0x90/0xc8)
> [<c09ff8a4>] (dump_stack) from [<c0125944>] (panic+0xfc/0x304)
> [<c0125944>] (panic) from [<c012bc98>] (do_exit+0xabc/0xc6c)
> [<c012bc98>] (do_exit) from [<c012c100>] (do_group_exit+0x3c/0xbc)
> [<c012c100>] (do_group_exit) from [<c0138908>] (get_signal+0x130/0xbf4)
> [<c0138908>] (get_signal) from [<c010c7a0>] (do_work_pending+0x130/0x618)
> [<c010c7a0>] (do_work_pending) from [<c0101034>]
> (slow_work_pending+0xc/0x20)
> Exception stack(0xe88c3fb0 to 0xe88c3ff8)
> 3fa0:                                     00000000 bea7787c 00000005
> b6e8d0b8
> 3fc0: bea77a18 b6f92010 b6e8d0b8 00000001 b6e8d0c8 00000001 b6e8c000
> bea77b60
> 3fe0: 00000020 bea77998 ffffffff b6d52368 60000050 ffffffff
> CPU3: stopping
> 
> I would like to help debugging and fixing this issue, but I don't really
> have idea where to start. Here are some more detailed information about
> my test system:
> 
> 1. Board: ARM 32bit Samsung Exynos4412-based Odroid U3 (device tree
> source: arch/arm/boot/dts/exynos4412-odroidu3.dts)
> 
> 2. Block device: MMC/SDHCI/SDHCI-S3C with SD card
> (drivers/mmc/host/sdhci-s3c.c driver, sdhci_2 device node in the device
> tree)
> 
> 3. Rootfs: Ext4
> 
> 4. Kernel config: arch/arm/configs/exynos_defconfig
> 
> I can gather more logs if needed, just let me which kernel option to
> enable. Reverting this commit on top of next-20190218 as well as current
> linux-next (tested with next-20190221) fixes this issue and makes the
> system bootable again.

Could you test the patch in following link and see if it can make a difference?

https://marc.info/?l=linux-aio&m=155070355614541&w=2

Thanks,
Ming

