Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28D2AC73C65
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 01:25:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D624520693
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 01:24:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="bdqZj66S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D624520693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7032E8E0065; Tue,  9 Jul 2019 21:24:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B30E8E0032; Tue,  9 Jul 2019 21:24:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A1138E0065; Tue,  9 Jul 2019 21:24:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3590D8E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 21:24:59 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id r67so358386ywg.7
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 18:24:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=7k/lgMwyAOSzNGQqdDXXYMv79vityN/pwh1Ws1jVVNs=;
        b=nXQ8Lctg2hu6NSvuFHWXUxTpy+CJkP3y2k4xpr/0BIW71a5u0wOz4WWY9pMt7XagSC
         o4KNaknw+nIQl3OPzJ/A/zT5Hs72OS36r2VLNcjrSulUnYU6/V3/Ou5Q8qGxhwBNXFBV
         qtJ8+hhimFAox+rA/fGP5tXdTC8eOoNdRbsrf9UJUYjZN3oDzAaHtx2XP4bhFYypjbU9
         YUcVtT5fzOkmCaj32O8prl2M06vRqv2Al7jtSQHEHYONntyLbgXqKmQk+S2QMhz6Vj4J
         oUSB0ApB+W0DmZwdckmz3u3m7i6ltF9LTSohAD3bkGTKEuvaclenWfmke/SA7++6hcRf
         VyUQ==
X-Gm-Message-State: APjAAAV/Yh40KT8Y3oV3GsM7wPrmCcNltyU4sctZwn86FLy9b5u4AFDj
	UisadaO7Y6z7PmUbCRfqmGp+qaXJyEYlX+rDh3XenGdhX3H5/huV6+gcnnBSdQjUYtoSQLiUbNe
	DkLzM7Ul6JsS+fachi+BDaTW5aCY/7m9y0ziHUeYhmYZvArjgNt9kcD6boG/DCM2sOQ==
X-Received: by 2002:a25:5f48:: with SMTP id h8mr14148981ybm.231.1562721898885;
        Tue, 09 Jul 2019 18:24:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpGAVsjWnoxxmyFkkBMUTBSSJDY+2qjrI+Ply455m3pdy7yq0er61YdZdjSAyd6JW/fUIA
X-Received: by 2002:a25:5f48:: with SMTP id h8mr14148969ybm.231.1562721898411;
        Tue, 09 Jul 2019 18:24:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562721898; cv=none;
        d=google.com; s=arc-20160816;
        b=hXuq/zZREEiwfksmwXsreGAb/k05g2CxSH8HLmU54Px0+tVKKlzSnNmnd8jlqiyB45
         kyU1C/T5zS1Wk0BkJVQvMr3M4ITNHGCnX80yVMvJX3bX8weXEptb445bosS/hqh740iD
         kqiveELdMhQnGIyoZBwF+89NcZcW0XdcI9UIQzP41l2Q2Ajt7uamX8dRB5ExzKmEja/c
         Jc1YY4D0IQr05IqIzyHwP9qU2OizSsscH3CXEsJZb/84TyZ+u2pLUReNVgMa8A97JT50
         WYhz8azuLgS18zOjfYIMBkqJxfIS18vqUxPVMVLgqlwUyjhgo46fN6vmkx1Sr9jx1khV
         0i2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=7k/lgMwyAOSzNGQqdDXXYMv79vityN/pwh1Ws1jVVNs=;
        b=00bZBy4MDC5+JSsjqSXZVxbF6OLop9Ttc8XllYQfwpgYsEGzd3xIzr96WJ9nglrbaZ
         GvH/6II+SzQfv+WtpkMeDVfCXbs987RrHAHVQdQJ3Kwg+NLLsyEz0Sfi+9ZiJKofLnVL
         l1zQxHzWgeRSimEQaJmLK+DyzT5vSWorJ8FyseYuaEZ6DRiTbobwqTcJ8VZPG1XdFGGj
         BBMADFJutRk0s+c55UK6tmg1vUp7caQ0Xfp+wU8gF+fMqdBS0rJudbqu9X9MgUKVBeum
         Ec+3ysKltxjGhWHt6Omp+R3lLHL9wiohCpoIwwX6Er60e62jJoTZLicXtGviviM39jPs
         wMBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=bdqZj66S;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 23si166805ywh.460.2019.07.09.18.24.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 18:24:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=bdqZj66S;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d253e6e0002>; Tue, 09 Jul 2019 18:25:02 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 09 Jul 2019 18:24:57 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 09 Jul 2019 18:24:57 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 10 Jul
 2019 01:24:57 +0000
Subject: Re: [PATCH] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
To: Andrew Morton <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>, Mike Kravetz <mike.kravetz@oracle.com>
References: <20190709223556.28908-1-rcampbell@nvidia.com>
 <20190709172823.9413bb2333363f7e33a471a0@linux-foundation.org>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <05fffcad-cf5e-8f0c-f0c7-6ffbd2b10c2e@nvidia.com>
Date: Tue, 9 Jul 2019 18:24:57 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190709172823.9413bb2333363f7e33a471a0@linux-foundation.org>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1562721902; bh=7k/lgMwyAOSzNGQqdDXXYMv79vityN/pwh1Ws1jVVNs=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=bdqZj66SSKe/Sej2HEmOBrXJF+zC/5PRqfyUvCr6pR8GfmbS1yp5prYZc/+vQeU11
	 +2fuVzrvi2SZd/aDuTcIlMzu7sf7T1kK4E0C9ThIPyJt+GyxmtMYTfrYTI3WUyBQ7S
	 +6sp5Z11zhxQ54RUOpuTxIXG6ddnyycB9I+s4NZYlGqbISCfwy+xe0qyJxnibrjLOa
	 IbXVXKq0PzfXx2np9JUzGj7empCUXNl/cmmb0f5RZttV/ZFDmwMrWJxt9sqKUQHICq
	 gWBtYR07FoHZy1mtc1BmG0WrxibQgD7Hf0aSBCLARpAs6lPNveVsx3oBmKuAzxtJtT
	 U9fy2s4k1Gd+A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/9/19 5:28 PM, Andrew Morton wrote:
> On Tue, 9 Jul 2019 15:35:56 -0700 Ralph Campbell <rcampbell@nvidia.com> wrote:
> 
>> When migrating a ZONE device private page from device memory to system
>> memory, the subpage pointer is initialized from a swap pte which computes
>> an invalid page pointer. A kernel panic results such as:
>>
>> BUG: unable to handle page fault for address: ffffea1fffffffc8
>>
>> Initialize subpage correctly before calling page_remove_rmap().
> 
> I think this is
> 
> Fixes:  a5430dda8a3a1c ("mm/migrate: support un-addressable ZONE_DEVICE page in migration")
> Cc: stable
> 
> yes?
> 

Yes. Can you add this or should I send a v2?

