Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B79EC31E4E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 20:57:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07F962168B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 20:57:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07F962168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 933FB6B0006; Fri, 14 Jun 2019 16:57:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BF086B0007; Fri, 14 Jun 2019 16:57:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 712146B0008; Fri, 14 Jun 2019 16:57:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 359566B0006
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 16:57:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 145so2568205pfv.18
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 13:57:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=SlcSAITLjgYo/km/m8d458+etYEbzRGb5/Cg+gxf2xA=;
        b=WfZR04eky9XpPgIJ3kCOmn/rKE//AIt4gUi0s92sKR9JrvmYwqBQZ1jAo4Oar/JGZY
         RBnmtD/0ERI49zWIloWQvFQ0NmQJTHbSLEafOggvy6iwSZFhppy5foA4MgSC2ZFrXlZU
         0itGdSytHdbFxqnFnjYB2xJmJ8WaMAK6u8vulpwOftCJ6gfS055KfZ5/7vrCMtIgoBig
         MvkO12a8Zi1zG40/WOTDhiynrWzbi8AVqATpFgBaKe6NY8ytNn5vfiyfbBcjAJfUrzHZ
         xOu7V/djzVa0BrM9QNPivBtdYLmepymFlaHoPGVhL2mmZq0kAT+nNS3A/SjgTnRcNBlT
         Ymuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUnWWx9UH2qHrTOfVvsWY+vN0tXlftY9cMyWhCWxLzbvi5Wc7E9
	thN7D1vbOXlP34X7jhmDK/b4M89Rjf+DsCCkyXExcXtkNoAgjoif/D1/Lf1sEOXTpI6+yT5R5g5
	p4W9nkwiRlbAQn/KPrWOhdOXwY/xmgT8k2q+0zkmfsO8G9RCs2KYhuE1bCQ3mvW9CSA==
X-Received: by 2002:a62:a511:: with SMTP id v17mr98210569pfm.129.1560545862841;
        Fri, 14 Jun 2019 13:57:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1YcBaK/aFFgCViPOany+w7XQ4gpvejH53uQ2MB+EB295SLnL6uiDjjzwzozL7WhG52XEa
X-Received: by 2002:a62:a511:: with SMTP id v17mr98210491pfm.129.1560545861593;
        Fri, 14 Jun 2019 13:57:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560545861; cv=none;
        d=google.com; s=arc-20160816;
        b=sFPrh+MtPbtZQ2YwQO/uMjO8jVXqyGMEmrTmBQtGzr72ZVhnFQVMsviArTFw76mQAU
         ZAGf0RgM7x3kjo6o+4cmVN8SaYjd/9teCAxRabX6VY80iCjuWFSh9qqjy9arV2b8OG1W
         iYKi18YUoVZcdlTN25fXvXU2PPXcD3Wy07Z7G2xtORQTbyOCx6Zwqv4cq4LkMMqUnLH6
         G8MLyU2O/y0TbxIJx0G67Hn/sAqo14zKpLYaUyOfIiDvC8qJ40P91mvdIHr+aQzpjIVO
         UkdvMa09T24GuYX7oEE6fBrdvw//qJADSgUz4igCckeMYZCLw0LVWDIdk6hS+UVHSqku
         en3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=SlcSAITLjgYo/km/m8d458+etYEbzRGb5/Cg+gxf2xA=;
        b=XMHmIyMSTWXeIiWF0dZYDc1e5d4iyB06V1DPOfpP2ah8aPlMqex7QSKMVk6Duf9DIS
         H86HX5ZgtrftnLTBuaixnilGuRGyWaafeOif6D8Kq6NnWEfoxhdAA1uOcrbf9kL6NFny
         rwdSZGWZAOPHhp2Cg42zfAVvjMFW0SOrekkZWHkm983TNt/TuBdP0hw23s+7iADqQwBI
         ENHcRTIUNup8hWLw5R6OlwCe5GU3AQbZihQRfP29fOw5lxZEUFug2Y61THINJbQKmNDR
         5IUpXAYppaNkV8Tiz2qEUfm0sQP08AHV9XHfZ3XkK0lnQDHLq9XL939sIgGhVcwG40vQ
         Gfvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id y21si3261159pfe.116.2019.06.14.13.57.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 13:57:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 13:57:41 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.201.15]) ([10.7.201.15])
  by orsmga002.jf.intel.com with ESMTP; 14 Jun 2019 13:57:40 -0700
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, Andy Lutomirski <luto@amacapital.net>
Cc: Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
 "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>,
 "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
 Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
 Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>,
 Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>,
 Randy Dunlap <rdunlap@infradead.org>,
 "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
 Dave Martin <Dave.Martin@arm.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
 <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
 <25281DB3-FCE4-40C2-BADB-B3B05C5F8DD3@amacapital.net>
 <e26f7d09376740a5f7e8360fac4805488b2c0a4f.camel@intel.com>
 <3f19582d-78b1-5849-ffd0-53e8ca747c0d@intel.com>
 <5aa98999b1343f34828414b74261201886ec4591.camel@intel.com>
 <0665416d-9999-b394-df17-f2a5e1408130@intel.com>
 <5c8727dde9653402eea97bfdd030c479d1e8dd99.camel@intel.com>
 <ac9a20a6-170a-694e-beeb-605a17195034@intel.com>
 <328275c9b43c06809c9937c83d25126a6e3efcbd.camel@intel.com>
 <92e56b28-0cd4-e3f4-867b-639d9b98b86c@intel.com>
 <1b961c71d30e31ecb22da2c5401b1a81cb802d86.camel@intel.com>
 <ea5e333f-8cd6-8396-635f-a9dc580d5364@intel.com>
 <cf0d1470e95e0a8b88742651d06601a53d6655c1.camel@intel.com>
 <5ddf59e2-c701-3741-eaa1-f63ee741ea55@intel.com>
 <b5a915602020a6ce26ea1254f7f60e239c91bc9f.camel@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <598edca7-c36a-a236-3b72-08b2194eb609@intel.com>
Date: Fri, 14 Jun 2019 13:57:40 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <b5a915602020a6ce26ea1254f7f60e239c91bc9f.camel@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/14/19 10:13 AM, Yu-cheng Yu wrote:
> On Fri, 2019-06-14 at 09:13 -0700, Dave Hansen wrote:
>> On 6/14/19 8:25 AM, Yu-cheng Yu wrote:
>>> The bitmap is very big.
>>
>> Really?  It's actually, what, 8*4096=32k, so 1/32,768th of the size of
>> the libraries legacy libraries you load?  Do our crash dumps really not
>> know how to represent or deal with sparse mappings?
> 
> Ok, even the core dump is not physically big, its size still looks odd, right?

Hell if I know.

Could you please go try this in practice so that we're designing this
thing fixing real actual problems instead of phantoms that we're
anticipating?

> Could this also affect how much time for GDB to load it.

I don't know.  Can you go find out for sure, please?

> I have a related question:
> 
> Do we allow the application to read the bitmap, or any fault from the
> application on bitmap pages?

We have to allow apps to read it.  Otherwise they can't execute
instructions.

We don't have to allow them to (popuating) fault on it.  But, if we
don't, we need some kind of kernel interface to avoid the faults.

