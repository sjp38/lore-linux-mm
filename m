Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76FECC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 13:49:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33BC12184C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 13:49:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33BC12184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC0408E0003; Thu, 14 Mar 2019 09:49:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6E2D8E0001; Thu, 14 Mar 2019 09:49:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A118A8E0003; Thu, 14 Mar 2019 09:49:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7694A8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:49:17 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id k21so4730706qkg.19
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 06:49:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=jM7lEdNxFfAF3JC1tjnKk4YbFexy4cY2i7J2knNu5j8=;
        b=oOy2lju8c4dqnr/k+GHPVGtWPNlhAW17YTZnae1lgZ76evwYYMvLr3kSF7LBt79LGl
         zmOft1Elc/w3nIRynHDg859x19csOdpSkVhKbVZHGiRqi6pJ8GMdgUuxsfdXDmXsIr6y
         td5QPuQ4QlyNrVrYnZP5ZXEH+Ld8lr0zwMSO/IXumXE+EmL8+/lnydfSEtfony4J/+JX
         VHyt6RuFp0aZFPTktO1kUFhIcVYUdqjxsSX7qqqOg+Qwtp5mxA2WUA1yWL79sT6EsNY9
         XO+EbM3beSRE0PfUvDIgvR3+run7TOkp7hxdmKeNKEjPG2/BqADP6kkbMcwinDfXmvfk
         wkiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVrjghkmVBkDt650HzgVJs8JghiHK1UaDFVy8nNWHXvOzAgYwJg
	sQQ6voYi79WdbbE9ubwxfCZ5dxUj/mz3G2wsiFkstQyd1uZ+vCa8g4uiTiuhrwsUZH5dd+BhuJu
	HokFq6GL6Z6HVRa+HvO7DNGNb+RCypGp4DrzHH+1s/fLZPH3q02WcFXK36Wr4ZuqpfQ==
X-Received: by 2002:ac8:67cb:: with SMTP id r11mr2318309qtp.388.1552571357269;
        Thu, 14 Mar 2019 06:49:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyu2HnqlTPCQSkxAofGSBvBltK1816qaqY+eVpBU/P0U7GR3eVd+v9S9X920j4w/Y5G6/SD
X-Received: by 2002:ac8:67cb:: with SMTP id r11mr2318264qtp.388.1552571356503;
        Thu, 14 Mar 2019 06:49:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552571356; cv=none;
        d=google.com; s=arc-20160816;
        b=dhGS2H8BUM48OHXW8X+XM7yEhAr7xyx2d15z11RDRH0qEay9eUje6moJLwG4qvCPcZ
         BaSV+Ona07dKLgE4luc3ShNC7lEdUufbLIQMZYc5ONUJIrU9FlbAPyXDx2g2wtL02i/5
         EVwbJ6dT6p9K8o1wFta1kEr8K4ODIqvi3tE/7CbqlGXjvoO+gh/sgivi7FpTkjHr6aYq
         czM4oSCM50spbD3WcmYTefmmeJ/eSJfO0nf+bZ9ZXUyVG9wvozsYUsAurPHj8fUdpufk
         7I7LuH/1mDqxgs9szBWmh+Sh/Xu/0GAwMvmIvgDCwfkHd2ZVvDIS000MAzG0kKf1U36U
         zfWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=jM7lEdNxFfAF3JC1tjnKk4YbFexy4cY2i7J2knNu5j8=;
        b=BTyVwYgeSCrfdXcKSDMs0FJSAgz7QUaeiKckVfQuGvrmRe6fnnKYr8ZgVuZVDq/5y5
         OEPeR0VYBPa/lKBSvSKDymLrgjvhTD+LYCUJi2LgM2pNCvXPtnbXN9/6Bmy+3FTcmkW4
         XSkGkK5vIvqUf3/kJxXb10wSv5jxHZtKc+4t4DfCTHie2N6wfDnn4rvXC56EwArZPSFr
         XyGrt+jx6Zc5lIOdTBetAjteDeLtHbfYDirypg10qZLbF5jBsII2s88Ro9x4bhTCd9nm
         SsEYtdBdMqBTP4yVOFdOcDQiCFKma9zYtvNmLVGykfUpcptWwL4gPUzGUcTbwhSZzfkx
         iLPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b5si5102456qkd.63.2019.03.14.06.49.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 06:49:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6E057307B494;
	Thu, 14 Mar 2019 13:49:15 +0000 (UTC)
Received: from [10.72.12.71] (ovpn-12-71.pek2.redhat.com [10.72.12.71])
	by smtp.corp.redhat.com (Postfix) with ESMTP id ABC525D73D;
	Thu, 14 Mar 2019 13:49:05 +0000 (UTC)
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
To: "Michael S. Tsirkin" <mst@redhat.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Christoph Hellwig <hch@infradead.org>,
 Andrea Arcangeli <aarcange@redhat.com>, David Miller <davem@davemloft.net>,
 kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, peterx@redhat.com,
 linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org,
 linux-parisc@vger.kernel.org
References: <20190311.111413.1140896328197448401.davem@davemloft.net>
 <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
 <20190311235140-mutt-send-email-mst@kernel.org>
 <76c353ed-d6de-99a9-76f9-f258074c1462@redhat.com>
 <20190312075033-mutt-send-email-mst@kernel.org>
 <1552405610.3083.17.camel@HansenPartnership.com>
 <20190312200450.GA25147@redhat.com>
 <1552424017.14432.11.camel@HansenPartnership.com>
 <20190313160529.GB15134@infradead.org>
 <1552495028.3022.37.camel@HansenPartnership.com>
 <20190314064004-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <74015196-2e18-4fe0-50ac-0c9d497315c7@redhat.com>
Date: Thu, 14 Mar 2019 21:49:03 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190314064004-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 14 Mar 2019 13:49:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/14 下午6:42, Michael S. Tsirkin wrote:
>>>>> Which means after we fix vhost to add the flush_dcache_page after
>>>>> kunmap, Parisc will get a double hit (but it also means Parisc
>>>>> was the only one of those archs needed explicit cache flushes,
>>>>> where vhost worked correctly so far.. so it kinds of proofs your
>>>>> point of giving up being the safe choice).
>>>> What double hit?  If there's no cache to flush then cache flush is
>>>> a no-op.  It's also a highly piplineable no-op because the CPU has
>>>> the L1 cache within easy reach.  The only event when flush takes a
>>>> large amount time is if we actually have dirty data to write back
>>>> to main memory.
>>> I've heard people complaining that on some microarchitectures even
>>> no-op cache flushes are relatively expensive.  Don't ask me why,
>>> but if we can easily avoid double flushes we should do that.
>> It's still not entirely free for us.  Our internal cache line is around
>> 32 bytes (some have 16 and some have 64) but that means we need 128
>> flushes for a page ... we definitely can't pipeline them all.  So I
>> agree duplicate flush elimination would be a small improvement.
>>
>> James
> I suspect we'll keep the copyXuser path around for 32 bit anyway -
> right Jason?


Yes since we don't want to slow down 32bit.

Thanks


> So we can also keep using that on parisc...
>
> -- 

