Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40DF4C31E40
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 20:03:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E39D82075C
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 20:03:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="I2YSIJHt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E39D82075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 814936B000E; Sat,  3 Aug 2019 16:03:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79DB56B0010; Sat,  3 Aug 2019 16:03:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6669A6B0266; Sat,  3 Aug 2019 16:03:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4326B000E
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 16:03:10 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 191so50580856pfy.20
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 13:03:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:references:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=ilU/8cKxAxLoWjJW9QtQ++HPyf9Kp7C47ReaMR8aBDk=;
        b=G/ggzv6UbYDZAjo7SvHgdqcW5VMyETwNY7C5/323YBRpgFQKXBSXBFu1YqostDlEMr
         zUsNPeEcJKOBJTaupcQi5zgCuO+wT3tqR9WALYwYKSGwWn3teorOiRK92xvXcJhT7wsZ
         hB9zQ1gUIG2X3Rp0SVgjDS+twR15jLLgLvmRI8jOFbx9QrrOqcl4Dy3dQfcUgpxsXXib
         imBxnUKmNvhk93N548ZlkQXbH7feirrDkT2dV79X1paZxLsGNPZeC6k6BZNY3Hxtooh8
         oPkypgXniq5i32oEWjJoJULLUHXIf1pBIWemiGle19l2cir7zwsO0EmfPvPYSU2QclGD
         btcA==
X-Gm-Message-State: APjAAAVRoyvOalltT9XN7PNv4kETW9kCZX++FppNW7hs0tutuwCOTqo1
	XcvyGAE0vLnpMPLfWTvlUKyhIoCogla8rnK6uANbjXv6FfGch+7iJSh+n8ZzD+fBdLua50hoWdh
	1lz4KM2I2dk/OzA9uahXXE+jKLEmBYT15WyKX/wF1x2Kwqb5vj3gp5woDjL64HsJLXA==
X-Received: by 2002:a62:1bd1:: with SMTP id b200mr64746091pfb.210.1564862589735;
        Sat, 03 Aug 2019 13:03:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsJ8Zp/p4Z0nXqNrBHean3d+qzRAYSseELIE6NHQlXksoEwaLN+0sKb3xc1eqwMEBWtJca
X-Received: by 2002:a62:1bd1:: with SMTP id b200mr64746049pfb.210.1564862589005;
        Sat, 03 Aug 2019 13:03:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564862589; cv=none;
        d=google.com; s=arc-20160816;
        b=KMk62AqivdFhxZW19HbWqlC6P6KYv15ippWTgVqxe5SZcwwvnn9+5n2k3rYzPAMiwZ
         OWV1FZf8Qy/BraSmbJ8+sv99Uk+dli0xCUrut7dj1jdQcNaC/BZHDqksdCX2SF+xAnWW
         kpI+77m5EPFHu6zDHpgkzinRjs7LD8SFSUQf8le+IYQq/fCczdoACIiJokeQMzoLzZ7V
         ZeDBzylSr/XRpMiNerrldF8Z5FwiQyxOqaoKD7j/8LZ9nAzFgqjx/J1hi4QASUTZnFes
         sVudLsfTWlqN3wAfDaimsdXfpcif5d+lTST+kBF1mY1Oz5q27T/BzNp/WDIlUVH0JLTB
         gUpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:references:cc
         :to:from:subject;
        bh=ilU/8cKxAxLoWjJW9QtQ++HPyf9Kp7C47ReaMR8aBDk=;
        b=O1p0EhW2GDk4znHxcLInkUAWM848aykucO1JF2c8h4J0FWHIYwZxszpM7yg7YQDcnl
         OK/tkPxnBsAPCypheRoJEl4wK/zq8M4NEbTAQMxwYnAR1TmVOSjybI/2FcOrGAZL4YpQ
         omz4YR//Hh+D4DeDAp2oS1ZV1hN0p86TTXfEWkPeVQC4KlpG6KfKi5jjGOHIFB1lwR20
         iaNqtJKiVlfv9jbPJ5xwwoEjiVSxi4RX2u1eUkoj1fjyGMPSs+jnQE5nFMju5ESQcocL
         rdLjmwYrJdsWGiwj2cfa1VvLy1wwp+4XBONg9+V1VeMKntIj7ywvcr7+G86oJInp0RQt
         /3xw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=I2YSIJHt;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id cu6si9055325pjb.102.2019.08.03.13.03.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Aug 2019 13:03:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=I2YSIJHt;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d45e87a0000>; Sat, 03 Aug 2019 13:03:06 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Sat, 03 Aug 2019 13:03:06 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Sat, 03 Aug 2019 13:03:06 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sat, 3 Aug
 2019 20:03:05 +0000
Subject: Re: [PATCH 06/34] drm/i915: convert put_page() to put_user_page*()
From: John Hubbard <jhubbard@nvidia.com>
To: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Andrew Morton
	<akpm@linux-foundation.org>, <john.hubbard@gmail.com>
CC: Christoph Hellwig <hch@infradead.org>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, Ira Weiny <ira.weiny@intel.com>, Jan Kara
	<jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<ceph-devel@vger.kernel.org>, <devel@driverdev.osuosl.org>,
	<devel@lists.orangefs.org>, <dri-devel@lists.freedesktop.org>,
	<intel-gfx@lists.freedesktop.org>, <kvm@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-block@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>, <linux-fbdev@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-media@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <linux-rpi-kernel@lists.infradead.org>,
	<linux-xfs@vger.kernel.org>, <netdev@vger.kernel.org>,
	<rds-devel@oss.oracle.com>, <sparclinux@vger.kernel.org>, <x86@kernel.org>,
	<xen-devel@lists.xenproject.org>, Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, David Airlie <airlied@linux.ie>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802022005.5117-7-jhubbard@nvidia.com>
 <156473756254.19842.12384378926183716632@jlahtine-desk.ger.corp.intel.com>
 <7d9a9c57-4322-270b-b636-7214019f87e9@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <22c309f6-a7ca-2624-79c3-b16a1487f488@nvidia.com>
Date: Sat, 3 Aug 2019 13:03:05 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <7d9a9c57-4322-270b-b636-7214019f87e9@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564862587; bh=ilU/8cKxAxLoWjJW9QtQ++HPyf9Kp7C47ReaMR8aBDk=;
	h=X-PGP-Universal:Subject:From:To:CC:References:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=I2YSIJHtEvh6s6ys5+qZOy9oK09e18lfnMQt77fXZCyrgzqntxCUGfZ7oWikmHJt5
	 4V1+y4MySAejsYy1JLbf4x7KQ0hiidb6jg5xsakkPPG/MxjywoS180jIN6uhV11y/O
	 011sP6dgxSCe7CPHZfVmc5h9v3h4EFz6CzWGnO3zjeLQA+xNf7n8Aq4VIo5dqejc1s
	 ogxZqWO3QmjUKVwNVzjjVrVg9ptoPI8+f8bAuuTtyZ6ixyHn7fxeF7f3r5zkr6u4id
	 LKe10E8R/74E4Fa+DG9GwiVmNsBu++raNIZCy4+8RyCJBTlO14Pl8lc8yCIpDgUHCO
	 oxDfeJ3aA6pnw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/2/19 11:48 AM, John Hubbard wrote:
> On 8/2/19 2:19 AM, Joonas Lahtinen wrote:
>> Quoting john.hubbard@gmail.com (2019-08-02 05:19:37)
>>> From: John Hubbard <jhubbard@nvidia.com>
...
> In order to deal with the merge problem, I'll drop this patch from my ser=
ies,
> and I'd recommend that the drm-intel-next take the following approach:

Actually, I just pulled the latest linux.git, and there are a few changes:

>=20
> 1) For now, s/put_page/put_user_page/ in i915_gem_userptr_put_pages(),
> and fix up the set_page_dirty() --> set_page_dirty_lock() issue, like thi=
s
> (based against linux.git):
>=20
> diff --git a/drivers/gpu/drm/i915/gem/i915_gem_userptr.c b/drivers/gpu/dr=
m/i915/gem/i915_gem_userptr.c
> index 528b61678334..94721cc0093b 100644
> --- a/drivers/gpu/drm/i915/gem/i915_gem_userptr.c
> +++ b/drivers/gpu/drm/i915/gem/i915_gem_userptr.c
> @@ -664,10 +664,10 @@ i915_gem_userptr_put_pages(struct drm_i915_gem_obje=
ct *obj,
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for_each_sgt_page(page, sgt_it=
er, pages) {
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 if (obj->mm.dirty)
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 set_page_dirty=
(page);
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 set_page_dirty=
_lock(page);

I see you've already applied this fix to your tree, in linux.git already.

>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 mark_page_accessed(page);
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 put_page(page);
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 put_user_page(page);

But this conversion still needs doing. So I'll repost a patch that only doe=
s=20
this (plus the other call sites).=20

That can go in via either your tree, or Andrew's -mm tree, without generati=
ng
any conflicts.

thanks,
--=20
John Hubbard
NVIDIA

