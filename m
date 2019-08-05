Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1ED8BC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 04:41:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D521921849
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 04:41:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D521921849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 739DE6B0006; Mon,  5 Aug 2019 00:41:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6EA7A6B0007; Mon,  5 Aug 2019 00:41:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DA6F6B0008; Mon,  5 Aug 2019 00:41:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3AFED6B0006
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 00:41:53 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p34so74672097qtp.1
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 21:41:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=xpUZrYjjX1az9uzQ6/FeD0kWIr34iNu/bh0NcGc69T4=;
        b=g9YSYo/2uonZa5fJNyMs83wic3rGFHFjdyWtczMFmkNs9EYIKSCvo+B72bx6rTOEVL
         6ZaZobXr6Kui50hGq3j8E9auKfayxO2cbUuQgSk05CbhE/t82vhp8Wi8/QF9iPo1G3/a
         gJChIldObmjUtI19E5r1mQC1JvG7ziTP8IRyGM0Z2o2azvSWLf3whCqitdPNVY7yHoy3
         7K8TGUbFahDglxxfCfVniNhWamMilQGNRl20OTARmg7HsqwoiLnmh0aQBZv4wEjoLOCE
         a6Mcvjmf4DPsAxOrM/IFsONp7X7lF1wiNc+YfIw0QYFWGa26XETDlwQQdQI1GweYBF5B
         Fu6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXDojk6Wcs9a+tEJy8/tH1lVbb1Rv7Aj0xQiM5Mvb108/PmU6Ua
	WvkZp/x4Qq2zgiouhwf0J8/KQfDRXFfh2If28RD2J9Y2fHyAl122YVZV05k0uDhsPnq8LaHKkiW
	cUAkXSLdCjavoeWdw3OHZ7g6t3jQXz/Tm+aNwqkBzG7bA6xyfq7EqQy7X1TEHAanB/w==
X-Received: by 2002:a37:a090:: with SMTP id j138mr100548439qke.83.1564980113003;
        Sun, 04 Aug 2019 21:41:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyv0PuoG2WKoEBjxpyKY0xAMswJHukEAbguNQPXyi/zKdzrajXieyUmWrcwdCjnJ4bDahLX
X-Received: by 2002:a37:a090:: with SMTP id j138mr100548430qke.83.1564980112394;
        Sun, 04 Aug 2019 21:41:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564980112; cv=none;
        d=google.com; s=arc-20160816;
        b=CT6aRggR3Rx8aBsc2z10rcN7yxxU/YJBGMcYvp9KdDl9NS6KZqijRzLR/IijI4xnMk
         LxbOIQe0IqnLXQcRFtF9gPulxXPjPttG/vM5YR4S5sbYOIfZpb0iioUY3GmrKPnLc/X5
         FhX16jYLdoqODQOy5sEOCxivp1Tz+zNSQdzf1kw1dmd6FGJIAyxOtr0n+o+oM2gjAYWA
         X9wsjFSmzS7cEm25DdHjiEcHShxQelz4U3HE3tsH0rDrDoa6ev7IJMYzNoZMPdiTdy2h
         9PnWz1JAiESOagf8L//zvh9jL1jV1A+yPYZsPUhjBUxnDawIuhe8yBC8rhmbq7Nejq4b
         EAsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=xpUZrYjjX1az9uzQ6/FeD0kWIr34iNu/bh0NcGc69T4=;
        b=EPv4X13vCv80kCmEKx48/SNs380q/ieYTrUYsl9ShSnQ8Bftjn9+boCcWK1P+X6AZq
         h4JgREGpMjZNMrebSL5AZmxuxtjI9+WMPEeZII1sATzWT/02jabcbe0nhSCAQgH2Nvnl
         y/oMM9nw76p2twn0mLFUQiKQEkZyZz8eemxHVdsHr1bR5jZqUaJKZaUstoKYkWH0u6b0
         QB7gM8TuBhn+IKYYAuj8nyVCq+93XjTlNi/OyCgUwnVmySsYziIMpYq+PdVZzQb6fz6J
         khCu/RZ/VwmoNEDo6PoBhzJ0QrhkzmL5bx4ypLgeHgGl+PUYUYU3QkLZkcOtYsGDs1aq
         pHzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y66si44693718qkd.319.2019.08.04.21.41.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Aug 2019 21:41:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9510FC0AD2BB;
	Mon,  5 Aug 2019 04:41:51 +0000 (UTC)
Received: from [10.72.12.115] (ovpn-12-115.pek2.redhat.com [10.72.12.115])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EE54619C59;
	Mon,  5 Aug 2019 04:41:46 +0000 (UTC)
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
From: Jason Wang <jasowang@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com> <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <20190802100414-mutt-send-email-mst@kernel.org>
 <e8ecb811-6653-cff4-bc11-81f4ccb0dbbf@redhat.com>
Message-ID: <494ac30d-b750-52c8-b927-16cd4b9414c4@redhat.com>
Date: Mon, 5 Aug 2019 12:41:45 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <e8ecb811-6653-cff4-bc11-81f4ccb0dbbf@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 05 Aug 2019 04:41:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/5 下午12:36, Jason Wang wrote:
>
> On 2019/8/2 下午10:27, Michael S. Tsirkin wrote:
>> On Fri, Aug 02, 2019 at 09:46:13AM -0300, Jason Gunthorpe wrote:
>>> On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
>>>>> This must be a proper barrier, like a spinlock, mutex, or
>>>>> synchronize_rcu.
>>>>
>>>> I start with synchronize_rcu() but both you and Michael raise some
>>>> concern.
>>> I've also idly wondered if calling synchronize_rcu() under the various
>>> mm locks is a deadlock situation.
>>>
>>>> Then I try spinlock and mutex:
>>>>
>>>> 1) spinlock: add lots of overhead on datapath, this leads 0 
>>>> performance
>>>> improvement.
>>> I think the topic here is correctness not performance improvement
>> The topic is whether we should revert
>> commit 7f466032dc9 ("vhost: access vq metadata through kernel virtual 
>> address")
>>
>> or keep it in. The only reason to keep it is performance.
>
>
> Maybe it's time to introduce the config option?


Or does it make sense if I post a V3 with:

- introduce config option and disable the optimization by default

- switch from synchronize_rcu() to vhost_flush_work(), but the rest are 
the same

This can give us some breath to decide which way should go for next release?

Thanks


>
>
>>
>> Now as long as all this code is disabled anyway, we can experiment a
>> bit.
>>
>> I personally feel we would be best served by having two code paths:
>>
>> - Access to VM memory directly mapped into kernel
>> - Access to userspace
>>
>>
>> Having it all cleanly split will allow a bunch of optimizations, for
>> example for years now we planned to be able to process an incoming short
>> packet directly on softirq path, or an outgoing on directly within
>> eventfd.
>
>
> It's not hard consider we've already had our own accssors. But the 
> question is (as asked in another thread), do you want permanent GUP or 
> still use MMU notifiers.
>
> Thanks
>
> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/virtualization

