Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A365C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:07:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 302C8218F0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:07:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 302C8218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFABB8E0007; Wed, 24 Jul 2019 15:07:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BABB88E0003; Wed, 24 Jul 2019 15:07:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A72C68E0007; Wed, 24 Jul 2019 15:07:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 83F4C8E0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:07:51 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x1so42428606qts.9
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:07:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=zd3Q/REwrsjKyut/24WFfZ5FoH0hUV4zjUzh2fjQPzw=;
        b=k/s0aEO4Of5z/Cmv70MFHm6iEv2ENbyZdieUwvhCEh76V+qMuvP/npI+B1OQBLyeg1
         /Cfw65UYxZWvDFtkE6txQidcPLt5bEk9qnlZRa25AK6k0mUiKxwthc9UnTOeJdgj1rmB
         xOJgCaum/hgooAYALhjMg3LS70wtVVPuPVHsjPqjI8pRXhKyOyodDKD7TH0MqRZT/fkU
         8RuGxqwaBxMdjyq37jj1zAsr8gGzmdktGZ/bJI5wSsHtJHNLMvqT91PUCTATin+0QJop
         keQnFjYW7KKS3Nq5cNiG7/MnRWqfdXGctpGWrBjUt1qEdaSNNc49oYs3HjVrRRROgVC0
         66wA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVIpsaWCbitbLw60IbCUvo7ZhqNOn0F/oH48ozSW2Fj4sohlSnA
	f5tCbAhDAr47ZosQk0oYFEKodAwdVS4eGrR7fr3fXnBSz5GallF06P9ZYvsHKv/dbl7q/tWrSMO
	lJ5N62ekT5Lpqx1mcAxVSupLy0iYdFGkBnLCRqevmiigwWWujWue7NTDP0IBybL6H7w==
X-Received: by 2002:a0c:fb01:: with SMTP id c1mr59676025qvp.122.1563995271288;
        Wed, 24 Jul 2019 12:07:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4TSAWJqUtX20FTKDfSTxBWbsHKuOcI34T+clhW2Tup/13JVLs2yJBR3Fcd8jZ4h7IiYKS
X-Received: by 2002:a0c:fb01:: with SMTP id c1mr59675966qvp.122.1563995270564;
        Wed, 24 Jul 2019 12:07:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563995270; cv=none;
        d=google.com; s=arc-20160816;
        b=ByoIt2++ca2+Jl6C7wi2+c1fb3Sou1nuZCCz2iTVDdKZbEPlgI6d9lJekqGVUoRN/W
         4CNujOgdTLONAqapOfq0G2gOGUEN6dSEeP0PdbMe8RoGTv4ja+c0B/7Dy7ccKdJZWDEV
         eKDdoGw35DZqsjN1S5kc2sNuf4oyPqv4UVfSTdZn0VeU/bqa7NkcfFTdKTBWVXlvtrmB
         Jwt/99A837Osz5eR+PQPVTZoIUDzrnXKtUVL0YtbUKjj50r/Qn0hxH61q+s6sRZS635B
         b54d3XRiic2hdTe48aEoF2Cn+3jMpZvMlcBeeXol2mRdr2raX3ezNNnS7eHV5EEseB6c
         6vig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=zd3Q/REwrsjKyut/24WFfZ5FoH0hUV4zjUzh2fjQPzw=;
        b=TzFdu9XJzvSVYHMCkjMADnwEpYzbO/Gm+PUgYlwsIzCT2Fg+6Kp3dyJHSjWQUiHQnp
         +i9lmSyQOO9ylRnaHk3NfQCvq0veSn5bp4XOM77dCh/KjLJZPu91zkWth0AiE9zoHWYB
         KqddTlGQMWtLc65MzChHf8TnIrnIYl0RZSGmb5e31BaOof6VQqDSxGv9+tjPLwpc6vpW
         BfLXobsfMwenCp8LNsxz1b9ysSpaAKEDWPOuegbzhT6wRyVqaW9jRoKBfaNe1RXd4mav
         ceboy9Nws0KdUEzxGFdDgKBZnHUmsCTld8I87Qf7QX6oYuIXVYVROy/e2qa5id9PIEsj
         vFdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i63si27263286qtb.366.2019.07.24.12.07.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 12:07:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A85DA81F2F;
	Wed, 24 Jul 2019 19:07:49 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 385AC5D71C;
	Wed, 24 Jul 2019 19:07:43 +0000 (UTC)
Subject: Re: [PATCH v2 5/5] virtio-balloon: Add support for providing page
 hints to host
To: "Michael S. Tsirkin" <mst@redhat.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm@vger.kernel.org, david@redhat.com, dave.hansen@intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724170514.6685.17161.stgit@localhost.localdomain>
 <20190724143902-mutt-send-email-mst@kernel.org>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <33e41a02-7a9c-f166-8eb3-50abacb9d2cc@redhat.com>
Date: Wed, 24 Jul 2019 15:07:42 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190724143902-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 24 Jul 2019 19:07:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/24/19 3:02 PM, Michael S. Tsirkin wrote:
> On Wed, Jul 24, 2019 at 10:05:14AM -0700, Alexander Duyck wrote:
>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>
>> Add support for the page hinting feature provided by virtio-balloon.
>> Hinting differs from the regular balloon functionality in that is is
>> much less durable than a standard memory balloon. Instead of creating a
>> list of pages that cannot be accessed the pages are only inaccessible
>> while they are being indicated to the virtio interface. Once the
>> interface has acknowledged them they are placed back into their respective
>> free lists and are once again accessible by the guest system.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> Looking at the design, it seems that hinted pages can immediately be
> reused. I wonder how we can efficiently support this
> with kvm when poisoning is in effect. Of course we can just
> ignore the poison. However it seems cleaner to
> 1. verify page is poisoned with the correct value
> 2. fill the page with the correct value on fault
Once VIRTIO_BALLOON_F_PAGE_POISON user side support is available.
Can't we just use that at the time of initialization?
> Requirement 2 requires some kind of madvise that
> will save the poison e.g. in the VMA.
>
> Not a blocker for sure ... 
>
>
>> ---
>>  drivers/virtio/Kconfig              |    1 +
>>  drivers/virtio/virtio_balloon.c     |   47 +++++++++++++++++++++++++++++++++++
>>  include/uapi/linux/virtio_balloon.h |    1 +
>>  3 files changed, 49 insertions(+)
>>
>> diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
>> index 078615cf2afc..d45556ae1f81 100644
>> --- a/drivers/virtio/Kconfig
>> +++ b/drivers/virtio/Kconfig
>> @@ -58,6 +58,7 @@ config VIRTIO_BALLOON
>>  	tristate "Virtio balloon driver"
>>  	depends on VIRTIO
>>  	select MEMORY_BALLOON
>> +	select PAGE_HINTING
>>  	---help---
>>  	 This driver supports increasing and decreasing the amount
>>  	 of memory within a KVM guest.
>> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
>> index 226fbb995fb0..dee9f8f3ad09 100644
>> --- a/drivers/virtio/virtio_balloon.c
>> +++ b/drivers/virtio/virtio_balloon.c
>> @@ -19,6 +19,7 @@
>>  #include <linux/mount.h>
>>  #include <linux/magic.h>
>>  #include <linux/pseudo_fs.h>
>> +#include <linux/page_hinting.h>
>>  
>>  /*
>>   * Balloon device works in 4K page units.  So each page is pointed to by
>> @@ -27,6 +28,7 @@
>>   */
>>  #define VIRTIO_BALLOON_PAGES_PER_PAGE (unsigned)(PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
>>  #define VIRTIO_BALLOON_ARRAY_PFNS_MAX 256
>> +#define VIRTIO_BALLOON_ARRAY_HINTS_MAX	32
>>  #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
>>  
>>  #define VIRTIO_BALLOON_FREE_PAGE_ALLOC_FLAG (__GFP_NORETRY | __GFP_NOWARN | \
>> @@ -46,6 +48,7 @@ enum virtio_balloon_vq {
>>  	VIRTIO_BALLOON_VQ_DEFLATE,
>>  	VIRTIO_BALLOON_VQ_STATS,
>>  	VIRTIO_BALLOON_VQ_FREE_PAGE,
>> +	VIRTIO_BALLOON_VQ_HINTING,
>>  	VIRTIO_BALLOON_VQ_MAX
>>  };
>>  
>> @@ -113,6 +116,10 @@ struct virtio_balloon {
>>  
>>  	/* To register a shrinker to shrink memory upon memory pressure */
>>  	struct shrinker shrinker;
>> +
>> +	/* Unused page hinting device */
>> +	struct virtqueue *hinting_vq;
>> +	struct page_hinting_dev_info ph_dev_info;
>>  };
>>  
>>  static struct virtio_device_id id_table[] = {
>> @@ -152,6 +159,22 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
>>  
>>  }
>>  
>> +void virtballoon_page_hinting_react(struct page_hinting_dev_info *ph_dev_info,
>> +				    unsigned int num_hints)
>> +{
>> +	struct virtio_balloon *vb =
>> +		container_of(ph_dev_info, struct virtio_balloon, ph_dev_info);
>> +	struct virtqueue *vq = vb->hinting_vq;
>> +	unsigned int unused;
>> +
>> +	/* We should always be able to add these buffers to an empty queue. */
>
> can be an out of memory condition, and then ...
>
>> +	virtqueue_add_inbuf(vq, ph_dev_info->sg, num_hints, vb, GFP_KERNEL);
>> +	virtqueue_kick(vq);
> ... this will block forever.
>
>> +	/* When host has read buffer, this completes via balloon_ack */
>> +	wait_event(vb->acked, virtqueue_get_buf(vq, &unused));
> However below I suggest limiting capacity which will solve
> this problem for you.
>
>
>
>> +}
>> +
>>  static void set_page_pfns(struct virtio_balloon *vb,
>>  			  __virtio32 pfns[], struct page *page)
>>  {
>> @@ -476,6 +499,7 @@ static int init_vqs(struct virtio_balloon *vb)
>>  	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
>>  	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
>>  	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
>> +	names[VIRTIO_BALLOON_VQ_HINTING] = NULL;
>>  
>>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
>>  		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
>> @@ -487,11 +511,19 @@ static int init_vqs(struct virtio_balloon *vb)
>>  		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
>>  	}
>>  
>> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
>> +		names[VIRTIO_BALLOON_VQ_HINTING] = "hinting_vq";
>> +		callbacks[VIRTIO_BALLOON_VQ_HINTING] = balloon_ack;
>> +	}
>> +
>>  	err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
>>  					 vqs, callbacks, names, NULL, NULL);
>>  	if (err)
>>  		return err;
>>  
>> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
>> +		vb->hinting_vq = vqs[VIRTIO_BALLOON_VQ_HINTING];
>> +
>>  	vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
>>  	vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
>>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
>> @@ -924,12 +956,24 @@ static int virtballoon_probe(struct virtio_device *vdev)
>>  		if (err)
>>  			goto out_del_balloon_wq;
>>  	}
>> +
>> +	vb->ph_dev_info.react = virtballoon_page_hinting_react;
>> +	vb->ph_dev_info.capacity = VIRTIO_BALLOON_ARRAY_HINTS_MAX;
> As explained above I think you should limit this by vq size.
> Otherwise virtqueue add buf might fail.
> In fact by struct spec reading you need to limit it
> anyway otherwise it will fail unconditionally.
> In practice on most hypervisors it will typically work ...
>
>> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
>> +		err = page_hinting_startup(&vb->ph_dev_info);
>> +		if (err)
>> +			goto out_unregister_shrinker;
>> +	}
>> +
>>  	virtio_device_ready(vdev);
>>  
>>  	if (towards_target(vb))
>>  		virtballoon_changed(vdev);
>>  	return 0;
>>  
>> +out_unregister_shrinker:
>> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
>> +		virtio_balloon_unregister_shrinker(vb);
>>  out_del_balloon_wq:
>>  	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
>>  		destroy_workqueue(vb->balloon_wq);
>> @@ -958,6 +1002,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
>>  {
>>  	struct virtio_balloon *vb = vdev->priv;
>>  
>> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
>> +		page_hinting_shutdown(&vb->ph_dev_info);
>>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
>>  		virtio_balloon_unregister_shrinker(vb);
>>  	spin_lock_irq(&vb->stop_update_lock);
>> @@ -1027,6 +1073,7 @@ static int virtballoon_validate(struct virtio_device *vdev)
>>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
>>  	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
>>  	VIRTIO_BALLOON_F_PAGE_POISON,
>> +	VIRTIO_BALLOON_F_HINTING,
>>  };
>>  
>>  static struct virtio_driver virtio_balloon_driver = {
>> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
>> index a1966cd7b677..2b0f62814e22 100644
>> --- a/include/uapi/linux/virtio_balloon.h
>> +++ b/include/uapi/linux/virtio_balloon.h
>> @@ -36,6 +36,7 @@
>>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
>>  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
>>  #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
>> +#define VIRTIO_BALLOON_F_HINTING	5 /* Page hinting virtqueue */
>>  
>>  /* Size of a PFN in the balloon interface. */
>>  #define VIRTIO_BALLOON_PFN_SHIFT 12
-- 
Thanks
Nitesh

