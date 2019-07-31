Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F03DC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 10:06:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F12E9216C8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 10:06:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F12E9216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EA1B8E0003; Wed, 31 Jul 2019 06:06:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89A608E0001; Wed, 31 Jul 2019 06:06:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AFAD8E0003; Wed, 31 Jul 2019 06:06:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF7D8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:06:06 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g30so60957316qtm.17
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 03:06:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=qeSzkAeOqx+WxJIT8ThTJTFcTvKGwVu47lDDkwPuz7U=;
        b=bTpEvGqzNd7EILsC+7fYdBhfFbOPHRlDmmz/8j113iXbAonRSLgcslJHm8NPPO486w
         JJPkTn7Zowv1t3twW73TPlGUMp25no8sPBZkF9dvZt17104PvZc0Quc1kT0m1VI46Csl
         70fhAsGYE75BQ5ZZUskt7kfgYdN0pDkUYFtm6EDMhImQiAvFknKfvz4bY3gDdNS+8DTs
         Bcxe0knl9ETwNBbEfwjO1KJWQLHOUBxjFo8eG46GnyGw+cF+VyO0iSYph5dCRkLDzoRS
         AbALJrteHYhB40z/MY0Q8XiB/8rpxXjmqw6YfTonf1TUceDzAFvhg/VmTgkPXjn0qH7G
         4CMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVjZfy8HiPklYTa8Fc22j/kVxebnBhAH2NJX4YWcgy0GPceo2zI
	EfGDl6yX8XjCjX7Qa+vhkjlDKrqgCEUJDOmNKfNuHUcoTqE5p/SwZBLTWD6acbdSDKFXxNAmM96
	L0jg6s+zjAG3lMFAUGaOwOdyxPQPmRdvhxAHmD+oO9velb91qxhvVHA1ffqbslqOAgg==
X-Received: by 2002:ae9:f019:: with SMTP id l25mr81556875qkg.473.1564567566112;
        Wed, 31 Jul 2019 03:06:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzR5UeMBH+CISkx42b4/1FODy42kBmH4+IYPSnkeTad/pZUI2LxJP/cG4cyHfMjbS+AOAyo
X-Received: by 2002:ae9:f019:: with SMTP id l25mr81556821qkg.473.1564567565524;
        Wed, 31 Jul 2019 03:06:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564567565; cv=none;
        d=google.com; s=arc-20160816;
        b=UX93/JWbr9BU+4a9ZcWozzsdoWRvAM4uj3/zceJCEEsw5T0gtOSFRpBE48LRZZwtVc
         JZ1AwweCaiwPle2k8su0bSQCFmCFUVVLC5HK4saoyXi/dYgr98HbN9s9OtsrtjjcIm9q
         9Yds86dfl47VrgI942zt02+rTfc5RU+OB+a5zSiCJNwW1fE0qvqH7s2HeA2SrbY+UlCq
         lNn2gIrvr0WM7oqdsymgQw54ucONMYdJmoyPcE3PabtJY3A2/Pb1AqvUCnHIjROk4OKh
         gska0fxZWBe1MBkpMrxo+PsoQoGCWjSEfVqBy1YNV6zECK55pyEzFwGz4UBq63UbdH16
         tkgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=qeSzkAeOqx+WxJIT8ThTJTFcTvKGwVu47lDDkwPuz7U=;
        b=Z13KWYUP0Y+Es6Pujni/Go63pruKmMPRbLP0zE5zIWQqjTQB7mPh34M1HZsQs3uMJk
         Afzi6X7phB98WDGIFOqbmq/epT1JklGAWu5o/G4obcqLxf3yDI7w6LNyhwj9CyJ+upa2
         RaNTDI0FNxo/NI0rtJ6AmEl6wbwUMmTUGTCJCx2qfnGecURx3VU7PWfDdBfH1b8XephN
         hJ0jAohBsr31YOv5zlu39kYiMsImQW0rAswYTeJavMtEg1i6gl24HnAoLGmTF8ZuhHuN
         dx8jEEscuCElhBXfmtgWruIrF5+tc9uYrfugG5PGL+h6OexbzBzOaVYTXO5d0sMG81Yr
         KDLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h5si37844059qkm.74.2019.07.31.03.06.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 03:06:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A9BF5285AE;
	Wed, 31 Jul 2019 10:06:04 +0000 (UTC)
Received: from [10.72.12.118] (ovpn-12-118.pek2.redhat.com [10.72.12.118])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 906F15C219;
	Wed, 31 Jul 2019 10:05:59 +0000 (UTC)
Subject: Re: [PATCH V2 9/9] vhost: do not return -EAGIAN for non blocking
 invalidation too early
To: Stefano Garzarella <sgarzare@redhat.com>
Cc: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, jgg@ziepe.ca
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-10-jasowang@redhat.com>
 <20190731095950.d6zr472megt7rgkt@steredhat>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <e00259ec-af5d-3c58-a936-2e1c6e1bc2b9@redhat.com>
Date: Wed, 31 Jul 2019 18:05:58 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190731095950.d6zr472megt7rgkt@steredhat>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 31 Jul 2019 10:06:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/31 下午5:59, Stefano Garzarella wrote:
> A little typo in the title: s/EAGIAN/EAGAIN
>
> Thanks,
> Stefano


Right, will fix if need respin or Michael can help to fix.

Thanks


>
> On Wed, Jul 31, 2019 at 04:46:55AM -0400, Jason Wang wrote:
>> Instead of returning -EAGAIN unconditionally, we'd better do that only
>> we're sure the range is overlapped with the metadata area.
>>
>> Reported-by: Jason Gunthorpe <jgg@ziepe.ca>
>> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>   drivers/vhost/vhost.c | 32 +++++++++++++++++++-------------
>>   1 file changed, 19 insertions(+), 13 deletions(-)
>>
>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> index fc2da8a0c671..96c6aeb1871f 100644
>> --- a/drivers/vhost/vhost.c
>> +++ b/drivers/vhost/vhost.c
>> @@ -399,16 +399,19 @@ static void inline vhost_vq_sync_access(struct vhost_virtqueue *vq)
>>   	smp_mb();
>>   }
>>   
>> -static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
>> -				      int index,
>> -				      unsigned long start,
>> -				      unsigned long end)
>> +static int vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
>> +				     int index,
>> +				     unsigned long start,
>> +				     unsigned long end,
>> +				     bool blockable)
>>   {
>>   	struct vhost_uaddr *uaddr = &vq->uaddrs[index];
>>   	struct vhost_map *map;
>>   
>>   	if (!vhost_map_range_overlap(uaddr, start, end))
>> -		return;
>> +		return 0;
>> +	else if (!blockable)
>> +		return -EAGAIN;
>>   
>>   	spin_lock(&vq->mmu_lock);
>>   	++vq->invalidate_count;
>> @@ -423,6 +426,8 @@ static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
>>   		vhost_set_map_dirty(vq, map, index);
>>   		vhost_map_unprefetch(map);
>>   	}
>> +
>> +	return 0;
>>   }
>>   
>>   static void vhost_invalidate_vq_end(struct vhost_virtqueue *vq,
>> @@ -443,18 +448,19 @@ static int vhost_invalidate_range_start(struct mmu_notifier *mn,
>>   {
>>   	struct vhost_dev *dev = container_of(mn, struct vhost_dev,
>>   					     mmu_notifier);
>> -	int i, j;
>> -
>> -	if (!mmu_notifier_range_blockable(range))
>> -		return -EAGAIN;
>> +	bool blockable = mmu_notifier_range_blockable(range);
>> +	int i, j, ret;
>>   
>>   	for (i = 0; i < dev->nvqs; i++) {
>>   		struct vhost_virtqueue *vq = dev->vqs[i];
>>   
>> -		for (j = 0; j < VHOST_NUM_ADDRS; j++)
>> -			vhost_invalidate_vq_start(vq, j,
>> -						  range->start,
>> -						  range->end);
>> +		for (j = 0; j < VHOST_NUM_ADDRS; j++) {
>> +			ret = vhost_invalidate_vq_start(vq, j,
>> +							range->start,
>> +							range->end, blockable);
>> +			if (ret)
>> +				return ret;
>> +		}
>>   	}
>>   
>>   	return 0;
>> -- 
>> 2.18.1
>>

