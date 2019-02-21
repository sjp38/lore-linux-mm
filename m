Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B4F7C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 10:17:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8D332148D
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 10:17:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8D332148D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E5DB8E006E; Thu, 21 Feb 2019 05:17:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 492DE8E0002; Thu, 21 Feb 2019 05:17:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35B858E006E; Thu, 21 Feb 2019 05:17:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 09C218E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 05:17:03 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 207so4962011qkl.2
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 02:17:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=8bIEyrOTlNzsFdr1meU51eHnqEdxe7MnndEylEHb54Q=;
        b=P6tTn19nkJPpDTNR2fYj1wYdLj6Z3aKHvvaGNpEWnh27TOlD4SvDo1aeNYMTH4iY6j
         zOqohFFMvEWi26i++384CPBh4FiYmVwJiC25DnX/xpRRL9x72kuFooFoM8Xo6w/g6atX
         g+mCqL7h772fVuMw7wv5A1JFhXs7llwjP/kEUH0NxMzNYJpI2MQQg56zlE/OQ3s7lfxT
         Y2sZeYwdFiriZm/PLhYvGppBWXuv13uZN3yPfU9G5zJX6HI6ZF+oIpG5zTjCj4InsBNQ
         KCjppea0aw07/vuJSV0NmdSeTiE7QYA5Rh6DJQdJKaR1XNtgD7iefZId388SbBUNO03X
         RRpw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYG/Ti7HzGAdzKO3R28o2041wwx5+/o4u7PwXx2h1Ctuchgb/EI
	a4etkUPv/jA3xBGZg4S1vHS4SeM8wolF4d1CYA59MkHUaShQ4LpOsz+1rBNX/eC3RXw2qhZz6Ld
	VXYwzTlrp18x4wH4wsZEVbR8RSuM5KzbVmP5RGbMybzLFqfvrYW9GOvVdz6wutfT8uQ==
X-Received: by 2002:ac8:2da3:: with SMTP id p32mr30866848qta.138.1550744222779;
        Thu, 21 Feb 2019 02:17:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaIqU9uqE315C+E+OwBRacmGzhwsCezZKsiAU5gnCoyU77QA1SRUO5rkpJ9hn955+t21CUi
X-Received: by 2002:ac8:2da3:: with SMTP id p32mr30866826qta.138.1550744222136;
        Thu, 21 Feb 2019 02:17:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550744222; cv=none;
        d=google.com; s=arc-20160816;
        b=IsMLCY+7XOXddYM6CMNC8OS9DeLwuyZN/dqPxEw4ZfoJd7mb7yF1VJ3zxRPlXnvzRa
         M3RmUNtY75uLFsKaUe44yOOMSA8BUjzXnVtE1Qk54hqs4wvJuBGxntkV6NGuIs8dlEf/
         vzr/ClcR8xzuOzQSEzHAroibkDg8rIeEpjrK3+mYba81BuVKf7U48fvLqD6tAgzssvfS
         epdw7Fr+6VNEeuJfVjkeCEFTT8mNypawnCrW1i3lznq7vHdHgFvsFZoFLi2XzdTl/bJ7
         lwgPO8vxpWYeXeEjN0ZL+oyhzEhfBLJiHcSEiirwBS3ULd7geGKlJ4ybBkmkKPJrCt/F
         1/LA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=8bIEyrOTlNzsFdr1meU51eHnqEdxe7MnndEylEHb54Q=;
        b=k8i3yInmil+dZ/MQDJ3KGHut1eg/Xoh1yi2JY7+43EwhUBTAogYz1JDz4AA4exLGnI
         N1T+fe++QAUbYeqPXq5vy/3Kba8ATy6mUnW5gmfo0Mw5bIUcpDftiyKFqWXdezrB9P7o
         8SX38ZCdcqXUP+2Ze7j0R57PIoBVqVjtYa4gac96X6qaL3em7FYdhv62I1/zetwbm61T
         ycwwa3sToDUjTGOtJKM1bw1ik4u4JIXYJbks8Ng5ose2Jk2XfLobwYzOCNjOVbJk9FRo
         Q43EIZEG4l2da7NaqJBZgDbDNkwMNmu1tQS7KJXjoycE+pS6hj0xo+kAw1pW+GsTJR71
         WVqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f88si194561qtb.123.2019.02.21.02.17.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 02:17:02 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 21746300BBA8;
	Thu, 21 Feb 2019 10:17:00 +0000 (UTC)
Received: from ming.t460p (ovpn-8-27.pek2.redhat.com [10.72.8.27])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 980B35C277;
	Thu, 21 Feb 2019 10:16:24 +0000 (UTC)
Date: Thu, 21 Feb 2019 18:16:19 +0800
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
Message-ID: <20190221101618.GB12448@ming.t460p>
References: <20190215111324.30129-1-ming.lei@redhat.com>
 <20190215111324.30129-15-ming.lei@redhat.com>
 <CGME20190221084301eucas1p11e8841a62b4b1da3cccca661b6f4c29d@eucas1p1.samsung.com>
 <6c9ae4de-c56f-a2b3-2542-da7d8b95601d@samsung.com>
 <20190221095733.GA12448@ming.t460p>
 <ba39138d-d65b-335d-d709-b95dbde1fd5c@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ba39138d-d65b-335d-d709-b95dbde1fd5c@samsung.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 21 Feb 2019 10:17:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 11:08:19AM +0100, Marek Szyprowski wrote:
> Hi Ming,
> 
> On 2019-02-21 10:57, Ming Lei wrote:
> > On Thu, Feb 21, 2019 at 09:42:59AM +0100, Marek Szyprowski wrote:
> >> On 2019-02-15 12:13, Ming Lei wrote:
> >>> This patch pulls the trigger for multi-page bvecs.
> >>>
> >>> Reviewed-by: Omar Sandoval <osandov@fb.com>
> >>> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> >> Since Linux next-20190218 I've observed problems with block layer on one
> >> of my test devices (Odroid U3 with EXT4 rootfs on SD card). Bisecting
> >> this issue led me to this change. This is also the first linux-next
> >> release with this change merged. The issue is fully reproducible and can
> >> be observed in the following kernel log:
> >>
> >> sdhci: Secure Digital Host Controller Interface driver
> >> sdhci: Copyright(c) Pierre Ossman
> >> s3c-sdhci 12530000.sdhci: clock source 2: mmc_busclk.2 (100000000 Hz)
> >> s3c-sdhci 12530000.sdhci: Got CD GPIO
> >> mmc0: SDHCI controller on samsung-hsmmc [12530000.sdhci] using ADMA
> >> mmc0: new high speed SDHC card at address aaaa
> >> mmcblk0: mmc0:aaaa SL16G 14.8 GiB
> >>
> >> ...
> >>
> >> EXT4-fs (mmcblk0p2): INFO: recovery required on readonly filesystem
> >> EXT4-fs (mmcblk0p2): write access will be enabled during recovery
> >> EXT4-fs (mmcblk0p2): recovery complete
> >> EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. Opts: (null)
> >> VFS: Mounted root (ext4 filesystem) readonly on device 179:2.
> >> devtmpfs: mounted
> >> Freeing unused kernel memory: 1024K
> >> hub 1-3:1.0: USB hub found
> >> Run /sbin/init as init process
> >> hub 1-3:1.0: 3 ports detected
> >> *** stack smashing detected ***: <unknown> terminated
> >> Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000004
> >> CPU: 1 PID: 1 Comm: init Not tainted 5.0.0-rc6-next-20190218 #1546
> >> Hardware name: SAMSUNG EXYNOS (Flattened Device Tree)
> >> [<c01118d0>] (unwind_backtrace) from [<c010d794>] (show_stack+0x10/0x14)
> >> [<c010d794>] (show_stack) from [<c09ff8a4>] (dump_stack+0x90/0xc8)
> >> [<c09ff8a4>] (dump_stack) from [<c0125944>] (panic+0xfc/0x304)
> >> [<c0125944>] (panic) from [<c012bc98>] (do_exit+0xabc/0xc6c)
> >> [<c012bc98>] (do_exit) from [<c012c100>] (do_group_exit+0x3c/0xbc)
> >> [<c012c100>] (do_group_exit) from [<c0138908>] (get_signal+0x130/0xbf4)
> >> [<c0138908>] (get_signal) from [<c010c7a0>] (do_work_pending+0x130/0x618)
> >> [<c010c7a0>] (do_work_pending) from [<c0101034>]
> >> (slow_work_pending+0xc/0x20)
> >> Exception stack(0xe88c3fb0 to 0xe88c3ff8)
> >> 3fa0:                                     00000000 bea7787c 00000005
> >> b6e8d0b8
> >> 3fc0: bea77a18 b6f92010 b6e8d0b8 00000001 b6e8d0c8 00000001 b6e8c000
> >> bea77b60
> >> 3fe0: 00000020 bea77998 ffffffff b6d52368 60000050 ffffffff
> >> CPU3: stopping
> >>
> >> I would like to help debugging and fixing this issue, but I don't really
> >> have idea where to start. Here are some more detailed information about
> >> my test system:
> >>
> >> 1. Board: ARM 32bit Samsung Exynos4412-based Odroid U3 (device tree
> >> source: arch/arm/boot/dts/exynos4412-odroidu3.dts)
> >>
> >> 2. Block device: MMC/SDHCI/SDHCI-S3C with SD card
> >> (drivers/mmc/host/sdhci-s3c.c driver, sdhci_2 device node in the device
> >> tree)
> >>
> >> 3. Rootfs: Ext4
> >>
> >> 4. Kernel config: arch/arm/configs/exynos_defconfig
> >>
> >> I can gather more logs if needed, just let me which kernel option to
> >> enable. Reverting this commit on top of next-20190218 as well as current
> >> linux-next (tested with next-20190221) fixes this issue and makes the
> >> system bootable again.
> > Could you test the patch in following link and see if it can make a difference?
> >
> > https://marc.info/?l=linux-aio&m=155070355614541&w=2
> 
> I've tested that patch, but it doesn't make any difference on the test
> system. In the log I see no warning added by it.

I guess it might be related with memory corruption, could you enable the
following debug options and post the dmesg log?

CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_KASAN=y

Thanks,
Ming

