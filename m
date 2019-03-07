Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8715EC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 02:43:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D6DF20661
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 02:43:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D6DF20661
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D39AF8E0005; Wed,  6 Mar 2019 21:43:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE9218E0002; Wed,  6 Mar 2019 21:43:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD8728E0005; Wed,  6 Mar 2019 21:43:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 972308E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 21:43:05 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id k1so13895809qta.2
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 18:43:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=eqb6V3KYyX0QhsYjF8E/sIPNIUg+AF4nnVMqGxQPoYQ=;
        b=hbiR5FhhCVZI31NE6t2DpGCeoRD2yfIr3tQkNV4NnDdei3C3Eja8hFf7rorDyFa4U9
         s+XByt1Ugfsn7gwiOA4mqJL8VbKqa6b4+L5Eb1N+KXPnAtXItGcaBYQEOwTtGXpGxAOw
         SlngsZ5cShS1GZ8RLoS39smXBsIS9lLUUlVaL1NQs8nvm1rpA9OqaJ3XDd5cNf5jHEKN
         MWsnqljsG3evbzKxKsOXlegeMh32LhpWMKfbzs/1PmsthVAi2MnJScTlzZDYJYwhFp1H
         Yps+NH/zMpK/5/f6Xl6IZPHM3vYMec+UJ/3ma2TLz/JDbzLQNGpKSuraHkiMktF/Evrw
         1WsA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWwGxdhMoGqsQYYXTPsxfcS6fPkHzmeKqEMQyzTosm7V5dRirZP
	gaQbXMs/iTg6wnUQZzPlPeI2MbMSmSDcrn/IiPY5atcC5qlqBTSrfLTjCxbn6s3T8NklKnQtQ+7
	RTjFZ3+ZYs0MEIxuVL5nHGGrI0E6DbmQ1Fx+jp+wKNZGnv7QC/BncbIjyVwcQqNMKuA==
X-Received: by 2002:ac8:7a8f:: with SMTP id x15mr8412562qtr.36.1551926585359;
        Wed, 06 Mar 2019 18:43:05 -0800 (PST)
X-Google-Smtp-Source: APXvYqwE+vmrujx34z14SybjM9Jt12amImaBPZ+zsSO7jAoUau5BO1t7X5hh8pG7ITHtCIombAfB
X-Received: by 2002:ac8:7a8f:: with SMTP id x15mr8412532qtr.36.1551926584650;
        Wed, 06 Mar 2019 18:43:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551926584; cv=none;
        d=google.com; s=arc-20160816;
        b=xBFpSHi3BGsZ1T1J3282nmmUFxjPzz6mnQG4buiK5I6ldkRKndxbBtkwKZu1RT/+04
         pGMak5OHeGHO8cLz/YxHHA4QrPJRv7eoCg48CVto/8URKCORNXsjs1BJOOWmFRGAZd5J
         WT/gT+z2to/HbQH1SKWk91r+HEsT0JVXl/nmCPae2Xuyo00KLpTD/3AvFUctP3ydR2+e
         7Kyng13EEO503LGiyoc3rvUaN0Lor/ksCG5YLTgauQrYKvMsBEeQOQ42N4crOML4uQqL
         otapmYBX00qaTZ6lnTXmot8etqyarMzb7drtXPUNv0DRU1BSnOcgYv7FnuX1reB+cgk0
         LSkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=eqb6V3KYyX0QhsYjF8E/sIPNIUg+AF4nnVMqGxQPoYQ=;
        b=uXzztiaEEWGpWazSsI6gl3vNAzGVmZ+dxaBAmzKmOI/tdZWd9rSDGVcnx8cFwEdBGg
         bOGhxffmZn571zHVGE2X6UWc/OAIZfiBWCKh0lZcJn4apyVRMFFe2fODEqLNIG9NTK3j
         8umyE1LraNz2WEVbK6BUrJnKRpLMOWwIi2ygheiVVs8ppMrj4NTtTNTMlaTtJ3+tTztb
         MhWolOOKaGUGHJI8qlP6AMHwQTYsX79217663qdeMqAIvNAypmJRP+qJfBHh6gtS6fC8
         BCoQllQVAtgrI6iqNPBTB/q1ympFyDrXe1dvQJP/kdY4v+r/FZewN1JGdCStPPwwrSrA
         VIkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g189si2450953qka.158.2019.03.06.18.43.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 18:43:04 -0800 (PST)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BE5C5308FB8A;
	Thu,  7 Mar 2019 02:43:03 +0000 (UTC)
Received: from [10.72.12.83] (ovpn-12-83.pek2.redhat.com [10.72.12.83])
	by smtp.corp.redhat.com (Postfix) with ESMTP id F0E06608C1;
	Thu,  7 Mar 2019 02:42:51 +0000 (UTC)
Subject: Re: [RFC PATCH V2 4/5] vhost: introduce helpers to get the size of
 metadata area
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: mst@redhat.com, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, peterx@redhat.com,
 Linux-MM <linux-mm@kvack.org>, aarcange@redhat.com
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-5-git-send-email-jasowang@redhat.com>
 <CAFqt6zYynfCn_SG6w98dHMA5rS6euPb+ihXtQcALE47K0LQb7g@mail.gmail.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <035c74bb-71eb-71db-f5f5-ed9d1a12d733@redhat.com>
Date: Thu, 7 Mar 2019 10:42:50 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <CAFqt6zYynfCn_SG6w98dHMA5rS6euPb+ihXtQcALE47K0LQb7g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Thu, 07 Mar 2019 02:43:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/7 上午2:43, Souptick Joarder wrote:
> On Wed, Mar 6, 2019 at 12:48 PM Jason Wang <jasowang@redhat.com> wrote:
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> Is the change log left with any particular reason ?


Nope, will add the log.

Thanks


>> ---
>>   drivers/vhost/vhost.c | 46 ++++++++++++++++++++++++++++------------------
>>   1 file changed, 28 insertions(+), 18 deletions(-)
>>
>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> index 2025543..1015464 100644
>> --- a/drivers/vhost/vhost.c
>> +++ b/drivers/vhost/vhost.c
>> @@ -413,6 +413,27 @@ static void vhost_dev_free_iovecs(struct vhost_dev *dev)
>>                  vhost_vq_free_iovecs(dev->vqs[i]);
>>   }
>>
>> +static size_t vhost_get_avail_size(struct vhost_virtqueue *vq, int num)
>> +{
>> +       size_t event = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
>> +
>> +       return sizeof(*vq->avail) +
>> +              sizeof(*vq->avail->ring) * num + event;
>> +}
>> +
>> +static size_t vhost_get_used_size(struct vhost_virtqueue *vq, int num)
>> +{
>> +       size_t event = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
>> +
>> +       return sizeof(*vq->used) +
>> +              sizeof(*vq->used->ring) * num + event;
>> +}
>> +
>> +static size_t vhost_get_desc_size(struct vhost_virtqueue *vq, int num)
>> +{
>> +       return sizeof(*vq->desc) * num;
>> +}
>> +
>>   void vhost_dev_init(struct vhost_dev *dev,
>>                      struct vhost_virtqueue **vqs, int nvqs, int iov_limit)
>>   {
>> @@ -1253,13 +1274,9 @@ static bool vq_access_ok(struct vhost_virtqueue *vq, unsigned int num,
>>                           struct vring_used __user *used)
>>
>>   {
>> -       size_t s = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
>> -
>> -       return access_ok(desc, num * sizeof *desc) &&
>> -              access_ok(avail,
>> -                        sizeof *avail + num * sizeof *avail->ring + s) &&
>> -              access_ok(used,
>> -                       sizeof *used + num * sizeof *used->ring + s);
>> +       return access_ok(desc, vhost_get_desc_size(vq, num)) &&
>> +              access_ok(avail, vhost_get_avail_size(vq, num)) &&
>> +              access_ok(used, vhost_get_used_size(vq, num));
>>   }
>>
>>   static void vhost_vq_meta_update(struct vhost_virtqueue *vq,
>> @@ -1311,22 +1328,18 @@ static bool iotlb_access_ok(struct vhost_virtqueue *vq,
>>
>>   int vq_meta_prefetch(struct vhost_virtqueue *vq)
>>   {
>> -       size_t s = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
>>          unsigned int num = vq->num;
>>
>>          if (!vq->iotlb)
>>                  return 1;
>>
>>          return iotlb_access_ok(vq, VHOST_ACCESS_RO, (u64)(uintptr_t)vq->desc,
>> -                              num * sizeof(*vq->desc), VHOST_ADDR_DESC) &&
>> +                              vhost_get_desc_size(vq, num), VHOST_ADDR_DESC) &&
>>                 iotlb_access_ok(vq, VHOST_ACCESS_RO, (u64)(uintptr_t)vq->avail,
>> -                              sizeof *vq->avail +
>> -                              num * sizeof(*vq->avail->ring) + s,
>> +                              vhost_get_avail_size(vq, num),
>>                                 VHOST_ADDR_AVAIL) &&
>>                 iotlb_access_ok(vq, VHOST_ACCESS_WO, (u64)(uintptr_t)vq->used,
>> -                              sizeof *vq->used +
>> -                              num * sizeof(*vq->used->ring) + s,
>> -                              VHOST_ADDR_USED);
>> +                              vhost_get_used_size(vq, num), VHOST_ADDR_USED);
>>   }
>>   EXPORT_SYMBOL_GPL(vq_meta_prefetch);
>>
>> @@ -1343,13 +1356,10 @@ bool vhost_log_access_ok(struct vhost_dev *dev)
>>   static bool vq_log_access_ok(struct vhost_virtqueue *vq,
>>                               void __user *log_base)
>>   {
>> -       size_t s = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
>> -
>>          return vq_memory_access_ok(log_base, vq->umem,
>>                                     vhost_has_feature(vq, VHOST_F_LOG_ALL)) &&
>>                  (!vq->log_used || log_access_ok(log_base, vq->log_addr,
>> -                                       sizeof *vq->used +
>> -                                       vq->num * sizeof *vq->used->ring + s));
>> +                                 vhost_get_used_size(vq, vq->num)));
>>   }
>>
>>   /* Can we start vq? */
>> --
>> 1.8.3.1
>>

