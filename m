Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA104C28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 15:55:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E903206C3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 15:55:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HDBAVMTy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E903206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E07B46B000E; Wed,  5 Jun 2019 11:55:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB9266B0010; Wed,  5 Jun 2019 11:55:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA6DD6B0266; Wed,  5 Jun 2019 11:55:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB896B000E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 11:55:15 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f9so19025711pfn.6
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 08:55:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2DfKoTbUkHhuP2+XX+gOP/GXMo98uk4f8Hq+Sd8x/uU=;
        b=kL9ZQJZkM7/XF5QnU1oNvqqwvYSo/e5ACvBJnjkm64ASaY2Ks7BsEupZUc6lg+D235
         N6Xnco2f/3J2WJY0mGJSUZFupQXErF1OVLNIOHfiwNreic/689+cz6Tf6/UucHJXc5P9
         IdF/P6mgzvUbGbHRHijQ+KoHVZlwEPFmO8gW9IFyi2IIFii0FxC4D9ceQpsEux6GGTO/
         f4sD8b+Sg0FCyLbntIm1aeEiyqhBe/TE6VMGZ2oIolAkF7Vge5uHTgUBTWdiOrKos7NI
         4x+puLwcFAqqPQ3E9iAYe3Ewyu1VIVLAqFG5NlBD1dGMnebkEp8VFdjMOTr6mQeacnJz
         jwbA==
X-Gm-Message-State: APjAAAWrp799xFAPPFKIDGEMT81yWhws9oehdWbrV/FnlEYx8hdcOkMy
	bsFkWqHfBZXhpDXPpbB8rcwswQDJFMLSqPktx/msUrSjZ5Nld3kl4FnxGV+A5k8KCOiNE6winDl
	5kNXg/ewM8TUvYFm/pIIiAZ63VpRHAHgWNr73ZLAYPSSVA2ND1csQ/2J07OkYtW1oVQ==
X-Received: by 2002:a65:5004:: with SMTP id f4mr5555972pgo.268.1559750115101;
        Wed, 05 Jun 2019 08:55:15 -0700 (PDT)
X-Received: by 2002:a65:5004:: with SMTP id f4mr5555848pgo.268.1559750113945;
        Wed, 05 Jun 2019 08:55:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559750113; cv=none;
        d=google.com; s=arc-20160816;
        b=066+J1bHPfeOwZE8XfcWLl12Keip7eywufPev9ElxIkNB8JiVQsM9alyVgwUYWp2yQ
         3m7AVLZ62huUFVgTGyCcLZaYhTi8tndbrWAP9UcFZ+laOz9nMhT+ZUbM8pBmqxNzQSX/
         834lKBsyP5Th8e6+8nzQQ8TvMSVjOTOmJsnrq3p+7Gfsz0ixgTI185qYkkfwr40Itrr/
         KGPbLFv+AR+ayMdFjOM+2qcfln2fvDvYLDj6UL+7S/1C7uT3TM5SfEwpWf6WZtKC004H
         l8osIhZYbHL1aFfO4BUYos/JG5B91fIFTY7wIZHHnbEmdDLEmqcCJJCFmEE+F8mKobHr
         mVmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2DfKoTbUkHhuP2+XX+gOP/GXMo98uk4f8Hq+Sd8x/uU=;
        b=DiC+2ecqEuUdmbsp8MbcASCXYdnZqj0AuMf95pwnfwnUyRY37OeGRksy3cZPjyHF3r
         75lr58yVi85aeY2GlXsc0CjkRb34DvyZA4Pensi7qKMSHCfPvgB9MyDkPfF0Qehri+Bz
         k+fIaCWF6EBiT/XqjyOIz95IWj80L3EKAzKJ829T3FIa7Blx7LxEXEY99Gr1JslI4ByZ
         3ibBf2kl96PDzbyxQE2Cl9gN+wOm9Vc3HlFanLJTJZVTfEN9kz/uf0qwoJo1vCkGRfne
         4ACLxBMbukyPvNz2LM9sFE4W6hr5RvBUUKh/d897wj0FTfeF81iDdqaUifpOfdMTRCou
         /F/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HDBAVMTy;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x9sor25321303pjt.18.2019.06.05.08.55.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 08:55:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HDBAVMTy;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2DfKoTbUkHhuP2+XX+gOP/GXMo98uk4f8Hq+Sd8x/uU=;
        b=HDBAVMTypXAZfR0duFmc4K1/93WlRwCVC+qISQ4GY2eJDWVecH5SDn/57rnesLcZRd
         Kqg4hHsMQ3VWgqL7eKCXp1f6Akskuui4UhGUmL9tRGFdrc25dsbksl+JTm2B9lOesyAZ
         mc0UmHCtbrTRjiGsHNbLd7G04dYKCZ0VfBxdUcUjAeDB4WxhGWhvdxdF2shqaZSXZ/B6
         T3+GcnMHZvdxzpXxVR330vE5tpbSk4bNXFlPssK/g+tlmA1+itYttxcOQVxVPk4NOEXh
         PQF8Auo4KoPHyHQFTNRt840Hu6I6IhGjHYNzi53ce+MZPmvKE94Vt0mIYhDwBQUdbw3V
         0UWg==
X-Google-Smtp-Source: APXvYqxpR5cEgDtmltAvYZ9AqYKidTDaDzzZM1TzdDM3zyq2rPE0LI3y59r5zJCpopq1OyFELGS5xw==
X-Received: by 2002:a17:90a:338e:: with SMTP id n14mr43932679pjb.35.1559750113484;
        Wed, 05 Jun 2019 08:55:13 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([2401:4900:2714:c5a9:f4d2:57f9:5d08:5667])
        by smtp.gmail.com with ESMTPSA id 26sm4625351pfi.147.2019.06.05.08.55.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 08:55:12 -0700 (PDT)
Date: Wed, 5 Jun 2019 21:25:01 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com,
	khalid.aziz@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Remove VM_BUG_ON in __alloc_pages_node
Message-ID: <20190605155501.GA5786@bharath12345-Inspiron-5559>
References: <20190605060229.GA9468@bharath12345-Inspiron-5559>
 <20190605070312.GB15685@dhcp22.suse.cz>
 <20190605130727.GA25529@bharath12345-Inspiron-5559>
 <20190605142246.GH15685@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605142246.GH15685@dhcp22.suse.cz>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

IMO the reason why a lot of failures must not have occured in the past
might be because the programs which use it use stuff like cpu_to_node or
have checks for nid.
If one day we do get a program which passes an invalid node id without
VM_BUG_ON enabled, it might get weird.

