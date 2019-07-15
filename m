Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC140C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 23:34:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94C472080A
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 23:34:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="OgRxe+A5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94C472080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 427D56B0005; Mon, 15 Jul 2019 19:34:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D8166B0006; Mon, 15 Jul 2019 19:34:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C7A66B0007; Mon, 15 Jul 2019 19:34:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4696B0005
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 19:34:30 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id i70so15570071ybg.5
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 16:34:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=h+BRneuTpawGqNjEBZFefMsMDl5kO4JZEpBOUwB1zsI=;
        b=aWtqN526eixe0Y4SOO3+QkiWMCasOWxXJusudBBKHydplxreqTf4q05KW+BMyOmHp7
         X5EE9CTgpfguU6WSBbnAcIlG+czPTyreGN0kjHr6P3r2doEBYTRN9Tvo+nfAhGDgdN94
         0bED84D7vVx5zEo4PXc/T+hkIgzKWo4dZ5IDWBfOCVhk2ILPi0L84bFBXW88FwNA34yg
         BbigOGdb45W5lVADIoOtOfFxUDP+11MtGqOtS5S30qAlvs8YwDQqV1nHwcVhvMms4JA3
         xtusW1dYIehGhtSOn2+CYBhW/70K9IwcJ/HupaNyFDYQUerVqZyeY6AbDvNU8YMMcBKr
         Vveg==
X-Gm-Message-State: APjAAAVodGO7PnczIeeXU43J3kTdHhrHM9InyIN327XxVolRVQMcxW/w
	3iHYCfJXXV/HW9XjM440RhXXdDqxKdG4b7K2ZJO9jdOrk49TQJXInp2DV48Mm39xwOvW/FtPnc2
	JAI9AqLqaL0GoO7zsIfBTtK/FGzk++nVPuVdJrKbSKGh7rPzA0eaL7TlXBhRP4axRnQ==
X-Received: by 2002:a81:3295:: with SMTP id y143mr17412973ywy.328.1563233669751;
        Mon, 15 Jul 2019 16:34:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtElsnkOTO2iB7rgQ2UnJbIVC8ymhZc9yPOV2oNDqjdwyrPxUlmNKjgtz9zwreQTFCFE2k
X-Received: by 2002:a81:3295:: with SMTP id y143mr17412942ywy.328.1563233669017;
        Mon, 15 Jul 2019 16:34:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563233669; cv=none;
        d=google.com; s=arc-20160816;
        b=G2KVBpPDfA7dGnUFJJ/VUzq3WWkZKz2lfpZ8NDZ44HpHARhJJ6CcWNumTUDI7I11mq
         biTYIbaetcJv7JpWPq9GS4VyC3Ddzi+Mc7PsXGHBhlBLbhh8w5uxIkwiYRsI4M2uJyA+
         t7Wf23m77d9W/nxV0HjmgLLK2jPVFtZY/xD/9dHLf5KpGAZJTx8OTSH3sbYzk0yX+FbJ
         fND2sCyIkQiTHMts/GfIZRW8HAhafYQRD6xYrxmxOKqHY9t1auOrLcywtdoo5tfjajXm
         mJI8j4ec5cBf670cSi2wWIc+PUFYJiugrCyyirWKKQNdobDvLhWqPRJt7hJezjlf/3ua
         hGSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=h+BRneuTpawGqNjEBZFefMsMDl5kO4JZEpBOUwB1zsI=;
        b=iWb+jA1xCO7OCWuv3bi0WeDiB6dJt8Mh/2RQvHb8ucwKsFp+hLhcsffXj1Rr8s5SDn
         uWNWFu0qIOydDPsMgbO+ek//OoeNpmuLRBStqlrk3xmNHzl8wWfCE5W9+wBZ9Ine/kP8
         dHE+jQeOYcqNjluDAv3FP9y3SjT2qF6CpGyYIV8xx2Un1WdynuNX0/jBfl/aBsD87152
         JgUGydXlJtN3n/CJTJLKfFTCK4tO0Y4ZMAHWY4A71Xl+3T6yHoHZIuo8GsCi6DAVdvX8
         2/WRJOS81UMoMhm1sqzzmKjF9PbPQZqFcIx+WRk4nhnBplZMTxq6DoZvHyNdFfMs6rCi
         tAzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=OgRxe+A5;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id q188si8235062ybc.18.2019.07.15.16.34.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 16:34:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=OgRxe+A5;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2d0d8a0000>; Mon, 15 Jul 2019 16:34:34 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 15 Jul 2019 16:34:28 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 15 Jul 2019 16:34:28 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 15 Jul
 2019 23:34:22 +0000
Subject: Re: [PATCH] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
To: Andrew Morton <akpm@linux-foundation.org>, Ralph Campbell
	<rcampbell@nvidia.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>, Mike Kravetz <mike.kravetz@oracle.com>,
	Jason Gunthorpe <jgg@mellanox.com>
References: <20190709223556.28908-1-rcampbell@nvidia.com>
 <20190709172823.9413bb2333363f7e33a471a0@linux-foundation.org>
 <05fffcad-cf5e-8f0c-f0c7-6ffbd2b10c2e@nvidia.com>
 <20190715150031.49c2846f4617f30bca5f043f@linux-foundation.org>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <0ee5166a-26cd-a504-b9db-cffd082ecd38@nvidia.com>
Date: Mon, 15 Jul 2019 16:34:22 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190715150031.49c2846f4617f30bca5f043f@linux-foundation.org>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563233674; bh=h+BRneuTpawGqNjEBZFefMsMDl5kO4JZEpBOUwB1zsI=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=OgRxe+A50xtVuH+HsQIV6/bprmeVGbsbaB9lBSbyHuzVUuWGvBTurzo+o5F6zORfN
	 N/3R1l9mp4EACbf8HPX+47skIoVrJDcI2f30c9obXLSGBxMmch4ZlQ/RkpNmGq1uHq
	 yd5NXiTOUdDT50Y2cxZQItGpRtiMe4zSUBt8EpplppDt7ZNEztv0cgDHU8YSludWXJ
	 3oHds8mnWZb7IDJCV7pvnbquGQcWz/xxH8GZUVa0tLGarj4n8r/vjY4EoIjCUwVDhC
	 JCTAhWe1S8S9/da9QISXzHS4rr+wJFRUhZ6iuuPD/J5SFnrQxE6TWtKYYX/EaP5S4H
	 ZFOYnotJa/3zg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/15/19 3:00 PM, Andrew Morton wrote:
> On Tue, 9 Jul 2019 18:24:57 -0700 Ralph Campbell <rcampbell@nvidia.com> w=
rote:
>=20
>>
>> On 7/9/19 5:28 PM, Andrew Morton wrote:
>>> On Tue, 9 Jul 2019 15:35:56 -0700 Ralph Campbell <rcampbell@nvidia.com>=
 wrote:
>>>
>>>> When migrating a ZONE device private page from device memory to system
>>>> memory, the subpage pointer is initialized from a swap pte which compu=
tes
>>>> an invalid page pointer. A kernel panic results such as:
>>>>
>>>> BUG: unable to handle page fault for address: ffffea1fffffffc8
>>>>
>>>> Initialize subpage correctly before calling page_remove_rmap().
>>>
>>> I think this is
>>>
>>> Fixes:  a5430dda8a3a1c ("mm/migrate: support un-addressable ZONE_DEVICE=
 page in migration")
>>> Cc: stable
>>>
>>> yes?
>>>
>>
>> Yes. Can you add this or should I send a v2?
>=20
> I updated the patch.  Could we please have some review input?
>=20
>=20
> From: Ralph Campbell <rcampbell@nvidia.com>
> Subject: mm/hmm: fix bad subpage pointer in try_to_unmap_one
>=20
> When migrating a ZONE device private page from device memory to system
> memory, the subpage pointer is initialized from a swap pte which computes
> an invalid page pointer. A kernel panic results such as:
>=20
> BUG: unable to handle page fault for address: ffffea1fffffffc8
>=20
> Initialize subpage correctly before calling page_remove_rmap().
>=20
> Link: http://lkml.kernel.org/r/20190709223556.28908-1-rcampbell@nvidia.co=
m
> Fixes: a5430dda8a3a1c ("mm/migrate: support un-addressable ZONE_DEVICE pa=
ge in migration")
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>=20
>  mm/rmap.c |    1 +
>  1 file changed, 1 insertion(+)
>=20
> --- a/mm/rmap.c~mm-hmm-fix-bad-subpage-pointer-in-try_to_unmap_one
> +++ a/mm/rmap.c
> @@ -1476,6 +1476,7 @@ static bool try_to_unmap_one(struct page
>  			 * No need to invalidate here it will synchronize on
>  			 * against the special swap migration pte.
>  			 */
> +			subpage =3D page;
>  			goto discard;
>  		}
> =20

Hi Ralph and everyone,

While the above prevents a crash, I'm concerned that it is still not
an accurate fix. This fix leads to repeatedly removing the rmap, against th=
e
same struct page, which is odd, and also doesn't directly address the
root cause, which I understand to be: this routine can't handle migrating
the zero page properly--over and back, anyway. (We should also mention more=
=20
about how this is triggered, in the commit description.)

I'll take a closer look at possible fixes (I have to step out for a bit) so=
on,=20
but any more experienced help is also appreciated here.

thanks,
--=20
John Hubbard
NVIDIA

