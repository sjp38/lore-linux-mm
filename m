Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 211BFC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 18:52:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C819A20B7C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 18:52:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ot3YKf5t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C819A20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B4246B0007; Fri,  2 Aug 2019 14:52:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63FC26B0008; Fri,  2 Aug 2019 14:52:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E0386B000A; Fri,  2 Aug 2019 14:52:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 12A9C6B0007
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 14:52:55 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n4so41630154plp.4
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 11:52:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=CFAZPyZ9nyhPuztKsk/cdMMUIvZ+gPTM3kJiO5Miqjw=;
        b=sy0RibOiJxlBQMMmA3pHZxHECSlZXvj6cuAiz0WHFD3cQ+j0h7gBNC0C51KPPBJdhF
         H9C0W3WAqgfw8EJdH/+K1W60AXWEwGkPTZbr27w3/odnaTDl+PKpslcsUeIJV0pWEfTk
         2EgQsLUDcuyAvlPv+np56sJM5hl6mJxT6x9uIqVeBAtro8HkBTJg6B4VFJNwdO1X2ajJ
         4hfzurgjazbwPZlNOyafcQnBy/M82mT7NedONoPJ3YY5DfTziRQuXEpY4r7stJ0rZHJx
         JUYrr4oiIWKWpFf4EqdfilCaoNRF2oHTS4wo2Ax8zYhcwy9g7jQ0Niq4QVIMQbBeKjrz
         Nipw==
X-Gm-Message-State: APjAAAV3FWJtPPvCqMCKGJ90UvugYYOH0QwiQogyL+r+xvV4YHQ4ZrFv
	QPla3h7g5rIHb4psolnVpGTho3P4A/xN8Tk50gr/4+5EFql65B7/plycIVEbx50JCZasfBIIlbv
	vqBuTcgrUKTeNOsjZTZfZwVTj+NoWNxmQ4UZFenSPD4F00RVA0l1LB2KDxiymmYf5HQ==
X-Received: by 2002:a62:e20b:: with SMTP id a11mr61817512pfi.0.1564771974573;
        Fri, 02 Aug 2019 11:52:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuG3SVXzBtzfSJ2zPJk0Du+zb9hl52jhtyELbYCUC6dJzdTBROjbvOyxwTMEJPIMX72puQ
X-Received: by 2002:a62:e20b:: with SMTP id a11mr61817454pfi.0.1564771973844;
        Fri, 02 Aug 2019 11:52:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564771973; cv=none;
        d=google.com; s=arc-20160816;
        b=kLsjwJ9Azvblm0JDMx/EQPVe7nSwwKpbTxdNSDaQcv3+DPHYyMo76DZGLIw2CermE5
         IanJFzIg/a0Vn+Y+xvAuf71Eaa4yAsl5UQdU3mFuq59CwnpG0cGv0C6ucyIV24atnDIn
         ++vByC32rBIJGX/3gRMsAVthUJ7N+DgGrKV3vb1TnSZ1hBHyN5UlfPa/l0nFZW5yJfFB
         pymMSQsY4Vby6gVfZNwf5ct+l+QfmzVZQnWTucsTteq1fiewL3HNCu9UEeNwSyROyar+
         zXJqijBvX72FGLpuxTpHLJpYyEyFxtCA7zJFxPoZ1gYsWjpc+hONTJ+FwNil+W7KtgTD
         BJ5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=CFAZPyZ9nyhPuztKsk/cdMMUIvZ+gPTM3kJiO5Miqjw=;
        b=BMdDumR3X7fcAwjS4dA4Z3HCYOrEPyYPebYKKVGnKS3/vtKk8BK0vlz9V6xUOzcrUP
         AuBv8p6t33mMxMSI207ZaB2hXqyzezWPNLMXiw81rMV9Z5dR1mbWjVNUNGooogtJoa9F
         2LTgfYqmEG4kfev3b3Aivb/ecyHRH+6GgRk6S/QM0jYebxx6opV9hDG+yeVZEUCX0P4Z
         zRlW44RwXO5fUgAcztEU58dw2/wnVbWcQTcYQU6WhvtQmvlyKh/QAeTsJ0yEcdjHcHfF
         mkBbzR3pEAUZP3RkGFDTjGyzSoQyrPKDe6tF1xSe9Yot5m0lhN9gbpFQGs0sXu+rEsA7
         trcw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ot3YKf5t;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id c127si41546704pfa.20.2019.08.02.11.52.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 11:52:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ot3YKf5t;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d44868e0000>; Fri, 02 Aug 2019 11:53:02 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 02 Aug 2019 11:52:53 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 02 Aug 2019 11:52:53 -0700
Received: from [10.2.171.217] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 2 Aug
 2019 18:52:52 +0000
Subject: Re: [PATCH 16/34] drivers/tee: convert put_page() to put_user_page*()
To: Jens Wiklander <jens.wiklander@linaro.org>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
	<hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner
	<david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ira Weiny
	<ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<ceph-devel@vger.kernel.org>, <devel@driverdev.osuosl.org>,
	<devel@lists.orangefs.org>, <dri-devel@lists.freedesktop.org>,
	<intel-gfx@lists.freedesktop.org>, <kvm@vger.kernel.org>, Linux ARM
	<linux-arm-kernel@lists.infradead.org>, <linux-block@vger.kernel.org>, "open
 list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>,
	<linux-fbdev@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-media@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<linux-rpi-kernel@lists.infradead.org>, <linux-xfs@vger.kernel.org>,
	<netdev@vger.kernel.org>, <rds-devel@oss.oracle.com>,
	<sparclinux@vger.kernel.org>, <x86@kernel.org>,
	<xen-devel@lists.xenproject.org>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802022005.5117-17-jhubbard@nvidia.com>
 <CAHUa44G++iiwU62jj7QH=V3sr4z26sf007xrwWLPw6AAeMLAEw@mail.gmail.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <23cc9ac3-4b03-9187-aae6-d64ba8cfca00@nvidia.com>
Date: Fri, 2 Aug 2019 11:51:14 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <CAHUa44G++iiwU62jj7QH=V3sr4z26sf007xrwWLPw6AAeMLAEw@mail.gmail.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564771982; bh=CFAZPyZ9nyhPuztKsk/cdMMUIvZ+gPTM3kJiO5Miqjw=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=ot3YKf5tvKuqvfXnHFOaqaBQdxJLPGhqZRpe5CvAqHZLCjzw07N/807rN30ol1bdm
	 nSwbs6gHuJ0OhztqkvSHwPR2slPtTDH8B6O0PTm5jeGujoQh8m+xI16KJQgg3RcoMR
	 UmCB87Ti9N/9lxRub68goKft4A4cSSIx2dfCYEbKRo3lQGuFQW16SKp/EWIKLGs/zO
	 EK17YqQ1lGvgW/45aW7/Z5pzy0Gf5VysXOYCi076on7MtH51Ov9Uy2W59ssEl2aP4N
	 G3YJtwUCv04lDB6y7cBERLsZUR9V90J5rUhO14bUw0xWFxWN4jqCBXztLnN9RVkDQG
	 l2CwayAFuEHwg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/1/19 11:29 PM, Jens Wiklander wrote:
> On Fri, Aug 2, 2019 at 4:20 AM <john.hubbard@gmail.com> wrote:
>>
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> For pages that were retained via get_user_pages*(), release those pages
>> via the new put_user_page*() routines, instead of via put_page() or
>> release_pages().
>>
>> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
>> ("mm: introduce put_user_page*(), placeholder versions").
>>
>> Cc: Jens Wiklander <jens.wiklander@linaro.org>
>> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
>> ---
>>   drivers/tee/tee_shm.c | 10 ++--------
>>   1 file changed, 2 insertions(+), 8 deletions(-)
> 
> Acked-by: Jens Wiklander <jens.wiklander@linaro.org>
> 
> I suppose you're taking this via your own tree or such.
> 

Hi Jens,

Thanks for the ACK! I'm expecting that Andrew will take this through his
-mm tree, unless he pops up and says otherwise.

thanks,
-- 
John Hubbard
NVIDIA

