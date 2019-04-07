Return-Path: <SRS0=rDiK=SJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9878BC10F0E
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 22:25:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D11E20896
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 22:25:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="STseUu4Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D11E20896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E005A6B0005; Sun,  7 Apr 2019 18:25:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAF556B0006; Sun,  7 Apr 2019 18:25:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9F716B0007; Sun,  7 Apr 2019 18:25:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id A07AA6B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 18:25:54 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id u10so4824178oie.10
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 15:25:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dSIYyhAN+JUdcw1802IqaWulYZduXux4t9PncKdVS1w=;
        b=Kc+3EznQC3r7yJNw6H1hbqcw2v3Dc0hcqG7SzFmApo3SdhNNad8XltCRIT8cMwgb+R
         jbaiLV18akYSdPXH/gLpWMeaZbVV3f9RLxKYw4tg637iQhlG1mFxGY1VTxH7f0U0mHvq
         cTJkSAdS9FzYczuDTXFBe9ptn3cCMPvJNI+npxo8LvVM2qkreGG9H6K3asOfGfVEzW7X
         EfhqljEgrBWmesK1F8TlWn6k/NCVuXzcu1i1ZWU5k3IbLpVu7mSWi+arI3zm86dJ7lqE
         ptdaRFQBeFI5PAJAgxLLEFSrHKFpMVBUQFdznQ4dRpNEn2cm/A7zdZKjwPBp+APAP+Wm
         GYRA==
X-Gm-Message-State: APjAAAUwFvHJYrI+zRUlqEgAMq/xqpl9Z9BGl0imkmHhY+ukRfT5aBeN
	/oiK1wht1dOFfY/SbbnlTCGmI8xZhiUbJgneuMdDDF+MJGrGEqKi44UgZxmxZOr6Wck/RhLvt2R
	Pqgc1JtNOwyCyIWeC+ruWpzeH/4h04/ks/sJh5NL5lXw5lAg0q/QBNIHQxOQeIZp7aw==
X-Received: by 2002:aca:32c2:: with SMTP id y185mr15129674oiy.177.1554675954196;
        Sun, 07 Apr 2019 15:25:54 -0700 (PDT)
X-Received: by 2002:aca:32c2:: with SMTP id y185mr15129652oiy.177.1554675953511;
        Sun, 07 Apr 2019 15:25:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554675953; cv=none;
        d=google.com; s=arc-20160816;
        b=ukzKIIKZnNssessGrsVTvoq0V5R3NmVNLtALZ/9yXL8wPSXwAq2ztZdyaS+EElJeZA
         KfRoYKDoQeaLNg8wspvT1NlD11LAAwyezEj/7/+Y3nDg2VdYLttoGS4VAH3q6RdREOau
         peIyiF2RvITuVZRXxX6vmCnfUHtq37CxLQ1QvIQZiXQfbPaF+loIyglTZ0sisoDF1zfE
         IBX9BPL8BvAMxt1Qc0oz3BvpAbl2iemD0TXRNqnSI06nAm6W1QAp4xCO3t6mn728RN9D
         H/Vbhn1kvkxn3ix2AaOXOzmGlU272HX9nVUlHGRKQ7tZbSPtiT4riX2v8KtE5TtWoCAp
         zNlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dSIYyhAN+JUdcw1802IqaWulYZduXux4t9PncKdVS1w=;
        b=g+SYFuXodeLsfFXDAeRue8/q9mQtR6AlMVEMwPJzobw+dQz1n5NxBEGi7vS1mwqDsF
         snjCpb63Wcm0iUCrVpy7eZ9mqqtXXQrmV+HiAD7r8/jzXDoegVWcbu2BLbP5KrLKRH20
         5wk/QO0rr7syqSo1NqCo8z8O0aAMXzYrMnJJCstRnDwakRnWLPsVNLmzkiUE1bkzG3+V
         b9IPLXPf5lWArAdCX616FdBghsF56m5HmFXdpWAMvjvTgaq5ZUHt41+iUyCxYpVwOCAW
         4xe4qq2zzxEJ/vIdWDLojDpGK+TcAZZ0qEuT4dQ4c6quvNuZoYiNl3ChiVFwmKHAlcFY
         EFCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=STseUu4Q;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q6sor15858423oth.97.2019.04.07.15.25.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Apr 2019 15:25:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=STseUu4Q;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dSIYyhAN+JUdcw1802IqaWulYZduXux4t9PncKdVS1w=;
        b=STseUu4Qjgjy9njAA9r9SS89Q1Qc1mHyKUU6BCe0QtFlsn76GnFYLweuE49QM8DbB5
         hFS9YcVM7A71oTo2WmekqkNlZmZHSOtNhIjgxzR01ggAKWwcmWuMP0mkFiOWI5NanNzp
         KORWicJE2SBhGZYKlmT3gmnJLLzv+Yox4jAKmuOKS3KtKbhavdkLXOm8roFPfdaN7PzJ
         zeb8XaMtoe8ax/i1r5fGfNQogByAO9Zv3rLVL5K0yIji8fafHY/gWNX9lQtu2YduUaKo
         xIKIjsaUNOkuH4fNWJT+oh5EbWths1bWHB4Vdgp7M4yRdz0jDyLrIm01sj8i+QmN2MJd
         GI2w==
X-Google-Smtp-Source: APXvYqwoVM65s3bU6ZL6Dq7BGZF2PTZbAkqqEHOI98T6m0K2l5zk/iusjB/xG87bXCPh38ljdRy+0lGj09jZOYWPeys=
X-Received: by 2002:a9d:3f4b:: with SMTP id m69mr17287564otc.246.1554675953202;
 Sun, 07 Apr 2019 15:25:53 -0700 (PDT)
MIME-Version: 1.0
References: <7885dce0-edbe-db04-b5ec-bd271c9a0612@arm.com> <5b18e1c2-4ec5-8c61-a658-fb91996b95d0@arm.com>
 <60d1c5b7-7f85-7658-00f3-a3e5c6edc302@arm.com>
In-Reply-To: <60d1c5b7-7f85-7658-00f3-a3e5c6edc302@arm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 7 Apr 2019 15:25:42 -0700
Message-ID: <CAPcyv4jMKc++ySHN4hDKtC3jFsXxntAx=0e0vWoW-LQsodAk3Q@mail.gmail.com>
Subject: Re: struct dev_pagemap corruption
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Robin Murphy <robin.murphy@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 5, 2019 at 7:54 AM Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
[..]
> > Given that what seems to ultimately get corrupted is the memory pointed to by pgmap here, how is *that* being allocated?
>
> struct dev_pagemap *pgmap;
>
> pgmap = devm_kzalloc(dev, sizeof(struct dev_pagemap), GFP_KERNEL);
>
> Is it problematic to use dev_kzalloc here instead of generic kmalloc/kzalloc
> functions ?

On this specific question, no. devm_kzalloc() is how the pmem and
device-dax drivers allocate the pgmap passed to devm_memremap_pages().
The unwind order of the devres resources ensures that the
devm_memremap_pages() devres actions occur before the release of the
pgmap allocation.

