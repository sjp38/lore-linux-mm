Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9626C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 21:49:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 529A420868
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 21:49:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="X//cpGAK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 529A420868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6E876B0006; Thu, 23 May 2019 17:49:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E46216B0007; Thu, 23 May 2019 17:49:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D352A6B0266; Thu, 23 May 2019 17:49:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id B275C6B0006
	for <linux-mm@kvack.org>; Thu, 23 May 2019 17:49:28 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id d6so6413863ybj.16
        for <linux-mm@kvack.org>; Thu, 23 May 2019 14:49:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=CA4BRvH7LpSOvdwGQ1RgbPK5R7ura7qGqy4SrVn6TGs=;
        b=DaqAIIOyyTeMC/HiopuXY3qGcEBoynIH6p3VRLQQ3QUzmRh/kAwppBfwHVXxLvNFEe
         FS7CkylT5sob2mkiZ0VB+na5BcILctPDns+VYk2zQLFHbi9OfLuGIy1+jliRQbTVPvn2
         bs3Bedqt87+MlD1HUFAsbWXLE30G8F77d8dP8genHgGeNJyuK6Um2ZUmjkGUhvkBrVOE
         LQRLS/N/ZHp+UUgZx4uPXEDftc/ML9+8lXdr+2/pu5ucHYPQNjz5lNyqnYKG1N0a2lYP
         3cNu002cPU2CvpREoSIn1ZIqQe8R69gewF6Qgyqr3iCxvNUrYSJsv5ieCfOGr1fauRqe
         /cuA==
X-Gm-Message-State: APjAAAUV6hSDoB+DdJa0m8XBQR6RD5OfXIgcpGMRxa/C/C6u4AMLOq/h
	D5i/lFQjlPKfRs6Y40auFyEZh6LIeFOfsyZ4DB4VHACbqoTVGTWv8FyT0pM2kAQ6Sp1lvIG3XYk
	KEP7LgGC8w3X4BlYVDP1+MFEU4YyvM9LYmsYuU8mOkcwp+LkjiZSNJh2p1vsN+bFhsw==
X-Received: by 2002:a0d:eb96:: with SMTP id u144mr45992834ywe.276.1558648168474;
        Thu, 23 May 2019 14:49:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrvNoTM4tAF62fJzUg7cAqnz/bjtvXvLuNFj0ngbELjAgKyXV8s6mTce+xmk7pxerNX3oO
X-Received: by 2002:a0d:eb96:: with SMTP id u144mr45992814ywe.276.1558648167789;
        Thu, 23 May 2019 14:49:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558648167; cv=none;
        d=google.com; s=arc-20160816;
        b=JzO8zU8Xws+LHAGy989f7KkKk23H8HO3aCrcFzjmtvwRhToqtFLWaYOf8ViSoySwuo
         akdxnqjksuFDPawQFUcR/8BjLpUv56i1KSo9zCH9j9yNdUXJpJRYRhcaRFkj5z+WinrS
         6fvwNmYQ4pqMuXLfs7Keie7nE75ZiKBvA6mcX80Rvx8KDDEFNeoRGBGIyWq8taOUhQV2
         sIdvm2/DRPnWzDA2ZFOtdGzoTaaDx0Ry52Rzd7x7ZdAkf23YyllgRqmpb8T6Xx3kmpRX
         8Mc16j7RO0hgvUpVnfcLG0iSKXo+vcJZBb6d17Y926CJHy5r68cAFI9oPW8cVpR6PVZV
         ZZtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=CA4BRvH7LpSOvdwGQ1RgbPK5R7ura7qGqy4SrVn6TGs=;
        b=1F66JKRwnEA3Vn9wN3L2wnj1+T3v19ngsPDKPtb9ABDTuS87tTZBnDLV3ipUF1pr/t
         2iB3xbjWC3sfnjn5Ov/Pp7iqATg8vO4jpnW9pNUP7Xc73wVOPI0qSvH1BxqEXxlLYipM
         agv02/S6MVNE19PdxnLPWP9ZvUThFtUBvq4QsMz28vVRwsp2/twv39hIyYgsI7xbunxa
         wFvwq/E3vFuhWVv5mL9IISu6ZsYG0//EJfnEOR23+u9+lAdcZkRqB5BrhM1kXqRNQ2BA
         6kPVQQmVlTzBMk8abFfKtGQQ1caGQ3cmV2dAGIZjEjzdRMZ1oSRimNWJifRkmficBeuJ
         nYHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="X//cpGAK";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 81si194945ywl.283.2019.05.23.14.49.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 14:49:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="X//cpGAK";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4NLhifU004317;
	Thu, 23 May 2019 21:49:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=CA4BRvH7LpSOvdwGQ1RgbPK5R7ura7qGqy4SrVn6TGs=;
 b=X//cpGAKkvYu1m1BjaIbh5y4EYuwM+8rZjWW5aAmW0vi1toc+ON7ojqHQsbcK6pAW1oD
 bdaUeEmghYKNyuWdojEirpuCtcEnGnpjzGNjA/TAPNGPvcylGBa+20OGWCMnCwLHj8Tf
 YRS6xbAb5NCY6/3hnPEk+xsQaxia6MP4a6XjVZSvoh9chZIbCYwa7XRJ+TOdhejZB+v7
 XSe3hifUXqlRGwDwQJJUjbd8e+die4vTzQ+aF3wEY1CdthC5hOmZQere78SM0w/UZFJa
 y1F1RpJmvyYHjzu9jq9fzTHoce2ebfeYA5vSKPJb2pXe3nPIQrp8MMBgMFftquXsLaI1 XQ== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2smsk5n948-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 23 May 2019 21:49:13 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4NLmFZJ185512;
	Thu, 23 May 2019 21:49:12 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2smsgvrm93-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 23 May 2019 21:49:12 +0000
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4NLn8SI003595;
	Thu, 23 May 2019 21:49:09 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 23 May 2019 21:49:08 +0000
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Kees Cook <keescook@chromium.org>, Evgenii Stepanov <eugenis@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        Linux Memory Management List <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
        dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
        linux-media@vger.kernel.org, kvm@vger.kernel.org,
        "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
        Vincenzo Frascino <vincenzo.frascino@arm.com>,
        Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Yishai Hadas <yishaih@mellanox.com>,
        Felix Kuehling
 <Felix.Kuehling@amd.com>,
        Alexander Deucher <Alexander.Deucher@amd.com>,
        Christian Koenig <Christian.Koenig@amd.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Jens Wiklander <jens.wiklander@linaro.org>,
        Alex Williamson <alex.williamson@redhat.com>,
        Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
        Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
        Jacob Bramley <Jacob.Bramley@arm.com>,
        Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
        Robin Murphy <robin.murphy@arm.com>,
        Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
        Dave Martin <Dave.Martin@arm.com>,
        Kevin Brodsky <kevin.brodsky@arm.com>,
        Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Elliott Hughes <enh@google.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp> <201905211633.6C0BF0C2@keescook>
 <6049844a-65f5-f513-5b58-7141588fef2b@oracle.com>
 <20190523201105.oifkksus4rzcwqt4@mbp>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <ffe58af3-7c70-d559-69f6-1f6ebcb0fec6@oracle.com>
Date: Thu, 23 May 2019 15:49:05 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190523201105.oifkksus4rzcwqt4@mbp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9266 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905230139
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9266 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905230139
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/23/19 2:11 PM, Catalin Marinas wrote:
> Hi Khalid,
>=20
> On Thu, May 23, 2019 at 11:51:40AM -0600, Khalid Aziz wrote:
>> On 5/21/19 6:04 PM, Kees Cook wrote:
>>> As an aside: I think Sparc ADI support in Linux actually side-stepped=

>>> this[1] (i.e. chose "solution 1"): "All addresses passed to kernel mu=
st
>>> be non-ADI tagged addresses." (And sadly, "Kernel does not enable ADI=

>>> for kernel code.") I think this was a mistake we should not repeat fo=
r
>>> arm64 (we do seem to be at least in agreement about this, I think).
>>>
>>> [1] https://lore.kernel.org/patchwork/patch/654481/
>>
>> That is a very early version of the sparc ADI patch. Support for tagge=
d
>> addresses in syscalls was added in later versions and is in the patch
>> that is in the kernel.
>=20
> I tried to figure out but I'm not familiar with the sparc port. How did=

> you solve the tagged address going into various syscall implementations=

> in the kernel (e.g. sys_write)? Is the tag removed on kernel entry or i=
t
> ends up deeper in the core code?
>=20

Another spot I should point out in ADI patch - Tags are not stored in
VMAs and IOMMU does not support ADI tags on M7. ADI tags are stripped
before userspace addresses are passed to IOMMU in the following snippet
from the patch:

diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
index 5335ba3c850e..357b6047653a 100644
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -201,6 +202,24 @@ int __get_user_pages_fast(unsigned long start, int
nr_pages
, int write,
        pgd_t *pgdp;
        int nr =3D 0;

+#ifdef CONFIG_SPARC64
+       if (adi_capable()) {
+               long addr =3D start;
+
+               /* If userspace has passed a versioned address, kernel
+                * will not find it in the VMAs since it does not store
+                * the version tags in the list of VMAs. Storing version
+                * tags in list of VMAs is impractical since they can be
+                * changed any time from userspace without dropping into
+                * kernel. Any address search in VMAs will be done with
+                * non-versioned addresses. Ensure the ADI version bits
+                * are dropped here by sign extending the last bit before=

+                * ADI bits. IOMMU does not implement version tags.
+                */
+               addr =3D (addr << (long)adi_nbits()) >> (long)adi_nbits()=
;
+               start =3D addr;
+       }
+#endif
        start &=3D PAGE_MASK;
        addr =3D start;
        len =3D (unsigned long) nr_pages << PAGE_SHIFT;


--
Khalid


