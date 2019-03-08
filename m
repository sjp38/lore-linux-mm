Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 744D0C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:32:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C3702081B
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:32:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C3702081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9AC88E0005; Thu,  7 Mar 2019 21:32:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D48FC8E0002; Thu,  7 Mar 2019 21:32:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C39818E0005; Thu,  7 Mar 2019 21:32:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9357D8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 21:32:11 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id g42so1295760qtb.20
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 18:32:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=iF16cgfp12yoaJJ5MQem592rInh+vH6ZaUK3pS+44v4=;
        b=DXL7zuL3O7f4Dj6ftA3Iqu7ZcrJovHQS+VcWYvDg8j3iU5zsHFlPkTPwbBz+mTQMf2
         LlbU5DDvlvrzC4hkLU9aGkWEfVPWTuYzrL1G/hFxIntk4h/xYY95LbvID4/kcfq59Ba3
         iDbjOrjSy5QfQAh/OSx3sY9lJK0532weK7vKJkkZSqi7xBM+10BOUmWylgxAtdRcKHhQ
         mhXkSKZoK4KurllWhvmauTHtRLvNT0iKKLoYipwcYL64l6Cb1wIv//Q3bJJk0EclRa5N
         Jx3VNh+ERMnxAXWdLYm2Deo2XO0ih/dTvgy2aA8KwrHoDIrb7nOBRlqJwPN1PKwy8mgT
         AUeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVBCvUGyKS/Axu7FqpKCjN9CZbtH+KEXpbs50VQ3Br+cPa6Afk0
	EQ8V0KwTy2QA6WLRmUZTaBuUNeyTRkhQq+5wAlq6aEZdU5n3t0OlpFw0Xsf37bYjpfKvkzUTnzz
	z/HuaTFROxFsr/fQfOt1UoTQKUGz1uMDPqte9oRpBYRqVLwoIskkOh4wSoJbV1hWnGBBUv7/FJv
	hlbTkw4J0gTs3jPm4Poig+z1eRg6xWyZQk+b1auoU0EXshewNFBNNh+qsFpzPCXLPJw8piE/BxY
	BbYrgj7HBLwvl54VjwuW6o42mSJiSN0ikKr9CnBlwfNDBGzOeyw8G7F3wV5j6V9md6qREk6AgiI
	dD5rNeRkeCG2sCKcdYGLcqKatdyVd60Lp3IrKAzXukOkRRIc07V1Q/1eJTFiDGZP3+FrasHXTf/
	D
X-Received: by 2002:a37:c313:: with SMTP id a19mr11955759qkj.220.1552012331359;
        Thu, 07 Mar 2019 18:32:11 -0800 (PST)
X-Received: by 2002:a37:c313:: with SMTP id a19mr11955727qkj.220.1552012330610;
        Thu, 07 Mar 2019 18:32:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552012330; cv=none;
        d=google.com; s=arc-20160816;
        b=K5YlBG/Ke5tCv6waqP4xpyLwS6hdHe0wzxOppdqY4KbslLQgamkuJAad3DifKTE3M6
         AcZ1mGtSRp6gqCIoi4VSCFE1byAf8Gcv8WZ3sKufA3mO8SlV/67pLeFvg5VQr948mx/M
         GA+6vozhPX5QgMUH1BKwQeaEfhOK6f8xK0HL3pQPXTOfy2P5qwRfUf0Dv7lWT+9cJ+3N
         S9aQ+TFpB4lYIRmlogOMG1zWlVyJV4aaDhmrmpvB45W5pHnRAOVK1j60f+K11u62kcmu
         tSgsg/lQKf8nuG747ITXoWMTKAsHq0GZbReWc4Ow5qveXo2/r6qrdf7c8Rv94u4MkOdr
         X05A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=iF16cgfp12yoaJJ5MQem592rInh+vH6ZaUK3pS+44v4=;
        b=r0XA5z2MzWJF3nlXCczcFbokm48H5TPXmsLRubrFmzVKAuaMT8jOso6jPeQxeen8cw
         C5XVeDzMr+fQg2UmJcFopTQhsCth1CFYOBxkh4ft2a4tggzbJ/NBPP2SgwiqLroibQVx
         N2VSk4lJUqjd4rtVMK+3mFq1DsDT4/kTxElMOlxeO9yzw1fn4MrCm9Hlxv1ej5o9s2ed
         ua3Vb/ti4oRZ6LtLNHkXQ+c67QSs39qad1BkTVI/m8t/bp7Bo21xcwzqWv2+GE9TbNBh
         2CHVOMl2WBm1mdn1LTtOIhzcEO1t/MsvvE6b/cBhAJsH+/yx4TgqWnOW0SLzqhBs6Lot
         xh9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n8sor7208710qvg.8.2019.03.07.18.32.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 18:32:10 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwFsRg/Gqf8+NEhgHdzJyicZWPFO0RBwKAp8m1NoEf1T1SAM90gXXpZVFq9IrBbWHCt/WLQtA==
X-Received: by 2002:a0c:b485:: with SMTP id c5mr13538580qve.78.1552012330342;
        Thu, 07 Mar 2019 18:32:10 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id p10sm2973617qkg.76.2019.03.07.18.32.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 18:32:09 -0800 (PST)
Date: Thu, 7 Mar 2019 21:32:07 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: David Hildenbrand <david@redhat.com>,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
	lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Rik van Riel <riel@surriel.com>, dodgen@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest
 free pages
Message-ID: <20190307212845-mutt-send-email-mst@kernel.org>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com>
 <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
 <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com>
 <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 02:35:53PM -0800, Alexander Duyck wrote:
> The only other thing I still want to try and see if I can do is to add
> a jiffies value to the page private data in the case of the buddy
> pages.

Actually there's one extra thing I think we should do, and that is make
sure we do not leave less than X% off the free memory at a time.
This way chances of triggering an OOM are lower.

> With that we could track the age of the page so it becomes
> easier to only target pages that are truly going cold rather than
> trying to grab pages that were added to the freelist recently.

I like that but I have a vague memory of discussing this with Rik van
Riel and him saying it's actually better to take away recently used
ones. Can't see why would that be but maybe I remember wrong. Rik - am I
just confused?


-- 
MST

