Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65D25C31E4D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:48:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FB1821841
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:48:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="mFSmNdWd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FB1821841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B1E36B000C; Fri, 14 Jun 2019 13:48:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8622C6B000D; Fri, 14 Jun 2019 13:48:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7510A6B000E; Fri, 14 Jun 2019 13:48:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 568F86B000C
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 13:48:18 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id p79so3428660yba.21
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:48:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=8ZilaY5NOYwAFhaPvzhLk/MxmC8VICubaNjNx3N4a0o=;
        b=bbmU58CF8U2rsWahOMPeWUdAZfMfozX5ovqyRWjmqONuKgfYPMSbrqVQDOAYdB0FD4
         VciCrJA13xyd1yUdwQoCcrPsTQTN13Ya0xtEiAIcEDazXxlmdvQl3CM6rvr9uhGl6Wv5
         IUzB7NgVHPiP1L47HW9F3CFoiIp/NjCC7wKNcrn4Lk+v5uWhENwmjjwnYiY/LcPOF72l
         o8JYTNoojPZEZPywyW5/vppWlztbJi9x0d6t/zeSxjiZM/JWYgwybicIUObCan1wIeuX
         Z5usvtb4h2bl9Qk7dea2eDKe3HE6jBIkixvK5cez4/oladPsedqAUgSCaaf2/hRz2rDl
         FNUQ==
X-Gm-Message-State: APjAAAVmkRnW2RS2VlYX6k/ZVLnle3ic9Oo9k+u+UvnkMG7CeY29q/hm
	RW+xkN+ycnKm0W9Wyo3uq9fp/zJ9FXoCBiFgVZ+v9Ugq5xWTApKwdey2ZaRxd8OTK/UdpK1gkG5
	vdK0noUkkB3grxKdxhQFATP7et2cjOEg0OdbKfKWI78wzNcTBR52NLYSCXZf810+Oyg==
X-Received: by 2002:a81:29ca:: with SMTP id p193mr42012837ywp.287.1560534498106;
        Fri, 14 Jun 2019 10:48:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBbO+rqA3lU5nGcRkYKm6aqPsioiroiN1Y5ow5JXeLuZ0vd8XRB1++8fv51r3cuPZlJ5vx
X-Received: by 2002:a81:29ca:: with SMTP id p193mr42012804ywp.287.1560534497569;
        Fri, 14 Jun 2019 10:48:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560534497; cv=none;
        d=google.com; s=arc-20160816;
        b=ibkgEgo3iZ2WvtZfN28wMTijdaYTuhhwklAvM2JY2Xfb0raFllZ/2t8UQAuDJTSQ36
         o9tG30tWq8XBjsCzgJ6qVLNd8vEN1sQ8zBbYOfXhIGZSuKcCvyjKs6RQ0DcK0AlK2+f/
         1U/59kPgGTe5WL+MvMJmrcGDirup/onU7xdU8oIaewrC9Hn039//B0RVPowiMjpOEuKA
         hWEOG6vNrH+dApMD3RDUP/wO2vQCqYEHpOirh7GvmrNj9AY/dVK/VTdt2FJryCzY5Nie
         9tKpaWqkZqUQEiSGBa9vnfIIKDmbIoQcYkqVppdguQcoyipcQq7mHlryr7FxnTvkmP4F
         Qo9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=8ZilaY5NOYwAFhaPvzhLk/MxmC8VICubaNjNx3N4a0o=;
        b=h+Vmcy3A5NO2c5j7VsDRzQ4j92/9Bd60ttaEnxGPimH2iyvGIt7wJUudvVlg4nMOCK
         mdg1yuQYRYPU7elmI4QkIA5riHHUGVM/MVZ7ElRfj+FIFBrtkLOvukp+cXV9ffW/DOXO
         P91NTisAHXN2LoItNHBZX+jA5jp19xf19qaFuj3If7LEIVyEdqbdgaDvTm6mTp32nhq0
         xbXJ4IzPT/yk0sn2qbH926NTQPBVfM24I0fq6/E5q6AWOHfO9dEsb9VqKzklJJkOeWkR
         2vzqgks+09iJv7Wv6DgVPii2/nK+qedlJ/B2Fpg0I5JWMa99t8fCOPvOl+PyUp+V1mX8
         H0kg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=mFSmNdWd;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id z65si1268688ywe.324.2019.06.14.10.48.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 10:48:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=mFSmNdWd;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d03dde00000>; Fri, 14 Jun 2019 10:48:16 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 14 Jun 2019 10:48:16 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 14 Jun 2019 10:48:16 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 14 Jun
 2019 17:48:14 +0000
Subject: Re: [PATCH] drm/nouveau/dmem: missing mutex_lock in error path
To: Ralph Campbell <rcampbell@nvidia.com>, Jerome Glisse <jglisse@redhat.com>,
	David Airlie <airlied@linux.ie>, Ben Skeggs <bskeggs@redhat.com>, "Jason
 Gunthorpe" <jgg@mellanox.com>
CC: <nouveau@lists.freedesktop.org>, <linux-mm@kvack.org>,
	<dri-devel@lists.freedesktop.org>, <linux-kernel@vger.kernel.org>
References: <20190614001121.23950-1-rcampbell@nvidia.com>
 <1fc63655-985a-0d60-523f-00a51648dc38@nvidia.com>
 <f67784db-dada-c827-f231-35549fc046dc@nvidia.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <6e412091-faf4-64b6-bcd8-95193b11a6ec@nvidia.com>
Date: Fri, 14 Jun 2019 10:48:13 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <f67784db-dada-c827-f231-35549fc046dc@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560534496; bh=8ZilaY5NOYwAFhaPvzhLk/MxmC8VICubaNjNx3N4a0o=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=mFSmNdWdXrunL+Kmfxc2GVVcBRexDPEWN8Cf9I5nt85sOkU+bpOYcsFznhq/NaaeX
	 a5iKxXQ2H9+C9AGr3nzU5XEjAX2ZDLPo0DxYeTQD+ID7+125ebw8k9BdVWuuwQ9MEK
	 6gTPjhKY8ZBko1repTxcCB7eqT6Kzv3hFJgAFJefMAJFYF/n4hpe5mXW5wc6tTTPl9
	 YocB5IVfiwI2RQEvosnpfO4NcI8dsS1obRGYloyAYJTYyA2VZ5pkZu23SjLUJ/eS9C
	 yWds3z5rmjGyRmqsXnVxfjqtmHjBJzI9otX3ep/mV2T9yxsJvt7TCG1A5+06qZWnIu
	 j28SxoSKocCEQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/14/19 10:39 AM, Ralph Campbell wrote:
> On 6/13/19 5:49 PM, John Hubbard wrote:
>> On 6/13/19 5:11 PM, Ralph Campbell wrote:
...
>> Actually, the pre-existing code is a little concerning. Your change pres=
erves
>> the behavior, but it seems questionable to be doing a "return 0" (whethe=
r
>> via the above break, or your change) when it's in this partially allocat=
ed
>> state. It's reporting success when it only allocates part of what was re=
quested,
>> and it doesn't fill in the pages array either.
>>
>>
>>
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return 0;
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return ret;
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 }
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mut=
ex_lock(&drm->dmem->mutex);
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 continue;
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
>>> =C2=A0
>>
>> The above comment is about pre-existing potential problems, but your pat=
ch itself
>> looks correct, so:
>>
>> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
>>
>>
>> thanks,
>>
> The crash was the NULL pointer bug in Christoph's patch #10.
> I sent a separate reply for that.
>=20
> Below is the console output I got, then I made the changes just based on
> code inspection. Do you think I should include it in the change log?

Yes, I think it's good to have it in there. If you look at git log,
you'll see that it's common to include the symptoms, including the
backtrace. It helps people see if they are hitting the same problem,
for one thing.

>=20
> As for the "return 0", If you follow the call chain,
> nouveau_dmem_pages_alloc() is only ever called for one page so this
> currently "works" but I agree it is a bit of a time bomb. There are a
> number of other bugs that I can see that need fixing but I think those
> should be separate patches.
>=20

Yes of course. I called it out for the benefit of the email list, not to
say that your patch needs any changes.=20

thanks,
--=20
John Hubbard
NVIDIA

