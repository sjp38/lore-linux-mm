Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05D2DC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:33:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C34EA222A7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:33:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C34EA222A7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=iogearbox.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53FFF8E00F1; Mon, 11 Feb 2019 10:33:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F0018E00EB; Mon, 11 Feb 2019 10:33:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DF158E00F1; Mon, 11 Feb 2019 10:33:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id D77A28E00EB
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:33:33 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id l17so6430135wme.1
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:33:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=6AsydycaEfknojHFFUgxjTMXgbgmE80KrPuR78p7KI0=;
        b=Y3XftCI9uTt1pfIBOgZymTHfFjj+jj2rtxrKFj2QKiKJCKhbysxLW4Deh2rhdK0S1m
         pbCW7t/g+mI0tuH4ouoHAGcxKbYpQst9trergvMBKJ4f+YUMYuo096fDhhFasDiy8Npc
         XqpZi5O0vnGTIXfVLbwGyPsvMOjm+ivZWPhFs0LXYtsWKOBvr6NxfZEEh3qY4fwQZ1Ul
         OiEXcMlMLN+XEOc5M327v/RxGUYtdn3QnltkfdaslNftT9R8he9aSZuJt7kwGWCZyJ0z
         GL4kHsrHQaZPlrW0PKzdfNmOCvyVtz9fPC8oPz50pXcFtJtobipw/RFa8fAeAB8CeEv/
         wpmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of daniel@iogearbox.net designates 213.133.104.62 as permitted sender) smtp.mailfrom=daniel@iogearbox.net
X-Gm-Message-State: AHQUAuZNm9+gF18H4tvOnhj0JAh4tYms0b7RKw5/JqhQnz4Mh5enEwFz
	nrh+GM0b0x8KxDFP3wuRaBmWu2d+WeyZuDu8/2eWPHR4n02Y0wTN5UbkAIYDAdAVWc4MoZLofa+
	7JHUPh4x+6aF1/dqO47+Dyj2N0B8mzNBPLh8q0lzy+k5DqJywiOvq6OePlCOC5LeA4A==
X-Received: by 2002:a5d:6b09:: with SMTP id v9mr29139407wrw.304.1549899213436;
        Mon, 11 Feb 2019 07:33:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYpeLIaFVKNuJEOQufz3oLCbqOjA+vXD1cxMOHtUIkW6q1M0v1ylq2fzuUphfiM6y0Auz89
X-Received: by 2002:a5d:6b09:: with SMTP id v9mr29139339wrw.304.1549899212398;
        Mon, 11 Feb 2019 07:33:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549899212; cv=none;
        d=google.com; s=arc-20160816;
        b=jUzsidEpG/tAvJwoP49K2/Y9+q7qCQtD4Q2q3z8+RGxGwbRFpC1PTLhWK9U5Gs8o4/
         daQp7w/I5a+4mlNURd/nMllZZaFnyyXk7vn2lE5f2anTTUxuGZnWr1gqoCFZq92kPTJD
         ForwLGlwN7Q9C6dU6FbmP0Gth1lgK6oT77jvD+SsqKwD9G/3oba65NtsccTmlO6RWoMa
         HyMXsIVy3QbDAfh3u4WIlTlcfu+Tmjz2AennYBaky9tppGNFp+MJaYJK428hOJp0+x8m
         /MJQAIcoOlKN9k5LpNfV4P8HnQdFYu0sg9CZJwmQtPG6mDmP9ybnDdhBfGTQWXi5BP5B
         njZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=6AsydycaEfknojHFFUgxjTMXgbgmE80KrPuR78p7KI0=;
        b=0hXMvie1sDdVon06/1hDu7xxC6YXOjKX45771ayVai1dxhTadfti4tNC0b8C1hV08p
         jM8XzVnChq3q0OHDogoCB6hrcu6xQI1xd5jMYZw80ng0nLRvD16jsvpnVm3BAvdFHLzi
         q0QHX7qU2J9lAzvY1XkPjkyts8P3KXMY6rzMGtbPYcOJWl9DffobU1PCiu5Ls/21nKKG
         T/S3owq4tCpz9Yt8+X0085jX2oomtJErFZP9Dytt3wyHAHyzB13u1GZSC8Sqsn/8ovhy
         89BYrDBJ/vCmhiyXL6qzr+ZNxsDCE6If/FdtUeScwGE8kDlJ8jiWeskRrW8LwfCSXVc8
         9XvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of daniel@iogearbox.net designates 213.133.104.62 as permitted sender) smtp.mailfrom=daniel@iogearbox.net
Received: from www62.your-server.de (www62.your-server.de. [213.133.104.62])
        by mx.google.com with ESMTPS id x126si25476519wmx.2.2019.02.11.07.33.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 07:33:32 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel@iogearbox.net designates 213.133.104.62 as permitted sender) client-ip=213.133.104.62;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of daniel@iogearbox.net designates 213.133.104.62 as permitted sender) smtp.mailfrom=daniel@iogearbox.net
Received: from [78.46.172.3] (helo=sslproxy06.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.89_1)
	(envelope-from <daniel@iogearbox.net>)
	id 1gtDaM-0007KE-6j; Mon, 11 Feb 2019 16:33:30 +0100
Received: from [2a02:1203:ecb1:b710:c81f:d2d6:50a9:c2d] (helo=linux.home)
	by sslproxy06.your-server.de with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.89)
	(envelope-from <daniel@iogearbox.net>)
	id 1gtDaL-000Ow1-WC; Mon, 11 Feb 2019 16:33:30 +0100
Subject: Re: [PATCH 1/2] xsk: do not use mmap_sem
To: =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@gmail.com>,
 Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
 LKML <linux-kernel@vger.kernel.org>, "David S . Miller"
 <davem@davemloft.net>, Bjorn Topel <bjorn.topel@intel.com>,
 Magnus Karlsson <magnus.karlsson@intel.com>, Netdev
 <netdev@vger.kernel.org>, Davidlohr Bueso <dbueso@suse.de>,
 dan.j.williams@intel.com
References: <20190207053740.26915-1-dave@stgolabs.net>
 <20190207053740.26915-2-dave@stgolabs.net>
 <CAJ+HfNg=Wikc_uY9W1QiVCONq3c1GyS44-xbrq-J4gqfth2kwQ@mail.gmail.com>
From: Daniel Borkmann <daniel@iogearbox.net>
Message-ID: <d92b7b49-81e6-1ac5-4ae4-4909f87bbea8@iogearbox.net>
Date: Mon, 11 Feb 2019 16:33:29 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.3.0
MIME-Version: 1.0
In-Reply-To: <CAJ+HfNg=Wikc_uY9W1QiVCONq3c1GyS44-xbrq-J4gqfth2kwQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Authenticated-Sender: daniel@iogearbox.net
X-Virus-Scanned: Clear (ClamAV 0.100.2/25357/Mon Feb 11 11:38:50 2019)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ +Dan ]

On 02/07/2019 08:43 AM, Björn Töpel wrote:
> Den tors 7 feb. 2019 kl 06:38 skrev Davidlohr Bueso <dave@stgolabs.net>:
>>
>> Holding mmap_sem exclusively for a gup() is an overkill.
>> Lets replace the call for gup_fast() and let the mm take
>> it if necessary.
>>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Bjorn Topel <bjorn.topel@intel.com>
>> Cc: Magnus Karlsson <magnus.karlsson@intel.com>
>> CC: netdev@vger.kernel.org
>> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
>> ---
>>  net/xdp/xdp_umem.c | 6 ++----
>>  1 file changed, 2 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
>> index 5ab236c5c9a5..25e1e76654a8 100644
>> --- a/net/xdp/xdp_umem.c
>> +++ b/net/xdp/xdp_umem.c
>> @@ -265,10 +265,8 @@ static int xdp_umem_pin_pages(struct xdp_umem *umem)
>>         if (!umem->pgs)
>>                 return -ENOMEM;
>>
>> -       down_write(&current->mm->mmap_sem);
>> -       npgs = get_user_pages(umem->address, umem->npgs,
>> -                             gup_flags, &umem->pgs[0], NULL);
>> -       up_write(&current->mm->mmap_sem);
>> +       npgs = get_user_pages_fast(umem->address, umem->npgs,
>> +                                  gup_flags, &umem->pgs[0]);
>>
> 
> Thanks for the patch!
> 
> The lifetime of the pinning is similar to RDMA umem mapping, so isn't
> gup_longterm preferred?

Seems reasonable from reading what gup_longterm seems to do. Davidlohr
or Dan, any thoughts on the above?

Thanks,
Daniel

