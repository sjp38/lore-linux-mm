Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1214C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 19:11:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B03821985
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 19:11:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="D7LBjEJY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B03821985
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C054E6B0007; Mon, 22 Jul 2019 15:11:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB75C8E0003; Mon, 22 Jul 2019 15:11:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA57E8E0001; Mon, 22 Jul 2019 15:11:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0F56B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 15:11:02 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id h67so31417238ybg.22
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 12:11:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=83PVez7k7U0Zqxj86oJddwWoO6j61lIp1H42K6LCjdM=;
        b=hjAeIY/B3YN1s2AuTSC5/1VKh7F/ZKQqwYijbTcfmR2jMQWk97MqT44/J0yhGP16rP
         rF9e4hueBOQ06ZWgD13M+tsJtHGWatVwPQH2YdXgVZpZgx4Vz2xnKCuv7rJqV8bWItSq
         CuFA2DD96vMQ/VX4YVsUtjZUVNtnneqDDHVD8iGHx6B2mMm9/wUq20Xetm1ucYVQ/WVi
         3dTWW99W5LJNCi2HqFPYadT3WKjO/zDj27rZFj/g8l+RaRxrO8HpA1AGZEvk3B4UAqGZ
         fsv8agGp7dWNdSKYoU6VdOcDEb6SbkkgIbYy6mTE/GCuNR0pyXGrty4B0e+ikyl7NagO
         bQyQ==
X-Gm-Message-State: APjAAAUDKs/Ri775kVKRLWTgkfJxDSVnmXegnwIs8hLweMnXJpLoWMmZ
	22hgnsWWcA4b16yvfht5W5YmLUMT3FU6/vRVSDRNPedRUEPvUAUH+3qKsxmuA8fl0V9NS83atJw
	f4gO3pZbUZw0KcYP1PsPCtWOtNOaQgU0euArpgYJ2KWsfhRf97dGoUNleMNsI56KZlA==
X-Received: by 2002:a81:9c0b:: with SMTP id m11mr41844188ywa.3.1563822662270;
        Mon, 22 Jul 2019 12:11:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMZfwTnSXTfaAsPbe6m0lTeE6FZrSCHdh1ocQPRejH4tSLx/L5uLH12/rGh2F3QMvRwdEz
X-Received: by 2002:a81:9c0b:: with SMTP id m11mr41844158ywa.3.1563822661733;
        Mon, 22 Jul 2019 12:11:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563822661; cv=none;
        d=google.com; s=arc-20160816;
        b=mGCt7ERyG21fO5+8TFPvHYc8Eoy1SgluI+SFwNIzSkI/Rw85Qzt7n8qXEma8weAkzU
         4EUh/aiXpZyILyYBBbPnQGMoak8WZr2STodcmsviQRhZq/RH66Vd616KdCk5H6hbuUDn
         mjNydtQLtzZsvaqSLcdDwNvyN8epKVaR0ogLCOtttIEno6s008tAW/fuC+J8k1SbJnr+
         vXukZJQZv2mgCOBFHVwspEL+PEsirjszLeWfGlzdQND1MYJmNWGGyNEbsVuAbRKZWsjm
         pUqbEmpFpAQoavS2b2adok/v1Xbl0AZ5sn4WqG+auCqCxUfXqwzK0LeUuFD/MwwlDSeX
         +D1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=83PVez7k7U0Zqxj86oJddwWoO6j61lIp1H42K6LCjdM=;
        b=DNwtdomZi1tMaAGCRfCwbBTmF1T1lhl01rpNVpoXhLDfZd3hh+pWG5XBsPnMkS7q8g
         0DIAUmUbtRqqbJyAzLMNs6EQFeHfUfRmrmrKrKn8f6u2nhOVI3mSP26yJ2zNeA3s5nmw
         O1kRui2XYqmYAE+cFGCv2CfUcRak5GqZa5CMWAsaJmrJflRfjKS7tDvdYlEC5hA/rJ++
         YHpxDglsMafJwVwjW00E3p+Ek/EUgL64xLifbA3LYSpVyKWviQl1HmuIv20YJq1YT6ks
         Lv9qwKNiyS2g+9kCUzZgJdrGXmClcdyXjS7qJ8bKEK2j9aDb8AHRq13DBwZIpCJbfrK1
         Jcyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=D7LBjEJY;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id i15si16016516ywc.391.2019.07.22.12.11.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 12:11:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=D7LBjEJY;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d360a4c0000>; Mon, 22 Jul 2019 12:11:08 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 22 Jul 2019 12:11:00 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 22 Jul 2019 12:11:00 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 22 Jul
 2019 19:11:00 +0000
Subject: Re: [PATCH 1/3] drivers/gpu/drm/via: convert put_page() to
 put_user_page*()
To: Matthew Wilcox <willy@infradead.org>
CC: Christoph Hellwig <hch@lst.de>, <john.hubbard@gmail.com>, Andrew Morton
	<akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>,
	=?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>, Boaz Harrosh
	<boaz@plexistor.com>, Daniel Vetter <daniel@ffwll.ch>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, David Airlie
	<airlied@linux.ie>, "David S . Miller" <davem@davemloft.net>, Ilya Dryomov
	<idryomov@gmail.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jens Axboe <axboe@kernel.dk>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Johannes Thumshirn
	<jthumshirn@suse.de>, Magnus Karlsson <magnus.karlsson@intel.com>, Miklos
 Szeredi <miklos@szeredi.hu>, Ming Lei <ming.lei@redhat.com>, Sage Weil
	<sage@redhat.com>, Santosh Shilimkar <santosh.shilimkar@oracle.com>, Yan
 Zheng <zyan@redhat.com>, <netdev@vger.kernel.org>,
	<dri-devel@lists.freedesktop.org>, <linux-mm@kvack.org>,
	<linux-rdma@vger.kernel.org>, <bpf@vger.kernel.org>, LKML
	<linux-kernel@vger.kernel.org>
References: <20190722043012.22945-1-jhubbard@nvidia.com>
 <20190722043012.22945-2-jhubbard@nvidia.com> <20190722093355.GB29538@lst.de>
 <397ff3e4-e857-037a-1aee-ff6242e024b2@nvidia.com>
 <20190722190722.GF363@bombadil.infradead.org>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <14ac5f41-c27e-c5a7-e16a-4bd3cec0d31f@nvidia.com>
Date: Mon, 22 Jul 2019 12:10:59 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190722190722.GF363@bombadil.infradead.org>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563822668; bh=83PVez7k7U0Zqxj86oJddwWoO6j61lIp1H42K6LCjdM=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=D7LBjEJY+k3NOupyUsz3QkjUUcPJWsBWTBbYyETUfk0uHH7d3QLbvQ+9RZH/28ZUE
	 sJfBT4O7QJ8wM9JX4nHRXKapNOpAYRi9LOgtrRHvxKHk2NLSGEB1ERlJVKKI3k/JJy
	 7S/lE/NB7MHjzQXMBBvvHctHDvo+mZLnO7Aio3aCrObQZB+awPaHKMVSROauRYPr3X
	 BJA/hGGdnsjgC4xdOAmvtDqjNiZJqnIwrrWggp9zNKGaVihgNE1edJSfqnrDSygNyO
	 Yzm74sohYm7Fi77+N0T5ApyjJHRiN3SgO4JJxNpSypLaSrrE54eHRmL/LyJAWG2MRa
	 b+Oe1FCWdve2g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/22/19 12:07 PM, Matthew Wilcox wrote:
> On Mon, Jul 22, 2019 at 11:53:54AM -0700, John Hubbard wrote:
>> On 7/22/19 2:33 AM, Christoph Hellwig wrote:
>>> On Sun, Jul 21, 2019 at 09:30:10PM -0700, john.hubbard@gmail.com wrote:
>>>>  		for (i = 0; i < vsg->num_pages; ++i) {
>>>>  			if (NULL != (page = vsg->pages[i])) {
>>>>  				if (!PageReserved(page) && (DMA_FROM_DEVICE == vsg->direction))
>>>> -					SetPageDirty(page);
>>>> -				put_page(page);
>>>> +					put_user_pages_dirty(&page, 1);
>>>> +				else
>>>> +					put_user_page(page);
>>>>  			}
>>>
>>> Can't just pass a dirty argument to put_user_pages?  Also do we really
>>
>> Yes, and in fact that would help a lot more than the single page case,
>> which is really just cosmetic after all.
>>
>>> need a separate put_user_page for the single page case?
>>> put_user_pages_dirty?
>>
>> Not really. I'm still zeroing in on the ideal API for all these call sites,
>> and I agree that the approach below is cleaner.
> 
> so enum { CLEAN = 0, DIRTY = 1, LOCK = 2, DIRTY_LOCK = 3 };
> ?
> 

Sure. In fact, I just applied something similar to bio_release_pages()
locally, in order to reconcile Christoph's and Jerome's approaches 
(they each needed to add a bool arg), so I'm all about the enums in the
arg lists. :)

I'm going to post that one shortly, let's see how it goes over. heh.

thanks,
-- 
John Hubbard
NVIDIA

