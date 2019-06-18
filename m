Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BF81C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 06:44:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F06A20652
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 06:44:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="PDyW8TAo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F06A20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9DC98E0002; Tue, 18 Jun 2019 02:44:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4E2C8E0001; Tue, 18 Jun 2019 02:44:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A158A8E0002; Tue, 18 Jun 2019 02:44:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 784DB8E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 02:44:46 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id l7so5950389otj.16
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 23:44:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=VK+Tna/iV8U0LWobX7frBvdux+Mmk/3A07T2dRSet2o=;
        b=pXAE/VjFlgk6EMWy3ZJSQzl3U+qfRY0cfTG31OFtWtZsH0mpC4WBKTo2X/WwcJvBL2
         c2aEwkIGnZLxwJoPfKqxYEQeWSJork4xc5/0CACkKTHQrhcs1jXK1j+7+kPdQRMkzeso
         i426ULh6H9Dwck6VXj9oR7zjpvZ0KIhrqAA8fma9DyDQb5k9fb6L+noCU9WK/iix46Yz
         FDbdlM51FLj29fLDtGZF7V7eWyOC2nde+o1kD0+PxJu7Zd9b+BxIrU2iwiFF3msLY7af
         rRxmzZhR6l0yVwC+W7PhKlJlb9IelmfItBV4RBF8zX0iQ62oC8pSRUmXUyiHwY0P8ii0
         C3mA==
X-Gm-Message-State: APjAAAUU89XJXeyGYXvmq2usJUsNJNA+NLcuvQ+cYe1yBYl3Lt+Rhl42
	xmd5BsfVVT1qTFSi/pd7OlCsyVs9dIGnxv3CMFB7/o8/L5jm7VYh141KQ+0hP7spb9GRlBGWApW
	c8bHxcM8gSEpFc9IvutXkaxgq9PK/DFF7YFfq37VWP1wgOHTX/E2+BB3rNxMxTzHjvw==
X-Received: by 2002:a9d:4f0f:: with SMTP id d15mr3455879otl.52.1560840286041;
        Mon, 17 Jun 2019 23:44:46 -0700 (PDT)
X-Received: by 2002:a9d:4f0f:: with SMTP id d15mr3455837otl.52.1560840285374;
        Mon, 17 Jun 2019 23:44:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560840285; cv=none;
        d=google.com; s=arc-20160816;
        b=DI1dAKHtvAjdfsEENs4z2DJyv7ofsQfOruD1WLEOm05O5drFBPhpqaVQO7wlKqKsss
         o8bPOoeEvJvbNTSV+axtqY4/VBDzciy8rA6aIYWc9cIOYuWxTIfZop4a0tCKNjCrcsQg
         jAYxahPeB09DZEoD+LzbzjLoXvNz/fGZZcod0D7IEU8+sydQaLVEEk3pVtyVGpOrbscz
         JT7IBPZ1bTzjYIX/DPp3USpDnDMxHzWg8z8BG5W9wwc85F5OOcVxobZvD2BEqRrAmgKQ
         G1Q3O5nSl/JRrZp6jhRB+M4aAFXynsV52mKNjL1WhvXEeYXvhQxx6iKiYu9nNOrkPDmp
         HHyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VK+Tna/iV8U0LWobX7frBvdux+Mmk/3A07T2dRSet2o=;
        b=PoJ44dmKMmnBsYILYlKJcRIjrNIDdYxTez+4VqbI5nRi4Q0xi1rho/0mZoBItHSQUC
         RNZBFjGR7xjN+jz4CRfFzBBu9mLliSfrFniRyQbRVuqgdUPy+bpcvThJZnP151nt3J8A
         BYeCxSULEYgBviNfOiX9Vfeh1QywxL6z8YcdaUUsFF1kSCpHPE6BZL8z0NXzHor/XA2g
         V38i1Z5IA/Zvol3gVgeYwekBitlg623MKoXmHO7SGu3C+KmB764CSWilJP1oQL4ZA2q0
         JRZXd6CdpFu8M5zCLGOLHcE+oCE4AhusTyA1ZONr6zxeMc1zkMxBuWlRlFgF6CLDV5P4
         ZYbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=PDyW8TAo;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g22sor6437193otg.158.2019.06.17.23.44.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 23:44:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=PDyW8TAo;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VK+Tna/iV8U0LWobX7frBvdux+Mmk/3A07T2dRSet2o=;
        b=PDyW8TAofhvqUW/2GACnAY5YkBvkFVU1w+wB59R0SpjrzCuk/bYvX8yNt8LtLzjEsY
         KUaeC+Fjq02TdAYL44zIwo6tZt+JNdRpWOlSZ/c0vKdSfjFJtazzXqfvqlSS3jgrw5sE
         fTR8RMwTGWygNypc4YyM31o8c0fSxpdSdqQnxT36Xiqik7NuWvXCL/qsaKFNuvGqmOaT
         KM4d2hz1PXB41WsBA0f0aPullp5tjm/OXKAkHS7zSO2tyAvSxoA53zEucxdlBpHh67Kc
         P61dfDC8g2EaJmY+aCM8S6vcLFqPyumX+jYhfnDEHBsiaDR5xE406kWXsSvQj7iNEKwY
         WD6w==
X-Google-Smtp-Source: APXvYqyaFChW+2Y3LxLrxij/hGfBTYgPu7CeqLIDpIpJp5MqTEPAxGlNYhpNDoo6MTuAem3A7Ef0h9Bg2W4wMyFdxyk=
X-Received: by 2002:a9d:470d:: with SMTP id a13mr28328925otf.126.1560840285119;
 Mon, 17 Jun 2019 23:44:45 -0700 (PDT)
MIME-Version: 1.0
References: <20190613045903.4922-1-namit@vmware.com>
In-Reply-To: <20190613045903.4922-1-namit@vmware.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 17 Jun 2019 23:44:34 -0700
Message-ID: <CAPcyv4hpWg5DWRhazS-ftyghiZP-J_M-7Vd5tiUd5UKONOib8g@mail.gmail.com>
Subject: Re: [PATCH 0/3] resource: find_next_iomem_res() improvements
To: Nadav Amit <namit@vmware.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Borislav Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra <peterz@infradead.org>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Bjorn Helgaas <bhelgaas@google.com>, 
	Ingo Molnar <mingo@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 9:59 PM Nadav Amit <namit@vmware.com> wrote:
>
> Running some microbenchmarks on dax keeps showing find_next_iomem_res()
> as a place in which significant amount of time is spent. It appears that
> in order to determine the cacheability that is required for the PTE,
> lookup_memtype() is called, and this one traverses the resources list in
> an inefficient manner. This patch-set tries to improve this situation.

Let's just do this lookup once per device, cache that, and replay it
to modified vmf_insert_* routines that trust the caller to already
know the pgprot_values.

