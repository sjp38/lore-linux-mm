Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E439C10F00
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 02:40:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C96CB206DD
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 02:40:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C96CB206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B2588E0004; Wed,  6 Mar 2019 21:40:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43A568E0002; Wed,  6 Mar 2019 21:40:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 328A48E0004; Wed,  6 Mar 2019 21:40:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 066D28E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 21:40:34 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 203so11836192qke.7
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 18:40:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=giZ3G8scpJp2Bk2ZLvCXcQDfm9BcEE61Ez2UBOzYhIA=;
        b=Ci1eeMW73YkmuJdLBchN/q4Ouw0QmBvtWbPFlYBLQEu8fOiAbCsSaAqzCmiJi9bw9X
         kkD5m+RdkWjlARHDmNYUh7vudY+kiPir+Cgyx3YyXHegV3/DOF5VM0yC3vvjSL+rJPeJ
         N6Ymd8bO3ISrtpoBn6Al2nz91mtUJ2s4CppWzOgqKc+tkzzuQP1DlAZGd8viaWtK8P59
         T3mf2G6emIuIq11n3VlEOQaWKO1rqCwysgaiz5AYprs/DM+rLd/vB88o6qnM8rrNLB7J
         39lLB5NLQoVw8UJZjFSPLx4Ca9d8Ktu5pnx26Y/iMfQRLgXnktDaRYUrpFP5aIrNghoV
         MFlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXRsfCqaVYmN0/b6ZsyS9wOWpTWxU617MoRrjx9oPVe6jUSS7J4
	4XTmfKoCnHDm+P9UdfnjDbF4yH69WkJenoyoEP+pI/6KQWRRbCL2XpBSFWJfNspUpi5tSAxVRhA
	a/X7ZxODDJJJBIxANNkT4nTbCO0x/ZBI4m0973d2811ZcN+YZrVsmkpNxfg52BXPV2A==
X-Received: by 2002:a0c:d911:: with SMTP id p17mr9091289qvj.183.1551926433776;
        Wed, 06 Mar 2019 18:40:33 -0800 (PST)
X-Google-Smtp-Source: APXvYqxJ2ey9O5gBZI7LNjroZvwwTmgX0sGrjX/4N6XlXSopKPS6EDc5zl54iIVyXn1pT5oombwf
X-Received: by 2002:a0c:d911:: with SMTP id p17mr9091259qvj.183.1551926432942;
        Wed, 06 Mar 2019 18:40:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551926432; cv=none;
        d=google.com; s=arc-20160816;
        b=G4WA80SuGaBI/kfebWjUqBifNMvkDf4yeE6kDkoMffe2T+WyegOz1kAuaez0j/RD+1
         blxWnOIA8lEZDS4NPcWOFtovXalPBtOz8j7fGclPb34vYNpi5oPpOHIzmQnE5hstIWAQ
         AEldw8uyV2x9FehpryaEKNSo8dYNHUNiFvdX6sUbBvBl0SoV3HZ6sSX/KtiAzLdI0FlJ
         YvqP0hUC4LKt1FDbCsnsJL/Ae72BBXV0wN4L97tCmf5h0ZE3YX4IIjfj4rtow1TKTV/e
         WLXF6hUen0p/ImJR8Yt0S/8tPYjx/Y5ZtaKQ/8TPitubyjYAz36JnXbDWlPnMiVVkLIO
         fEmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=giZ3G8scpJp2Bk2ZLvCXcQDfm9BcEE61Ez2UBOzYhIA=;
        b=JrpEtK5kohEMusutFkK0U8r01MCnwSFAt23NE0RS9WCfIwJBRpK0HjyC0dTQgK6hEd
         N0WMpcEnCLw8N0ZgQp/w/VKsB/eeC1l9Lttqwl0QLqA2jhpqfacAkzZZRoJ0/h+h+vnq
         GH2dhqDPn/sUUVWeD/Qf6e5SptPV9VCax7JEKK5nBgLCe2lNLoUyLtpYS2maohk4I+lD
         tDuMqsgveARKBFsPeiw4pbSdxVVmaLdZ/rWo1a97doRuwcsC+FsA8YQMKjKzmMN0lSJ5
         82gtCNDWozsDN6lldpG9uzbcVrGBjCeDqFItQRLxQNWfyDbpJ5QQ3dhDLYq5dioAziIb
         QPtA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f54si2098902qtk.147.2019.03.06.18.40.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 18:40:32 -0800 (PST)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 219EE356E5;
	Thu,  7 Mar 2019 02:40:32 +0000 (UTC)
Received: from [10.72.12.83] (ovpn-12-83.pek2.redhat.com [10.72.12.83])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4D61960C1B;
	Thu,  7 Mar 2019 02:40:21 +0000 (UTC)
Subject: Re: [RFC PATCH V2 4/5] vhost: introduce helpers to get the size of
 metadata area
To: Christophe de Dinechin <christophe.de.dinechin@gmail.com>
Cc: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
 aarcange@redhat.com
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-5-git-send-email-jasowang@redhat.com>
 <608E47C2-5130-41DE-9D52-02807EBCDD43@dinechin.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <f61076eb-93ec-b924-2ad9-96af0df45830@redhat.com>
Date: Thu, 7 Mar 2019 10:40:20 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <608E47C2-5130-41DE-9D52-02807EBCDD43@dinechin.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 07 Mar 2019 02:40:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/6 下午6:56, Christophe de Dinechin wrote:
>> On 6 Mar 2019, at 08:18, Jason Wang<jasowang@redhat.com>  wrote:
>>
>> Signed-off-by: Jason Wang<jasowang@redhat.com>
>> ---
>> drivers/vhost/vhost.c | 46 ++++++++++++++++++++++++++++------------------
>> 1 file changed, 28 insertions(+), 18 deletions(-)
>>
>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> index 2025543..1015464 100644
>> --- a/drivers/vhost/vhost.c
>> +++ b/drivers/vhost/vhost.c
>> @@ -413,6 +413,27 @@ static void vhost_dev_free_iovecs(struct vhost_dev *dev)
>> 		vhost_vq_free_iovecs(dev->vqs[i]);
>> }
>>
>> +static size_t vhost_get_avail_size(struct vhost_virtqueue *vq, int num)
> Nit: Any reason not to make `num` unsigned or size_t?
>

Let me use unsigned int to match the definition of vq->num.

Thanks


