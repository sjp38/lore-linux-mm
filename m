Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C081C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:29:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B055208E3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:29:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B055208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D6438E0003; Wed, 31 Jul 2019 09:29:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 986058E0001; Wed, 31 Jul 2019 09:29:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 874CB8E0003; Wed, 31 Jul 2019 09:29:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 66FF48E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:29:38 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 199so58171052qkj.9
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:29:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=/l9CIrx+tsd6BhzKWBZdQwioPjYy7tO9qRppVPToZns=;
        b=pG/WdBi7SmLkV4Sz2hN60NLIkqjLsPAlaKW1+4DCg4hEf2ZRxJ4avS52v0+GKCTgAY
         8IWyaauIFvCR/eONwqgwiEVludsO8fKMPQ2KtqcAXYfELcVtCehpzRn2Cy2u7j+x7QyJ
         ShWmR/EQsCUYj/DFEJXnTIBcuDC0PEpKsELNZm4jKrKNYESdIal02WdiG663CgargEOu
         oo3HnOFXsP4U8dMI1Ksy2t+vXeEUAIcGfae98greDx37kJS8d2drpJtJO3T8whTR79tW
         fiRzOmC2+pzlSq4zhzWtHIai+/MqqV0wJzWN5C/S32n5xbGwGhTzRtE3+hVYgEnYtfoJ
         U2sA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUFupQ22eNCqtlXfW1is+bbRAhYRe3zN26GVhnAB6OavIo1QBRM
	dgmiRyld2+t0QoxmO4Ceg2fXrz+mPB+afLLiCGMtOtuFSowGu5c6r4rKIEZuOJO37rJ5OLvuoXY
	3yedXjKSPjW9ZADQ64feXAEXX3Lh0b5lQbL8/0M6WIG3zMGeSpCNnx58vNjFOIVxoxg==
X-Received: by 2002:ac8:65d4:: with SMTP id t20mr81317249qto.249.1564579778206;
        Wed, 31 Jul 2019 06:29:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEYCY0AHpWcMPAPg+ohv4avIM9yQfKnlAgvd8UwL/mAJFD0z3TMD45bxuzoUsDRsj0Qnt3
X-Received: by 2002:ac8:65d4:: with SMTP id t20mr81317212qto.249.1564579777695;
        Wed, 31 Jul 2019 06:29:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564579777; cv=none;
        d=google.com; s=arc-20160816;
        b=iAo4l4Wr+QCb6SDtyH+2krGKhnyUCyrZwKWIa15ACSHpiRwmkqdgDXt+TiVCNspDFQ
         r7q3ggNExGYwJj5Ta/6pkkk88JR9mEP3DZu/6LS2LFv3LsNUTaM5FG0BSEKQ0wU6Lkbi
         C3fsicsC/bG9tX0SneJLX71O678yeD9ocKo6l3Kj0MhcjCqtAafs5fBkxQ2ESZfmsmPR
         UnQCuAESR5d/CrVz3AotwlsKMLVjR9ORhTX2/L5A/sy0AkZdGX5gpZNoqew5uLOmkiBx
         6FEaoCNSlULFtORdnQA0lzdBRVzfBa1tr4yEmnk8yM9kD9jjAuQozEbos34UMZ6SGtX1
         r0DQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=/l9CIrx+tsd6BhzKWBZdQwioPjYy7tO9qRppVPToZns=;
        b=pv8ugkc7+4Dm6QaEpApNKu6QWnPUvlCnH1PVdbspznAftzqGCpTE8Un4vomYXlTiTe
         Ncoro3cF+HqZaYwY71AZKqozmLGajOQb9ire8VNGmz8/Wepx+hQofg+5ok4HQ49jUMK6
         TbJLT3geMEKNYoncVUhk5haDu7ae7quHo4gaDTH5eR8mV4ctT1Dbn7qziK/Js1atzfYV
         JZAU1CEuGXvUlmACZv0L5WexOwA0pINwaru6WkUQv3NLrTKMLoMeIvoWi8fxbKl5mkcM
         DSH3B82weFL8o5O3zK14e1WinQ6AxXj4cBG88v4aFJSO88Ss8O3DwldMusFE3/yyzqP9
         BWCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z53si43417455qta.355.2019.07.31.06.29.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 06:29:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F304781F13;
	Wed, 31 Jul 2019 13:29:36 +0000 (UTC)
Received: from [10.72.12.118] (ovpn-12-118.pek2.redhat.com [10.72.12.118])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1B5E35C1B5;
	Wed, 31 Jul 2019 13:29:29 +0000 (UTC)
Subject: Re: [PATCH V2 4/9] vhost: reset invalidate_count in
 vhost_set_vring_num_addr()
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-5-jasowang@redhat.com> <20190731124124.GD3946@ziepe.ca>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <31ef9ed4-d74a-3454-a57d-fa843a3a802b@redhat.com>
Date: Wed, 31 Jul 2019 21:29:28 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190731124124.GD3946@ziepe.ca>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 31 Jul 2019 13:29:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/31 下午8:41, Jason Gunthorpe wrote:
> On Wed, Jul 31, 2019 at 04:46:50AM -0400, Jason Wang wrote:
>> The vhost_set_vring_num_addr() could be called in the middle of
>> invalidate_range_start() and invalidate_range_end(). If we don't reset
>> invalidate_count after the un-registering of MMU notifier, the
>> invalidate_cont will run out of sync (e.g never reach zero). This will
>> in fact disable the fast accessor path. Fixing by reset the count to
>> zero.
>>
>> Reported-by: Michael S. Tsirkin <mst@redhat.com>
> Did Michael report this as well?


Correct me if I was wrong. I think it's point 4 described in 
https://lkml.org/lkml/2019/7/21/25.

Thanks


>
>> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>   drivers/vhost/vhost.c | 4 ++++
>>   1 file changed, 4 insertions(+)
>>
>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> index 2a3154976277..2a7217c33668 100644
>> +++ b/drivers/vhost/vhost.c
>> @@ -2073,6 +2073,10 @@ static long vhost_vring_set_num_addr(struct vhost_dev *d,
>>   		d->has_notifier = false;
>>   	}
>>   
>> +	/* reset invalidate_count in case we are in the middle of
>> +	 * invalidate_start() and invalidate_end().
>> +	 */
>> +	vq->invalidate_count = 0;
>>   	vhost_uninit_vq_maps(vq);
>>   #endif
>>   

