Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD84AC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:12:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B2FA217D7
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:12:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="yPVtcuIm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B2FA217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39EB56B0007; Tue,  6 Aug 2019 17:12:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 328326B0008; Tue,  6 Aug 2019 17:12:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C9096B000A; Tue,  6 Aug 2019 17:12:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id E19E06B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 17:12:08 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id d13so50638738oth.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 14:12:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=SxfvXS8dkeLPpXkICvCXwX+4rlE1NK6AW+Bou/1xFzU=;
        b=DGPUoWmkexU9Utp8aKxcd2RpZ2/fwRTJMLuPNa1CBNjAAhKUrTrlgmewbxy7YZVJD8
         oHoV5xCPsrnCVGIYmiGsREh4vaHLRdEOMHprZlq0EvtGGm+8gTQKeSGyWkY7S5d5HSjW
         QUSRdrXsrAPmZVjaP70+foFvsxCFc9Ml8MiYy0mtxWR2u/s2bmRuktRsm/sj7e4OIaKF
         NkhkNHrJFPxD71pAJniMSnPR0tzgIUekGMewHF4pEdzA7z+L1pBenX9maLsV15/s+eLE
         MI/fWcK1pPWXe6F2uIfLFOyJEXZde2db7e104gf/ufj1qW4FFBkOR6sw8Hha2qJuxGN6
         VSDg==
X-Gm-Message-State: APjAAAXeO/SoSmESBeW8ioo7n0U/O/p4JkGJUEk1chgBtHGiwC7Xf+cC
	oZAQlqcFPOfDOEKshvrdwcJjol4vGMmuIeV7yPHjMXm6w+1UIXjFcotQRwDAyqoBfW0OFUllf3G
	uAlSHEmDiAeRMnZxlMMLW5SrEoI9ZrpkH1ctQozBDO4D5wxokRKys/XSAEy/n/fepEw==
X-Received: by 2002:a05:6808:4d6:: with SMTP id a22mr2829840oie.55.1565125928603;
        Tue, 06 Aug 2019 14:12:08 -0700 (PDT)
X-Received: by 2002:a05:6808:4d6:: with SMTP id a22mr2829818oie.55.1565125928057;
        Tue, 06 Aug 2019 14:12:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565125928; cv=none;
        d=google.com; s=arc-20160816;
        b=AtP0M/F6QOHQYB4RgF2/Y5QLjNyEqchj42D0P1RqIe5yZG57MnApHleYkdxYTchZvx
         4Crb+Al82SVR+a2ueCfsov7M+LcgqnPXdAHD8n1/ndy8VokymbAq+A1HUzluaHniEv4w
         PQgRJl9y4E/jlM9/nvoe/KCXYL3+0d9Lz1MbrsWnnX2l+Nxu/k3E36ezdK301PmLNzKe
         4p++JqyWpjib8Po7sAbcNweKNHOSaZ/EJ03o0UnhWVpygY2lEG8iUQu16DrcRhNpUD5w
         uv2a5upl3vlpaeeynq9wLrFd4Umq24zwhC3ciMEuY+ANsoPyTzdOmDdYTjiy3HISrhjj
         JNSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=SxfvXS8dkeLPpXkICvCXwX+4rlE1NK6AW+Bou/1xFzU=;
        b=erkeXC3jAtC0ZMxDoK5t+TJEkyEyoTxJP80Ju7J4uSu3rgjPmedLF6AApkZNavXhUf
         hWcia1JYI2P9XIegP2YcNYY+HXncpuQRMHsW1THLvDMSLpnSfJSMRvBGTQSvslIZa9jG
         Tj7h5hEj2rxZiKu/X8tCQO7ddqthV+Kb+0eRm4Xr/bCpqOZwpFDyilxeWeB83DWj6RNm
         6JmpZ2PL9zG/es+47FJU73ci9l7Yuk9fSdMd7jHWHrSfDdR6phWI4MjqZRgQoT027L1v
         tDAQ/C8wnnj4NFYbC2eXWOLInghd5q2XF80JdBbL4F3bzJQh+pTTuW6YxNmAB1h7RXsQ
         U4hQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=yPVtcuIm;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c15sor47355466otr.178.2019.08.06.14.12.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 14:12:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=yPVtcuIm;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=SxfvXS8dkeLPpXkICvCXwX+4rlE1NK6AW+Bou/1xFzU=;
        b=yPVtcuImiPOLRP461tix/AcQLCmPpM2hT6wfZ3z3u8rK+/Z4Wcy9TZYR1+pBKb1sEv
         8s5ZXsKoBm0t/6DdFcCMSQQnCtMuYyJQRjyChWPlRiCLIdVoUKmVW20uRNmVEQwz55Q0
         bE/hu0rH2S8PkC3OoCF8CUVDVOjsDrmQt5AwkwC3N5pRqe3g/DntzunlOcmsfFn2MCbD
         i/D13Z/hbxjfwNu62slNJ6Upz8aIY9OSQn0Oh9mvcGHdw8JdOq4oK7LKRHM//+sN1MJN
         6p+ftsIHRD7HxlD2OO+al3P77mmVq899M63tNAeQ9Mm+CdQEQz3bbwdYoFTGtLZ1zNlr
         Fcgw==
X-Google-Smtp-Source: APXvYqw9o9Yb/ND1MDNnGatZSfaVVbG1TKnSQ9e0LNGeNp1/ZpabJ2T1j/9smMMqoDrW/seGup0iO9zq36rzrSQKj2U=
X-Received: by 2002:a9d:7a8b:: with SMTP id l11mr4580336otn.247.1565125927538;
 Tue, 06 Aug 2019 14:12:07 -0700 (PDT)
MIME-Version: 1.0
References: <1565112345-28754-1-git-send-email-jane.chu@oracle.com> <1565112345-28754-3-git-send-email-jane.chu@oracle.com>
In-Reply-To: <1565112345-28754-3-git-send-email-jane.chu@oracle.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 6 Aug 2019 14:11:56 -0700
Message-ID: <CAPcyv4jgtYMKgEB4jnQ0g4fQPO39BCOmQM8Zo231=_D7L6wH=A@mail.gmail.com>
Subject: Re: [PATCH v4 2/2] mm/memory-failure: Poison read receives SIGKILL
 instead of SIGBUS if mmaped more than once
To: Jane Chu <jane.chu@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 10:28 AM Jane Chu <jane.chu@oracle.com> wrote:
>
> Mmap /dev/dax more than once, then read the poison location using address
> from one of the mappings. The other mappings due to not having the page
> mapped in will cause SIGKILLs delivered to the process. SIGKILL succeeds
> over SIGBUS, so user process looses the opportunity to handle the UE.
>
> Although one may add MAP_POPULATE to mmap(2) to work around the issue,
> MAP_POPULATE makes mapping 128GB of pmem several magnitudes slower, so
> isn't always an option.
>
> Details -
>
> ndctl inject-error --block=10 --count=1 namespace6.0
>
> ./read_poison -x dax6.0 -o 5120 -m 2
> mmaped address 0x7f5bb6600000
> mmaped address 0x7f3cf3600000
> doing local read at address 0x7f3cf3601400
> Killed
>
> Console messages in instrumented kernel -
>
> mce: Uncorrected hardware memory error in user-access at edbe201400
> Memory failure: tk->addr = 7f5bb6601000
> Memory failure: address edbe201: call dev_pagemap_mapping_shift
> dev_pagemap_mapping_shift: page edbe201: no PUD
> Memory failure: tk->size_shift == 0
> Memory failure: Unable to find user space address edbe201 in read_poison
> Memory failure: tk->addr = 7f3cf3601000
> Memory failure: address edbe201: call dev_pagemap_mapping_shift
> Memory failure: tk->size_shift = 21
> Memory failure: 0xedbe201: forcibly killing read_poison:22434 because of failure to unmap corrupted page
>   => to deliver SIGKILL
> Memory failure: 0xedbe201: Killing read_poison:22434 due to hardware memory corruption
>   => to deliver SIGBUS
>
> Signed-off-by: Jane Chu <jane.chu@oracle.com>
> Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Looks good, ignore the checkpatch warning about too long subject line,
looks appropriate to me:

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

