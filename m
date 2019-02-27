Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A20EBC00319
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 23:30:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6638721850
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 23:30:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6638721850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA5AB8E0004; Wed, 27 Feb 2019 18:30:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2C0B8E0001; Wed, 27 Feb 2019 18:30:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF3378E0004; Wed, 27 Feb 2019 18:30:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A14148E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:30:14 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id k5so17033053qte.0
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 15:30:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=I4Vklq5Cm+4b9fviVVC3//uYdOk1v/1jBOcgNBB6zIE=;
        b=i1ezJp3F57XxtokUo8ysp/eM+boAvoS/M2HYpnbE3rJqpYiVTCAmWTu+St9v2zFmHi
         404pRw7mVnEIzOuxDnT/UjIbtY5dL9EBxK1hFj6+bnBLxsAMgkXCvye6u0LNuJnUw0+y
         z2A3OmHtoevC2bxtKbZSrvL/850Xf+PuGZ1tbHfdS09zyhjKY1IVyfa7Mp72dQWRT9CA
         YfkPEm1E6fiE3IXJuxdkons1Iomda/4eGrBscP6A9qJP2FiuTirkJJkRhS/hHvtLPEEZ
         Zx5BDvq58bIeaxuL/r9wVpmOsC0ECNELGDoG93ucZkH45KJiHnjTyVKSbdDUw8upKOAH
         O1SQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWtTGiyNVk6ajIrX1nlbMu3GiUKCKwHHP3e/nX03cCNMI3yukiL
	fZm5FglU042I6u29gU4OBDy3SwKO/4DKtmyUh11cNhYkMmuyFNRhbX7s5oO2ZJADT4N24FdqcWK
	pDw4eeQj9blbNhlZqXqrhmyaO8XFfA+bYPq/ssKLpjpRhEkkE7I2lZrh1CL9d1dj8RA==
X-Received: by 2002:ac8:2d68:: with SMTP id o37mr3729692qta.377.1551310214356;
        Wed, 27 Feb 2019 15:30:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iaq7iRcR648mDcI8Tecq8q0pa78o4WC556IlAdx93qMrgORaQoaCTs9h4pwgEswulfVIENe
X-Received: by 2002:ac8:2d68:: with SMTP id o37mr3729637qta.377.1551310213282;
        Wed, 27 Feb 2019 15:30:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551310213; cv=none;
        d=google.com; s=arc-20160816;
        b=CTuycppFxOW//skU/YVJ1dGgB3I0ZzwfiZXC77n4uYmtEG2yhjXRLuxg+Vmds5kOUT
         bMHbh8C1imuf8NLqmatKyKYyXAlVEwryhDkuWC4yZM5Di+jSleHMCI4dZAXs0gnrRPl1
         jHmtWMpzmYtDpPm/J60HaUeOwaef3Qm49k/pZeGVUd+rogJYK/yp+ZPgqlAwcil5cbfq
         dIE7mxgWwkWt7m7HwBmobnqqXVZxgEbqRrJvnR+tFhtb5ibtK1niSWLgxItui3nH5/CT
         eK+ISolnMxiG6Fr1vUdmnzUUr6LAzSLSLLx73AsZ0pd43aHVWnIXXjPQNkDKQXtVRjlL
         rRRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=I4Vklq5Cm+4b9fviVVC3//uYdOk1v/1jBOcgNBB6zIE=;
        b=Y5L6lqecVDGrjxtbFKyCbtYYR2Ni+mb1ZalqIhCryhlsh7lTIfXFJ9rPZqONUwnbJV
         afAWfMrvMRtB6foLenLG3iHzNKpryLNvmQ1FKc71SJpuDrXNZYrzCMrD/PXLAGhPyf5u
         KjC5LYm669BV3Mq8wHpWvT7XICU5ChM4T2sM0r4m546wdOy/o5tdq+nn8frc2TEOc5u+
         QABzmeoAOM5CNr9iDHVuJI5DqEfgCOaKfHmw86D8sD25hW+AsUQfwZPSoCkb8Ghcqkyn
         0LK/5QdCRApLMe3jhAX088A/YYx9thewoWJu9kJx8ExfdaJEjYg3emYayJYiibYfATfO
         WjAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d127si3621442qka.79.2019.02.27.15.30.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 15:30:13 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7CB5030842B2;
	Wed, 27 Feb 2019 23:30:11 +0000 (UTC)
Received: from ming.t460p (ovpn-8-16.pek2.redhat.com [10.72.8.16])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7E34F5E7A3;
	Wed, 27 Feb 2019 23:29:46 +0000 (UTC)
Date: Thu, 28 Feb 2019 07:29:41 +0800
From: Ming Lei <ming.lei@redhat.com>
To: Jon Hunter <jonathanh@nvidia.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>,
	Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org,
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
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	linux-tegra <linux-tegra@vger.kernel.org>
Subject: Re: [PATCH V15 14/18] block: enable multipage bvecs
Message-ID: <20190227232940.GA13319@ming.t460p>
References: <20190215111324.30129-1-ming.lei@redhat.com>
 <20190215111324.30129-15-ming.lei@redhat.com>
 <CGME20190221084301eucas1p11e8841a62b4b1da3cccca661b6f4c29d@eucas1p1.samsung.com>
 <6c9ae4de-c56f-a2b3-2542-da7d8b95601d@samsung.com>
 <0dbbee64-5c6b-0374-4360-6dc218c70d58@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0dbbee64-5c6b-0374-4360-6dc218c70d58@nvidia.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Wed, 27 Feb 2019 23:30:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 08:47:09PM +0000, Jon Hunter wrote:
> 
> On 21/02/2019 08:42, Marek Szyprowski wrote:
> > Dear All,
> > 
> > On 2019-02-15 12:13, Ming Lei wrote:
> >> This patch pulls the trigger for multi-page bvecs.
> >>
> >> Reviewed-by: Omar Sandoval <osandov@fb.com>
> >> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> > 
> > Since Linux next-20190218 I've observed problems with block layer on one
> > of my test devices (Odroid U3 with EXT4 rootfs on SD card). Bisecting
> > this issue led me to this change. This is also the first linux-next
> > release with this change merged. The issue is fully reproducible and can
> > be observed in the following kernel log:
> > 
> > sdhci: Secure Digital Host Controller Interface driver
> > sdhci: Copyright(c) Pierre Ossman
> > s3c-sdhci 12530000.sdhci: clock source 2: mmc_busclk.2 (100000000 Hz)
> > s3c-sdhci 12530000.sdhci: Got CD GPIO
> > mmc0: SDHCI controller on samsung-hsmmc [12530000.sdhci] using ADMA
> > mmc0: new high speed SDHC card at address aaaa
> > mmcblk0: mmc0:aaaa SL16G 14.8 GiB
> I have also noticed some failures when writing to an eMMC device on one
> of our Tegra boards. We have a simple eMMC write/read test and it is
> currently failing because the data written does not match the source.
> 
> I did not seem the same crash as reported here, however, in our case the
> rootfs is NFS mounted and so probably would not. However, the bisect
> points to this commit and reverting on top of -next fixes the issues.

It is sdhci, probably related with max segment size, could you test the
following patch:

https://marc.info/?l=linux-mmc&m=155128334122951&w=2

Thanks,
Ming

