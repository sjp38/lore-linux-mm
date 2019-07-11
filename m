Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED8D0C74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 11:13:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9039121019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 11:13:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9039121019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1E658E00B4; Thu, 11 Jul 2019 07:13:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC6E88E0032; Thu, 11 Jul 2019 07:13:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D215C8E00B4; Thu, 11 Jul 2019 07:13:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF1288E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:13:40 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id v9so987729vsq.7
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 04:13:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=Pi1hz/ZvuBkD63pxBMuavYKnog49zRy+A/6g2DK+I9c=;
        b=V96Ooo/XbptzoD3q5aO3VoKJJcAJ4PgeCcDQO+N5Gn2O7MEV0xR6cgP4gcNTfswb3m
         LJmqwCsjsQT8KayObvZlJHzdC1U4d92LjpamdI7NJN6nsa8Hb4Bw9Ztri43KfmiFkr4H
         XboA2jqqZpHSwn1uqse1jqUS54u94W53/im9RjTzlPdXl15ZuJqa/ICKyq+tIfAFbsl2
         Rgiplu7e+68Ugu1Z1lpv/7/iE/fXYQvYX05Oamlc4RbuN0YyUNyEhFPXSu8qpVL85tfp
         h4Vcr0lHp0g9p48cW9IxvUmTUB7CS9TIG6aSEYqQE0ou6GeKduvBfGwL7vRG731oEPXT
         KigA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXZyL2EqkhkOr79KAa37ct+0S9rGDdjVA/RnAS/LhabyYzoT322
	bBUyh7VE3UCR4G/pA004utrOhMfBjLlf2oBLC7UjVMJJwEQuHzRwd6r6Nl1iTfQ97rIQkfpfvm7
	YQPfR4YgExTF1pdqRgy0o1Rw6r/EgqT14dV1CLAmzRNG5C8o0JnQsM2dYIOADHb89Wg==
X-Received: by 2002:a1f:4e87:: with SMTP id c129mr2363413vkb.56.1562843620327;
        Thu, 11 Jul 2019 04:13:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjEHgVll1Lg/ODJtMgHtDB+8nxdhosJXKRW5K2lngAMpDKwYWInrTTmlUuU93ISws5gzPD
X-Received: by 2002:a1f:4e87:: with SMTP id c129mr2363326vkb.56.1562843619392;
        Thu, 11 Jul 2019 04:13:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562843619; cv=none;
        d=google.com; s=arc-20160816;
        b=hsU6BY4/7tMux/+JLUPA3EIgTDlOvZh7ByX4bVTQ1214bZ1i+jZsS8QjcWYn9eybZ/
         wTF0whgrTXO0JEw6hft0s6H+tAYBi3G+LEfeJ+LfDn+H1RoM8bq4QZ/Q1JvIGriAOBil
         QgA9o4jw7FOvdb2ZPgg7QxghUoYK957jBo10cSiTQFZsaVGsWRofjwjJWosia2h5dxy8
         WFb5WOSK/QpE4dK/JKdKYIGhYCI7pwnOl9sgn19LQfdoSRlZwYo8w5VuOdOjI3LBz44F
         8yabELWMQ0qHQwxcqbfdFAY6Z0TtG5ycPdyfn4WtJKPZr2bzjelW8t7avL/DR7Rcqu/y
         /Hiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Pi1hz/ZvuBkD63pxBMuavYKnog49zRy+A/6g2DK+I9c=;
        b=HPZUAz2W0sfghu+huC9LGze0yT9A4ElwjiP/GDv8XiX1Gdr6PC/Ti3pLG9/xsnqTnK
         d897lxrUTxYFXICvVSAqQDHnZifFfNLVtIfUGZ6u1IEhfFLJqtMNTpZvWw/6zfoRxee8
         /+0JO4tOg8wATiyQlXfF9zviwhFopAs2K7Anfz12E6rQSRxghabpP5OUsowA1nwDQEzf
         JKPrb0itIWwQ2qugp4HCnm3An6rJ0g7abOKV9e++9P5p+3fxNd0rsJHORt57GmePHCBn
         rsE1yZdrTV6UNgtYrm2jUh3IsYVu4XKg631B79UaQYyURWFpkfxml5Cfxvzjq0I8vdDN
         xa+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d89si1509920uad.242.2019.07.11.04.13.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 04:13:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7AF9A3082E8E;
	Thu, 11 Jul 2019 11:13:37 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 491E31001F41;
	Thu, 11 Jul 2019 11:13:26 +0000 (UTC)
Subject: Re: [QEMU Patch] virtio-baloon: Support for page hinting
To: Cornelia Huck <cohuck@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
 wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
 david@redhat.com, mst@redhat.com, dodgen@google.com, konrad.wilk@oracle.com,
 dhildenb@redhat.com, aarcange@redhat.com, alexander.duyck@gmail.com,
 john.starks@microsoft.com, dave.hansen@intel.com, mhocko@suse.com
References: <20190710195158.19640-1-nitesh@redhat.com>
 <20190710195303.19690-1-nitesh@redhat.com>
 <20190711104912.2cd79aeb.cohuck@redhat.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <167d8375-f85b-e330-561f-a4f0a6ab5c12@redhat.com>
Date: Thu, 11 Jul 2019 07:13:25 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190711104912.2cd79aeb.cohuck@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 11 Jul 2019 11:13:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/11/19 4:49 AM, Cornelia Huck wrote:
> On Wed, 10 Jul 2019 15:53:03 -0400
> Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
>
> $SUBJECT: s/baloon/balloon/
>
>> Enables QEMU to perform madvise free on the memory range reported
>> by the vm.
> [No comments on the actual functionality; just some stuff I noticed.]
>
>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
>> ---
>>  hw/virtio/trace-events                        |  1 +
>>  hw/virtio/virtio-balloon.c                    | 59 ++++++++++++++++++=
+
>>  include/hw/virtio/virtio-balloon.h            |  2 +-
>>  include/qemu/osdep.h                          |  7 +++
>>  .../standard-headers/linux/virtio_balloon.h   |  1 +
>>  5 files changed, 69 insertions(+), 1 deletion(-)
>>
> (...)
>
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
> Indentation seems to be off here (also in other places; please double
> check.)
Thanks, I will check it.
>
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
> I don't think you can add this unconditionally if you want to keep this=

> migratable. This should be done via a property (as for deflate-on-oom
> and free-page-hint) so it can be turned off in compat machines.
I see, I will take a look at it.
>
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
> This should probably be conditional in the same way as the free page hi=
nt
> queue (also see above).
Makes sense. Thanks.
>
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
> This object does not have any accessors; what purpose does it serve?
I think its not required. I will correct this.
>
>> =20
>>      object_property_add(obj, "guest-stats-polling-interval", "int",
>>                          balloon_stats_get_poll_interval,
> (...)
>
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
> Please split off any update to these headers into a separate patch, so
> that it can be replaced by a proper headers update when it is merged.
I will do that.
--=20
Thanks
Nitesh

