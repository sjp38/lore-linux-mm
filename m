Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40E7DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 08:43:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB24C20880
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 08:43:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b="COOzo5jJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB24C20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=samsung.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79CCE8E0062; Thu, 21 Feb 2019 03:43:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7713B8E0002; Thu, 21 Feb 2019 03:43:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EBFC8E0062; Thu, 21 Feb 2019 03:43:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B47A8E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:43:09 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id y66so21064556pfg.16
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 00:43:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:subject:to:cc:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language:cms-type:references;
        bh=s4vQCFfJNgY7j1aVVCvYRzsum15lWTDFGJKVaSmae3w=;
        b=KX4RxRnhWeWPAEC6ggZ/6QB1fCOKjD746moBrwVIppndvSf8ao0h5xsVWkQ86ViY7g
         HbfvE0Hq9OeBAdomiKAw9wYOYJVTGbSOrd1DTx6oa0aJPbQk/vpl+XnFlMLRtLF2NQUx
         Zuw8QBFMRZUMS5xdn9zLTIVOMJMaJrXROgIXPwBOaRvjAXUxlqvqP6+Aj6/cY/lSHhI/
         sjehMRbQwrlFxWLqeWw9qKiKg1PPrb+P0ABWWqtFlHUz4uAv2xiiMfXsVNkUgpt2h4Jq
         fkg3bcCM2jqrmdg+8qRkSnbXr4D05csOZrCz+/TwVIiiFDeD7UGqftb9R2SmChtgJxqh
         JPeA==
X-Gm-Message-State: AHQUAuY+dvFxAc3T7l7BNttlvaXWyhL0YzVHTY11OU+ZIsED50ptPaQv
	tM1fgpRm6AuB7otDJ3cp/+apoRgf9XNJD0NjCHRJgdpZzT2A4D07c//kc5UvGrVa32CJTfDRfzt
	25SG2xS+nLfWaf/yFZvAyJna4UVuJQp5RztiQ8/TahKaGl1OoigXmi3ymcfs1mrpNNA==
X-Received: by 2002:a62:4743:: with SMTP id u64mr22022650pfa.95.1550738588716;
        Thu, 21 Feb 2019 00:43:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbnkU7711ZpTlde5S2eBKC8wGRdNKUDT2TbDvjT8/L7x4AVOn9Mi2SoUL5fLDm+4TkMJO2K
X-Received: by 2002:a62:4743:: with SMTP id u64mr22022580pfa.95.1550738587361;
        Thu, 21 Feb 2019 00:43:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550738587; cv=none;
        d=google.com; s=arc-20160816;
        b=hh06dgTf42a8NUl8pmWrEjudIJHmxkci84jJ/pHr6wBcqyHubyGbnh0DR0BV5DEbeO
         u9aygWPeVQuXV1v/qgm9VE54BvPHNtSMAkswfx50VB6W9cHr/ClvzVqJlz2zVi6hlYUl
         x+HGSl05Km6CIQEvjcCRVyCkI3eUxl3z0/CLyGes9nSfxP3Pvbftjib+7o6Z3xnJ9qwv
         5EkQkNXOghZZVt3Z/AopSWmfcTYKR660Ll+dE7ZSd22cuZ8rL1sRe2Y9pzmX8dFhodQ1
         sGx7e09l4lkgOT341B/SprhWaAHXebA8imB3vU0sfeqZTVnZAnv1ugNFkbOM9ueC9hZp
         Kwtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:cms-type:content-language:content-transfer-encoding
         :in-reply-to:mime-version:user-agent:date:message-id:from:cc:to
         :subject:dkim-signature:dkim-filter;
        bh=s4vQCFfJNgY7j1aVVCvYRzsum15lWTDFGJKVaSmae3w=;
        b=bKJ0Es8yB9Z+bZWbVWuuNhgk5y3uDTBIJMD/CCayAsUMbVO9fP2MAcezWgHRf3Gl7p
         8m2AdBlNkWWwen0zSAEe6AxEYkWLURCoyzp5KlPoDgz9aDLFgW4nyN52C5kDghI5AjmI
         yEyVWFLGuzEpxXlDcEPikHY+U4LQJlmw4fKYgtq+9HpqysKxxs/rrE8zAzJjmrKgKj63
         lsidL3ztc+cRvktunu+KElKz+b/fWMNLSY4QGiOjXnxE/rXwRPxGeR/Jpa6VoZ3PHmfe
         RA8MIS6ViQqVBfrkr4cbj1xUTNIb6+PoeEmBktxWFSaNcE34egWf5FhoPwG2NF2t4CAP
         F8iA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@samsung.com header.s=mail20170921 header.b=COOzo5jJ;
       spf=pass (google.com: domain of m.szyprowski@samsung.com designates 210.118.77.12 as permitted sender) smtp.mailfrom=m.szyprowski@samsung.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=samsung.com
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id t70si1762883pgd.85.2019.02.21.00.43.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 00:43:07 -0800 (PST)
Received-SPF: pass (google.com: domain of m.szyprowski@samsung.com designates 210.118.77.12 as permitted sender) client-ip=210.118.77.12;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@samsung.com header.s=mail20170921 header.b=COOzo5jJ;
       spf=pass (google.com: domain of m.szyprowski@samsung.com designates 210.118.77.12 as permitted sender) smtp.mailfrom=m.szyprowski@samsung.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=samsung.com
Received: from eucas1p2.samsung.com (unknown [182.198.249.207])
	by mailout2.w1.samsung.com (KnoxPortal) with ESMTP id 20190221084303euoutp02ddd134506cf95dcf2cf4e652e0914619~FVIZ_nfPt3022230222euoutp02P;
	Thu, 21 Feb 2019 08:43:03 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout2.w1.samsung.com 20190221084303euoutp02ddd134506cf95dcf2cf4e652e0914619~FVIZ_nfPt3022230222euoutp02P
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1550738583;
	bh=s4vQCFfJNgY7j1aVVCvYRzsum15lWTDFGJKVaSmae3w=;
	h=Subject:To:Cc:From:Date:In-Reply-To:References:From;
	b=COOzo5jJLzwHx6jWmWKILSClrZcztSg4PeFThqqkw5CCvGoaYOCGS8CE/wrReH8y4
	 83IodjO9QoB3w/2tHg7vAMrNJze7Kdzgic8Zkj5bm32nhKK89X4/IadA/P7KK+Qma3
	 ousHB3KJhPE+W8uHoIXHmKgyOQ5kM6sXIcb+NRgU=
Received: from eusmges1new.samsung.com (unknown [203.254.199.242]) by
	eucas1p1.samsung.com (KnoxPortal) with ESMTP id
	20190221084302eucas1p197a7a79faffba146d2bf752202ea7bbb~FVIZdWvpr0898408984eucas1p1h;
	Thu, 21 Feb 2019 08:43:02 +0000 (GMT)
Received: from eucas1p2.samsung.com ( [182.198.249.207]) by
	eusmges1new.samsung.com (EUCPMTA) with SMTP id F2.2A.04441.6946E6C5; Thu, 21
	Feb 2019 08:43:02 +0000 (GMT)
Received: from eusmtrp1.samsung.com (unknown [182.198.249.138]) by
	eucas1p1.samsung.com (KnoxPortal) with ESMTPA id
	20190221084301eucas1p11e8841a62b4b1da3cccca661b6f4c29d~FVIYatHfU0667606676eucas1p1S;
	Thu, 21 Feb 2019 08:43:01 +0000 (GMT)
Received: from eusmgms1.samsung.com (unknown [182.198.249.179]) by
	eusmtrp1.samsung.com (KnoxPortal) with ESMTP id
	20190221084301eusmtrp1b37465228ad54751317eb5c596caa0f6~FVIYIE7zD1535615356eusmtrp1E;
	Thu, 21 Feb 2019 08:43:01 +0000 (GMT)
X-AuditID: cbfec7f2-5c9ff70000001159-b3-5c6e6496b067
Received: from eusmtip1.samsung.com ( [203.254.199.221]) by
	eusmgms1.samsung.com (EUCPMTA) with SMTP id C3.18.04284.5946E6C5; Thu, 21
	Feb 2019 08:43:01 +0000 (GMT)
Received: from [106.116.147.30] (unknown [106.116.147.30]) by
	eusmtip1.samsung.com (KnoxPortal) with ESMTPA id
	20190221084259eusmtip1354f4555199188cc1528f683f2250d71~FVIWvPy6o0274402744eusmtip1z;
	Thu, 21 Feb 2019 08:42:59 +0000 (GMT)
Subject: Re: [PATCH V15 14/18] block: enable multipage bvecs
To: Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval
	<osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner
	<dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike
	Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro
	<viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
	linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>,
	linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph
	Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>,
	linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob
	Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ulf Hansson
	<ulf.hansson@linaro.org>, "linux-mmc@vger.kernel.org"
	<linux-mmc@vger.kernel.org>, 'Linux Samsung SOC'
	<linux-samsung-soc@vger.kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>,
	Adrian Hunter <adrian.hunter@intel.com>, Bartlomiej Zolnierkiewicz
	<b.zolnierkie@samsung.com>
From: Marek Szyprowski <m.szyprowski@samsung.com>
Message-ID: <6c9ae4de-c56f-a2b3-2542-da7d8b95601d@samsung.com>
Date: Thu, 21 Feb 2019 09:42:59 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
	Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190215111324.30129-15-ming.lei@redhat.com>
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Brightmail-Tracker: H4sIAAAAAAAAA01SbUxbZRTee79p1nm5zHAcM4s1I+oiSPTHGyUMv7L3hybG6KYOJ53cFAot
	pHdsbvvDqAxoiNVtCpTNaRYdArZA+BorGFmhqYV1gF0mFkIGDimByqcS3ebauyn/nuc5zznn
	OckRaGmS2ybkmQ/JFrO+QMdpmI6B9cDTX+SYs55x3dqOfdNNHG4ct3O4pcbFYl/jFIerTwR4
	PB7pZPFQ+ByPexbqWHztrxMUXrkTZPF3jf0U9pQew4FAM48HOq5TuGdsFx6Zqudx7ZchDrt7
	fAwe7T7L4Ymmuyz23LUjXH6+G+GaQC+Fu//p4nHfaSuFf59Lxlcmggy21ZVx2DkXYfDJllWE
	y6rWeez9fh8O3PaymY8R50oNSz6zLvDkkmOcJ4GJFoZ87JlnyQX3LEVGh4pJa0MlR1qXTvEk
	dN3Nkcu/lHCkdLCfJou/jTEk0hvkyCdtDYi42oLMGwnvadJz5IK8w7IlNSNbk/vHTx1U0d/p
	H7mm2qkSNJhmQ3ECiM/Bn7511oY0giTWIxhva6ZUsoJgdt6DVLKMYMHjQg9a/NWd910XEfi/
	+ZxTSQSBd3aJi7oSxHS4+W1TrGOrmAnOSEVsFC1OCFDmtscKnJgGtnnbvQZB0IoZ8MNMelRm
	xJ0w0FjFRvHDYhacuerho1grxoOvdpqJ4jjxebDPBGNjaHEHWNvraBUnwtj0eUpN2hkHnQu8
	il+B8lE7q+IECHvb7uvbwX+6iolmA9GKoLzGwaukCkH72S5Odb0AV7zDbDQoLT4Jru5UVX4R
	vu5xxWQQt8CN+Xg1wxY41VFNq7IWKk5KqjsZHF7nf2t/vDZCf4p0jg2XOTZc49hwjeP/vV8h
	pgElysWKySAraWb5SIqiNynFZkPKh4WmVnTv7/13vEtdaHXkYB8SBaTbrG1+x5QlsfrDylFT
	HwKB1m3VStnmLEmboz96TLYUfmApLpCVPpQkMLpE7fFNk/sl0aA/JOfLcpFseVClhLhtJSgp
	vHg7/2Vm52jGo8urSehIbfabTuX1A6/FP75i3DO0O2T/1TA3WB/KGza+apwreLf+7Zdszwp7
	2c3G8Pt1a4R6pPlGzlRqaX/8sOd4mWY9t6XyoT0XpSdKNiX7rSF3/u79DZOFa70HjEUVKUWL
	w5nVlYYzmT/vWNt382p4ZjnhlvSWjlFy9WlP0RZF/y/8vHyT8wMAAA==
X-Brightmail-Tracker: H4sIAAAAAAAAA02SbUxTZxTH89x3jI3XgvERlzhvfEk2rV4QOZhCSBbN4yfNTJw6Nmzkjhpp
	i72tEf1S6dCtURkqCsXBNnyZlIEwRGBFTXmzQ1YDKVGkfLAsOBGKm8vGBB2FLeHbL/9zfic5
	yV+gtS/ZeOGg2aZYzYYciVvAdL/pCq0vzjJnbPQ8WQz+4WoOPKFCDupKalnwe8IcXDoR4CEU
	uc1Cz/OveWgdL2Ph4d8nKHj1JsjCDU8HBe35xyAQuMlDZ2M/Ba0D70Nv+HseSssHOfC2+hno
	a7nMwVD1Wxba3xYiOFXRgqAkcIeClqkmHnznnRQ8G10DbUNBBlxlBRzUjEYYOFn3J4KC05M8
	dP3wEQSmu9j0laTmVQlLipzjPGl2h3gSGKpjyOftYyyp9P5Gkb4eO6mv+pIj9b+f48lgv5cj
	Pz12cCT/QQdNXv46wJDInSBHzjZUIVLbEGR2xu7T6a0Wu01512hRbanSxzIk6OQU0CVsStHJ
	icmfbElIkjak6bOUnINHFOuGtP0648TPjVTua/3R2vAtyoEeyC4UI2BxE+6+dJtyoQWCVryK
	8HcTg9zc4B3sv+hg5zgWT/W7uLmlMYTPX63mo4NYUY+fXqtGUY4T03FN5AsUXaLFpwK+cqp4
	1taKRtz96PIsc6KMXWPRS4KgEdPw3RF9NGbE1bjTc5qNxkvEDBz8ZfakRlyM/aXDTJRjxC24
	cCQ4m9PiWjxV3kvP8QrsvFX2Hy/FA8MV1FdI656nu+cp7nmKe57yDWKqUJxiV03ZJlXWqQaT
	ajdn6w5YTPVopm6NnZM/NqHeul0+JApIWqi5uceUoWUNR9Q8kw9hgZbiNNr95gytJsuQd0yx
	WjKt9hxF9aGkmd+K6PglBywz5TXbMuUkORlS5OTE5MTNIC3VBDbm7dOK2QabckhRchXr/x4l
	xMQ70F7HlTP3InQ43fnMeW6d0NVDFu3+Z1XHhbEhN33o2/FRJdSy4/WFFbAu7DU+XLmw2XX8
	j0XLFX95z/1CX9P6NW0vtiWNfFgsxX3wqXeSLytKPbzs5NaGs7ml+uurputTeq9Lg5nFT7bH
	38g5U5KtVBZMNLfl6fMvpk47tvbd++uzyj6JUY0G+T3aqhr+BeGZ066EAwAA
X-CMS-MailID: 20190221084301eucas1p11e8841a62b4b1da3cccca661b6f4c29d
X-Msg-Generator: CA
Content-Type: text/plain; charset="utf-8"
X-RootMTR: 20190221084301eucas1p11e8841a62b4b1da3cccca661b6f4c29d
X-EPHeader: CA
CMS-TYPE: 201P
X-CMS-RootMailID: 20190221084301eucas1p11e8841a62b4b1da3cccca661b6f4c29d
References: <20190215111324.30129-1-ming.lei@redhat.com>
	<20190215111324.30129-15-ming.lei@redhat.com>
	<CGME20190221084301eucas1p11e8841a62b4b1da3cccca661b6f4c29d@eucas1p1.samsung.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dear All,

On 2019-02-15 12:13, Ming Lei wrote:
> This patch pulls the trigger for multi-page bvecs.
>
> Reviewed-by: Omar Sandoval <osandov@fb.com>
> Signed-off-by: Ming Lei <ming.lei@redhat.com>

Since Linux next-20190218 I've observed problems with block layer on one
of my test devices (Odroid U3 with EXT4 rootfs on SD card). Bisecting
this issue led me to this change. This is also the first linux-next
release with this change merged. The issue is fully reproducible and can
be observed in the following kernel log:

sdhci: Secure Digital Host Controller Interface driver
sdhci: Copyright(c) Pierre Ossman
s3c-sdhci 12530000.sdhci: clock source 2: mmc_busclk.2 (100000000 Hz)
s3c-sdhci 12530000.sdhci: Got CD GPIO
mmc0: SDHCI controller on samsung-hsmmc [12530000.sdhci] using ADMA
mmc0: new high speed SDHC card at address aaaa
mmcblk0: mmc0:aaaa SL16G 14.8 GiB

...

EXT4-fs (mmcblk0p2): INFO: recovery required on readonly filesystem
EXT4-fs (mmcblk0p2): write access will be enabled during recovery
EXT4-fs (mmcblk0p2): recovery complete
EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. Opts: (null)
VFS: Mounted root (ext4 filesystem) readonly on device 179:2.
devtmpfs: mounted
Freeing unused kernel memory: 1024K
hub 1-3:1.0: USB hub found
Run /sbin/init as init process
hub 1-3:1.0: 3 ports detected
*** stack smashing detected ***: <unknown> terminated
Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000004
CPU: 1 PID: 1 Comm: init Not tainted 5.0.0-rc6-next-20190218 #1546
Hardware name: SAMSUNG EXYNOS (Flattened Device Tree)
[<c01118d0>] (unwind_backtrace) from [<c010d794>] (show_stack+0x10/0x14)
[<c010d794>] (show_stack) from [<c09ff8a4>] (dump_stack+0x90/0xc8)
[<c09ff8a4>] (dump_stack) from [<c0125944>] (panic+0xfc/0x304)
[<c0125944>] (panic) from [<c012bc98>] (do_exit+0xabc/0xc6c)
[<c012bc98>] (do_exit) from [<c012c100>] (do_group_exit+0x3c/0xbc)
[<c012c100>] (do_group_exit) from [<c0138908>] (get_signal+0x130/0xbf4)
[<c0138908>] (get_signal) from [<c010c7a0>] (do_work_pending+0x130/0x618)
[<c010c7a0>] (do_work_pending) from [<c0101034>]
(slow_work_pending+0xc/0x20)
Exception stack(0xe88c3fb0 to 0xe88c3ff8)
3fa0:                                     00000000 bea7787c 00000005
b6e8d0b8
3fc0: bea77a18 b6f92010 b6e8d0b8 00000001 b6e8d0c8 00000001 b6e8c000
bea77b60
3fe0: 00000020 bea77998 ffffffff b6d52368 60000050 ffffffff
CPU3: stopping

I would like to help debugging and fixing this issue, but I don't really
have idea where to start. Here are some more detailed information about
my test system:

1. Board: ARM 32bit Samsung Exynos4412-based Odroid U3 (device tree
source: arch/arm/boot/dts/exynos4412-odroidu3.dts)

2. Block device: MMC/SDHCI/SDHCI-S3C with SD card
(drivers/mmc/host/sdhci-s3c.c driver, sdhci_2 device node in the device
tree)

3. Rootfs: Ext4

4. Kernel config: arch/arm/configs/exynos_defconfig

I can gather more logs if needed, just let me which kernel option to
enable. Reverting this commit on top of next-20190218 as well as current
linux-next (tested with next-20190221) fixes this issue and makes the
system bootable again.

> ---
>  block/bio.c         | 22 +++++++++++++++-------
>  fs/iomap.c          |  4 ++--
>  fs/xfs/xfs_aops.c   |  4 ++--
>  include/linux/bio.h |  2 +-
>  4 files changed, 20 insertions(+), 12 deletions(-)
>
> diff --git a/block/bio.c b/block/bio.c
> index 968b12fea564..83a2dfa417ca 100644
> --- a/block/bio.c
> +++ b/block/bio.c
> @@ -753,6 +753,8 @@ EXPORT_SYMBOL(bio_add_pc_page);
>   * @page: page to add
>   * @len: length of the data to add
>   * @off: offset of the data in @page
> + * @same_page: if %true only merge if the new data is in the same physical
> + *		page as the last segment of the bio.
>   *
>   * Try to add the data at @page + @off to the last bvec of @bio.  This is a
>   * a useful optimisation for file systems with a block size smaller than the
> @@ -761,19 +763,25 @@ EXPORT_SYMBOL(bio_add_pc_page);
>   * Return %true on success or %false on failure.
>   */
>  bool __bio_try_merge_page(struct bio *bio, struct page *page,
> -		unsigned int len, unsigned int off)
> +		unsigned int len, unsigned int off, bool same_page)
>  {
>  	if (WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED)))
>  		return false;
>  
>  	if (bio->bi_vcnt > 0) {
>  		struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
> +		phys_addr_t vec_end_addr = page_to_phys(bv->bv_page) +
> +			bv->bv_offset + bv->bv_len - 1;
> +		phys_addr_t page_addr = page_to_phys(page);
>  
> -		if (page == bv->bv_page && off == bv->bv_offset + bv->bv_len) {
> -			bv->bv_len += len;
> -			bio->bi_iter.bi_size += len;
> -			return true;
> -		}
> +		if (vec_end_addr + 1 != page_addr + off)
> +			return false;
> +		if (same_page && (vec_end_addr & PAGE_MASK) != page_addr)
> +			return false;
> +
> +		bv->bv_len += len;
> +		bio->bi_iter.bi_size += len;
> +		return true;
>  	}
>  	return false;
>  }
> @@ -819,7 +827,7 @@ EXPORT_SYMBOL_GPL(__bio_add_page);
>  int bio_add_page(struct bio *bio, struct page *page,
>  		 unsigned int len, unsigned int offset)
>  {
> -	if (!__bio_try_merge_page(bio, page, len, offset)) {
> +	if (!__bio_try_merge_page(bio, page, len, offset, false)) {
>  		if (bio_full(bio))
>  			return 0;
>  		__bio_add_page(bio, page, len, offset);
> diff --git a/fs/iomap.c b/fs/iomap.c
> index af736acd9006..0c350e658b7f 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -318,7 +318,7 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  	 */
>  	sector = iomap_sector(iomap, pos);
>  	if (ctx->bio && bio_end_sector(ctx->bio) == sector) {
> -		if (__bio_try_merge_page(ctx->bio, page, plen, poff))
> +		if (__bio_try_merge_page(ctx->bio, page, plen, poff, true))
>  			goto done;
>  		is_contig = true;
>  	}
> @@ -349,7 +349,7 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  		ctx->bio->bi_end_io = iomap_read_end_io;
>  	}
>  
> -	__bio_add_page(ctx->bio, page, plen, poff);
> +	bio_add_page(ctx->bio, page, plen, poff);
>  done:
>  	/*
>  	 * Move the caller beyond our range so that it keeps making progress.
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 1f1829e506e8..b9fd44168f61 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -616,12 +616,12 @@ xfs_add_to_ioend(
>  				bdev, sector);
>  	}
>  
> -	if (!__bio_try_merge_page(wpc->ioend->io_bio, page, len, poff)) {
> +	if (!__bio_try_merge_page(wpc->ioend->io_bio, page, len, poff, true)) {
>  		if (iop)
>  			atomic_inc(&iop->write_count);
>  		if (bio_full(wpc->ioend->io_bio))
>  			xfs_chain_bio(wpc->ioend, wbc, bdev, sector);
> -		__bio_add_page(wpc->ioend->io_bio, page, len, poff);
> +		bio_add_page(wpc->ioend->io_bio, page, len, poff);
>  	}
>  
>  	wpc->ioend->io_size += len;
> diff --git a/include/linux/bio.h b/include/linux/bio.h
> index 089370eb84d9..9f77adcfde82 100644
> --- a/include/linux/bio.h
> +++ b/include/linux/bio.h
> @@ -441,7 +441,7 @@ extern int bio_add_page(struct bio *, struct page *, unsigned int,unsigned int);
>  extern int bio_add_pc_page(struct request_queue *, struct bio *, struct page *,
>  			   unsigned int, unsigned int);
>  bool __bio_try_merge_page(struct bio *bio, struct page *page,
> -		unsigned int len, unsigned int off);
> +		unsigned int len, unsigned int off, bool same_page);
>  void __bio_add_page(struct bio *bio, struct page *page,
>  		unsigned int len, unsigned int off);
>  int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter);

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

