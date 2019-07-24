Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1BDCC76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:56:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80F5E205C9
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:56:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80F5E205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 064E16B0007; Wed, 24 Jul 2019 15:56:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F311B6B0008; Wed, 24 Jul 2019 15:56:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD0208E0002; Wed, 24 Jul 2019 15:56:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1D9D6B0007
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:56:57 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id o202so20778350vko.16
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:56:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=UTQ1Tb9Sza6noSGSJr3ICyN6eib7q7f/W762etL2prE=;
        b=kpw+A3YPhjQT6PmDcQy/E+AuulMUY1pHAuuGJqBnpMY6o2P4FeyxTZixeuz3MBMReQ
         SAvmyFQnI2k/TbGH5t3GdkvX84a36p44+kMaZ6VVtBzSg6UAmdmsYHOiizUsu4vEaxmM
         p7VackQsKeMnjDDfeAKz2NG4CKkz1KI3DuR81kc2/Kb8LibnUQ2TmAMUc1fwyTgm5J1h
         d/cKcIdQiceBZwdpJJq9NOnA6FhUqg0vSRBztaw2ZOX5ynsU3858qWihvC2ArxuGPNPd
         XClgiWW/QolOsp0qpO9g6bsiQVF4YaWvfXZ2/3xxLdfBpwMiqJAr+hyHa60TvjQEmUij
         Fa0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVjSARZXvGSjqedAYU3w3Cy4cpTiUQgw/lvXNE4HCmrDTk0rhB1
	76XQWNXXz54t619kcFmHtknz53hbIHQGNuJDN8CmdeUOhwiXF7GEE0/ehK8bOJlhWvoW0LvoqBR
	Y8IhgRp+WFRwQ6Wb+E9QUS4qK81F7ckjW/uA2cx6seO+sYYL1CyHFVVVI8anHLwqrYw==
X-Received: by 2002:ab0:7848:: with SMTP id y8mr35549410uaq.58.1563998217416;
        Wed, 24 Jul 2019 12:56:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZWxG3l8AtNUrmh6diOaV5mtYHnGcZZeGKHjKmDzHgNdxcuwJ5VNb55Cw+bXaR+iK2UJ4j
X-Received: by 2002:ab0:7848:: with SMTP id y8mr35549332uaq.58.1563998216765;
        Wed, 24 Jul 2019 12:56:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563998216; cv=none;
        d=google.com; s=arc-20160816;
        b=NZjlFCVZdhicQXYR0452K4w8BPO5RoWU46LM0SkDqhIsLCeIe68UFNsFjFmKAk1KhR
         6pPL/hfzrAA96QKUwZ39fDTADbNX8z3KkgZaohdEmW5aTlBHcW+5jzBfcUejAXhYt+in
         eWRGeN9omv52tN9WfRhKZ6IWVcKIOHHmo/w87z9aADOPNt5yWIf5b6r8cUgvDrSQBc9j
         IjgI5sMewNA/J499kIsbMjHXIb5Y48OIE3rOwUGsjeYj8Cnhq9a8q+1qxeQx4PRwnk/H
         FxFyxU+5ckE9TLq3FRXpCEsIh3CxfpiirRiScwAG11CMfDF20Jjjfe/Qgy8B6LDEg2nV
         dC3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=UTQ1Tb9Sza6noSGSJr3ICyN6eib7q7f/W762etL2prE=;
        b=d1m6Iqz3bbA6GhDECgXqCCtMFErEG5AYUsEsw1xYQVYCIeLBn2OrdLE2TNujELahwq
         x05uK54iFvXVj6X0n5MsE4yESmtXtPsjyw7HgiWa7a5GrQyWx2VcQvQFCz7CEd84tUge
         OtEiL/kuT4pW7G44zLot+YBHnOj9JHppfR7o+iZgWyDzroAcsdCDmP8gzIpUBYMCRXLM
         JlZZ8ncLyiTa2Wv6V+73fpe/Zh3+/46EYtRlMYzmLo5fGk1oBTk5zEQ7uZV1Xp4vNZAA
         lwq+AuUcV4zMullK28vOVZq2TMacLFfSBkoS+mrB3VCpEYxtVGVQ61ql3KGOE1gL7zAU
         pY+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 4si18296957uat.189.2019.07.24.12.56.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 12:56:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D582A330272;
	Wed, 24 Jul 2019 19:56:55 +0000 (UTC)
Received: from [10.36.116.35] (ovpn-116-35.ams2.redhat.com [10.36.116.35])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E7AFB605C3;
	Wed, 24 Jul 2019 19:56:44 +0000 (UTC)
Subject: Re: [RFC][Patch v11 2/2] virtio-balloon: page_hinting: reporting to
 the host
To: "Michael S. Tsirkin" <mst@redhat.com>,
 Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
 wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
 dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
 aarcange@redhat.com, alexander.duyck@gmail.com, john.starks@microsoft.com,
 dave.hansen@intel.com, mhocko@suse.com
References: <20190710195158.19640-1-nitesh@redhat.com>
 <20190710195158.19640-3-nitesh@redhat.com>
 <20190724153951-mutt-send-email-mst@kernel.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <d4f827a5-7914-4f8c-932e-91ef173b65d0@redhat.com>
Date: Wed, 24 Jul 2019 21:56:44 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190724153951-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 24 Jul 2019 19:56:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 24.07.19 21:47, Michael S. Tsirkin wrote:
> On Wed, Jul 10, 2019 at 03:51:58PM -0400, Nitesh Narayan Lal wrote:
>> Enables the kernel to negotiate VIRTIO_BALLOON_F_HINTING feature with the
>> host. If it is available and page_hinting_flag is set to true, page_hinting
>> is enabled and its callbacks are configured along with the max_pages count
>> which indicates the maximum number of pages that can be isolated and hinted
>> at a time. Currently, only free pages of order >= (MAX_ORDER - 2) are
>> reported. To prevent any false OOM max_pages count is set to 16.
>>
>> By default page_hinting feature is enabled and gets loaded as soon
>> as the virtio-balloon driver is loaded. However, it could be disabled
>> by writing the page_hinting_flag which is a virtio-balloon parameter.
>>
>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
>> ---
>>  drivers/virtio/Kconfig              |  1 +
>>  drivers/virtio/virtio_balloon.c     | 91 ++++++++++++++++++++++++++++-
>>  include/uapi/linux/virtio_balloon.h | 11 ++++
>>  3 files changed, 102 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
>> index 023fc3bc01c6..dcc0cb4269a5 100644
>> --- a/drivers/virtio/Kconfig
>> +++ b/drivers/virtio/Kconfig
>> @@ -47,6 +47,7 @@ config VIRTIO_BALLOON
>>  	tristate "Virtio balloon driver"
>>  	depends on VIRTIO
>>  	select MEMORY_BALLOON
>> +	select PAGE_HINTING
>>  	---help---
>>  	 This driver supports increasing and decreasing the amount
>>  	 of memory within a KVM guest.
>> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
>> index 44339fc87cc7..1fb0eb0b2c20 100644
>> --- a/drivers/virtio/virtio_balloon.c
>> +++ b/drivers/virtio/virtio_balloon.c
>> @@ -18,6 +18,7 @@
>>  #include <linux/mm.h>
>>  #include <linux/mount.h>
>>  #include <linux/magic.h>
>> +#include <linux/page_hinting.h>
>>  
>>  /*
>>   * Balloon device works in 4K page units.  So each page is pointed to by
>> @@ -35,6 +36,12 @@
>>  /* The size of a free page block in bytes */
>>  #define VIRTIO_BALLOON_FREE_PAGE_SIZE \
>>  	(1 << (VIRTIO_BALLOON_FREE_PAGE_ORDER + PAGE_SHIFT))
>> +/* Number of isolated pages to be reported to the host at a time.
>> + * TODO:
>> + * 1. Set it via host.
>> + * 2. Find an optimal value for this.
>> + */
>> +#define PAGE_HINTING_MAX_PAGES	16
>>  
>>  #ifdef CONFIG_BALLOON_COMPACTION
>>  static struct vfsmount *balloon_mnt;
>> @@ -45,6 +52,7 @@ enum virtio_balloon_vq {
>>  	VIRTIO_BALLOON_VQ_DEFLATE,
>>  	VIRTIO_BALLOON_VQ_STATS,
>>  	VIRTIO_BALLOON_VQ_FREE_PAGE,
>> +	VIRTIO_BALLOON_VQ_HINTING,
>>  	VIRTIO_BALLOON_VQ_MAX
>>  };
>>  
>> @@ -54,7 +62,8 @@ enum virtio_balloon_config_read {
>>  
>>  struct virtio_balloon {
>>  	struct virtio_device *vdev;
>> -	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq;
>> +	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq,
>> +			 *hinting_vq;
>>  
>>  	/* Balloon's own wq for cpu-intensive work items */
>>  	struct workqueue_struct *balloon_wq;
>> @@ -112,6 +121,9 @@ struct virtio_balloon {
>>  
>>  	/* To register a shrinker to shrink memory upon memory pressure */
>>  	struct shrinker shrinker;
>> +
>> +	/* Array object pointing at the isolated pages ready for hinting */
>> +	struct isolated_memory isolated_pages[PAGE_HINTING_MAX_PAGES];
>>  };
>>  
>>  static struct virtio_device_id id_table[] = {
>> @@ -119,6 +131,66 @@ static struct virtio_device_id id_table[] = {
>>  	{ 0 },
>>  };
>>  
>> +static struct page_hinting_config page_hinting_conf;
>> +bool page_hinting_flag = true;
>> +struct virtio_balloon *hvb;
>> +module_param(page_hinting_flag, bool, 0444);
>> +MODULE_PARM_DESC(page_hinting_flag, "Enable page hinting");
>> +
>> +static int page_hinting_report(void)
>> +{
>> +	struct virtqueue *vq = hvb->hinting_vq;
>> +	struct scatterlist sg;
>> +	int err = 0, unused;
>> +
>> +	mutex_lock(&hvb->balloon_lock);
>> +	sg_init_one(&sg, hvb->isolated_pages, sizeof(hvb->isolated_pages[0]) *
>> +		    PAGE_HINTING_MAX_PAGES);
>> +	err = virtqueue_add_outbuf(vq, &sg, 1, hvb, GFP_KERNEL);
> 
> In Alex's patch, I really like it that he's passing pages as sg
> entries. IMHO that's both cleaner and allows seamless
> support for arbitrary page sizes.
> 

+1

I especially like passing full addresses and sizes instead of PFNs and
orders (compared to Alex's v1, where he would pass PFNs and orders).

-- 

Thanks,

David / dhildenb

