Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCB1EC28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:44:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91DE423CEB
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:44:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91DE423CEB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 374B36B0270; Tue,  4 Jun 2019 12:44:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FE206B0271; Tue,  4 Jun 2019 12:44:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1789B6B0272; Tue,  4 Jun 2019 12:44:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3AC16B0270
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 12:44:35 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id p15so11129369qti.11
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:44:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=semDZpSxYsWvNkjAQR6n+xha8VD8CWFhuaexjyktjxU=;
        b=TaCFfBobjvJAYYtRc9Lf9daMNOfe1QHgO8ydtWoll9cUKP5M1KLQS4anWV4LamrgtD
         HQcHVyWEqb3prFf5FbklAl5goGmO7/qzvAFsB1qw2PqQADQsRJW1JwMg3BLY2QSmELpE
         H2Aad9sZ8tBshhJFJywbywiec3zkn3s3WCJdY4ZvRZEKPWMaiJa5QFqLu0qwYlpSZiGV
         2t4GBqwsjV9L6DWDJQghbNuuq89r1mLXX5tK/zrGphm/cY1mL9AofaZQth+JxQAI0jQ5
         /y+lftOwoF3b1WFFuvoliT5qnLexrDEclv7eUoNBTzp6F5h7slothh4BLVI4wcZP4toX
         L1dA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVJZ7GvrVAo9QgXqQ8U/fLRKH5udd7iRAkTPKSWNpeiaDiVbtTq
	djRFzna6bOJip3LbGJU4ChsXLzfeOHynLCamrBhWSOoiHpIkxubHAPYKjxudQ4SegCr/y2jFMz/
	3ULzrY2IDI4xN7gB04qVbuthQrLz7avuhBsuMaPQYUB3ddX1bx1cHo0peCvUQgdnUog==
X-Received: by 2002:a05:620a:144a:: with SMTP id i10mr27869790qkl.130.1559666675658;
        Tue, 04 Jun 2019 09:44:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytV9/EKOd+lPFtjY//CUXhsrz2CtxoWks7DoE/EPH5bouNqsOX90lu0bpPP6O2MbLK9yFr
X-Received: by 2002:a05:620a:144a:: with SMTP id i10mr27869732qkl.130.1559666674949;
        Tue, 04 Jun 2019 09:44:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559666674; cv=none;
        d=google.com; s=arc-20160816;
        b=MmiNYipmq5P1qhU8yKdg8A7i2LN9XzjlYmSR0jQP0jWjDdxQfAVlEe4DyIk1VwNg9O
         RezM4WrBF01yZZAlipTWFIHyQ6RVc9ccol+zf7ppKa7H1PPqmlXtEzmANuOnjha0/FCy
         REf26LGq3FiQ8JdIVRO18zA6PxRWHflCTYqvNKGTuRVE9+pRWGYZz915pw9uBVQB8jw7
         /dkZKaFWuZTH/Z80ikJ7acY3AGbKJX6mFGJrh0lVR68OUGYH4tpDb2tuCLwBgS1P7RYm
         TlDa+eDpuyNa8oKIHw+zjrKaon9lBRg3U7XmtQI73iKFlLW1UUu3WqiDZGy+rJCE9HSD
         ZS/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=semDZpSxYsWvNkjAQR6n+xha8VD8CWFhuaexjyktjxU=;
        b=KcWYX+oy4l12tOTZKHHn562DQ0Ma6TGD8JT57F9tuOB93swewjdDorxZrHP2m0AHxi
         oEJth7v+h9WP2AZe36r2he48Oth1m6YdwOgnQ9bS5U8mAaUYTDiDmCmhId58XQweKSfR
         MCzqwmXO8xTlfi8cx5mTNtgCrQTl2vS22qh0tQu9sZNvb0low7lZWpL9mygF0DObUBUW
         EAhahtBMfEe53NQyKTcnGu4a6h3/wRyv6vLd2JM8fxIw6mJFVlBXmHwPGz4XLEIf93ly
         JkSQBttE2RpcW+5syx1WEhd97u78gIfuaUqMJe9YJ87iJSayNMl8DRtPfYU8NuFfqq1x
         8wXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l18si303918qtl.339.2019.06.04.09.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 09:44:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 037D459474;
	Tue,  4 Jun 2019 16:44:24 +0000 (UTC)
Received: from [10.40.205.182] (unknown [10.40.205.182])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 93144608A7;
	Tue,  4 Jun 2019 16:44:08 +0000 (UTC)
Subject: Re: [RFC][Patch v10 2/2] virtio-balloon: page_hinting: reporting to
 the host
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <20190603170306.49099-1-nitesh@redhat.com>
 <20190603170306.49099-3-nitesh@redhat.com>
 <CAKgT0UeRkG0FyESjjQQWeOs3x2O=BUzFYZAdDkjjLyXRiJMnCQ@mail.gmail.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <9511482c-acfd-2415-24fa-6586c5bd3e33@redhat.com>
Date: Tue, 4 Jun 2019 12:44:05 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAKgT0UeRkG0FyESjjQQWeOs3x2O=BUzFYZAdDkjjLyXRiJMnCQ@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="wHqLVccT6sgdHUJ7PuXlZKd3wrVDA6XlB"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 04 Jun 2019 16:44:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--wHqLVccT6sgdHUJ7PuXlZKd3wrVDA6XlB
Content-Type: multipart/mixed; boundary="J41RieuYN08h5ItQqdOsvIJEMDpfLAlWB";
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
Message-ID: <9511482c-acfd-2415-24fa-6586c5bd3e33@redhat.com>
Subject: Re: [RFC][Patch v10 2/2] virtio-balloon: page_hinting: reporting to
 the host
References: <20190603170306.49099-1-nitesh@redhat.com>
 <20190603170306.49099-3-nitesh@redhat.com>
 <CAKgT0UeRkG0FyESjjQQWeOs3x2O=BUzFYZAdDkjjLyXRiJMnCQ@mail.gmail.com>
In-Reply-To: <CAKgT0UeRkG0FyESjjQQWeOs3x2O=BUzFYZAdDkjjLyXRiJMnCQ@mail.gmail.com>

--J41RieuYN08h5ItQqdOsvIJEMDpfLAlWB
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 6/4/19 12:33 PM, Alexander Duyck wrote:
> On Mon, Jun 3, 2019 at 10:04 AM Nitesh Narayan Lal <nitesh@redhat.com> =
wrote:
>> Enables the kernel to negotiate VIRTIO_BALLOON_F_HINTING feature with =
the
>> host. If it is available and page_hinting_flag is set to true, page_hi=
nting
>> is enabled and its callbacks are configured along with the max_pages c=
ount
>> which indicates the maximum number of pages that can be isolated and h=
inted
>> at a time. Currently, only free pages of order >=3D (MAX_ORDER - 2) ar=
e
>> reported. To prevent any false OOM max_pages count is set to 16.
>>
>> By default page_hinting feature is enabled and gets loaded as soon
>> as the virtio-balloon driver is loaded. However, it could be disabled
>> by writing the page_hinting_flag which is a virtio-balloon parameter.
>>
>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
>> ---
>>  drivers/virtio/virtio_balloon.c     | 112 +++++++++++++++++++++++++++=
-
>>  include/uapi/linux/virtio_balloon.h |  14 ++++
>>  2 files changed, 125 insertions(+), 1 deletion(-)
> <snip>
>
>> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/=
virtio_balloon.h
>> index a1966cd7b677..25e4f817c660 100644
>> --- a/include/uapi/linux/virtio_balloon.h
>> +++ b/include/uapi/linux/virtio_balloon.h
>> @@ -29,6 +29,7 @@
>>  #include <linux/virtio_types.h>
>>  #include <linux/virtio_ids.h>
>>  #include <linux/virtio_config.h>
>> +#include <linux/page_hinting.h>
> So this include breaks the build and from what I can tell it isn't
> really needed. I deleted it in order to be able to build without
> warnings about the file not being included in UAPI.
I agree here, it is not required any more.
>
>>  /* The feature bitmap for virtio balloon */
>>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST        0 /* Tell before recla=
iming pages */
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
>> @@ -108,4 +110,16 @@ struct virtio_balloon_stat {
>>         __virtio64 val;
>>  } __attribute__((packed));
>>
>> +#ifdef CONFIG_PAGE_HINTING
>> +/*
>> + * struct hinting_data- holds the information associated with hinting=
=2E
>> + * @phys_add:  physical address associated with a page or the array h=
olding
>> + *             the array of isolated pages.
>> + * @size:      total size associated with the phys_addr.
>> + */
>> +struct hinting_data {
>> +       __virtio64 phys_addr;
>> +       __virtio32 size;
>> +};
>> +#endif
>>  #endif /* _LINUX_VIRTIO_BALLOON_H */
>> --
>> 2.21.0
>>
--=20
Regards
Nitesh


--J41RieuYN08h5ItQqdOsvIJEMDpfLAlWB--

--wHqLVccT6sgdHUJ7PuXlZKd3wrVDA6XlB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlz2n9UACgkQo4ZA3AYy
ozntJhAAlqT4thTU40bCNsdn9GCcVwr+p9rf9V+Vy2idk8dEvRRU7unQ6fBXYNQP
udujYoM+sJkApNmVAbI948y91O+LAl6z/V3aWbo7VvKCnGUe5p6SJdT9Ch+UeoFa
nh8Op8lpB5BUEXujpp2nX0ZGiYfRKWYapZ/LPat5SZyMui38nn97Ln8tZuDIqHzN
I3qYm4PXTP5QKs05Nh9DSjZzF7hd143vmdk3JBUpltD9OWzUJZJ4vOe6yAKYVK/O
LcB1k6BV7E8Vkv08ekLLdVc+cKoSmH/Gcomp8hQi/flxuNtKZjPU7ulo0dsucO1R
emEKhqiFXQMz1H29W63bSg+wc6/cGGTindSX64/Z4D9Wpqe1V99KO+3tknLflHWb
sjy8OVT7Cquup3rg5lh/vgLt8sSWcisoLZEbvUrzIzUWnSlRp3ZDm6+BQqAZLylz
f5QnbqJeH0X7gbv66No85DjK7NzPrVWP7h3/v4a/HmHpCFwDIWe/4A9/Kl8xOdKL
GSxDpMVpwqhwPickMK//FSTcYRswbAK6QIru66V/fcp6SBIltsySYVUhSrBxrcto
3E705yP6WV65iW2PaS5Yt/GZ6qMNdtNLCRalOnN8if4DkHi7xXcrUs5WJX9H43ps
mNoaxoaZNHjMHRxs+rRiMstaOa62LfW6gBXsL7uDnzCjbYhw7Tc=
=YVDb
-----END PGP SIGNATURE-----

--wHqLVccT6sgdHUJ7PuXlZKd3wrVDA6XlB--

