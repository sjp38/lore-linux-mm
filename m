Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EA9BC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:20:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9A5921743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:20:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9A5921743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15F196B0005; Fri,  9 Aug 2019 08:20:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E7676B0006; Fri,  9 Aug 2019 08:20:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC9D36B0007; Fri,  9 Aug 2019 08:20:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3AB66B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 08:20:53 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 30so59615770pgk.16
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 05:20:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=5g471xOV0VPvS8UKp/9O4XrULZm0cpxx88LE+95X5qE=;
        b=CYhrebNxgigQ5eDTUDe1YZhgVwbLs4vPujjBCJUANnI23uJtr425wxnU5iH1WpzElX
         pyAgLOv22hQoMqQwqHzrihxC0M1m0zyTgImwKeEt+os94IxHPvHFgZCga8vrMftkpeIA
         uVndUNJcGTZKMkcPKbHd29OmeYDX6avxbCY0EbrFud2tGplxPbn043k+TzJ1WVfRuVMk
         J+2QeKjj34McrtZT3YZ8GA7t7BF0MEm/I8kBRqb7fjbgPibnZrfzn1B6FB50vXrMV2+0
         tcqxSTWCo+jPHsgnV0O1Rix9n/hXgsscEl1YJzWxNsJgx/dYqCKH6r7yZscQFVC3WZR1
         xWHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mpe@ellerman.id.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: APjAAAUJcNiMDeODE01PghWw8/oU4RU7uuqFb+p0gK3uXtMVyFgnKcgO
	MxbpAbhydcQoaTmua4Lb7DIAgyschwcw6p5guk0/WdXYRez0gMm18EWRQgYJ/94S536y3gmSFmP
	HyE6NUDpn0vN5FSTem4O6o/bDXQeI5gDOU11zJjsMbWwxgCYxucoI//4eX1bCTRAWXA==
X-Received: by 2002:a17:90a:898e:: with SMTP id v14mr9159028pjn.119.1565353253366;
        Fri, 09 Aug 2019 05:20:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdqZCmvhlG2cZcCdVbt0GnnvYHUsBUPwC2hFkETRdsrCUDwq+KzOiusi9N1kcRv13pecTT
X-Received: by 2002:a17:90a:898e:: with SMTP id v14mr9158978pjn.119.1565353252500;
        Fri, 09 Aug 2019 05:20:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565353252; cv=none;
        d=google.com; s=arc-20160816;
        b=cAiE/SwkiBzSGW1CUk3bOsgCvW8ILAF1N7FfCWrQKoNbuoru2V2nGfz3/Xst4clKmL
         QQoardVM10zH/WGRlvxg12UWZfUKjvMAbrqOf5zuLQyUlDpM4YuKjXJZphebl34JJNNg
         33HAH6rCq3xYF5NkKQfmLhJmJdFSRqADYbH/fwnrClSi9kcJiDaB2828cuIiA+6R7Ulc
         4a5k6cLi48QVw5JIOGbpyOf3zJzS9kRx7O2jMgLkcLzWi5Bst2jm5lY9H7dV0b/XAaGl
         nkcHoqXm9y/FLD0KQX1zpugexQXYpPLkdtYgEk8WXUMSIethHb7AqnVp3izaEvbrvvX4
         G1Ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=5g471xOV0VPvS8UKp/9O4XrULZm0cpxx88LE+95X5qE=;
        b=xduf/sVoQZJt+aFb1zP6EQfRJ9x6ypGm/i88dmlWgCcfdGX/806kzWx/fbuHkOphsa
         eiqgWUV5MNg19/Xg24LnTZv49h05uxDBk4M/wqJfjwvOWXnq1PVZIKXNq2l9qeSJEPGj
         LkTUvejHjIixBXKgRLojiOWcdWt9jsZ56vKRGs0rjKPrN/Is8T691xZgl8TLJrh9ZXBr
         tzVCtXRdNd6iS+tnKi0E6Ks9bb7OU1K1YQ38RKhGYLdqjpg3NeOB5bSRtwSdm4L97gVV
         Wyw75KTs7Hy/oNCUouymoUkov1qrqDnK+yiwyugNKfg70OpHe3/vB/yPX2Ku0riBnvlm
         fGIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mpe@ellerman.id.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (bilbo.ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id k16si53224143pfi.174.2019.08.09.05.20.51
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 09 Aug 2019 05:20:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of mpe@ellerman.id.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mpe@ellerman.id.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 464kpy5K69z9sBF;
	Fri,  9 Aug 2019 22:20:42 +1000 (AEST)
From: Michael Ellerman <mpe@ellerman.id.au>
To: John Hubbard <jhubbard@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Dan Williams
 <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave
 Hansen <dave.hansen@linux.intel.com>, Ira Weiny <ira.weiny@intel.com>, Jan
 Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, =?utf-8?B?SsOpcsO0?=
 =?utf-8?B?bWU=?= Glisse
 <jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
 amd-gfx@lists.freedesktop.org, ceph-devel@vger.kernel.org,
 devel@driverdev.osuosl.org, devel@lists.orangefs.org,
 dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org,
 kvm@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-block@vger.kernel.org, linux-crypto@vger.kernel.org,
 linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-media@vger.kernel.org, linux-mm@kvack.org,
 linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
 linux-rpi-kernel@lists.infradead.org, linux-xfs@vger.kernel.org,
 netdev@vger.kernel.org, rds-devel@oss.oracle.com,
 sparclinux@vger.kernel.org, x86@kernel.org,
 xen-devel@lists.xenproject.org, Benjamin Herrenschmidt
 <benh@kernel.crashing.org>, Christoph Hellwig <hch@lst.de>,
 linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v3 38/41] powerpc: convert put_page() to put_user_page*()
In-Reply-To: <248c9ab2-93cc-6d8b-606d-d85b83e791e5@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com> <20190807013340.9706-39-jhubbard@nvidia.com> <87k1botdpx.fsf@concordia.ellerman.id.au> <248c9ab2-93cc-6d8b-606d-d85b83e791e5@nvidia.com>
Date: Fri, 09 Aug 2019 22:20:40 +1000
Message-ID: <875zn6ttrb.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

John Hubbard <jhubbard@nvidia.com> writes:
> On 8/7/19 10:42 PM, Michael Ellerman wrote:
>> Hi John,
>> 
>> john.hubbard@gmail.com writes:
>>> diff --git a/arch/powerpc/mm/book3s64/iommu_api.c b/arch/powerpc/mm/book3s64/iommu_api.c
>>> index b056cae3388b..e126193ba295 100644
>>> --- a/arch/powerpc/mm/book3s64/iommu_api.c
>>> +++ b/arch/powerpc/mm/book3s64/iommu_api.c
>>> @@ -203,6 +202,7 @@ static void mm_iommu_unpin(struct mm_iommu_table_group_mem_t *mem)
>>>  {
>>>  	long i;
>>>  	struct page *page = NULL;
>>> +	bool dirty = false;
>> 
>> I don't think you need that initialisation do you?
>> 
>
> Nope, it can go. Fixed locally, thanks.

Thanks.

> Did you get a chance to look at enough of the other bits to feel comfortable 
> with the patch, overall?

Mostly :) It's not really my area, but all the conversions looked
correct to me as best as I could tell.

So I'm fine for it to go in as part of the series:

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers

