Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 553EEC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:39:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AB6C20665
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:39:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="aftmkmmN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AB6C20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82FFB6B0003; Thu,  1 Aug 2019 22:39:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E1116B0005; Thu,  1 Aug 2019 22:39:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A8C96B0006; Thu,  1 Aug 2019 22:39:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3DF8C6B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:39:03 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id v49so40372319otb.6
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:39:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=uB7qKWJf2vIk7MCI51NrKGKnU0tjP3n9YQM4FSsQ99A=;
        b=GJbpe7JmFH8VwEUr/hNjD9kN3QtuSY7mLg9zV8j+mLo4VeVoG6TworhLC/YhHy+g6O
         ghHJ09fm5dU5nQv8UuVdM9mksVYbXtIUoGhL5smv/B70AUvmRjxor18VfIqMsdNJ6VDL
         JJDNfpDYEwetepZDuHyCZgYoHnk5L1Pzg26/pPKPE1hFCHsose/X/fdPg/NsJO7LolJU
         JzBy2/e6/MtAj5NI5vetiZBHcHS+aY2cnIV5ckVFXo0EClroaL8cE5QeTzBcn231kEyq
         gWGu8ar7LLDD1scm3ecPlPXTA7fcWQCn9JAjBwp8CeZ0xzsBUZPQmYotEDlR87onL1if
         jk+g==
X-Gm-Message-State: APjAAAU+A0OxtZCKSvkJEETpF4WVxILLMTvHRFxS04K2D4w+q8cUpGCj
	A8k3mXUGn5mLwKja//kYIvV1y/X0OaF5wUoLESiajrNIZe0mBmNLodtdMYkBP2H5VLxy3iAO/Oj
	dfIEE4gPIzyAK66QOrlbKRvY5hD2U/KOLbrVzLyFjLoRVrEmtFVvQML0N39zymQgTOw==
X-Received: by 2002:aca:5641:: with SMTP id k62mr1297130oib.142.1564713542803;
        Thu, 01 Aug 2019 19:39:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqw6SmA7w8aOeMENbtnK9KOAyxWgfR/MiljUVxaXJXO08oDhSclHYhVPMe9G1CIypQAdwz
X-Received: by 2002:aca:5641:: with SMTP id k62mr1297105oib.142.1564713542129;
        Thu, 01 Aug 2019 19:39:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564713542; cv=none;
        d=google.com; s=arc-20160816;
        b=iWGgTjV9GiJqwNaUYjOw3k8XhupMZodQXL94g/XxKE2P4isijJBF5BmGMYIAXudMo+
         nDiiG6DoYSasoeysAwfDfyT4jnMJiaA60iFC9SxvU3bXMHFagRnz6tlCYQNYflIerOyh
         CknZmpeJD4gruN7oNRD9UJIRCRMv+Q+hzmTTB+PKvzkpPqYI6+mwTdU1Ti1/BMHlYEwj
         QCnhN2v/PEU8SMuPLjXcKdqIh30U0qa7Aw0yftg0rDB45zCaXO/zYesrrIzVtC4q8NTW
         qFkXpKZOCRzzzpl5y3RtRgJxlEiSziIEFJBeLSdFugWp8n0kz6uAtmBOKHtj43o2B/4k
         T6JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=uB7qKWJf2vIk7MCI51NrKGKnU0tjP3n9YQM4FSsQ99A=;
        b=o6GF1QEWYYQeHynBHVo+x0uG1O5y+LipTHkIXI/xZAS8skcLJ8iIfXbavwXqfzijkO
         tY/gCblausDfMnQeyMuHsyc/wfjYzUmkKmM3UXc50ZuvNHo57Vd87qmyTWP+7uBXU5kn
         7636jAG6/NYJqtKWgxHhepsIcicMSEIIq0RDbMk1Hc0VDpHBpAVCzHTal5MVKGP8PZmf
         G+3UhiXGIZ3Dm4u2QbHgxVDb1TufFpguQFHtvTTkaEsUPdsB7FgrwpLX6aLaj6TWY3zK
         n9wsV2Vlpo+STAmYvj4d0LZqUL0r1lWblH4eR2FraeqOTGXrmp+KMUHG/MPmHpI5PrtT
         YUMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=aftmkmmN;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id s17si22680288oic.0.2019.08.01.19.39.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 19:39:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=aftmkmmN;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d43a24e0000>; Thu, 01 Aug 2019 19:39:10 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 01 Aug 2019 19:39:01 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 01 Aug 2019 19:39:01 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 2 Aug
 2019 02:39:00 +0000
Subject: Re: [PATCH 00/34] put_user_pages(): miscellaneous call sites
To: <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
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
	<xen-devel@lists.xenproject.org>
References: <20190802021653.4882-1-jhubbard@nvidia.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <ec87b662-0fc2-0951-1337-a91b4888201b@nvidia.com>
Date: Thu, 1 Aug 2019 19:39:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190802021653.4882-1-jhubbard@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564713550; bh=uB7qKWJf2vIk7MCI51NrKGKnU0tjP3n9YQM4FSsQ99A=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=aftmkmmNomCdfG4/nsU7QFjmse0kzSiVn7k6qdyITGQKtpIb7fXB3ira93x2ikjhP
	 hh9fWh6OxSH7I4ITUxx9rk4nMXoUcCl6xE7j7d8OaKs0QzK3tWjGXYe1PPsA5+CMkF
	 sKiN+5/hdBTh4TsmJWAPetkvcksKG1W7KX4K24lGpfHw6t/QQ4fbKf5zlriq/zHiCI
	 WN7lLvY4tFrWOLTfdOFRIa/sFBuq00RVcHrLnsHi/Dnbw2dVeWXrugMTAYnP04jnRA
	 tXP1GLNpYcsDC/T0sb/csl6pvYXC87xnKjlVca8dQdSp/cuFTGUobSHcHyKfqM9q/X
	 eCw5n+JFkzHyg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/1/19 7:16 PM, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> Hi,
> 
> These are best characterized as miscellaneous conversions: many (not all)
> call sites that don't involve biovec or iov_iter, nor mm/. It also leaves
> out a few call sites that require some more work. These are mostly pretty
> simple ones.
> 
> It's probably best to send all of these via Andrew's -mm tree, assuming
> that there are no significant merge conflicts with ongoing work in other
> trees (which I doubt, given that these are small changes).
> 

In case anyone is wondering, this truncated series is due to a script failure:
git-send-email chokes when it hits email addresses whose names have a
comma in them, as happened here with patch 0003.  

Please disregard this set and reply to the other thread.

thanks,
-- 
John Hubbard
NVIDIA

