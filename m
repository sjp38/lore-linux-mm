Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57AB4C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 03:19:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 076FA20854
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 03:19:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="bMYCIroi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 076FA20854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DB588E0003; Wed, 13 Mar 2019 23:19:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88A318E0001; Wed, 13 Mar 2019 23:19:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7793D8E0003; Wed, 13 Mar 2019 23:19:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 381C98E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 23:19:34 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e5so4616691pgc.16
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 20:19:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=8/FESUTll/7HXtBTMTTiOUp3okh43kK5SAPTWHHLwRg=;
        b=ZC5MBQlMvaGGgVmYUatD2s2j7m+PguhZNUAb82R/tGjatncTnJ/s3r+lfg4h4T0j7L
         8/CeY35tdAUDbbft4criMdd/k+P3O540O2zowTdICF5kM5IpyLuybD7SKyF0uL3lWXc2
         k3rPsEgr1zMpLMSF5rdwmaOxKSY6rQQV5s3SVROic83adwHOG3s1LHDJ3yRR7Nv5o0+P
         X/WGc/de+NirbLjOGi7XCeaJDPZXVUvTtbxk28MNUyJk3V8zK5Ll4IZxddgTcs1ejQi5
         y4RcjwZkdtTPX/wYqXQxzrV8myxmFCTZLK4N54BBr6OVlGDfD6eHh/ntt10eppFyMSLn
         hP3g==
X-Gm-Message-State: APjAAAXCSu/HBfcyBMRLadwavNkOlgWZss99saeRnhUpAg1Bfn8a+G8v
	Ixg1HFVv0EUFgHrueelJFANd78v70xJLkCAPuWoEbZoEh/YL8lcM3x0klrbWL6wF/kpMpUH7nS9
	3hFZpnSHDdtIZFgzPn0I0lgCFLRlnHexedg5DCbFdmC1LM2KsmFo+D99FT/ISxVe9nQ==
X-Received: by 2002:a17:902:8f81:: with SMTP id z1mr50068471plo.265.1552533573692;
        Wed, 13 Mar 2019 20:19:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNJ8bxeGNniP/5/HhJ4RSEGW/lq33Ehj099+dzryHB6M5Wm+kWar1Plq2iAJmqee2fYSDF
X-Received: by 2002:a17:902:8f81:: with SMTP id z1mr50068400plo.265.1552533572442;
        Wed, 13 Mar 2019 20:19:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552533572; cv=none;
        d=google.com; s=arc-20160816;
        b=BAR/vGcxk7h0Dx8E7uWg1rtVtYE6kNUh8AZpPaRxE3UbH3Xnh9KSgKHF2z3F51X6bm
         rGfkMYHtTj/o+sX+O9Xx5oaIAl4PMsDz2SWVi8N9GRy09oSzfstDi+reg8b8q1HFXKA8
         n5ISwVmfrKB64qPzG7kDLiIvy0KXzjh3fXbC9P/fe001GMlGje7UdXS3bbFtW8vmTlVH
         EAZolkFPKEjZYBeWhjXNjYz1yK49PORUZNFJYUDuG61+YpNKT3fvAXFLADM5dL3zAJn8
         ViDNGO7AMyMQZxqUnAh+8CV5A8KHSvX/c6uiVwMnMROgVWwf2k1ahVSSzDFAPx3+o6Bx
         s2TQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=8/FESUTll/7HXtBTMTTiOUp3okh43kK5SAPTWHHLwRg=;
        b=BKOiYRrHrMmhnj0OMJzveIWPTHMjnkmSEX9inN0+pHkt7aThPU6vFmo2U1ogZXxb+c
         5ASqBSjFkohMNUJv7jsAVgwnSJ3ZkeBYaKk7+Bv+8aiybrP4MNd30yaQvZ2I51Ae3nKQ
         /NTSizcGq4lSwl8I79Fmbr1zXqfJWwnJxCCFjqwQ1l8euE9CdO4r6qbkVGukAf3M+onV
         8dYCcen0+2pNNkj2Uu+rRQnkr97zAc1YBsCn3faw01O9umm6w7qsrfv2KOsm2n9Pf+xs
         sf4p+78wZFKzStYQ2CsZixwGBMsgNqkVlvwAYjOb4bHz2IersumdYF0yUW2kr9Z45G6e
         0aQg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=bMYCIroi;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id b9si1506277pgw.308.2019.03.13.20.19.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 20:19:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=bMYCIroi;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c89c8450000>; Wed, 13 Mar 2019 20:19:33 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 13 Mar 2019 20:19:31 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 13 Mar 2019 20:19:31 -0700
Received: from [10.2.175.16] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 14 Mar
 2019 03:19:31 +0000
Subject: Re: [PATCH v3 1/1] mm: introduce put_user_page*(), placeholder
 versions
To: Ira Weiny <ira.weiny@intel.com>
CC: <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>,
	<linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti
	<benve@cisco.com>, Christoph Hellwig <hch@infradead.org>, Christopher Lameter
	<cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner
	<david@fromorbit.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox
	<willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Rapoport
	<rppt@linux.ibm.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph
 Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, LKML
	<linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <20190306235455.26348-2-jhubbard@nvidia.com>
 <20190312153033.GG1119@iweiny-DESK2.sc.intel.com>
 <c9c80511-0805-a877-af6f-b769c6dcb111@nvidia.com>
 <20190313144941.GA23350@iweiny-DESK2.sc.intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <c29ddfcc-ce1d-f4bd-7e0d-905b6f92ecc7@nvidia.com>
Date: Wed, 13 Mar 2019 20:19:08 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190313144941.GA23350@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1552533573; bh=8/FESUTll/7HXtBTMTTiOUp3okh43kK5SAPTWHHLwRg=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=bMYCIroiLhtLgP5RD406L4RZ9r+wOTIToldbo1EQJPFCYWmUfroe4suZ8m8ZDjJ8l
	 VM21eJpIEFgno268ZPf359z+FDlWnEPginnpJomfLAtcu3GXvZlEkc0/ArWh91XvUs
	 CRtEw+YPsXaorRoLfYMwizU/eZgKRRjFcVefqF8p98v0mWlXbXTRG3cDqYFJe3MaTZ
	 eRogMcX3yIHOwOPTW0rrOEv+87wsuLkV3o/IrZ1s9EqPFjf21c+4R8GfVU9O0LEisw
	 Q1W1wYAS6UWtj2f/ceWun2FGe8t4WK5H3QQrAoyrhTwfh4V9+oUeWSvJklWMdKIelY
	 5tc/s+hECaeUw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/13/19 7:49 AM, Ira Weiny wrote:
> On Tue, Mar 12, 2019 at 05:38:55PM -0700, John Hubbard wrote:
>> On 3/12/19 8:30 AM, Ira Weiny wrote:
>>> On Wed, Mar 06, 2019 at 03:54:55PM -0800, john.hubbard@gmail.com wrote:
>>>> From: John Hubbard <jhubbard@nvidia.com>
>>>>
>>>> Introduces put_user_page(), which simply calls put_page().
>>>> This provides a way to update all get_user_pages*() callers,
>>>> so that they call put_user_page(), instead of put_page().
>>>
>>> So I've been running with these patches for a while but today while ramping up
>>> my testing I hit the following:
>>>
>>> [ 1355.557819] ------------[ cut here ]------------
>>> [ 1355.563436] get_user_pages pin count overflowed
>>
>> Hi Ira,
>>
>> Thanks for reporting this. That overflow, at face value, means that we've
>> used more than the 22 bits worth of gup pin counts, so about 4 million pins
>> of the same page...
> 
> This is my bug in the patches I'm playing with.  Somehow I'm causing more puts
> than gets...  I'm not sure how but this is for sure my problem.
> 
> Backing off to your patch set the numbers are good.

Now that's a welcome bit of good news!

> 
> Sorry for the noise.
> 
> With the testing I've done today I feel comfortable adding
> 
> Tested-by: Ira Weiny <ira.weiny@intel.com>
> 
> For the main GUP and InfiniBand patches.
> 
> Ira
> 

OK, I'll add your tested-by tag to patches 1, 2, 4, 5 (the numbering refers
to the "RFC v2: mm: gup/dma tracking" posting [1]) in my repo [2], and they'll 
show up in the next posting. (Patch 3 is already upstream, and patch 6 is
documentation that needs to be rewritten entirely.)

[1] https://lore.kernel.org/r/20190204052135.25784-1-jhubbard@nvidia.com

[2] https://github.com/johnhubbard/linux/tree/gup_dma_core

thanks,
-- 
John Hubbard
NVIDIA

