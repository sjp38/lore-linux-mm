Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 500BEC32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 14:02:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1224E21E6E
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 14:02:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1224E21E6E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 981EE6B0003; Wed,  7 Aug 2019 10:02:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 931996B0006; Wed,  7 Aug 2019 10:02:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 848C06B0007; Wed,  7 Aug 2019 10:02:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 666A26B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 10:02:18 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id l14so79019692qke.16
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 07:02:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=Hmes6i97EUWXjJ7pVOvb6iTylz+Ec7pLW61tcZ8T28Y=;
        b=SzEOnsUAZOJkAgr20aTJ13ENh7EyR6TY2hhemvV2Hx4z7nG5TLrEqGgH5XdGMx6H5o
         2QcuIe86y6G1s5uVQosQfefIt/4D2/8BFPyo27dz4Njj7pFvYYpz0dPp5Zm6I0eby7S/
         OmfydHBFOaTR/28EsRYC+ssTJqStjzWzrnTPqCdA1PrxtZHNeqSYA+16TwaZ/K92RmTp
         MpqE9jZBvrQmMc4hXDVznJMt5O4ywh2Js0flmwAWc0yNNREhIWKbCQ4Iyg/2SKepKklZ
         HgtQa6Oi1mCB43m07ux0OKDc6VUY24Tvd85mHUN0vrDwSRsjFW4TB6XzefFVs95k9Ag/
         WYCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWpiIh6NMjugHvgX8kfEcW66AA7wJnyS8UwVaWdzwPZCyXu3kxc
	HqS0hvm51+yOpN7Om3K2673cuJ65Z2FnEbcMQW6oJU6kjGJ2BLNGnSIGjmJ8w2FWn52QqeQOlWV
	rquGK+kAKIWLkNzVNQYWFCvjtm5JccUNfJmmIIm+0wzFJMJHtfechNo1lHoH3TmcWVw==
X-Received: by 2002:ae9:f447:: with SMTP id z7mr7798597qkl.468.1565186538114;
        Wed, 07 Aug 2019 07:02:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuFRvc8aa31roNALIQeZ0B339xUtrdi4mt2rc6KdimpDYlK+a+iLhb8+uEbU/keddHI4t3
X-Received: by 2002:ae9:f447:: with SMTP id z7mr7798495qkl.468.1565186537107;
        Wed, 07 Aug 2019 07:02:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565186537; cv=none;
        d=google.com; s=arc-20160816;
        b=nwHWsoFu/dRIDK7MCEu7nPVt29euyjWrbNhOc41E8qzjEiFzKphKtaWq3qEtjm8/vl
         /7Qf2ufHX/JBilducYuIvO1KKdifS96bKZmv8M02pX5G/hegdd5IsRMrpCpqi1X54ZZJ
         FW88rAqCx6ZEd5r1UAsq4Zlj69uRE00OLLi8BdvPzkC/eM/4zg+vygAUVnMksx4mXF45
         ohwzKU89OwRQfnJ8WXho1XfIOsdtlfNXVE1WOaSD57vXhZt4006wc4Scw8RTo78TQnYS
         BHi9TGZdjbCjCh124L2fF0pVFMm0yQwIFS0WaBSsUyMsUFMt3kzfwOPRJR6LsGtSTmP+
         8JKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Hmes6i97EUWXjJ7pVOvb6iTylz+Ec7pLW61tcZ8T28Y=;
        b=CLAk2l5q06GE0PaT2mBJSEn36RzIqJxJMlqBA6xQl76ZdJeS9RBUq2dSPDK83t3EvM
         6L5C0FCeeZhpPaYoPlvARj46dodDfN6QErR3D5+wAU/0SZ3w8emTrowT4y2RlLaWg7j/
         xSRoL9g0s12cpw6S5kdAw7XeVaDuLMfUNnRQ+P4I9kxqM5mxrJH6xZBi8R3VIboPB+2F
         RR9uml6WB9v58vU7HumChz6iX+rQ/Vsf7Ed4o496n/w11AcnH+THTkE7bLrOMzlJ4EeH
         7Stq68OnsFR5lb8IyFBIhtTVgkKbqqk0Q42vx4XiExNklahC2FhZXy9FdtQ3BRJdSnbC
         VNsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b138si501573qkg.81.2019.08.07.07.02.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 07:02:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 16CE351F0B;
	Wed,  7 Aug 2019 14:02:16 +0000 (UTC)
Received: from [10.72.12.139] (ovpn-12-139.pek2.redhat.com [10.72.12.139])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A825B608AB;
	Wed,  7 Aug 2019 14:02:13 +0000 (UTC)
Subject: Re: [PATCH V4 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190807070617.23716-1-jasowang@redhat.com>
 <20190807070617.23716-8-jasowang@redhat.com> <20190807120738.GB1557@ziepe.ca>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <ba5f375f-435a-91fd-7fca-bfab0915594b@redhat.com>
Date: Wed, 7 Aug 2019 22:02:12 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190807120738.GB1557@ziepe.ca>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 07 Aug 2019 14:02:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/7 下午8:07, Jason Gunthorpe wrote:
> On Wed, Aug 07, 2019 at 03:06:15AM -0400, Jason Wang wrote:
>> We used to use RCU to synchronize MMU notifier with worker. This leads
>> calling synchronize_rcu() in invalidate_range_start(). But on a busy
>> system, there would be many factors that may slow down the
>> synchronize_rcu() which makes it unsuitable to be called in MMU
>> notifier.
>>
>> So this patch switches use seqlock counter to track whether or not the
>> map was used. The counter was increased when vq try to start or finish
>> uses the map. This means, when it was even, we're sure there's no
>> readers and MMU notifier is synchronized. When it was odd, it means
>> there's a reader we need to wait it to be even again then we are
>> synchronized. Consider the read critical section is pretty small the
>> synchronization should be done very fast.
>>
>> Reported-by: Michael S. Tsirkin <mst@redhat.com>
>> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>   drivers/vhost/vhost.c | 141 ++++++++++++++++++++++++++----------------
>>   drivers/vhost/vhost.h |   7 ++-
>>   2 files changed, 90 insertions(+), 58 deletions(-)
>>
>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> index cfc11f9ed9c9..57bfbb60d960 100644
>> +++ b/drivers/vhost/vhost.c
>> @@ -324,17 +324,16 @@ static void vhost_uninit_vq_maps(struct vhost_virtqueue *vq)
>>   
>>   	spin_lock(&vq->mmu_lock);
>>   	for (i = 0; i < VHOST_NUM_ADDRS; i++) {
>> -		map[i] = rcu_dereference_protected(vq->maps[i],
>> -				  lockdep_is_held(&vq->mmu_lock));
>> +		map[i] = vq->maps[i];
>>   		if (map[i]) {
>>   			vhost_set_map_dirty(vq, map[i], i);
>> -			rcu_assign_pointer(vq->maps[i], NULL);
>> +			vq->maps[i] = NULL;
>>   		}
>>   	}
>>   	spin_unlock(&vq->mmu_lock);
>>   
>> -	/* No need for synchronize_rcu() or kfree_rcu() since we are
>> -	 * serialized with memory accessors (e.g vq mutex held).
>> +	/* No need for synchronization since we are serialized with
>> +	 * memory accessors (e.g vq mutex held).
>>   	 */
>>   
>>   	for (i = 0; i < VHOST_NUM_ADDRS; i++)
>> @@ -362,6 +361,40 @@ static bool vhost_map_range_overlap(struct vhost_uaddr *uaddr,
>>   	return !(end < uaddr->uaddr || start > uaddr->uaddr - 1 + uaddr->size);
>>   }
>>   
>> +static void inline vhost_vq_access_map_begin(struct vhost_virtqueue *vq)
>> +{
>> +	write_seqcount_begin(&vq->seq);
>> +}
>> +
>> +static void inline vhost_vq_access_map_end(struct vhost_virtqueue *vq)
>> +{
>> +	write_seqcount_end(&vq->seq);
>> +}
> The write side of a seqlock only provides write barriers. Access to
>
> 	map = vq->maps[VHOST_ADDR_USED];
>
> Still needs a read side barrier, and then I think this will be no
> better than a normal spinlock.
>
> It also doesn't seem like this algorithm even needs a seqlock, as this
> is just a one bit flag


Right, so then I tend to use spinlock first for correctness.


>
> atomic_set_bit(using map)
> smp_mb__after_atomic()
> .. maps [...]
> atomic_clear_bit(using map)
>
>
> map = NULL;
> smp_mb__before_atomic();
> while (atomic_read_bit(using map))
>     relax()
>
> Again, not clear this could be faster than a spinlock when the
> barriers are correct...


Yes, for next release we may want to use the idea from Michael like to 
mitigate the impact of mb.

https://lwn.net/Articles/775871/

Thanks


>
> Jason

