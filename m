Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6611FC74A59
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 15:25:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 250A12166E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 15:25:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 250A12166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F28F8E00E5; Thu, 11 Jul 2019 11:25:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A2CC8E00DB; Thu, 11 Jul 2019 11:25:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8427C8E00E5; Thu, 11 Jul 2019 11:25:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1708E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 11:25:57 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id m8so1064701uad.14
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 08:25:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=YWVfBiXQJyizp0S279LrZc8U7GJxFm4Boqf6pncByr4=;
        b=n8T0xelaGRhVHgg0drCl8LdwLVPcHnYwmHSnHh6nBoV68hQ2Ja7Zv8oK9LTNgmaxko
         3wf0uLiiZBfbcorLb2nYgdmct3r5D/bF2crY2878ERGdul7uILePeWJaEii+m9raELcS
         UxF4S6iKQhCw02S1esoS1XZy2eeSG6x2hrkapBF4wttyyCnZ/0xHlbg4H1Xc3mqRO8So
         wWUX3jgm7UiJRheOfvmjZQddlPLDAFCROq6vhQEG2QoIA/RW7tDOqiSdNxI2xUCSlUNL
         JX/Mrpj3wxRdUV2bUygPALlC4WRYmY3QqOtBVYI7s+OCExsRjoDOHqaaUZVs6vG/rG3v
         +8GA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUiiDhAn4o6TefW92/85iPK2VUNYmlpGWt3l8FvgWGKe6ppfN6e
	BthS5eC+rwh2+B5saovaIK3EnB55RqSXuND8w+/+TjN0o4GmMGKuRz+wO4xOZ25e/jSq08ng32E
	e/xxqKj6wdhHumbYQRqfR/fGF9ZfeW4kHmEFh+et+xCdLnWWhdK0LvqfQezt0wxyPKA==
X-Received: by 2002:a67:8c84:: with SMTP id o126mr5174742vsd.122.1562858757040;
        Thu, 11 Jul 2019 08:25:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztKe9qUhLnimj6IQIJcPC82qzPkKdGXdHbM179NtYVh4t+H7opP4uXBXYzqNfynQdA7w7d
X-Received: by 2002:a67:8c84:: with SMTP id o126mr5174685vsd.122.1562858756496;
        Thu, 11 Jul 2019 08:25:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562858756; cv=none;
        d=google.com; s=arc-20160816;
        b=Qjhf+xvH+1MDstHce6mF94sLD2PgKfQcCHaPrSH2qfm2m0V0AgmEr8NFx3TuCKpJ7+
         NiMMWFUl/KBzCSqXOg+zGlKIDlohiKXpC0TRjS95ugZ/UOByG678+zuQ1QEwMZiXfBJ+
         yXTXvVadCMmGLMl41oAQuJkqCs1xzhzxQeajIZ3qrFp0EduoyyzyAaVXR0wyzV1L2ii+
         R/NNbwFLgPPKZRhGqiu9lOBkTLh8Hs/j6y+fex3FLVy5BTkOyk4RSC64ML3tSu2HzH0B
         2UVvHOvE9nWbCs1os9tx76FLj6v2h/8pUWPoePT0L+/eGluxgqQ12GUPJjERtzkkwj58
         nVWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:to:subject;
        bh=YWVfBiXQJyizp0S279LrZc8U7GJxFm4Boqf6pncByr4=;
        b=OJRtGAfsmNxnBpIWNVVWDJjBDPatN7KB7/PJriNX32j3b/7ocS74X4t1v1OYEOZ/8Z
         BR1IF7xZr43rVLA6Mwbb7MWg2DTm8trFeMUK8YrDtJXWx3ZL2zrp5DhJ7wxGoXDMerQX
         uq3dC6Rp/NAU46lAMnMsN7ZgMqGPUg3bYFMuBmeyERKGfwDn93L5GGsyvWHXsMtfpE6k
         cER6HAZ1lGis6zVcIL71G7S3ai4BKB+FXVlooYkgsy+kvx55dnj+di4YyG3xRawXpX1U
         O7g8KR0uxMzAJT/djGqZoKyIJW1YFXO3n6c63mPbwfZlw5ez5qO+PonZ7NudoFq60+a8
         vAeg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g9si961708uac.187.2019.07.11.08.25.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 08:25:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 82F77285AE;
	Thu, 11 Jul 2019 15:25:55 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A8CB860C05;
	Thu, 11 Jul 2019 15:25:48 +0000 (UTC)
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
Message-ID: <0b871cf1-e54f-f072-1eaf-511a03c2907f@redhat.com>
Date: Thu, 11 Jul 2019 11:25:47 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <3f9a7e7b-c026-3530-e985-804fc7f1ec31@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 11 Jul 2019 15:25:55 +0000 (UTC)
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
> per-zone data in ... 'struct zone'?
Will it be acceptable to add fields in struct zone, when they will only
be used by page hinting?
>   The cover letter claims that it
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
I usually run checkpatch to detect such indentation issues. For the
patches, I shared it didn't show me any issues.
>
> It has big "TODO"s.  It's virtually comment-free.  I'm shocked it's at
> the 11th version and still looking like this.
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

