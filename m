Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C92CBC32750
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:54:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BF5020693
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:54:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BF5020693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 244A28E0003; Tue, 30 Jul 2019 16:54:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F3B28E0001; Tue, 30 Jul 2019 16:54:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BC518E0003; Tue, 30 Jul 2019 16:54:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C82CF8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 16:54:07 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 145so41604361pfw.16
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:54:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=OzpF7h7NuM1248sEBu0Sr7s2YQ/3dF8MN7kRdxTEXxQ=;
        b=FQ5ULgGMPp8MgrDKUKv9e16V88uOamlB7TEDy87bC7WhXXpuvMxY+Bp5sF6uX7+dg0
         mPSeB4Vs2YtMDLTJdpSD4tyMxb/VhfNA5vZKW0VYCuOyRR+HumAS0RjHDl1lf8i+GN7A
         cdDXPhmfcpSxoJkI5fpXsOtYehC2r+YV/y27MIQWLNXx7lgC6p2Be1IqgWczcsarBQP4
         jtWLTNUfDk8L0IywU+0wWVMt3Zf40yPcRMHvUj+NNAF91H/C7kAJv/QIUKTr3RRujqBe
         nt+crlsIGDgZ2wPrUILPt+UB+H0e23v/GRu9jq+ak8oyroCR1LyJMgn60tNU8r+bscvy
         vpcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUxUB1UOiTpi5C5GyEsC+8+BDXuQcx+i+U6ydhaY+EfXEkmPWjj
	DSMiltMRSjD620pEDPGCyauh1hiGeXytHge7M4xUeTSWyPq0X0rg/cotiWM+iOKLsoV2+esOpEv
	0toBr6mr7xvbD03z/wR+HBLVaa3ZRpvzbAp5fngjmznrtkWjUmq0O9oAdTgYttDBDjQ==
X-Received: by 2002:a65:458d:: with SMTP id o13mr109023198pgq.34.1564520047401;
        Tue, 30 Jul 2019 13:54:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHxFSvtewKRI1+my0t0deSmha2eeB+uAxiocvJ+ix9jEU36VcDmCnv2OFCGIpOudw+oNSs
X-Received: by 2002:a65:458d:: with SMTP id o13mr109023170pgq.34.1564520046732;
        Tue, 30 Jul 2019 13:54:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564520046; cv=none;
        d=google.com; s=arc-20160816;
        b=ZyIU5OiJMInaZ9FwJa+e08SEnXUxUsySdvk46mTU0N6gwmOON8oadxqcuutKDQ+oM+
         iCLtBe+WJvtyyz4hyrcvPV/4Zf4UIre08nHnhwKcdDx/xwFgPv7kZjvA//G0Ia5EmULU
         QzKxZzoRFK657cRl9DailhaMMlsaGWc73cCrJdpiPyoF0DPfRI/hwt8NNWnyBqp2ZO18
         jHfMesuO0XEbTXTKqo9ptSe6r282aHzIjT/wcwXHAUwDUQ0AqXs045yAue+NhIQ9bVtz
         s6e8WHRWi7LXYHNebXsf/fMozNarzCmiDRzFexxWTXTpQbxXGbKriY/qvAHf69kQrQDP
         a/iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=OzpF7h7NuM1248sEBu0Sr7s2YQ/3dF8MN7kRdxTEXxQ=;
        b=gjlhgMQRg04FOeU1qj8gqs2APDDSEAIWFKUobvchBA3nPKHxRRsHphdWdyrs0lnGRW
         V6UIBegTluiivFXc7uocUpRHbB8DsjM6e9MTHytSHf8r3hTSmiM8IeIVf7aVqYiwo/QC
         XGPcmq2gpJLy/WOzE58JXYOw6MBJbv0aTK2VxAM0d/uptNshIFoE36vSlQohoV/m2pGR
         InEjS9YqpwzQVMp32Jlob9FPX9xUqCww8vYkzAYojm/6yNsu+B4GSyjBV2j/g7TKpKPo
         V6TkTTaGs8svgTjjP1WafQqBInrlJnT/ltZyO+Z2uj7uYaXz+NbmfLGMbnNLj22PnY+1
         cK7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id v45si29043625pgn.10.2019.07.30.13.54.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 13:54:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 Jul 2019 13:54:06 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,327,1559545200"; 
   d="scan'208";a="183370711"
Received: from ray.jf.intel.com (HELO [10.7.201.140]) ([10.7.201.140])
  by orsmga002.jf.intel.com with ESMTP; 30 Jul 2019 13:54:06 -0700
Subject: Re: [PATCH v1 1/1] mm/vmalloc.c: Fix percpu free VM area search
 criteria
To: Uladzislau Rezki <urezki@gmail.com>,
 sathyanarayanan.kuppuswamy@linux.intel.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190729232139.91131-1-sathyanarayanan.kuppuswamy@linux.intel.com>
 <20190730204643.tsxgc3n4adb63rlc@pc636>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <d121eb22-01fd-c549-a6e8-9459c54d7ead@intel.com>
Date: Tue, 30 Jul 2019 13:54:06 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190730204643.tsxgc3n4adb63rlc@pc636>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/30/19 1:46 PM, Uladzislau Rezki wrote:
>> +		/*
>> +		 * If required width exeeds current VA block, move
>> +		 * base downwards and then recheck.
>> +		 */
>> +		if (base + end > va->va_end) {
>> +			base = pvm_determine_end_from_reverse(&va, align) - end;
>> +			term_area = area;
>> +			continue;
>> +		}
>> +
>>  		/*
>>  		 * If this VA does not fit, move base downwards and recheck.
>>  		 */
>> -		if (base + start < va->va_start || base + end > va->va_end) {
>> +		if (base + start < va->va_start) {
>>  			va = node_to_va(rb_prev(&va->rb_node));
>>  			base = pvm_determine_end_from_reverse(&va, align) - end;
>>  			term_area = area;
>> -- 
>> 2.21.0
>>
> I guess it is NUMA related issue, i mean when we have several
> areas/sizes/offsets. Is that correct?

I don't think NUMA has anything to do with it.  The vmalloc() area
itself doesn't have any NUMA properties I can think of.  We don't, for
instance, partition it into per-node areas that I know of.

I did encounter this issue on a system with ~100 logical CPUs, which is
a moderate amount these days.

