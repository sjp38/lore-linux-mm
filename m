Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C80F6C74A5F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 16:22:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67AA52064B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 16:22:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67AA52064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE9F98E00EB; Thu, 11 Jul 2019 12:22:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9A5E8E00DB; Thu, 11 Jul 2019 12:22:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A62608E00EB; Thu, 11 Jul 2019 12:22:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9BF8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 12:22:51 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y66so3718914pfb.21
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 09:22:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=BCNWmtsaR398sjU4SKOoSmQfUtaAGosFyWZSrVnkYqw=;
        b=WxlqKjhZvKwlpum+rNE6uM0BFzBAcA7awfRFHnPnW+SxhgUfL94Yuua++bd9qEUPtW
         TTca93OnJan8y+166ZOKTyqV3AoODy1E90TCcfTlIp0vK4sGSPqUJ7OLErnm5CftZjBm
         LOl8cSMnfKsDv1PM0DYTlT8n2AifWLTsbugHlAA3fZJNsrrYio+I1TevXRSprKCbi/dG
         AMU2XrqLtAgmk2dqscDoiLuAvQvhn+Tit2/bk961cskdju4HceKkdczuSB5Q6je33C9m
         65qu4pEKFjVV0Zf8UBCwdA42XzecDpQOJtCvqFoNSB2KPHQZ5YbQGgTo493PGtuxJzlL
         CDEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWydRqtQXF+WEYwQacIevc8DPehe6L44SQA0n9h59h4gd4uvKKV
	OQUhy4ySwhFZERf9XaSqpIU+Y+7fJIDerA2vyy/L+hYGCfshqOKRG4B/ywEcBX2s2M5bnn8NRwn
	AlyCmOVZThcM4JMVCtqabnq0niIWcxuuhXZTvHD/6GYNgcgHGXViWcFiay/9JkWYoJA==
X-Received: by 2002:a63:8ac3:: with SMTP id y186mr5254664pgd.13.1562862170836;
        Thu, 11 Jul 2019 09:22:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzijedJPgU7pSC30bQa1A8j0Yw/eFndsZljwjwfeOdXkZSzVwo+d/FG2I8mrX98q4X2bj+A
X-Received: by 2002:a63:8ac3:: with SMTP id y186mr5254600pgd.13.1562862170067;
        Thu, 11 Jul 2019 09:22:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562862170; cv=none;
        d=google.com; s=arc-20160816;
        b=CuBXBrx5N15F3uGvrMezG6bIa8/9izFkxqA1Ao3ibDrfaHZOaI+Bl4SxEsAKZ1DuAv
         XDUEhl2BslNFvY4NXQfNsTQ9XAwBu8AsN8O02k0jUxY+vMnas9KAZlbqTx0pfRvv+fzz
         A/zV7Yo4jeSbQSU/8RmE8wHFjVvgoCNx9GmN0pGDroJUBw/+QTkoZvKifLNp7se3M8Js
         8qDDNXFhbLy+e9VHSHCZhpD1ApeoU22mVgEX3Dx4Ge3A9+5AO1DX9JElFYYfHnrNA3Np
         GLaZI4ePjr53XIXl58KKuybZrsCudAaGovEvTR2lblbPYX4Bn3dY5eox916HhOlvb2yq
         KNKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:to
         :subject;
        bh=BCNWmtsaR398sjU4SKOoSmQfUtaAGosFyWZSrVnkYqw=;
        b=lqfoFmEPTHXZANJqmLmBeYIertab/VFNqfTJcmWeHpnJZIcUaGcJhfiIdF1xY1mxJM
         /F+970Q08X/dt8eB1shjsAqG3Fupy2sziEJ2E4FsNZwEy/9b5rLHg7YZ+lnfBKEtBFMy
         +RlBOcpIPhHRfmfjOLpafRbpHuXeF0j+nNsh6hFer67CfO1p77ZZNLsKKKJ+tAZmcViW
         Hf2nzB7n0F6vVFU98I1RmJsB2VFYoD9wKGumjmwrcUAzrEjBz9XItUEO2KzCM3/MkRbc
         t81c4gez9y6oIF57vuv61oYPFHc3sT2ZgnWIXyK6PR6bAZBxXSxMfMAS0d3EzEkXbzfB
         d8yQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id s62si5636964pjc.75.2019.07.11.09.22.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 09:22:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Jul 2019 09:22:49 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,479,1557212400"; 
   d="scan'208";a="177215469"
Received: from unknown (HELO [10.7.201.139]) ([10.7.201.139])
  by orsmga002.jf.intel.com with ESMTP; 11 Jul 2019 09:22:48 -0700
Subject: Re: [RFC][Patch v11 1/2] mm: page_hinting: core infrastructure
To: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbonzini@redhat.com,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 yang.zhang.wz@gmail.com, riel@surriel.com, david@redhat.com, mst@redhat.com,
 dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
 aarcange@redhat.com, alexander.duyck@gmail.com, john.starks@microsoft.com,
 mhocko@suse.com
References: <20190710195158.19640-1-nitesh@redhat.com>
 <20190710195158.19640-2-nitesh@redhat.com>
 <3f9a7e7b-c026-3530-e985-804fc7f1ec31@intel.com>
 <0b871cf1-e54f-f072-1eaf-511a03c2907f@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <c41671f0-2080-b925-39e2-79e33a84088b@intel.com>
Date: Thu, 11 Jul 2019 09:22:48 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <0b871cf1-e54f-f072-1eaf-511a03c2907f@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/11/19 8:25 AM, Nitesh Narayan Lal wrote:
> On 7/10/19 4:45 PM, Dave Hansen wrote:
>> On 7/10/19 12:51 PM, Nitesh Narayan Lal wrote:
>>> +struct zone_free_area {
>>> +	unsigned long *bitmap;
>>> +	unsigned long base_pfn;
>>> +	unsigned long end_pfn;
>>> +	atomic_t free_pages;
>>> +	unsigned long nbits;
>>> +} free_area[MAX_NR_ZONES];
>> Why do we need an extra data structure.  What's wrong with putting
>> per-zone data in ... 'struct zone'?
> Will it be acceptable to add fields in struct zone, when they will only
> be used by page hinting?

Wait a sec...  MAX_NR_ZONES the number of zone types not the maximum
number of *zones* in the system.

Did you test this on a NUMA system?

In any case, yes, you can put these in 'struct zone'.  It will waste
less space that way, on average, than what you have here (one you scale
it to MAX_NR_ZONE*MAX_NUM_NODES.

>>   The cover letter claims that it
>> doesn't touch core-mm infrastructure, but if it depends on mechanisms
>> like this, I think that's a very bad thing.
>>
>> To be honest, I'm not sure this series is worth reviewing at this point.
>>  It's horribly lightly commented and full of kernel antipatterns lik
>>
>> void func()
>> {
>> 	if () {
>> 		... indent entire logic
>> 		... of function
>> 	}
>> }
> I usually run checkpatch to detect such indentation issues. For the
> patches, I shared it didn't show me any issues.

Just because checkpatch doesn't complain does not mean it is good form.
 We write the above as:

void func()
{
	if (!something)
		goto out;

	... logic of function here
out:
	// cleanup
}

