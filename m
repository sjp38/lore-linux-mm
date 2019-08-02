Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60438C32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 19:26:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D1CB2171F
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 19:26:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="byi/JLB7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D1CB2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B57F76B0007; Fri,  2 Aug 2019 15:26:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B079A6B0008; Fri,  2 Aug 2019 15:26:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CEE96B000A; Fri,  2 Aug 2019 15:26:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 67FED6B0007
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 15:26:41 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id l11so26635124pgc.14
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 12:26:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=rRhheBqnK3+cjDjuz6CHnpsz5YflbO5z8PXp1A2YK5w=;
        b=p+bZsru/LHCq4JAkIEKrmziNTHE+RD4QoDIcJ2ADJhxwoPLEkfffy6pESmZyTA5B8G
         lHnSWVaOTrTpd2xtr+noDvZ9aFatkmMKipuI4n8pNuC7PZ9tTnTaV6rxQkFX8L6g87Aa
         uvv+Zl2Uhvu0mYp8xDyaysDmH99drlb9cqPG/s1LtVMLuLQ20ktIUsuNSWO6fUNcUt0i
         gaTOdKwSD5SkLmx+XN2ITX7fTN5AhhLXDz4N1Z4SQ7DwdfWN2hbiOi+WeCTVcSUK/lEO
         7t5Wsw5+bjyxvNUuKujssgXj7rnvYqsClxc83KQwYFYElxi/L/KzHVxjoCMt8rpEt6O8
         EhTA==
X-Gm-Message-State: APjAAAV9ddZV6TJDFB0UE5geMc06Z8/Kz1+fIT/jDbVFKhdOhKixZRDM
	fqZa6VBRTnX2hD5c8Exwe/VDFXcQwWL2cyB8uP0Uqvom7PpBbJViGUb/G7v1jvjK+y0FYAuUKHb
	xP7GmDMM2o1Ph7HNEQBTWNxN/rn+pDP43MY79nAVcJsF+f9C5ILo8ts53olrKYlksag==
X-Received: by 2002:a17:902:9a49:: with SMTP id x9mr134094144plv.282.1564774001103;
        Fri, 02 Aug 2019 12:26:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsSGTkasG7L8B++rgeAGkUyCuCexxhiD8j4EYGs2wSAEvDZWoChlzqiqwDwvFTWk4ACwS2
X-Received: by 2002:a17:902:9a49:: with SMTP id x9mr134094105plv.282.1564774000452;
        Fri, 02 Aug 2019 12:26:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564774000; cv=none;
        d=google.com; s=arc-20160816;
        b=ROe38pcur/JxD7MtpGtDjd0TgR2+aaEt9oX+CWEl66doJbXqDN1IkTaMrx4T85uWsD
         BenZEX43UdJEsBzFRmr+kTdsL8jWH6qxt3iF8jETRXfaicNr5Zy7OArRKRj+9z28t69M
         s0civB0qsQK07gAqKbOA2vTmJVWT3MZ7ODGMKevMmLE3e7x8dpvhYcp3FzVIRIvV5ppT
         YzR/b+ZMdcssYW4YS9V6cvk2EbA1XJqXFQj45oJhckinwzEut4ny7ad055NnQDdlIDpE
         aoY+A6p7Eds3vZZ18GI/eEJhxQxgE608IjJYgzdx+DJ3MGtQefADcEBgmN6tM9FwnNgr
         H5Zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=rRhheBqnK3+cjDjuz6CHnpsz5YflbO5z8PXp1A2YK5w=;
        b=IznznTU+QVVZa2h0KEncZgUhRi6BwRI3jN3+Ra883ATXwXqyuepMgRfvlDmPOS3wS/
         zJf0m/sZRzTGRmjtRnZ2vjn58yKgNdrbGlBOTcJLS6Je5JZ40EUr29RvfDif9KF7aQ1e
         lFgSvf0CUyT2sfxLQTjwwU6ZSFD6cIOyhDoSoeklEQ3bSNE164OXiuThFiE3PH8gy7jJ
         N9oSZTRc7HO0fHJ7LgegoyeyhACkidn6GIzgoy+Ngk25dXf5rxujA3ecxUOxrZ+oAh6E
         b/B25D1dXY883cTuHvwlFrY9vdU9HZzZMcZoHvI4L2LCd9OCw6DL0z38nKxYBhUF4TBG
         Ojyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="byi/JLB7";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id x4si37855707pln.70.2019.08.02.12.26.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 12:26:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="byi/JLB7";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d448e710000>; Fri, 02 Aug 2019 12:26:41 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 02 Aug 2019 12:26:39 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 02 Aug 2019 12:26:39 -0700
Received: from [10.2.171.217] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 2 Aug
 2019 19:26:39 +0000
Subject: Re: [PATCH 20/34] xen: convert put_page() to put_user_page*()
To: "Weiny, Ira" <ira.weiny@intel.com>, Juergen Gross <jgross@suse.com>,
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>, Andrew Morton
	<akpm@linux-foundation.org>
CC: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Dave Chinner
	<david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "Williams, Dan
 J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Hansen
	<dave.hansen@linux.intel.com>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "intel-gfx@lists.freedesktop.org"
	<intel-gfx@lists.freedesktop.org>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-rpi-kernel@lists.infradead.org"
	<linux-rpi-kernel@lists.infradead.org>, "devel@lists.orangefs.org"
	<devel@lists.orangefs.org>, "xen-devel@lists.xenproject.org"
	<xen-devel@lists.xenproject.org>, Boris Ostrovsky
	<boris.ostrovsky@oracle.com>, "rds-devel@oss.oracle.com"
	<rds-devel@oss.oracle.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jan Kara <jack@suse.cz>, "ceph-devel@vger.kernel.org"
	<ceph-devel@vger.kernel.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	"linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML
	<linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org"
	<linux-media@vger.kernel.org>, "linux-nfs@vger.kernel.org"
	<linux-nfs@vger.kernel.org>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "linux-xfs@vger.kernel.org"
	<linux-xfs@vger.kernel.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802022005.5117-21-jhubbard@nvidia.com>
 <4471e9dc-a315-42c1-0c3c-55ba4eeeb106@suse.com>
 <d5140833-e9ee-beb5-ff0a-2d13a4fe819f@nvidia.com>
 <d4931311-db01-e8c3-0f8c-d64685dc2143@suse.com>
 <2807E5FD2F6FDA4886F6618EAC48510E79E66216@CRSMSX101.amr.corp.intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <746b2412-f48a-9722-2763-253a1b9c899d@nvidia.com>
Date: Fri, 2 Aug 2019 12:25:01 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <2807E5FD2F6FDA4886F6618EAC48510E79E66216@CRSMSX101.amr.corp.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564774001; bh=rRhheBqnK3+cjDjuz6CHnpsz5YflbO5z8PXp1A2YK5w=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=byi/JLB7CNtV06561y8XoJ3SAPfLWvMAReG7pbHQL4vyYMWIeKNh0N7pvRnXFQG1L
	 qdrcKeqyYLdfyHlBvNt3iltX04f4l9yslTmpDdtWvq1t3b7bkuO+rrbkZHys+WsmhV
	 6Aa9W+8qQAz5X83c7tyDcDc6Mg36wKOuzq27pabbfn+69ez0SBMHEuaNtlKh20Fcaj
	 gTip6LdymKj+uFDjnVTxb7sYVNWRS9rebCu5gBiFOf/CT8TUXKtD/8+Sk9b10OKO7l
	 1Y0kk6maXEh1JdSy6qqRDc1JYyIdeVQu9Kdnt4cKXn6PzYq3IXSks/FI+pwJb3dRVj
	 9ZhtT6T5hfRNQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/2/19 9:09 AM, Weiny, Ira wrote:
>>
>> On 02.08.19 07:48, John Hubbard wrote:
>>> On 8/1/19 9:36 PM, Juergen Gross wrote:
>>>> On 02.08.19 04:19, john.hubbard@gmail.com wrote:
>>>>> From: John Hubbard <jhubbard@nvidia.com>
>>> ...
>>> If that's not the case (both here, and in 3 or 4 other patches in this
>>> series, then as you said, I should add NULL checks to put_user_pages()
>>> and put_user_pages_dirty_lock().
>>
>> In this case it is not correct, but can easily be handled. The NULL case can
>> occur only in an error case with the pages array filled partially or not at all.
>>
>> I'd prefer something like the attached patch here.
> 
> I'm not an expert in this code and have not looked at it carefully but that patch does seem to be the better fix than forcing NULL checks on everyone.
> 

OK, I'll use Juergen's approach, and also check for that pattern in the
other patches.


thanks,
-- 
John Hubbard
NVIDIA

