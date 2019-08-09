Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E36AC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 01:26:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58AE5214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 01:26:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="sN/0osHq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58AE5214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E924A6B0003; Thu,  8 Aug 2019 21:26:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1BAE6B0006; Thu,  8 Aug 2019 21:26:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE4086B0007; Thu,  8 Aug 2019 21:26:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 94BC96B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 21:26:45 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x18so60278597pfj.4
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 18:26:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=mIo2y95DYwpm5TwfN0ChMwsAj72bzfnkFfj+rLdjqVU=;
        b=LNQsiuT8JR1ghsKHkDfqO/acVS4ZmU5v3WkYiFzLRZBj6Y4tYJQN2Pv63UhBIHucHY
         4CyvH5yRSIrYeFCoYZa5TqDYTNajwuIfvg/09icQ5IcSsTlYfZYz3A0AWQPGkeVU16Uy
         OUlpdlS6FLn0Wdp7MZOGZ4B2W4cqEO1VeP6VYQXhkCx8SO8A+XRQVvk7d25xcCUYc8qq
         vmLp7osAT6RbnDVV5/U+tFWZDGjF9cL56KMs7Q2PLSN1pxwyh5bDN4OTq/FKJQWAE804
         /oBsdlnro3s+cm1U398ofN16UwQn/2NFPfxsG71Gmsk+qk5QBVlrmXciu7fh5Uh7fMgL
         61dw==
X-Gm-Message-State: APjAAAUukEj/oc5SJp95eo3zQJvlDeSryOvXVvgovUQdEcGkVYra+IBS
	up6Pq81gKunx03ROUm9E4t6fioC4N4EYMRwsZHj2EiRKILly7fKgCNxq0eY0cDMMIBXL6fYDBVr
	WCKqGexH+QoOKn0ie9knYlzRuhChyuWzD9AtPgHzZHJOvRDy7jh17MxzuL16y36WUJA==
X-Received: by 2002:a17:902:9307:: with SMTP id bc7mr15953195plb.183.1565314005278;
        Thu, 08 Aug 2019 18:26:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHOKm73I32twWRG4Gk8Gq7chR8xTmQL2RaYpjdU5+X2tAWi7I2VbSHN3jnxjis3n+yIAEO
X-Received: by 2002:a17:902:9307:: with SMTP id bc7mr15953154plb.183.1565314004530;
        Thu, 08 Aug 2019 18:26:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565314004; cv=none;
        d=google.com; s=arc-20160816;
        b=vhK+nlls2izqwqCMuzjFnl+d005VqrdHpH/XBspf6EShWlR4rNLW3bPfmMIojv/0OB
         jGpOAy4KRcDVNwNdWfL9AvnUOwNw6VmHyjU8sJCxav2TMW2cuH33HwjypU5wlpZuXJFL
         DTWXdT98M7M1/CVO6OIwD/sDtsWs56Gdf4qQCArwdHRh6+aREvV7B2eiqv/yoOJHr4qo
         8y4a6fvMeIu4r//Arus4+6WstXuPvQ/VT547EIM5sC4a12pFfvk9m2B9ABIKfWbG2URk
         3GtXYkyUZ/ciSFUB4dKLEwF4mkguGDgS4WSOZQ719QcqE7idfUfFP0pPbFZAWZY78dXZ
         mM/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=mIo2y95DYwpm5TwfN0ChMwsAj72bzfnkFfj+rLdjqVU=;
        b=Pt0Bans3o8BXc9viLxLwBBk6u8Vjiw+kCpYZRwOw+Vcv96l4H2/pyxOjk37W6RCi/N
         kOQJ4lPJ0D+t0eaoI5arDYnvaEyJ8JnK1f7CHz7aHfHyqpcff1do6u4x7OGuSy//t+B/
         MeZBbOV3GtdI7Evn9KFLvazKPXzxdPySheLQAOAn2SJou6plmlK4CVNnEUy3MyVoL2rZ
         gWlFYIEXm66CEukFt7DBVJV+Tr8mQo6ziPD2xW2caeyQ4FIjWrjSdsab3nQhrJ/jm9tg
         A+/jFRuBmjyfqCKpc5tiUtCh9X341/SOvyOpbwBVinxYkDLJ8rKqcaWRnnQX/LqD7uow
         z57w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="sN/0osHq";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id bi3si46579380plb.226.2019.08.08.18.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 18:26:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="sN/0osHq";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4ccbd50000>; Thu, 08 Aug 2019 18:26:45 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 08 Aug 2019 18:26:43 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 08 Aug 2019 18:26:43 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 9 Aug
 2019 01:26:42 +0000
Subject: Re: [PATCH v3 38/41] powerpc: convert put_page() to put_user_page*()
To: Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton
	<akpm@linux-foundation.org>
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
	<xen-devel@lists.xenproject.org>, Benjamin Herrenschmidt
	<benh@kernel.crashing.org>, Christoph Hellwig <hch@lst.de>,
	<linuxppc-dev@lists.ozlabs.org>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
 <20190807013340.9706-39-jhubbard@nvidia.com>
 <87k1botdpx.fsf@concordia.ellerman.id.au>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <248c9ab2-93cc-6d8b-606d-d85b83e791e5@nvidia.com>
Date: Thu, 8 Aug 2019 18:26:42 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <87k1botdpx.fsf@concordia.ellerman.id.au>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565314005; bh=mIo2y95DYwpm5TwfN0ChMwsAj72bzfnkFfj+rLdjqVU=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=sN/0osHqfMASG3Gn5uYJsmBevNgkDITrwy5z0XhYDRnSVjTtczC6Zn93vXUVACtgl
	 zsE5J5OQn1U0e8RQtUv/QuY5iXNoztc7U7xk0b8D/XTbbdQX85oERprBP+FlchEBmH
	 cDA/Z0zP30Are5EcBXQtJgaAWOYtGMQytxGRabpoiJwuifLVi+3nH2crRLrU8L/jsz
	 NjANrKoFZE22mpOq52s3fZ9ut+mKAUlAXHfdi2WiqPjr5KVieTASv9oPdSZ5QUx628
	 sL0qbeXqIPI+CnsO9wdJm+9w+qSRY9+X67MIO8EOa4e3TPJTGVb16/VuBW7YteYrzL
	 bdoBRcdIA11ng==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/7/19 10:42 PM, Michael Ellerman wrote:
> Hi John,
> 
> john.hubbard@gmail.com writes:
>> diff --git a/arch/powerpc/mm/book3s64/iommu_api.c b/arch/powerpc/mm/book3s64/iommu_api.c
>> index b056cae3388b..e126193ba295 100644
>> --- a/arch/powerpc/mm/book3s64/iommu_api.c
>> +++ b/arch/powerpc/mm/book3s64/iommu_api.c
>> @@ -203,6 +202,7 @@ static void mm_iommu_unpin(struct mm_iommu_table_group_mem_t *mem)
>>  {
>>  	long i;
>>  	struct page *page = NULL;
>> +	bool dirty = false;
> 
> I don't think you need that initialisation do you?
> 

Nope, it can go. Fixed locally, thanks.

Did you get a chance to look at enough of the other bits to feel comfortable 
with the patch, overall?

thanks,
-- 
John Hubbard
NVIDIA

