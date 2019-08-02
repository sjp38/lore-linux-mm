Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0174AC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 20:40:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D3492087E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 20:40:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D3492087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 357E36B0003; Fri,  2 Aug 2019 16:40:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 308ED6B0005; Fri,  2 Aug 2019 16:40:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D0156B0006; Fri,  2 Aug 2019 16:40:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id EDD836B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 16:40:25 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e39so68913145qte.8
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 13:40:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=8oa43N5pHPI72oasUoxHfEvNvvBJ1vX6dMZtEq2CnpE=;
        b=HdOqx5iLWhLJZp0eZKlNu+tQ1xYw+bBrF4WcXnfKVmW7cmkN/8dpT0dp+sa6Un6SNJ
         uVXaWluYG4fLBmz49KknMDY+sOU6JkA7JjdC/gR7BmfU0zcBasTVON7nszZQsYiwKPLP
         49tEiAPvX+gJdYEn1a9nycaP40cfCh6CtUV0KpwHXYbg1PVHE7xpzcrcE4WIK+sl4M64
         aAi20JwlDKXgX7n4CcdPPdjhZtv4RnYHCAdx/ZfpPi2cwX2IIhGoV5xCcITEtmjiL0TN
         mjjLnEFmcN6oCaeViQGI2cu8dQ5uQDirOPhF6DcI4u5AHx/VYFmXxMS3VkpPRpedH1l0
         33SQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWjQ8tMn6W6zdTty8zE0hyz+Z1bnCTa25+aYQVGeND16K9sETkc
	CL+8ypJBpEcGHDc6Eo0Im0B4xET1fiklW8uiAsyXX/cls+sGEwX3y9w3UZKSXwH4LqdIQP4K+JJ
	BSSogY7D7kR9Hokiqg37u+69nlKAfoCFILtgoB/7sbw0+tXg/rZhi/+pqB7Y92VqSRg==
X-Received: by 2002:ac8:6898:: with SMTP id m24mr96060987qtq.362.1564778425715;
        Fri, 02 Aug 2019 13:40:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvmYtv8xhISKct6ZoDN9kF8nAqdok3XaFiK0ogFhi+mCA6rIWwNLSBwC1bKLi8/x47PUED
X-Received: by 2002:ac8:6898:: with SMTP id m24mr96060947qtq.362.1564778424900;
        Fri, 02 Aug 2019 13:40:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564778424; cv=none;
        d=google.com; s=arc-20160816;
        b=xfsH4+iRJDpsUoWVzl2X59NneTR5CCKpDhHgiKbM6Txg23KhRS6bpXBA0dwyf/1Vqy
         ahNwLFqagzhGsQJJTdUQpg3IiAg/dhzYROi+SwplslUaCtrFxrr2Bdr6aD1zjvR/Zgn9
         g5W1IdG1q9fKQWtbt4rDVGxuYbfENvoofJrV52qLWiZYbptpdGm0Pch2zgEU8avY7EkM
         axlDrzg4XbL4Aq2gHtv50NW67ufX+76SXIDwewrd8vMObaAoHKIIpWKl1mCLz0IPW9Zr
         1V4Xifrl7C6C5zF2XDU4nsyNuixOyobI5HZczmPEzdvqZ6NbFxVgd+6oK2WTcv2Y61Ao
         OyXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=8oa43N5pHPI72oasUoxHfEvNvvBJ1vX6dMZtEq2CnpE=;
        b=R2HjhFDfzClKVG3w9iznSInujfIvwy3c9Dpz6xaGgzRSLz5my4Sr+C4DDVdQ1zEDy+
         FaxGxJBPys95cCWkMD2p2UjZh1rtrBHb+NhE+kPMOU4liNCNs5seEkVj+8eq+Pqp2DEV
         x7UjDZlV/jbs2uGc7WXb6MdpJuWFAC7tgoq68ogqmZbKov0kdFhLpG7sTcP7Fc9IkKVQ
         TNr07bIkCaF1QVDkhW+c3w/0k5wXGc2Z+09IfUjvF3Lp5DcE5NNSpjvb1d1JgHH9DlTt
         SejCHCSCQyJPok7dx/oxfYlse52TZ1PO4MHFOa4hslEq+mAw+yfRgCDZFfBZXr2EJJo/
         pIcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m14si47398078qta.354.2019.08.02.13.40.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 13:40:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E9C2F3090FD0;
	Fri,  2 Aug 2019 20:40:23 +0000 (UTC)
Received: from [10.40.204.149] (ovpn-204-149.brq.redhat.com [10.40.204.149])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3B1195C207;
	Fri,  2 Aug 2019 20:40:03 +0000 (UTC)
Subject: Re: [PATCH v3 QEMU 2/2] virtio-balloon: Provide a interface for
 unused page reporting
To: Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
 david@redhat.com, mst@redhat.com, dave.hansen@intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
References: <20190801222158.22190.96964.stgit@localhost.localdomain>
 <20190801224320.24744.16673.stgit@localhost.localdomain>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <63bbf480-7d0c-dd5c-08bf-1951039fcd54@redhat.com>
Date: Fri, 2 Aug 2019 16:40:00 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190801224320.24744.16673.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 02 Aug 2019 20:40:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/1/19 6:43 PM, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>
> Add support for what I am referring to as "unused page reporting".
> Basically the idea is to function very similar to how the balloon works=

> in that we basically end up madvising the page as not being used. Howev=
er
> we don't really need to bother with any deflate type logic since the pa=
ge
> will be faulted back into the guest when it is read or written to.
>
> This is meant to be a simplification of the existing balloon interface
> to use for providing hints to what memory needs to be freed. I am assum=
ing
> this is safe to do as the deflate logic does not actually appear to do =
very
> much other than tracking what subpages have been released and which one=
s
> haven't.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
>  hw/virtio/virtio-balloon.c                      |   46 +++++++++++++++=
+++++++-
>  include/hw/virtio/virtio-balloon.h              |    2 +
>  include/standard-headers/linux/virtio_balloon.h |    1 +
>  3 files changed, 46 insertions(+), 3 deletions(-)
>
> diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
> index 003b3ebcfdfb..7a30df63bc77 100644
> --- a/hw/virtio/virtio-balloon.c
> +++ b/hw/virtio/virtio-balloon.c
> @@ -320,6 +320,40 @@ static void balloon_stats_set_poll_interval(Object=
 *obj, Visitor *v,
>      balloon_stats_change_timer(s, 0);
>  }
> =20
> +static void virtio_balloon_handle_report(VirtIODevice *vdev, VirtQueue=
 *vq)
> +{
> +    VirtIOBalloon *dev =3D VIRTIO_BALLOON(vdev);
> +    VirtQueueElement *elem;
> +
> +    while ((elem =3D virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
> +    	unsigned int i;
> +
> +        for (i =3D 0; i < elem->in_num; i++) {
> +            void *addr =3D elem->in_sg[i].iov_base;
> +            size_t size =3D elem->in_sg[i].iov_len;
> +            ram_addr_t ram_offset;
> +            size_t rb_page_size;
> +            RAMBlock *rb;
> +
> +            if (qemu_balloon_is_inhibited() || dev->poison_val)
> +                continue;
> +
> +            rb =3D qemu_ram_block_from_host(addr, false, &ram_offset);=

> +            rb_page_size =3D qemu_ram_pagesize(rb);
> +
> +            /* For now we will simply ignore unaligned memory regions =
*/
> +            if ((ram_offset | size) & (rb_page_size - 1))
> +                continue;
> +
> +            ram_block_discard_range(rb, ram_offset, size);
> +        }
> +
> +        virtqueue_push(vq, elem, 0);
> +        virtio_notify(vdev, vq);
> +        g_free(elem);
> +    }
> +}
> +
>  static void virtio_balloon_handle_output(VirtIODevice *vdev, VirtQueue=
 *vq)
>  {
>      VirtIOBalloon *s =3D VIRTIO_BALLOON(vdev);
> @@ -627,7 +661,8 @@ static size_t virtio_balloon_config_size(VirtIOBall=
oon *s)
>          return sizeof(struct virtio_balloon_config);
>      }
>      if (virtio_has_feature(features, VIRTIO_BALLOON_F_PAGE_POISON) ||
> -        virtio_has_feature(features, VIRTIO_BALLOON_F_FREE_PAGE_HINT))=
 {
> +        virtio_has_feature(features, VIRTIO_BALLOON_F_FREE_PAGE_HINT) =
||
> +        virtio_has_feature(features, VIRTIO_BALLOON_F_REPORTING)) {
>          return sizeof(struct virtio_balloon_config);
>      }
>      return offsetof(struct virtio_balloon_config, free_page_report_cmd=
_id);
> @@ -715,7 +750,8 @@ static uint64_t virtio_balloon_get_features(VirtIOD=
evice *vdev, uint64_t f,
>      VirtIOBalloon *dev =3D VIRTIO_BALLOON(vdev);
>      f |=3D dev->host_features;
>      virtio_add_feature(&f, VIRTIO_BALLOON_F_STATS_VQ);
> -    if (virtio_has_feature(f, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
> +    if (virtio_has_feature(f, VIRTIO_BALLOON_F_FREE_PAGE_HINT) ||
> +        virtio_has_feature(f, VIRTIO_BALLOON_F_REPORTING)) {
>          virtio_add_feature(&f, VIRTIO_BALLOON_F_PAGE_POISON);
>      }
> =20
> @@ -805,6 +841,10 @@ static void virtio_balloon_device_realize(DeviceSt=
ate *dev, Error **errp)
>      s->dvq =3D virtio_add_queue(vdev, 128, virtio_balloon_handle_outpu=
t);
>      s->svq =3D virtio_add_queue(vdev, 128, virtio_balloon_receive_stat=
s);
> =20
> +    if (virtio_has_feature(s->host_features, VIRTIO_BALLOON_F_REPORTIN=
G)) {
> +        s->rvq =3D virtio_add_queue(vdev, 32, virtio_balloon_handle_re=
port);
> +    }
> +
This does makes sense. I haven't seen the kernel patch yet, but I am gues=
sing
you will use this max_vq size to define the capacity.
>      if (virtio_has_feature(s->host_features,
>                             VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
>          s->free_page_vq =3D virtio_add_queue(vdev, VIRTQUEUE_MAX_SIZE,=

> @@ -931,6 +971,8 @@ static Property virtio_balloon_properties[] =3D {
>       */
>      DEFINE_PROP_BOOL("qemu-4-0-config-size", VirtIOBalloon,
>                       qemu_4_0_config_size, false),
> +    DEFINE_PROP_BIT("unused-page-reporting", VirtIOBalloon, host_featu=
res,
> +                    VIRTIO_BALLOON_F_REPORTING, true),
>      DEFINE_PROP_LINK("iothread", VirtIOBalloon, iothread, TYPE_IOTHREA=
D,
>                       IOThread *),
>      DEFINE_PROP_END_OF_LIST(),
> diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/vir=
tio-balloon.h
> index 7fe78e5c14d7..db5bf7127112 100644
> --- a/include/hw/virtio/virtio-balloon.h
> +++ b/include/hw/virtio/virtio-balloon.h
> @@ -42,7 +42,7 @@ enum virtio_balloon_free_page_report_status {
> =20
>  typedef struct VirtIOBalloon {
>      VirtIODevice parent_obj;
> -    VirtQueue *ivq, *dvq, *svq, *free_page_vq;
> +    VirtQueue *ivq, *dvq, *svq, *free_page_vq, *rvq;
>      uint32_t free_page_report_status;
>      uint32_t num_pages;
>      uint32_t actual;
> diff --git a/include/standard-headers/linux/virtio_balloon.h b/include/=
standard-headers/linux/virtio_balloon.h
> index 9375ca2a70de..1c5f6d6f2de6 100644
> --- a/include/standard-headers/linux/virtio_balloon.h
> +++ b/include/standard-headers/linux/virtio_balloon.h
> @@ -36,6 +36,7 @@
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */=

>  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages *=
/
>  #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisonin=
g */
> +#define VIRTIO_BALLOON_F_REPORTING	5 /* Page reporting virtqueue */

Do we really need this change? or is this something which is picked from =
the
Linux kernel?
If we do need it, then Cornelia suggested to split off any update to this=
 header
into a separate patch, so that it can be replaced by a proper headers upd=
ate
when it is merged.

> =20
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
>
--=20
Thanks
Nitesh

