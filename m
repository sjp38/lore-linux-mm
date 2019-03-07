Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7EB6C10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 13:23:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5997C20840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 13:23:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5997C20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47DD58E0005; Thu,  7 Mar 2019 08:23:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4059F8E0002; Thu,  7 Mar 2019 08:23:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1962E8E0005; Thu,  7 Mar 2019 08:23:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id D78298E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 08:23:56 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id q17so15033799qta.17
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 05:23:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=Q17vOIdJKIN8LrO7oo8XCCXEk5ANYkH6kNOAPmM1ynY=;
        b=QIVFVVHLrqlIK7ZcDd1v3pfpoy9GiF6yNhiZXUJA7mf/MHAs4PHbqF6isKFu5JPMBM
         I5VUgbdjJftc0sp/1r2mVFFgY8GQCKEAMjWz804oJbJH2v9BtPbcQtzIU6WbllzIgn+K
         bfoRDITAhVVJSwmcfuuvEhI0g/Ds8AFMWWW23zW7kx2588RRDvuWDyJBJIgZJSm260DA
         HW7uqMrz8HYRJgSj6Wt8QIs0lblRDbdlAPe9uNIKYwF0S3bzTiEzmmUcV/xc3CdUvN3w
         KqH/gtV3HTZV0aX5ASQIc8Yq8IwvzSXGMug9uMfmKaMnoAPzlzWSVT6/Li737D5Su92e
         EEWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV2POL1FYV/5QwahwdVQmNem5MGVpWkxHOIeuv0Zge/8ltC6kie
	phBXhHW2tKkjs2nvuXgGng7o12j2lSrs5xqojQZZIf8NUgv9Vrs0WKxq3SVF6e3gXfQUb3J250E
	6BXBApD3oNMJPLANSb/x7Go9x/lL7yldVjesG1n09iZzlgb/64FypJFpDlbv+Kd+x7g==
X-Received: by 2002:aed:3f2c:: with SMTP id p41mr9992165qtf.261.1551965036644;
        Thu, 07 Mar 2019 05:23:56 -0800 (PST)
X-Google-Smtp-Source: APXvYqw9M1ZVAJQ79a/deWYP/NZLgX882r3lzWopoC1XzU7BbUvfZrssb4sy7JHPimYWlq4XkYHg
X-Received: by 2002:aed:3f2c:: with SMTP id p41mr9992105qtf.261.1551965035697;
        Thu, 07 Mar 2019 05:23:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551965035; cv=none;
        d=google.com; s=arc-20160816;
        b=UHNW1u/sE3XCXfzdxK9KZOulCL2oD+P4SMYKdgOv5BwvTGVCIV/hA3U9m9XAcVa60H
         jRpKcUVIErEbBgcnkSGJ6DOd9/cS19wAUwCoAksGulumuhQB4rCqP8HUoE1IBw0FccPM
         Mu3BBmEhuZOb9g4xVVkT+f/B1la/h5wlqIN34RNsfaobWUI49z8FSB9j/R6KklQ9aWTl
         2HOUU/tkdS+OoXoj9u/Vq6Gh3enuunY8moH9YvOLQSfZc3BXdsrP1Yb9fxJ6VJqSPmNJ
         qlPNcONNIxA+vq/yFLbbdKDlLHRbLNk+93NAoz4JKq1AVMlUvfrPAxZS7Oh/olcbndGh
         4RaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=Q17vOIdJKIN8LrO7oo8XCCXEk5ANYkH6kNOAPmM1ynY=;
        b=DGq5Q833u5ura9szl4wc4ETPKUnaXbmirjQQKTrJH4QS3PmE7Kk5Zw46eTDVk2Eexz
         /TiMpdjOje2xtf5FcP1Q4I58spHfjE7Sj0bBkcLbySwz6Dn0O3IChWAEjJKl4/jP4eq0
         6Pk5clNiBUWfw/PXDcF43nwTizAyjD9bHWg+OLI+FMTI+qUhqGq3W8oW+kupSzWAPFcw
         CpZzlSlZ8MwNMDwpyFHzWJCOoxd/dzvc7H5i0QALxKMeQXsn7sqYoyMt9xTqkb5nzrC0
         PYKP/RPuur+oWV3t6imngntMsUbgH2TUCmP6jYskjoXW+JUvk1TtncOzPujUpLK0rwS0
         0IAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j30si2816667qta.227.2019.03.07.05.23.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 05:23:55 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9D78F30EBE70;
	Thu,  7 Mar 2019 13:23:54 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2278D5D783;
	Thu,  7 Mar 2019 13:23:20 +0000 (UTC)
Subject: Re: [RFC][Patch v9 3/6] KVM: Enables the kernel to report isolated
 pages
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-4-nitesh@redhat.com>
 <CAKgT0Udrzo4Ddx4UsJr+x-kgEVJpzQf_PhtAmoShSU8PPDOZEQ@mail.gmail.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <7e1d0731-46e8-443e-7c37-62999fcb5642@redhat.com>
Date: Thu, 7 Mar 2019 08:23:11 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0Udrzo4Ddx4UsJr+x-kgEVJpzQf_PhtAmoShSU8PPDOZEQ@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="COJYhzE626r78ogLRs1o91zqQ8RbiIzvS"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 07 Mar 2019 13:23:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--COJYhzE626r78ogLRs1o91zqQ8RbiIzvS
Content-Type: multipart/mixed; boundary="ONVDPkgYTEpnzsc7KMu6PgbAFFhIVYh8G";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <7e1d0731-46e8-443e-7c37-62999fcb5642@redhat.com>
Subject: Re: [RFC][Patch v9 3/6] KVM: Enables the kernel to report isolated
 pages
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-4-nitesh@redhat.com>
 <CAKgT0Udrzo4Ddx4UsJr+x-kgEVJpzQf_PhtAmoShSU8PPDOZEQ@mail.gmail.com>
In-Reply-To: <CAKgT0Udrzo4Ddx4UsJr+x-kgEVJpzQf_PhtAmoShSU8PPDOZEQ@mail.gmail.com>

--ONVDPkgYTEpnzsc7KMu6PgbAFFhIVYh8G
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 3/6/19 4:30 PM, Alexander Duyck wrote:
> On Wed, Mar 6, 2019 at 7:51 AM Nitesh Narayan Lal <nitesh@redhat.com> w=
rote:
>> This patch enables the kernel to report the isolated pages
>> to the host via virtio balloon driver.
>> In order to do so a new virtuqeue (hinting_vq) is added to the
>> virtio balloon driver. As the host responds back after freeing
>> the pages, all the isolated pages are returned back to the buddy
>> via __free_one_page().
>>
>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> I ran into a few build issues due to this patch. Comments below.
>
>> ---
>>  drivers/virtio/virtio_balloon.c     | 72 ++++++++++++++++++++++++++++=
-
>>  include/linux/page_hinting.h        |  4 ++
>>  include/uapi/linux/virtio_balloon.h |  8 ++++
>>  virt/kvm/page_hinting.c             | 18 ++++++--
>>  4 files changed, 98 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_b=
alloon.c
>> index 728ecd1eea30..cfe7574b5204 100644
>> --- a/drivers/virtio/virtio_balloon.c
>> +++ b/drivers/virtio/virtio_balloon.c
>> @@ -57,13 +57,15 @@ enum virtio_balloon_vq {
>>         VIRTIO_BALLOON_VQ_INFLATE,
>>         VIRTIO_BALLOON_VQ_DEFLATE,
>>         VIRTIO_BALLOON_VQ_STATS,
>> +       VIRTIO_BALLOON_VQ_HINTING,
>>         VIRTIO_BALLOON_VQ_FREE_PAGE,
>>         VIRTIO_BALLOON_VQ_MAX
>>  };
>>
>>  struct virtio_balloon {
>>         struct virtio_device *vdev;
>> -       struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_pa=
ge_vq;
>> +       struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_pa=
ge_vq,
>> +                                                               *hinti=
ng_vq;
>>
>>         /* Balloon's own wq for cpu-intensive work items */
>>         struct workqueue_struct *balloon_wq;
>> @@ -122,6 +124,56 @@ static struct virtio_device_id id_table[] =3D {
>>         { 0 },
>>  };
>>
>> +#ifdef CONFIG_KVM_FREE_PAGE_HINTING
>> +int virtballoon_page_hinting(struct virtio_balloon *vb,
>> +                            void *hinting_req,
>> +                            int entries)
>> +{
>> +       struct scatterlist sg;
>> +       struct virtqueue *vq =3D vb->hinting_vq;
>> +       int err;
>> +       int unused;
>> +       struct virtio_balloon_hint_req *hint_req;
>> +       u64 gpaddr;
>> +
>> +       hint_req =3D kmalloc(sizeof(struct virtio_balloon_hint_req), G=
FP_KERNEL);
>> +       while (virtqueue_get_buf(vq, &unused))
>> +               ;
>> +
>> +       gpaddr =3D virt_to_phys(hinting_req);
>> +       hint_req->phys_addr =3D cpu_to_virtio64(vb->vdev, gpaddr);
>> +       hint_req->count =3D cpu_to_virtio32(vb->vdev, entries);
>> +       sg_init_one(&sg, hint_req, sizeof(struct virtio_balloon_hint_r=
eq));
>> +       err =3D virtqueue_add_outbuf(vq, &sg, 1, hint_req, GFP_KERNEL)=
;
>> +       if (!err)
>> +               virtqueue_kick(vb->hinting_vq);
>> +       else
>> +               kfree(hint_req);
>> +       return err;
>> +}
>> +
>> +static void hinting_ack(struct virtqueue *vq)
>> +{
>> +       int len =3D sizeof(struct virtio_balloon_hint_req);
>> +       struct virtio_balloon_hint_req *hint_req =3D virtqueue_get_buf=
(vq, &len);
>> +       void *v_addr =3D phys_to_virt(hint_req->phys_addr);
>> +
>> +       release_buddy_pages(v_addr, hint_req->count);
>> +       kfree(hint_req);
>> +}
>> +
> You use release_buddy_pages here, but never exported it in the call
> down below. Since this can be built as a module and I believe the page
> hinting can be built either into the kernel or as a seperate module
> shouldn't you be exporting it?
Thanks for pointing this out.
>
>> +static void enable_hinting(struct virtio_balloon *vb)
>> +{
>> +       request_hypercall =3D (void *)&virtballoon_page_hinting;
>> +       balloon_ptr =3D vb;
>> +}
>> +
>> +static void disable_hinting(void)
>> +{
>> +       balloon_ptr =3D NULL;
>> +}
>> +#endif
>> +
>>  static u32 page_to_balloon_pfn(struct page *page)
>>  {
>>         unsigned long pfn =3D page_to_pfn(page);
>> @@ -481,6 +533,7 @@ static int init_vqs(struct virtio_balloon *vb)
>>         names[VIRTIO_BALLOON_VQ_DEFLATE] =3D "deflate";
>>         names[VIRTIO_BALLOON_VQ_STATS] =3D NULL;
>>         names[VIRTIO_BALLOON_VQ_FREE_PAGE] =3D NULL;
>> +       names[VIRTIO_BALLOON_VQ_HINTING] =3D NULL;
>>
>>         if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {=

>>                 names[VIRTIO_BALLOON_VQ_STATS] =3D "stats";
>> @@ -492,11 +545,18 @@ static int init_vqs(struct virtio_balloon *vb)
>>                 callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] =3D NULL;
>>         }
>>
>> +       if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
>> +               names[VIRTIO_BALLOON_VQ_HINTING] =3D "hinting_vq";
>> +               callbacks[VIRTIO_BALLOON_VQ_HINTING] =3D hinting_ack;
>> +       }
>>         err =3D vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ=
_MAX,
>>                                          vqs, callbacks, names, NULL, =
NULL);
>>         if (err)
>>                 return err;
>>
>> +       if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
>> +               vb->hinting_vq =3D vqs[VIRTIO_BALLOON_VQ_HINTING];
>> +
>>         vb->inflate_vq =3D vqs[VIRTIO_BALLOON_VQ_INFLATE];
>>         vb->deflate_vq =3D vqs[VIRTIO_BALLOON_VQ_DEFLATE];
>>         if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {=

>> @@ -908,6 +968,11 @@ static int virtballoon_probe(struct virtio_device=
 *vdev)
>>                 if (err)
>>                         goto out_del_balloon_wq;
>>         }
>> +
>> +#ifdef CONFIG_KVM_FREE_PAGE_HINTING
>> +       if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
>> +               enable_hinting(vb);
>> +#endif
>>         virtio_device_ready(vdev);
>>
>>         if (towards_target(vb))
>> @@ -950,6 +1015,10 @@ static void virtballoon_remove(struct virtio_dev=
ice *vdev)
>>         cancel_work_sync(&vb->update_balloon_size_work);
>>         cancel_work_sync(&vb->update_balloon_stats_work);
>>
>> +#ifdef CONFIG_KVM_FREE_PAGE_HINTING
>> +       if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
>> +               disable_hinting();
>> +#endif
>>         if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))=
 {
>>                 cancel_work_sync(&vb->report_free_page_work);
>>                 destroy_workqueue(vb->balloon_wq);
>> @@ -1009,6 +1078,7 @@ static unsigned int features[] =3D {
>>         VIRTIO_BALLOON_F_MUST_TELL_HOST,
>>         VIRTIO_BALLOON_F_STATS_VQ,
>>         VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
>> +       VIRTIO_BALLOON_F_HINTING,
>>         VIRTIO_BALLOON_F_FREE_PAGE_HINT,
>>         VIRTIO_BALLOON_F_PAGE_POISON,
>>  };
>> diff --git a/include/linux/page_hinting.h b/include/linux/page_hinting=
=2Eh
>> index d554a2581826..a32af8851081 100644
>> --- a/include/linux/page_hinting.h
>> +++ b/include/linux/page_hinting.h
>> @@ -11,6 +11,8 @@
>>  #define HINTING_THRESHOLD      128
>>  #define FREE_PAGE_HINTING_MIN_ORDER    (MAX_ORDER - 1)
>>
>> +extern void *balloon_ptr;
>> +
>>  void guest_free_page_enqueue(struct page *page, int order);
>>  void guest_free_page_try_hinting(void);
>>  extern int __isolate_free_page(struct page *page, unsigned int order)=
;
>> @@ -18,3 +20,5 @@ extern void __free_one_page(struct page *page, unsig=
ned long pfn,
>>                             struct zone *zone, unsigned int order,
>>                             int migratetype);
>>  void release_buddy_pages(void *obj_to_free, int entries);
>> +extern int (*request_hypercall)(void *balloon_ptr,
>> +                               void *hinting_req, int entries);
>> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/=
virtio_balloon.h
>> index a1966cd7b677..a7e909d77447 100644
>> --- a/include/uapi/linux/virtio_balloon.h
>> +++ b/include/uapi/linux/virtio_balloon.h
>> @@ -29,6 +29,7 @@
>>  #include <linux/virtio_types.h>
>>  #include <linux/virtio_ids.h>
>>  #include <linux/virtio_config.h>
>> +#include <linux/page_hinting.h>
>>
>>  /* The feature bitmap for virtio balloon */
>>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST        0 /* Tell before recla=
iming pages */
> So I am pretty sure that this isn't valid. You have a file in
> include/uapi/linux referencing one in include/linux. As such when the
> userspace headers are built off of this they cannot access the kernel
> include file.
>
>> @@ -36,6 +37,7 @@
>>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM        2 /* Deflate balloon o=
n OOM */
>>  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT        3 /* VQ to report free=
 pages */
>>  #define VIRTIO_BALLOON_F_PAGE_POISON   4 /* Guest is using page poiso=
ning */
>> +#define VIRTIO_BALLOON_F_HINTING       5 /* Page hinting virtqueue */=

>>
>>  /* Size of a PFN in the balloon interface. */
>>  #define VIRTIO_BALLOON_PFN_SHIFT 12
>> @@ -108,4 +110,10 @@ struct virtio_balloon_stat {
>>         __virtio64 val;
>>  } __attribute__((packed));
>>
>> +#ifdef CONFIG_KVM_FREE_PAGE_HINTING
>> +struct virtio_balloon_hint_req {
>> +       __virtio64 phys_addr;
>> +       __virtio64 count;
>> +};
>> +#endif
>>  #endif /* _LINUX_VIRTIO_BALLOON_H */
>> diff --git a/virt/kvm/page_hinting.c b/virt/kvm/page_hinting.c
>> index 9885b372b5a9..eb0c0ddfe990 100644
>> --- a/virt/kvm/page_hinting.c
>> +++ b/virt/kvm/page_hinting.c
>> @@ -31,11 +31,16 @@ struct guest_isolated_pages {
>>         unsigned int order;
>>  };
>>
>> -void release_buddy_pages(void *obj_to_free, int entries)
>> +int (*request_hypercall)(void *balloon_ptr, void *hinting_req, int en=
tries);
>> +EXPORT_SYMBOL(request_hypercall);
>> +void *balloon_ptr;
>> +EXPORT_SYMBOL(balloon_ptr);
>> +
> Why are you using a standard EXPORT_SYMBOL here instead of
> EXPORT_SYMBOL_GPL? It seems like these are core functions that can
> impact the memory allocator. It might make more sense to use
> EXPORT_SYMBOL_GPL.
>
>> +void release_buddy_pages(void *hinting_req, int entries)
>>  {
>>         int i =3D 0;
>>         int mt =3D 0;
>> -       struct guest_isolated_pages *isolated_pages_obj =3D obj_to_fre=
e;
>> +       struct guest_isolated_pages *isolated_pages_obj =3D hinting_re=
q;
>>
>>         while (i < entries) {
>>                 struct page *page =3D pfn_to_page(isolated_pages_obj[i=
].pfn);
> See my comment above, I am pretty sure you need to be exporting this.
> I had to change this in order to be able to build.
Thanks, I will take note and correct it in the next version.
--=20
Regards
Nitesh


--ONVDPkgYTEpnzsc7KMu6PgbAFFhIVYh8G--

--COJYhzE626r78ogLRs1o91zqQ8RbiIzvS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyBGz8ACgkQo4ZA3AYy
ozn6WA/9FDo4v9fvG6Y9nkaxuFZbUiSYXbqZzqk5/mVmDjoqOWx6HjZfh4mJJRYV
VrE0Vg24oc+2EnugBmYe9upjOshqoyLzWJy1dGEePfHTGisG0u9+ojRj3bNIuF0J
G27jCNS5XS2Q6LtEP5MOaNjhDBQ42qmEZUwrfx55E88Og/LPw2fsSKI4CXnLqPgL
nGQ+9l0wWWRG6XyatWkNi9KZg0W6VTG8dF/6AULg0aZ9mEjDtmjj3kLKpu832uW/
x4FmoxYuh4I+9oYre/lm3BIFGtG45TRB0EcfTJelP15REQiGiRomid8eQnKDSpM2
JnBlDzfwQOuE4dLInxPZBEL7/xq9EXWJLsc04mVdnZIXuCKRnHlv6oVSGW8Rbv8z
P4jnYuI/yQamUmuJip1fO6maZu+Q4xkKA/Zg3ncVthqU87EpsAtEj7YdudG+VCCf
k0V38Qfh8HgXE8Bkwp4SfLN8jcPVtxAqKUY86nT081725LP9MNfTGBu5lHOW2Aay
65arsXc77CD2mzf1bnuAotey7TA2P0ABkx9AxtaBEiXimtCWdVeC4HjI5j2u7lQk
Y43mII3g4GiEXHn+2q5ILtuzO/4fLtnV7AYzKqM5pnekyj2B0AB5tTpTofWnlQ6K
+Q9WzzJ6IgfSxR7p0SH3EQuM0eW9z31e7TO+vLaF4lo9gOCdBnk=
=3SuD
-----END PGP SIGNATURE-----

--COJYhzE626r78ogLRs1o91zqQ8RbiIzvS--

