Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3555C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 05:49:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8271A2073D
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 05:49:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="g4+wbBM5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8271A2073D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13AE06B0008; Fri,  2 Aug 2019 01:49:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 111596B000A; Fri,  2 Aug 2019 01:49:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF4BB6B000C; Fri,  2 Aug 2019 01:49:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id C69376B0008
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 01:49:56 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id a8so40502989oti.8
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 22:49:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=OWvjPY2RJnSXiNaT1G8Eyahp8MUAsm98cTkExQmaDUY=;
        b=LAh5XA+wiykj26A9Xa7vGSG8l5KvhrwHeao5lo5mYVzaS0ohTmTJtTQLA2afzFjMDk
         QFuUJ0aodvqhhPr5jCGZ/dujt9SB2vpYbW8z0Oj+ofc/19tfUxmjEwVpnn/5FfK9zqP+
         b1meAogetng0lTeqBzx6kXecxF86k5i96RDB7scNG+CCrD98aIXkTGZRIEpCL+VcBWrj
         I0Nds2PzlLUifb9v73ZHUVYYiAhx50LkBKiDWGcd26POMDc5butWutna2O4AJyeEX4Pm
         UyX3Tb2eKGvlhAvV3p0smOcwaQycUJ9a7A2lSiSNcrEnhLE9uS//wT9aPbvpO4XAh/9n
         5FEA==
X-Gm-Message-State: APjAAAWLBDmkwR3yL24Tmkoa3rao0YWFvT4tnwVqYwmurbEabKr+KV9B
	8AAqLSpulbwdY2S0/ena2Gsh4y7phKAYHmXL8lVbfgKz/jH+0JM6S86C4s4s3yFh072Lf6Q3R57
	DdcilYkkLF2TeqNMDtNVZzc7u0Ahr3k7y4KriDSwfnWGGrjL/1/1yv1oHsBIwQQDXhw==
X-Received: by 2002:aca:cfd0:: with SMTP id f199mr1575016oig.50.1564724996393;
        Thu, 01 Aug 2019 22:49:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4ulDvszlePjm7rOHzj25RobdLWZHfTLDdh0np8PbYKxVAKV8ljqpekRONQ+FZG1BBjGn8
X-Received: by 2002:aca:cfd0:: with SMTP id f199mr1574987oig.50.1564724995490;
        Thu, 01 Aug 2019 22:49:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564724995; cv=none;
        d=google.com; s=arc-20160816;
        b=CF587dHZKuKvoxHan8/sKnIJIJHC+O3t/w7XkbQeEndiiTr7/LRIQ7EjFoCfKxl/+n
         NCLHRMpA+1sCdEy3AkUND6Q03awNh9L1CpLL0NtJpLQYpTWmwnyb38T/L+j5j5AaCzxD
         1Bt5H4oGYd6feusU1li9xDCDZh7viKy+9ODWPhon+514oq4GRbsLLgXFJez/3A4zixx6
         5JTu433j5v84DJIaF9vthCDSuAd2f8vXZUyI6AEh5kKFPqa0BbM+Lr7KRTg2X1b90nUg
         lSob/G8YjBPE16LERiiGY9yxRhvfMtPrW/dSDanhFfOnoyXvborBuxMcUMDsGhwHU6Ir
         KCSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=OWvjPY2RJnSXiNaT1G8Eyahp8MUAsm98cTkExQmaDUY=;
        b=VV3Gw2oUVbSoTctttemtNcINtrvd/AevyViwBFOfRJ5K7mTU8lqGMae4RGPD2f3g55
         OVjXUPZhpXr6mLvJDeMppijX/L7mTNrLEhI/vQC611gezZDGOZeTjv+79ci7NaCSW5hw
         Uje35N87qTCvWfjs79NDUYLonqlz2lTolT7xfcMJsJa/KlUJWSDBQ3U3ZeTfog3BnBfT
         E1KziXrDSYS/u3NlS9AEJZGW0+2aiat654bs8+FGhaDVxfShk2nsEMTF+bEMJAHqCbYh
         gi8pff/42SREeh26uc3/iKaFjeGhQqKM0CGYovl2fTqm76WGDhyrgDEk6IyMoQEqfeUc
         whRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=g4+wbBM5;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id n31si43733897ota.239.2019.08.01.22.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 22:49:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=g4+wbBM5;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d43cf030000>; Thu, 01 Aug 2019 22:49:55 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 01 Aug 2019 22:49:54 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 01 Aug 2019 22:49:54 -0700
Received: from [10.2.171.217] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 2 Aug
 2019 05:49:53 +0000
Subject: Re: [PATCH 20/34] xen: convert put_page() to put_user_page*()
To: Juergen Gross <jgross@suse.com>, <john.hubbard@gmail.com>, Andrew Morton
	<akpm@linux-foundation.org>
CC: <devel@driverdev.osuosl.org>, Dave Chinner <david@fromorbit.com>,
	Christoph Hellwig <hch@infradead.org>, Dan Williams
	<dan.j.williams@intel.com>, Ira Weiny <ira.weiny@intel.com>,
	<x86@kernel.org>, <linux-mm@kvack.org>, Dave Hansen
	<dave.hansen@linux.intel.com>, <amd-gfx@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <intel-gfx@lists.freedesktop.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-rpi-kernel@lists.infradead.org>, <devel@lists.orangefs.org>,
	<xen-devel@lists.xenproject.org>, Boris Ostrovsky
	<boris.ostrovsky@oracle.com>, <rds-devel@oss.oracle.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara
	<jack@suse.cz>, <ceph-devel@vger.kernel.org>, <kvm@vger.kernel.org>,
	<linux-block@vger.kernel.org>, <linux-crypto@vger.kernel.org>,
	<linux-fbdev@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>, LKML
	<linux-kernel@vger.kernel.org>, <linux-media@vger.kernel.org>,
	<linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<linux-xfs@vger.kernel.org>, <netdev@vger.kernel.org>,
	<sparclinux@vger.kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802022005.5117-21-jhubbard@nvidia.com>
 <4471e9dc-a315-42c1-0c3c-55ba4eeeb106@suse.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <d5140833-e9ee-beb5-ff0a-2d13a4fe819f@nvidia.com>
Date: Thu, 1 Aug 2019 22:48:15 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <4471e9dc-a315-42c1-0c3c-55ba4eeeb106@suse.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564724995; bh=OWvjPY2RJnSXiNaT1G8Eyahp8MUAsm98cTkExQmaDUY=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=g4+wbBM5eRNl11+v4FSAl8PrvEnWACjbjTJMUv4Ewv3g+h7PgD8hueH5dPeoF8sW5
	 c20eFrVi38BUjWugKSUxA2GH7CM3A3OrXQMppFfNCHg/NTgln/g1EuAeIEfsheR70J
	 47ajhTYRdBziMz0qVCHRjvKDjLN869T+rpjyKMqZQbhfLl80UOF5a6wxQMkyYeuu5C
	 +SnQBQbOJUSigTfdZ2ZjmuC0GsGJhOMqTD72slI2rg2m1d7LKmLad2tBrS2UUN+9aI
	 ixGXEdOyIH0YMQhEWsNGgp8xCyCNq0cOZ0EzzfGMekaZZJReXbXnLe2japHjsnQzSN
	 gxuwPmkfTC8TQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/1/19 9:36 PM, Juergen Gross wrote:
> On 02.08.19 04:19, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
...
>> diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
>> index 2f5ce7230a43..29e461dbee2d 100644
>> --- a/drivers/xen/privcmd.c
>> +++ b/drivers/xen/privcmd.c
>> @@ -611,15 +611,10 @@ static int lock_pages(
>> =C2=A0 static void unlock_pages(struct page *pages[], unsigned int nr_pa=
ges)
>> =C2=A0 {
>> -=C2=A0=C2=A0=C2=A0 unsigned int i;
>> -
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (!pages)
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return;
>> -=C2=A0=C2=A0=C2=A0 for (i =3D 0; i < nr_pages; i++) {
>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (pages[i])
>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 put_=
page(pages[i]);
>> -=C2=A0=C2=A0=C2=A0 }
>> +=C2=A0=C2=A0=C2=A0 put_user_pages(pages, nr_pages);
>=20
> You are not handling the case where pages[i] is NULL here. Or am I
> missing a pending patch to put_user_pages() here?
>=20

Hi Juergen,

You are correct--this no longer handles the cases where pages[i]
is NULL. It's intentional, though possibly wrong. :)

I see that I should have added my standard blurb to this
commit description. I missed this one, but some of the other patches
have it. It makes the following, possibly incorrect claim:

"This changes the release code slightly, because each page slot in the
page_list[] array is no longer checked for NULL. However, that check
was wrong anyway, because the get_user_pages() pattern of usage here
never allowed for NULL entries within a range of pinned pages."

The way I've seen these page arrays used with get_user_pages(),
things are either done single page, or with a contiguous range. So
unless I'm missing a case where someone is either

a) releasing individual pages within a range (and thus likely messing
up their count of pages they have), or

b) allocating two gup ranges within the same pages[] array, with a
gap between the allocations,

...then it should be correct. If so, then I'll add the above blurb
to this patch's commit description.

If that's not the case (both here, and in 3 or 4 other patches in this
series, then as you said, I should add NULL checks to put_user_pages()
and put_user_pages_dirty_lock().


thanks,
--=20
John Hubbard
NVIDIA

