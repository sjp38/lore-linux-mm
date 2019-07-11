Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE525C742A2
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 19:06:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C8F2208E4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 19:06:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C8F2208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88AD78E00F6; Thu, 11 Jul 2019 15:06:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8146F8E00DB; Thu, 11 Jul 2019 15:06:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 668288E00F6; Thu, 11 Jul 2019 15:06:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4251C8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 15:06:45 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id i12so4781106qtq.4
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 12:06:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=oX7L4nWhOkdoDYyyahmbPkew0oBI217xTzLvjnwpnyQ=;
        b=UIybzfS/Hsu98VfK2nMlVTq5VBM/IxjvWqKFxEnYLqE8lIY7spGDs3A5H0PsbiAGnX
         qswXOlhDzNOk478oNUd2Z7vtMHhIhKINhzDeDSOnI9c6pHGqG3VsDMpAWDJUdbZcrG/B
         o1rT1AjSD8nrMqH3kDtHdz1QTAaPGymSrM1PI8whkGKqfMw/G/2CforbM6DJSrlfFNil
         Y/34uRriwzVH+qTQFBIz884eut/uCjkK/1qJNKK3i7tWWjbdX+5EqhPdFigSstSFGGl6
         ChRl2OM0Z9v3PcpfMAm2BzlYv9HhT8sbntxuNUYbMdCUUI3h5MKPvGNa5XdZUiP0rF8h
         hk2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUvAmIebT5ZshKeI972ZvNXjDpCRApCLJ+pZXr+d7elWIKzHf4J
	0161rhtVkAB0GHSZKIkMOnxdTsTDgnku9t4PniLxnZvX8L7AOsjQDkSW7n/KQmLVm53ARxwD656
	dvCo4EhYsc+EyxrouQMaB/+JtTBgiKFRAr5vd1cpwDc2pDJo2iGeLdqhktxPO8rETOw==
X-Received: by 2002:a37:7a84:: with SMTP id v126mr3027804qkc.439.1562872004982;
        Thu, 11 Jul 2019 12:06:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoJaUthOfq03cVIjA+C2n5cEwCMyNJpxbk6UHHVXFrVy4y3QSjxv0r4qqcoe1T+/cwNlue
X-Received: by 2002:a37:7a84:: with SMTP id v126mr3027753qkc.439.1562872004282;
        Thu, 11 Jul 2019 12:06:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562872004; cv=none;
        d=google.com; s=arc-20160816;
        b=RixMeEpaOrsls2Gnyv9usOKyvhuTBpUBjItRoVz4oYbX9rBhDMGtu+6OtZxtz6bASt
         NJmI7HLKEPbMmJxS3Hq9BDx9AYe9yCwNvKKJUBORa0PLnsS39g+0WIL7YEeZre8HDIOS
         LmbT1TVj7AljdYcjLRVJ+NaHtcGHzgFrG9s1bjU4fAYXfeCJhfkbCGif62GP3zSRiWnD
         q7ujzndcnNk3Xk+UArnfUDOUlMvwjfr24jmdXvp1uTPOGtEmE1JbksCk7FFa3ozltROi
         Nq53lke4AIk1UxPdb3yJoAJqYavfk5yXEpxjMRrZ0kfQo4iE+Xke4OaEsjWM5bIRi7NC
         mN7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=oX7L4nWhOkdoDYyyahmbPkew0oBI217xTzLvjnwpnyQ=;
        b=rT0cWcMq85l5vFuKEbVLVA09J+Ua/gYDWuYyCoZCUjYOiV0yRqt67VhU9TFVBCcFmW
         iSq2uFT2R3mDgKxehRAmQxAHRakUbKGwg1CUEzzWp+huALYpWSqLKS8ytd1GQSQj7pf7
         8VQ38zioB/zgBaV+x6av/P9bisaqplgf0npAsXiiPK0vGHKI6IlivbsyleeemnASWwdn
         xe3x6MVP7gpC91VF/mE+rOIbpPxYHSrIzl7RGkA26b6WZUKlzSE5E1SEP/TywV66SVl0
         zo6YANu5EQkxm7Je3xyXRaSc6/h3vdojdNNaWAJyu7eNyrSt4OoTzsOXIVAsI+9bks3N
         nUqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q3si3704621qte.268.2019.07.11.12.06.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 12:06:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4FEE04E90E;
	Thu, 11 Jul 2019 19:06:43 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3209360A97;
	Thu, 11 Jul 2019 19:06:34 +0000 (UTC)
Subject: Re: [QEMU Patch] virtio-baloon: Support for page hinting
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
 wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
 david@redhat.com, dodgen@google.com, konrad.wilk@oracle.com,
 dhildenb@redhat.com, aarcange@redhat.com, alexander.duyck@gmail.com,
 john.starks@microsoft.com, dave.hansen@intel.com, mhocko@suse.com
References: <20190710195158.19640-1-nitesh@redhat.com>
 <20190710195303.19690-1-nitesh@redhat.com>
 <20190711141036-mutt-send-email-mst@kernel.org>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <00f4d486-e4e8-c796-5b4f-c0e8b6b74dc2@redhat.com>
Date: Thu, 11 Jul 2019 15:06:32 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190711141036-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 11 Jul 2019 19:06:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/11/19 2:55 PM, Michael S. Tsirkin wrote:
> On Wed, Jul 10, 2019 at 03:53:03PM -0400, Nitesh Narayan Lal wrote:
>> Enables QEMU to perform madvise free on the memory range reported
>> by the vm.
>>
>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> Missing second "l" in the subject :)
>
>> ---
>>  hw/virtio/trace-events                        |  1 +
>>  hw/virtio/virtio-balloon.c                    | 59 ++++++++++++++++++=
+
>>  include/hw/virtio/virtio-balloon.h            |  2 +-
>>  include/qemu/osdep.h                          |  7 +++
>>  .../standard-headers/linux/virtio_balloon.h   |  1 +
>>  5 files changed, 69 insertions(+), 1 deletion(-)
>>
>> diff --git a/hw/virtio/trace-events b/hw/virtio/trace-events
>> index e28ba48da6..f703a22d36 100644
>> --- a/hw/virtio/trace-events
>> +++ b/hw/virtio/trace-events
>> @@ -46,6 +46,7 @@ virtio_balloon_handle_output(const char *name, uint6=
4_t gpa) "section name: %s g
>>  virtio_balloon_get_config(uint32_t num_pages, uint32_t actual) "num_p=
ages: %d actual: %d"
>>  virtio_balloon_set_config(uint32_t actual, uint32_t oldactual) "actua=
l: %d oldactual: %d"
>>  virtio_balloon_to_target(uint64_t target, uint32_t num_pages) "balloo=
n target: 0x%"PRIx64" num_pages: %d"
>> +virtio_balloon_hinting_request(unsigned long pfn, unsigned int num_pa=
ges) "Guest page hinting request PFN:%lu size: %d"
>> =20
>>  # virtio-mmio.c
>>  virtio_mmio_read(uint64_t offset) "virtio_mmio_read offset 0x%" PRIx6=
4
>> diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
>> index 2112874055..5d186707b5 100644
>> --- a/hw/virtio/virtio-balloon.c
>> +++ b/hw/virtio/virtio-balloon.c
>> @@ -34,6 +34,9 @@
>> =20
>>  #define BALLOON_PAGE_SIZE  (1 << VIRTIO_BALLOON_PFN_SHIFT)
>> =20
>> +#define VIRTIO_BALLOON_PAGE_HINTING_MAX_PAGES	16
>> +void free_mem_range(uint64_t addr, uint64_t len);
>> +
>>  struct PartiallyBalloonedPage {
>>      RAMBlock *rb;
>>      ram_addr_t base;
>> @@ -328,6 +331,58 @@ static void balloon_stats_set_poll_interval(Objec=
t *obj, Visitor *v,
>>      balloon_stats_change_timer(s, 0);
>>  }
>> =20
>> +void free_mem_range(uint64_t addr, uint64_t len)
>> +{
>> +    int ret =3D 0;
>> +    void *hvaddr_to_free;
>> +    MemoryRegionSection mrs =3D memory_region_find(get_system_memory(=
),
>> +                                                 addr, 1);
>> +    if (!mrs.mr) {
>> +	warn_report("%s:No memory is mapped at address 0x%lu", __func__, add=
r);
>> +        return;
>> +    }
>> +
>> +    if (!memory_region_is_ram(mrs.mr) && !memory_region_is_romd(mrs.m=
r)) {
>> +	warn_report("%s:Memory at address 0x%s is not RAM:0x%lu", __func__,
>> +		    HWADDR_PRIx, addr);
>> +        memory_region_unref(mrs.mr);
>> +        return;
>> +    }
>> +
>> +    hvaddr_to_free =3D qemu_map_ram_ptr(mrs.mr->ram_block, mrs.offset=
_within_region);
>> +    trace_virtio_balloon_hinting_request(addr, len);
>> +    ret =3D qemu_madvise(hvaddr_to_free,len, QEMU_MADV_FREE);
>> +    if (ret =3D=3D -1) {
>> +	warn_report("%s: Madvise failed with error:%d", __func__, ret);
>> +    }
>> +}
>> +
>> +static void virtio_balloon_handle_page_hinting(VirtIODevice *vdev,
>> +					       VirtQueue *vq)
>> +{
>> +    VirtQueueElement *elem;
>> +    size_t offset =3D 0;
>> +    uint64_t gpa, len;
>> +    elem =3D virtqueue_pop(vq, sizeof(VirtQueueElement));
>> +    if (!elem) {
>> +        return;
>> +    }
>> +    /* For pending hints which are < max_pages(16), 'gpa !=3D 0' ensu=
res that we
>> +     * only read the buffer which holds a valid PFN value.
>> +     * TODO: Find a better way to do this.
> Indeed. In fact, what is wrong with passing the gpa as
> part of the element itself?
There are two values which I need to read 'gpa' and 'len'. I will have
to check how to pass them both as part of the element.
But, I will look into it.
>> +     */
>> +    while (iov_to_buf(elem->out_sg, elem->out_num, offset, &gpa, 8) =3D=
=3D 8 && gpa !=3D 0) {
>> +	offset +=3D 8;
>> +	offset +=3D iov_to_buf(elem->out_sg, elem->out_num, offset, &len, 8)=
;
>> +	if (!qemu_balloon_is_inhibited()) {
>> +	    free_mem_range(gpa, len);
>> +	}
>> +    }
>> +    virtqueue_push(vq, elem, offset);
>> +    virtio_notify(vdev, vq);
>> +    g_free(elem);
>> +}
>> +
>>  static void virtio_balloon_handle_output(VirtIODevice *vdev, VirtQueu=
e *vq)
>>  {
>>      VirtIOBalloon *s =3D VIRTIO_BALLOON(vdev);
>> @@ -694,6 +749,7 @@ static uint64_t virtio_balloon_get_features(VirtIO=
Device *vdev, uint64_t f,
>>      VirtIOBalloon *dev =3D VIRTIO_BALLOON(vdev);
>>      f |=3D dev->host_features;
>>      virtio_add_feature(&f, VIRTIO_BALLOON_F_STATS_VQ);
>> +    virtio_add_feature(&f, VIRTIO_BALLOON_F_HINTING);
>> =20
>>      return f;
>>  }
>> @@ -780,6 +836,7 @@ static void virtio_balloon_device_realize(DeviceSt=
ate *dev, Error **errp)
>>      s->ivq =3D virtio_add_queue(vdev, 128, virtio_balloon_handle_outp=
ut);
>>      s->dvq =3D virtio_add_queue(vdev, 128, virtio_balloon_handle_outp=
ut);
>>      s->svq =3D virtio_add_queue(vdev, 128, virtio_balloon_receive_sta=
ts);
>> +    s->hvq =3D virtio_add_queue(vdev, 128, virtio_balloon_handle_page=
_hinting);
>> =20
>>      if (virtio_has_feature(s->host_features,
>>                             VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
>> @@ -875,6 +932,8 @@ static void virtio_balloon_instance_init(Object *o=
bj)
>> =20
>>      object_property_add(obj, "guest-stats", "guest statistics",
>>                          balloon_stats_get_all, NULL, NULL, s, NULL);
>> +    object_property_add(obj, "guest-page-hinting", "guest page hintin=
g",
>> +                        NULL, NULL, NULL, s, NULL);
>> =20
>>      object_property_add(obj, "guest-stats-polling-interval", "int",
>>                          balloon_stats_get_poll_interval,
>> diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/vi=
rtio-balloon.h
>> index 1afafb12f6..a58b24fdf2 100644
>> --- a/include/hw/virtio/virtio-balloon.h
>> +++ b/include/hw/virtio/virtio-balloon.h
>> @@ -44,7 +44,7 @@ enum virtio_balloon_free_page_report_status {
>> =20
>>  typedef struct VirtIOBalloon {
>>      VirtIODevice parent_obj;
>> -    VirtQueue *ivq, *dvq, *svq, *free_page_vq;
>> +    VirtQueue *ivq, *dvq, *svq, *free_page_vq, *hvq;
>>      uint32_t free_page_report_status;
>>      uint32_t num_pages;
>>      uint32_t actual;
>> diff --git a/include/qemu/osdep.h b/include/qemu/osdep.h
>> index af2b91f0b8..bb9207e7f4 100644
>> --- a/include/qemu/osdep.h
>> +++ b/include/qemu/osdep.h
>> @@ -360,6 +360,11 @@ void qemu_anon_ram_free(void *ptr, size_t size);
>>  #else
>>  #define QEMU_MADV_REMOVE QEMU_MADV_INVALID
>>  #endif
>> +#ifdef MADV_FREE
>> +#define QEMU_MADV_FREE MADV_FREE
>> +#else
>> +#define QEMU_MADV_FREE QEMU_MADV_INVALID
>> +#endif
>> =20
>>  #elif defined(CONFIG_POSIX_MADVISE)
>> =20
>> @@ -373,6 +378,7 @@ void qemu_anon_ram_free(void *ptr, size_t size);
>>  #define QEMU_MADV_HUGEPAGE  QEMU_MADV_INVALID
>>  #define QEMU_MADV_NOHUGEPAGE  QEMU_MADV_INVALID
>>  #define QEMU_MADV_REMOVE QEMU_MADV_INVALID
>> +#define QEMU_MADV_FREE QEMU_MADV_INVALID
>> =20
>>  #else /* no-op */
>> =20
>> @@ -386,6 +392,7 @@ void qemu_anon_ram_free(void *ptr, size_t size);
>>  #define QEMU_MADV_HUGEPAGE  QEMU_MADV_INVALID
>>  #define QEMU_MADV_NOHUGEPAGE  QEMU_MADV_INVALID
>>  #define QEMU_MADV_REMOVE QEMU_MADV_INVALID
>> +#define QEMU_MADV_FREE QEMU_MADV_INVALID
>> =20
>>  #endif
>> =20
>> diff --git a/include/standard-headers/linux/virtio_balloon.h b/include=
/standard-headers/linux/virtio_balloon.h
>> index 9375ca2a70..f9e3e82562 100644
>> --- a/include/standard-headers/linux/virtio_balloon.h
>> +++ b/include/standard-headers/linux/virtio_balloon.h
>> @@ -36,6 +36,7 @@
>>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM *=
/
>>  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages =
*/
>>  #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoni=
ng */
>> +#define VIRTIO_BALLOON_F_HINTING	5 /* Page hinting virtqueue */
>> =20
>>  /* Size of a PFN in the balloon interface. */
>>  #define VIRTIO_BALLOON_PFN_SHIFT 12
>> --=20
>> 2.21.0
--=20
Thanks
Nitesh

