Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62D6EC74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 11:48:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 291EC216FD
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 11:48:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 291EC216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0CFB8E00B7; Thu, 11 Jul 2019 07:48:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABB838E0032; Thu, 11 Jul 2019 07:48:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 982F28E00B7; Thu, 11 Jul 2019 07:48:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 74CAF8E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:48:43 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id b23so1014897vsl.20
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 04:48:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=roccKqfKTM/Jq6frriL7ZwuQHnyVYFmMQnzfKoyL1Ak=;
        b=PINQuBxf8/nAFFswt49IJXFpSu3JMSlF8ADN05grYdlp3AE8rHbJP0EbZnCwEJSJTe
         d1BXs5hD3p9kmD7miXMmhXnjprSMdU+QdM/M1cWwORuw/EfRD8pi9wk7QmZHczbfitQB
         CpFQqG8E0h2pbehPJCjD8sqG3eor1OmFCtB4oog9I2DC5aSuvLMS4/kKpVvgHxYMEddM
         0XBorqHs6jAo/zHgwPXhYHoDTDbmDKa62OTpKU5bAAJ11pqPMPr/U1M6ViaX6vSRRVOJ
         CWUbNNbHtwfeOu5yxTtL0jKP5GmklQwt/1zywCfF3FGzt/zyIO9Uox3jvjk0JP6c9UQl
         W2gA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXLjXseDJM/0EKmfgeZrR+1bbRDIfzB4Cl+/0BZWoS8JwZtf736
	SDWlRAslDa27DHX23HsmBa4iyxFKKqLHeDpywujNsTlyIWX7+jmL9ByjY2QgsYUc2qhLhGU5z93
	WLatL2FN5OfiIojbzp/PCTtBQDble/u92hqf5FKuQhG9PCuwLrT4bPbpy4qIocaqeDg==
X-Received: by 2002:ab0:290a:: with SMTP id v10mr3632925uap.74.1562845723174;
        Thu, 11 Jul 2019 04:48:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4LxpQAeiPSSbUFTVHRA5Sm/tC8njcj++RL13xAnbc91fLuDk7zWiF/rV351VuXT6qO9Dm
X-Received: by 2002:ab0:290a:: with SMTP id v10mr3632874uap.74.1562845722623;
        Thu, 11 Jul 2019 04:48:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562845722; cv=none;
        d=google.com; s=arc-20160816;
        b=EoiTR78XQ+mpS0HnouvyVrKvXwYJ2TbUv0RnAzdR2Pn3Sidmfwlr4vGkqe1KTHJ1L2
         Z1b8r2VSKwdyTrYCOhdVHIdqF51atRFbUE9auU7LQwvzssCqRO0PQPJeVpr/QmDUl5/0
         2LQuPwn+Uk4FFg0lDZmxVAuoJOWsJn8qHFNtUv+zQxeAbNW46m5bKW3keVDlYGqOWIG2
         8npYyCs+CV6n28XDChcrf5S5X3cddAIciTyxig1GFUbz2svylr0caP5sCBWa0sHaGc8+
         d/ho2fmI++tcyREoFnh2xdPg9TnaZTZLtB/V+/TzxEcz2c9kcn7I1iE+qPkCgbE35tzN
         9dpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:to:subject;
        bh=roccKqfKTM/Jq6frriL7ZwuQHnyVYFmMQnzfKoyL1Ak=;
        b=A/UFc1D8oA69T7mW5uQ9O3+j/dt8En0EZxBXShtSBJdsH1RTTItan9NaYD+iRJRK9c
         izKE7EBGjqekB6DHkxoldNmcBfTj3NWrZD7dwq7WfwTGYV0ZpBmf0KBuFCRknsA9m7T6
         XZ/mD4u8qRMiJWRlEmUWyBo/wOvxu9v4VGVJrHINoKdXd92a+JC4ZOQlUO7pPbMQm7O/
         ryXPOgbSibbfJ6NnnaiRt/WvaoG9zFk9qesJkCejvnmgRnVD0pBypnKp0FZRpos6pKtt
         e+MPl0H/6EzSzgZf2lXX5SqqRg8SnLwzDEuGBPNgcpqkyMzTIeQOKfjRxJH+jpV6PYI7
         BBDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m135si1576260vkd.93.2019.07.11.04.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 04:48:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6C880308218D;
	Thu, 11 Jul 2019 11:48:41 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 81F6B19C70;
	Thu, 11 Jul 2019 11:48:32 +0000 (UTC)
Subject: Re: [RFC][Patch v11 1/2] mm: page_hinting: core infrastructure
To: Dave Hansen <dave.hansen@intel.com>, kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbonzini@redhat.com,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 yang.zhang.wz@gmail.com, riel@surriel.com, david@redhat.com, mst@redhat.com,
 dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
 aarcange@redhat.com, alexander.duyck@gmail.com, john.starks@microsoft.com,
 mhocko@suse.com
References: <20190710195158.19640-1-nitesh@redhat.com>
 <20190710195158.19640-2-nitesh@redhat.com>
 <3f9a7e7b-c026-3530-e985-804fc7f1ec31@intel.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <f41dfb69-5754-75a4-3eb0-1dda22b11b9c@redhat.com>
Date: Thu, 11 Jul 2019 07:48:31 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <3f9a7e7b-c026-3530-e985-804fc7f1ec31@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 11 Jul 2019 11:48:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/10/19 4:45 PM, Dave Hansen wrote:
> On 7/10/19 12:51 PM, Nitesh Narayan Lal wrote:
>> +struct zone_free_area {
>> +	unsigned long *bitmap;
>> +	unsigned long base_pfn;
>> +	unsigned long end_pfn;
>> +	atomic_t free_pages;
>> +	unsigned long nbits;
>> +} free_area[MAX_NR_ZONES];
> Why do we need an extra data structure.  What's wrong with putting
> per-zone data in ... 'struct zone'?  The cover letter claims that it
> doesn't touch core-mm infrastructure, but if it depends on mechanisms
> like this, I think that's a very bad thing.
>
> To be honest, I'm not sure this series is worth reviewing at this point=
=2E
>  It's horribly lightly commented and full of kernel antipatterns lik
>
> void func()
> {
> 	if () {
> 		... indent entire logic
> 		... of function
> 	}
> }
>
> It has big "TODO"s.  It's virtually comment-free.  I'm shocked it's at
> the 11th version and still looking like this.
One of the reasons for being on v11 was that the entire design has
changed a few times.
But that's no excuse, I understand what you are saying and I will work
on it and improve this.
>
>> +
>> +		for (zone_idx =3D 0; zone_idx < MAX_NR_ZONES; zone_idx++) {
>> +			unsigned long pages =3D free_area[zone_idx].end_pfn -
>> +					free_area[zone_idx].base_pfn;
>> +			bitmap_size =3D (pages >> PAGE_HINTING_MIN_ORDER) + 1;
>> +			if (!bitmap_size)
>> +				continue;
>> +			free_area[zone_idx].bitmap =3D bitmap_zalloc(bitmap_size,
>> +								   GFP_KERNEL);
> This doesn't support sparse zones.  We can have zones with massive
> spanned page sizes, but very few present pages.  On those zones, this
> will exhaust memory for no good reason.
Thanks, I will look into this.
>
> Comparing this to Alex's patch set, it's of much lower quality and at a=

> much earlier stage of development.  The two sets are not really even
> comparable right now.  This certainly doesn't sell me on (or even reall=
y
> enumerate the deltas in) this approach vs. Alex's.
>
--=20
Thanks
Nitesh

