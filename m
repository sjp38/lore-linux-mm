Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64BA1C46499
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 16:32:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27603216E3
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 16:32:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27603216E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA7CA8E0003; Fri,  5 Jul 2019 12:32:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A58BC8E0001; Fri,  5 Jul 2019 12:32:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91EFC8E0003; Fri,  5 Jul 2019 12:32:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 707E78E0001
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 12:32:11 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x16so2636342qtk.7
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 09:32:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=Z+Ll5aWy1Qty19+jUD0PYaZURaSxcI+6or9UIULi7jU=;
        b=r1vYFPzz3T3uPMPNz/oHcqyyC7uOc85E8R3H558QoaCXkiw0LNwJhGk6CQwEZnpk57
         f1OLaEOw/7nY1cc/f6PJq9Bmar9YNIoS3w7mMUYO8OPWIjVhbl+m4k35hdpTus5Unq9W
         jHDfiyOhZ5V1p4lVWrO4is8GvUB3m5kIYzT5QqMI9Ur52YK2tejIhylEz4nmkCh4DAEY
         94zLWN0U6kLPkotcA/K5z9Q/WInN7TF7BzBvaNyS1jTUgprLQm2cfdNUQEDG5q6OpAiu
         WCHk0S2LWz58ut0IO9BXzjfPgvyB177lPKjJn0Zawnl8kmVmC8HQ17YW1XM0OhMz+V56
         hpAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAVYcZHiPVKGCVy33ctO5G4MtHpTUCFfEzCt4czpzwS/dScnerBd
	/dtfyZ3m7ZPZWDwNR0/zQfk3pE5MCWXPDkotIxYctFzZfULUKflEXM6Mqi4f4BmgLQbPrLH3aKg
	eow3uk0WQnEqkpzbDpIXZlb5X0YMW3AcZHVDWEVfyF0cbKTBd5YoMak+7Lepiq6E=
X-Received: by 2002:a0c:8885:: with SMTP id 5mr4134447qvn.137.1562344331182;
        Fri, 05 Jul 2019 09:32:11 -0700 (PDT)
X-Received: by 2002:a0c:8885:: with SMTP id 5mr4134384qvn.137.1562344330271;
        Fri, 05 Jul 2019 09:32:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562344330; cv=none;
        d=google.com; s=arc-20160816;
        b=a+oTP5z8VBPGDrdQO5YOQ7LqKXAj9c68Ix1YOU1T+oD2EutL5SB0oNSsK5TwWvNvhY
         wX2NcVxn00TuZ22k+5cAlnI1I1mgyDLVtz1ZAZKs6hlqq7/fsRC6nad/Tnn6HXVUsQxx
         0Eo3NEwGwWcCsu+egqATt/mTcKpGdQR3rEzkm4p7oqa0EQgtLlPuY3nbNxmmxowMpT/o
         SU2NwbtzyPWYrVhybNfIKVg/fJ4tYfqgPK6XqILH0SmB+X0mX0BJEg3LhSNOK1VpaLjC
         cTj4Tkc5n1db+FK0SGxUBhwx9P5DNfYKR1WaLxQGtFdDErkSlM7TiEfNv+JdhfSbtDeZ
         tO+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=Z+Ll5aWy1Qty19+jUD0PYaZURaSxcI+6or9UIULi7jU=;
        b=LbPfG/wRuKouayNIv8aHd4NJLUf1FVNagmiyuFzDPUlsnZ8Qk3hYVLEW4AsuHQvSgb
         MZFnnAPvigbG7WJD3ew4FiFwmjYcFetnp4w20kSYYYgpSjI3ntw6tKGex6KWIwoszIun
         gn2QROO/WK3fkPnPhjwq5RvfmARCNM/Uh8yCbJIThADmmzNyKtyy3fMoHH/1U/oWn8Qk
         jPouo52pJhA1etnDjdSeao6ZTdvUxhW/0V2aPJvToj47mes52uXeJo5MaQJPHj/bLNzy
         0mXiAAp5CbIcr82bFwvvK3Flc+/GANLNqyYzh7aVoMN3X/xOrr63DbSRB9mutqYPDYca
         UZUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n24sor8251701qvd.2.2019.07.05.09.32.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Jul 2019 09:32:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqzbKktKqp9uhoV9vXQtX+yr4qrddqZeixUg0JHk9T9z0CkBpogcwCP2RGTyS+kBPHd4G/z9oTTSySyNO6hkDOg=
X-Received: by 2002:a0c:e952:: with SMTP id n18mr3948664qvo.63.1562344329835;
 Fri, 05 Jul 2019 09:32:09 -0700 (PDT)
MIME-Version: 1.0
References: <201907060045.bQY0GTP0%lkp@intel.com> <20190705161529.GA8626@kroah.com>
In-Reply-To: <20190705161529.GA8626@kroah.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 5 Jul 2019 18:31:51 +0200
Message-ID: <CAK8P3a099ZeiEe-zOTJb5tXKtTU7iwzGkjv8riQVK+navotRxw@mail.gmail.com>
Subject: Re: [linux-stable-rc:linux-4.9.y 9986/9999] ptrace.c:undefined
 reference to `abort'
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Sasha Levin <alexander.levin@microsoft.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 5, 2019 at 6:15 PM Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
> On Sat, Jul 06, 2019 at 12:08:59AM +0800, kbuild test robot wrote:
> >    arch/arc/built-in.o: In function `arc_pmu_device_probe':
> > >> perf_event.c:(.text+0x99e6): undefined reference to `abort'
> >    arch/arc/built-in.o:perf_event.c:(.text+0x99e6): more undefined references to `abort' follow
>
> I've queued up af1be2e21203 ("ARC: handle gcc generated __builtin_trap
> for older compiler") to hopefully resolve this now.

Thanks, I remember the same problem happening in mainline now,
and this should solve the issue.

I also see that the backported patch that introduced the regression
has succeed in getting rid of many of the warnings in 4.9.y, and kernelci
itself does not run into the abort() issue because it has a different
compiler version:

https://kernelci.org/build/stable-rc/branch/linux-4.9.y/kernel/v4.9.184-93-gaf13e6db0db4/

All that remains now is

cc1: error: '-march=r3000' requires '-mfp32'
(.text+0x1bf20): undefined reference to `iommu_is_span_boundary'
(.text+0x1bbd0): undefined reference to `iommu_is_span_boundary'
warning: (SIBYTE_SWARM && SIBYTE_SENTOSA && SIBYTE_BIGSUR &&
SWIOTLB_XEN && AMD_IOMMU) selects SWIOTLB which has unmet direct
dependencies (CAVIUM_OCTEON_SOC || MACH_LOONGSON64 && CPU_LOONGSON3 ||
NLM_XLP_BOARD || NLM_XLR_BOARD)
arch/arc/kernel/unwind.c:188:14: warning: 'unw_hdr_alloc' defined but
not used [-Wunused-function]
drivers/clk/sunxi/clk-sun8i-bus-gates.c:85:27: warning: 'clk_parent'
may be used uninitialized in this function [-Wmaybe-uninitialized]
arch/arm64/kernel/vdso.c:127:6: warning: 'memcmp' reading 4 bytes from
a region of size 1 [-Wstringop-overflow=]

The two arm specific issues are fixed with these patches

4e903450bcb9 ("clk: sunxi: fix uninitialized access")
dbbb08f500d6 ("arm64, vdso: Define vdso_{start,end} as array")

The arc unwind fix needs to make it into mainline first, and the rest are mips
issues that may need a custom fix since there is no specific upstream
patch that could be backported.

      Arnd

