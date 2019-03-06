Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4ECAEC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 08:53:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 185CC20675
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 08:53:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 185CC20675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 932D58E0003; Wed,  6 Mar 2019 03:53:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EA8A8E0001; Wed,  6 Mar 2019 03:53:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A9858E0003; Wed,  6 Mar 2019 03:53:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19C668E0001
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 03:53:07 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d31so5962506eda.1
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 00:53:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:user-agent:mime-version;
        bh=j/cO0QT9gHHXuTUV7/YQ2ezgg4fDau5xMe/vyjSujpI=;
        b=luAr0tTcaWr4RO97lgt3S5oIh4kwQ4K8v6IvxkM+NmCXVc/6fsEbnfvi1arMicVbZH
         GmCqOwpaJG8XHOiy03yGUi/JvVUvl9DKDl70PIUXwuOSCicXKKRotmrL4n8sEBcZPzyP
         2t6OiJx9s3G6QCI1tk4U2Ny742r4g2m6NZmIY/riVjGkzTQNXqe5NR7Df4z+yD1H00Z9
         g775iRy3tdc8btyFPn30Lsb2y1CHSzZW0l44laDbp0+n43cn51GB503O5bdCL4PP/Abc
         at7Y3EwG15Z2CgllsV7BhKheDbHXQ1nTi8XVwnzZdTko3kwxeAsxPzMVDqQHDezhnpyy
         GBQg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rguenther@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rguenther@suse.de
X-Gm-Message-State: APjAAAWVZD5dNBBPislhpGMdHHJsBSYJfScucuwf/mYr7tX5K4mXl+5t
	V7YGRcwuraxsTdlYEM6MPRSr2OiZWLy9i+lHmCo2Smzk0SestLjyUUA1ScU5AY9jfvorH1tns05
	TitGEAcTb5uDR2TqHsMECZcw9Dcl/xcQCrdhAalSNfhezIwu3xtTOxV8FA1i7EXIrRQ==
X-Received: by 2002:a17:906:f101:: with SMTP id gv1mr3120147ejb.73.1551862386432;
        Wed, 06 Mar 2019 00:53:06 -0800 (PST)
X-Google-Smtp-Source: APXvYqzQurq0Wd1KBwsuO8I9Fi2hS7JirqIkHfitRzDQOGMPRw29JLceCj4590gi/kptzJ2sMK2J
X-Received: by 2002:a17:906:f101:: with SMTP id gv1mr3120079ejb.73.1551862385045;
        Wed, 06 Mar 2019 00:53:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551862385; cv=none;
        d=google.com; s=arc-20160816;
        b=gOYPHuKxyMf2nCuj9dAG/3+UxOXWLbdCHUdEPtXmzj1BX8sPJ0hLfDp5zdUw1Thb/+
         rQlm2xirb375Wzmlk20N0fiuI+XYNOmcPgp62gJnb06BEsuLtDKZ9eLpzLXOypAD/vZH
         Zv9lsIipTycSKkBuN16mtPu0ZbGoWl/YT6UbZqrjGb6wyfTSelD+n0acpLn6pGTtOH3n
         v5bV6jhfAj4EIed5v+Xsu123+iWKC1vdBrKGPiqk+bTOvPXDYxMuYo5miqYWY8jJhpU6
         ASQ7ywRx04tv7krqdoTqFdk46ii78R23iKETH5DFZF3QNj+p8BC6wHTFM+Fjb5k1gP0Q
         JCJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:subject:cc:to:from:date;
        bh=j/cO0QT9gHHXuTUV7/YQ2ezgg4fDau5xMe/vyjSujpI=;
        b=BwmwMPNlalSOgjzBfNzzTJ/TWXW0qgWYky94Ch1LnuEqprpFdooVDRRH0Ck5J9X6zK
         KI/EGmrt9Y7lQPEYmNiIY2dNrbBI1a6ODSBNFMnmnkrVo0PuOxB0BJlHG56f1fOlHTsG
         N6xt32P5i2WJM8eci711qkvN168UXk2CUm3SfUYit19rtmeJZ4EQlTQ9R9vovOK9AxN8
         5GCHC8V9QXqGSNkeD8EpSx+QYyFoLtpBkySqBdV78MJlgZ42joSKUFEI3UC++taKumRN
         ihDgdXcFNu7sTrtX/ouCK584B27IWIibk5MPfqyGHY7NBH6QUDbc05yHz+KLbaFMxV/4
         OYLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rguenther@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rguenther@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b11si378739ede.340.2019.03.06.00.53.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 00:53:05 -0800 (PST)
Received-SPF: pass (google.com: domain of rguenther@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rguenther@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rguenther@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0FC33AFDF;
	Wed,  6 Mar 2019 08:53:04 +0000 (UTC)
Date: Wed, 6 Mar 2019 09:53:03 +0100 (CET)
From: Richard Biener <rguenther@suse.de>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com
cc: mhocko@suse.com
Subject: Kernel bug with MPX?
Message-ID: <alpine.LSU.2.20.1903060944550.7898@zhemvz.fhfr.qr>
User-Agent: Alpine 2.20 (LSU 67 2015-01-07)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hi,

I've reported this internally but got directed here, hopefully
the correct forum for bugreporting.

When running the gcc.target/i386/mpx/memmove-1.c testcase
from the GCC 8 branch on MPX capable hardware the testcase
faults and the kernel log reports the following:

[1216548.787494] BUG: Bad rss-counter state mm:0000000017ce560b idx:0 
val:385
[1216548.787498] BUG: Bad rss-counter state mm:0000000017ce560b idx:1 
val:551
[1216548.787500] BUG: non-zero pgtables_bytes on freeing mm: 24576

This is on a 4.20.7 kernel but it was reproduced it with 5.0 as well.
I believe it was fine on earlier kernels though.

I've put a statically linked executable at
http://www.suse.de/~rguenther/memmove-1.exe (needs some time to sync
to the public webserver still).

Thanks,
Richard.

-- 
Richard Biener <rguenther@suse.de>
SUSE LINUX GmbH, GF: Felix Imendoerffer, Jane Smithard, Graham Norton, HRB 21284 (AG Nuernberg)

---------- Forwarded message ----------
Date: Tue, 5 Mar 2019 15:22:22 +0100
From: Michal Hocko <mhocko@suse.com>
To: Richard Biener <rguenther@suse.de>
Cc: suse-labs@suse.de
Subject: Re: [suse-labs] Kernel bug with MPX?

On Mon 04-03-19 14:12:07, Richard Guenther wrote:
> 
> I have a MPX testcase (GCC mpx testsuite) that triggers
> 
> [1216548.787494] BUG: Bad rss-counter state mm:0000000017ce560b idx:0 
> val:385
> [1216548.787498] BUG: Bad rss-counter state mm:0000000017ce560b idx:1 
> val:551
> [1216548.787500] BUG: non-zero pgtables_bytes on freeing mm: 24576
> 
> on Tumbleweed from a few weeks ago

That looks like both file and anonymous mappings do not get torn down
properly and some memory leaks.

> > uname -a
> Linux e23 4.20.7-1-default #1 SMP PREEMPT Thu Feb 7 07:16:45 UTC 2019 
> (730812f) x86_64 x86_64 x86_64 GNU/Linux
> 
> does this ring any bell?

Not really but I haven't been following MPX development closely. I
can reproduce the issue on 5.0 kernel

BUG: Bad rss-counter state mm:00000000406bd30e idx:1 val:25591

so I guess it would be best to report upstream (Cc linux-mm@kvack.org,
linux-kernel@vger.kernel.org and dave.hansen@intel.com). Let me know if
you need any help.

-- 
Michal Hocko
SUSE Labs

