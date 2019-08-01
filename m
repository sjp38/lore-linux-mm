Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72587C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 09:04:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24F8C20644
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 09:04:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24F8C20644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5F3C8E0006; Thu,  1 Aug 2019 05:04:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A11558E0001; Thu,  1 Aug 2019 05:04:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 926498E0006; Thu,  1 Aug 2019 05:04:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 565BD8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 05:04:04 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 21so45257871pfu.9
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 02:04:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=UscLS+uJA1ujJoA0gKk+oi7dNCZiYhBw78grAqLe0F0=;
        b=Yl2j1WVeqx8nVSHd5FcMs9QfQZngYUqgC9QClCAYe4mPmnOFgm95sFwoBT3WdEj2Au
         3f2psDZ8MSg7joewS1ojx0CDhlXWnVEBotPRnM5a2CV+FCXYib4eziRx5H5HpAyjqtqH
         +xIDCFmeziSdPY48FFVrl2iiHwGSPIRDMuLJGzyoeQ2oNoY651Edu5k7V9sJlsuOsejm
         //PPVuxfcGbWpTdfnxAte8gcPkfjDMwJ5ZUGOedO7ua1A+PAPtiFOx6gBFNXNQ2w8BgZ
         M5DWk4UgY8Jf8zLT3x6plLBDqAwdR6omEasAsk9qORolgV6UvZbqEruZmYyubdyXAqlM
         fE6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAWEzR5ZhKwqqUyjtocPXg4e9dVC9QVCegGtTy1n9sCKhnyV2ByQ
	vqiP/BHmKxNqtuzpYSrkYG3iMb4gi/Q1BGNOeH9zzubQij7RLkO20Stt4OBALo1iAzFxwZaIw/V
	UctKnDL361q9TQi+Clfr/PEUnis5dgy6iyeH6fVXxDo5qramNcwJvtHCXn0knI1LwBg==
X-Received: by 2002:a63:3006:: with SMTP id w6mr40249748pgw.440.1564650243909;
        Thu, 01 Aug 2019 02:04:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3TzIrHEx9GbOz3GiNa1uRJfQVC4+iBctTcsTzSBax0XRZbYwxEXZjI0vG+abcjM4CIHSb
X-Received: by 2002:a63:3006:: with SMTP id w6mr40249608pgw.440.1564650242397;
        Thu, 01 Aug 2019 02:04:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564650242; cv=none;
        d=google.com; s=arc-20160816;
        b=bzWazg8hhOl06FdVuZa9VNoVyjxWPxFH/3lehL7tUmq4GO8rcuIjDyg9uXqafxkwca
         pzDwGCfvJclah1NZc9BHV+6YijqeRGfnVWG9MxMwzi4bckIjk1mYF7Lp6IuotcsbAnnX
         JSfu3uMuY+QHD6+B8iKSe91/vG12eiEz/hUpVZ2MKvjhIvpSYnRICOJm6ZMCyyFnmqDw
         /3obOWaTmsGrVJFRRi2OCQv8G5h76Jb5czH3zabZ9NQHAwxXGo0vpZsc/bSJmsv3k57S
         RzpN3AzgzselXGgvIn4e6oeHjiZuBXFo+mZWPJgpxP3awv6TZ0LbAMC4tRoVnH57Hat1
         oQsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=UscLS+uJA1ujJoA0gKk+oi7dNCZiYhBw78grAqLe0F0=;
        b=M/1W/8Hj8pJvEozfAWY6feCD3T1AmIGuIjIwJcgrXMO0fhsXwP7JF/U7K+6XZKNvuf
         a32SAise3W5JcBGSfFa3OvwTpxIxMSjXXrKLmGm8kpH1a8nLoVFFnoNjEHXYNSjMc+hb
         H+2Cy0rY7yT3syLYYbJ5lks14q4ztnpNwodYPHVSDMkqsDvwy4tOEe1wI7RRXzFmQZub
         0OeKlM+9H2aMz9lb1d2eHwMYjyfM0WdxaFq0O4DJlBRRbP77Pwc5NZnLMeQwlLdf55eF
         Ot8DPTqD+/F83qiKuAwXnuO3dObwfSsd1MFgjKAcFB6ZpSuU4WddqVKcrDvrfFnokTni
         DKkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id x3si29972264plv.26.2019.08.01.02.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 02:04:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x71940SC015459
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 1 Aug 2019 18:04:00 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x71940LC010973;
	Thu, 1 Aug 2019 18:04:00 +0900
Received: from mail03.kamome.nec.co.jp (mail03.kamome.nec.co.jp [10.25.43.7])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x7193E3B027604;
	Thu, 1 Aug 2019 18:04:00 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.151] [10.38.151.151]) by mail03.kamome.nec.co.jp with ESMTP id BT-MMP-2655495; Thu, 1 Aug 2019 17:18:27 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC23GP.gisp.nec.co.jp ([10.38.151.151]) with mapi id 14.03.0439.000; Thu, 1
 Aug 2019 17:18:27 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Jane Chu <jane.chu@oracle.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Subject: Re: [PATCH v3 2/2] mm/memory-failure: Poison read receives SIGKILL
 instead of SIGBUS if mmaped more than once
Thread-Topic: [PATCH v3 2/2] mm/memory-failure: Poison read receives SIGKILL
 instead of SIGBUS if mmaped more than once
Thread-Index: AQHVQzSPZWUqS0z8rU+q1hsF+rBObKblZhkA
Date: Thu, 1 Aug 2019 08:18:26 +0000
Message-ID: <20190801081826.GB31767@hori.linux.bs1.fc.nec.co.jp>
References: <1564092101-3865-1-git-send-email-jane.chu@oracle.com>
 <1564092101-3865-3-git-send-email-jane.chu@oracle.com>
In-Reply-To: <1564092101-3865-3-git-send-email-jane.chu@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <3643947E1DEB764F9AEBCC8A0B8504B2@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 04:01:41PM -0600, Jane Chu wrote:
> Mmap /dev/dax more than once, then read the poison location using address
> from one of the mappings. The other mappings due to not having the page
> mapped in will cause SIGKILLs delivered to the process. SIGKILL succeeds
> over SIGBUS, so user process looses the opportunity to handle the UE.
>=20
> Although one may add MAP_POPULATE to mmap(2) to work around the issue,
> MAP_POPULATE makes mapping 128GB of pmem several magnitudes slower, so
> isn't always an option.
>=20
> Details -
>=20
> ndctl inject-error --block=3D10 --count=3D1 namespace6.0
>=20
> ./read_poison -x dax6.0 -o 5120 -m 2
> mmaped address 0x7f5bb6600000
> mmaped address 0x7f3cf3600000
> doing local read at address 0x7f3cf3601400
> Killed
>=20
> Console messages in instrumented kernel -
>=20
> mce: Uncorrected hardware memory error in user-access at edbe201400
> Memory failure: tk->addr =3D 7f5bb6601000
> Memory failure: address edbe201: call dev_pagemap_mapping_shift
> dev_pagemap_mapping_shift: page edbe201: no PUD
> Memory failure: tk->size_shift =3D=3D 0
> Memory failure: Unable to find user space address edbe201 in read_poison
> Memory failure: tk->addr =3D 7f3cf3601000
> Memory failure: address edbe201: call dev_pagemap_mapping_shift
> Memory failure: tk->size_shift =3D 21
> Memory failure: 0xedbe201: forcibly killing read_poison:22434 because of =
failure to unmap corrupted page
>   =3D> to deliver SIGKILL
> Memory failure: 0xedbe201: Killing read_poison:22434 due to hardware memo=
ry corruption
>   =3D> to deliver SIGBUS
>=20
> Signed-off-by: Jane Chu <jane.chu@oracle.com>
> Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks for the fix.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

