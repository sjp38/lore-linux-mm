Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AACE0C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 17:06:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DA1826CCD
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 17:06:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="e4VDpBlK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DA1826CCD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06E8D6B0010; Fri, 31 May 2019 13:06:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01F8E6B026F; Fri, 31 May 2019 13:06:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E75CF6B0272; Fri, 31 May 2019 13:06:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id C71276B0010
	for <linux-mm@kvack.org>; Fri, 31 May 2019 13:06:42 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id z4so8051110ybo.4
        for <linux-mm@kvack.org>; Fri, 31 May 2019 10:06:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=4u7NP6lvly4mO3KnmAXEEl0mNU5GJqGvkmUhB0mUTec=;
        b=BXwAkk2EZEpUxgSMDd73G6AM1iy2EALfRWJDhsVW3z1I1QWc6+otWMnxK+fCliMV81
         f2PeJUw0Rm0RIIUg1gu3Ve5OXHN/Gd7dOalqglGZ//QXz4MCMCS1KIjsgQK3F/q5twat
         /oOD1/7pGpiYJOxJC7ZQ6FfVoEHGN0brX+c2OVl0U2FZkdMHOeT7jRxWJD/H3AMT5Nco
         HZHHzy50x0yhBOClljFvMuw0wMF2EmF2KRveGC8w+KGo7AmCn22MdQtwdi3BF64hN/e/
         /h96+euSQQ0aB3yXFNHC5cq0NKJIZAuAodHiXhncXAzTv4stpsm0npVddSNGS7k8jIsk
         Gh3w==
X-Gm-Message-State: APjAAAUkGEucVu8qWFUkf+QhL8gYXc6DbSMIJjTLPScV8lHg4k7v/qxv
	TxIbo1R7ghUVDjQUTLxr7EaOQfUMdnFc1zzwKki/Q1axYhtrfHoHNuMysarFJzljNwe/m5TLWSl
	bsgo4fiw8yxbj1gE1aRQxoNdNwQ8L7cDZUDY888t17EaUgEWqzhW8zYdhVYZBktCv+A==
X-Received: by 2002:a81:a30f:: with SMTP id a15mr5199065ywh.284.1559322402534;
        Fri, 31 May 2019 10:06:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDS+0j2dR0S1Nroa6j6uwGEL9P/u5xcKJ/kmmRdMUt0OcIu8J3w2n1r2kCY4imCZTLFwEL
X-Received: by 2002:a81:a30f:: with SMTP id a15mr5199032ywh.284.1559322401783;
        Fri, 31 May 2019 10:06:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559322401; cv=none;
        d=google.com; s=arc-20160816;
        b=MIUhf/4ia1AvX8bScRmR+E2L32j+hOUCqwJNMYmBVCu2jz73Q6MZkr1MuMVzGBfEYU
         UeP0q9yuwrOy5v4LPtEvijYlAQ1iCc31UgRgIK1j/1FL1GByhIUYGRFFMAy1ZX+adQ9q
         gPES2P5WyhrlbOo4pTtt/+Ltao2KA5d7h7rhW8mq3YoTg3xL1jcBfBH6H1ZCtejbhvK2
         HhtuiCYWbP+6pmujUagY7BN0TVSn5W4xOkcWUmxs49LB3OOgA/Zjgo/pEJFv8aJfu7we
         4TFR7Jp5yWNQu3M++PjwOIwEj2QrQVHSVbrxhS7pbvTkNSMfkYA+Cg4kyokmXIggcrqm
         weMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=4u7NP6lvly4mO3KnmAXEEl0mNU5GJqGvkmUhB0mUTec=;
        b=t9SIHg9V7u/qY8L544ivDAkLM+aMi5RoPVtmziWt3EYSYf2VyWF49pVkXWRhRAUats
         C8oBWsI86/A4ZplIflw7uMskoT700zFf+AM6FRS259nNHZPPqiS6FXMcnKSxLs2wdY7I
         TMqahfCcrjjbjONVPXbcvsht8LiWK6BRw10yHYuMCdveUDgp/+LLsqDyJZxlnXKZqUoY
         ojhJGwmiRCbDuiJ4mEflkRpNtJl6Hg+FTuoCDHv97jaSGGOcgW+VzNrsL+onyoRQohXA
         UoJp3BM1Apt04078zyyFGNFGp0snd3nixJw2i9aXcixw35sj3AjIFOnYDCz/zZ8d30dg
         1DXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=e4VDpBlK;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id h130si483707ybh.62.2019.05.31.10.06.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 10:06:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=e4VDpBlK;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf15f160000>; Fri, 31 May 2019 10:06:30 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 31 May 2019 10:06:40 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 31 May 2019 10:06:40 -0700
Received: from [10.2.167.144] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 31 May
 2019 17:06:40 +0000
Subject: Re: [PATCH] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
To: Pingfan Liu <kernelfans@gmail.com>
CC: Ira Weiny <ira.weiny@intel.com>, <linux-mm@kvack.org>, Andrew Morton
	<akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, Dan Williams
	<dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Aneesh
 Kumar K.V <aneesh.kumar@linux.ibm.com>, Keith Busch <keith.busch@intel.com>,
	LKML <linux-kernel@vger.kernel.org>
References: <1559170444-3304-1-git-send-email-kernelfans@gmail.com>
 <20190530214726.GA14000@iweiny-DESK2.sc.intel.com>
 <1497636a-8658-d3ff-f7cd-05230fdead19@nvidia.com>
 <CAFgQCTtVcmLUdua_nFwif_TbzeX5wp31GfTpL6CWmXXviYYLyw@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <d5dde9e8-3628-850e-f2b2-73c08098a094@nvidia.com>
Date: Fri, 31 May 2019 10:05:45 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAFgQCTtVcmLUdua_nFwif_TbzeX5wp31GfTpL6CWmXXviYYLyw@mail.gmail.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559322390; bh=4u7NP6lvly4mO3KnmAXEEl0mNU5GJqGvkmUhB0mUTec=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=e4VDpBlKbhPDzAJLuWnscBXEAaDG9079ehYtghHjJec5u0+iOHeJOTJUlV0OzKqsW
	 frVPPI74bk2qLLFaDblREL3nO9Pnsjg2m2HmUsmP/hR7cSU2nfmg8kHgIy5RUpL0tL
	 4ddMRWibENh2+g4oD58qdHpo0J+o3rQaDmCy6J0Uv7G2h187C9YNGdV9aKWUvG04Q5
	 N/lFpXY0p8zBrbR1IAvmWf5s6431uUDuiv1Q8xEy3HIbm7pYHFZ46s/3/jeO0t/Kfx
	 6aDhwXqhubKYuH1WD1T/Ohsnv4CzSsLFd9I8JAy+By3xexzOWkEmFXxpS9di5jJ9Js
	 +muX9ERjabdAQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/31/19 4:05 AM, Pingfan Liu wrote:
> On Fri, May 31, 2019 at 7:21 AM John Hubbard <jhubbard@nvidia.com> wrote:
>> On 5/30/19 2:47 PM, Ira Weiny wrote:
>>> On Thu, May 30, 2019 at 06:54:04AM +0800, Pingfan Liu wrote:
>> [...]
>> Rather lightly tested...I've compile-tested with CONFIG_CMA and !CONFIG_CMA,
>> and boot tested with CONFIG_CMA, but could use a second set of eyes on whether
>> I've added any off-by-one errors, or worse. :)
>>
> Do you mind I send V2 based on your above patch? Anyway, it is a simple bug fix.
> 

Sure, that's why I sent it. :)  Note that Ira also recommended splitting the
"nr --> nr_pinned" renaming into a separate patch.

thanks,
-- 
John Hubbard
NVIDIA

