Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67F41C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:58:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FD25216FD
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:58:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FD25216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 712996B0003; Fri, 17 May 2019 10:58:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6EA7C6B0008; Fri, 17 May 2019 10:58:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B2DB6B000A; Fri, 17 May 2019 10:58:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3977F6B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 10:58:56 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id i5so6638497qtd.17
        for <linux-mm@kvack.org>; Fri, 17 May 2019 07:58:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=UiU20EKhHV/zWxGYH8EP6TF2WnOvoJG6eQ3pKoQyz9A=;
        b=J+15ET6YJ8JqrutFHknPsIbzfDERmkcanJWXhqC00uplly5PV6zPPYyid67WW3R8LI
         GOIwoiGbE89EhcAhR5DcAzMTQXjl6pH8SvydcQF17w9Xcc3oEcTalxu0bNVjrQ0dDYRI
         5/CLaAagoU++LSU+QmejtYKNcLUzJfg6zh+N14EhHulLO340IvPVIuVaRo9iRO11VT/u
         CtMVSUUePm0eGo12O/hceEWdhFglPEpdQrOgmRnVHTDy5KMhuZBri8JhK04yxgdhs/Tp
         zZtBB1fvF2t3DwFUWbgYoUOzvpjBTkdLJ8X0GqGPerfHQPCoQdx/Dh5mUfgFi15L2cYc
         1XAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUQwFQUmrzyj0mjZDMQr+ADg7VNtWD1hQjFKFU+5idhCkmjufIC
	PUgCSb87IjYmow/+3gvkbONcZNZMbzTtGkUibF8r4Sw56sngtYO74KRUNdgQKYyc8KwUvBLNFHY
	EuuiNFgf86R60xRABuOnyrT6BZWhWD0/YnVtP/DqXEsL+xDJKUyxWU7GH+niumAqIqg==
X-Received: by 2002:ac8:538f:: with SMTP id x15mr14274527qtp.263.1558105134652;
        Fri, 17 May 2019 07:58:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0pG9uuj/q/ZX3DwVNMvhhPvoRY5mGobcAmaLXCsGQnMOkyi9UQHaNPXFd6i9vT7ZGraMf
X-Received: by 2002:ac8:538f:: with SMTP id x15mr14274353qtp.263.1558105132545;
        Fri, 17 May 2019 07:58:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558105132; cv=none;
        d=google.com; s=arc-20160816;
        b=idqUj0VGpmSqBLqfEHFi/I+2l+88g7lIvqkuDUx00kV/rt3TL2tFi7tJL/iR8qgcOc
         8HaV0oMmV2u9W1w3o9JhWBABuyZ7BBqcR6gXU70PTqWwMT0xtKoy7zNnXv7ARDHWwWoY
         p/LPLXFWELBWGJO8VbMGrsDkBZEPlOtH3ZVEamFAPnUSSrvhHCd2NpfYyqDYGVVYKFKg
         8vzJ4uXiBFK4txoeHm8BISWfzssYGSvowHCj2oTjpx/T5juX+9DQyJ6I6DbXkDoC+NOv
         Y0266NRXZC1yDup0pmKR+3vhu/Px4ynj1U1441wJPuszPi42omT0OAdZ55YaimKPHRK4
         ifkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=UiU20EKhHV/zWxGYH8EP6TF2WnOvoJG6eQ3pKoQyz9A=;
        b=zntUOH/bkPYXpivJVwHCip9JXSJWO+XE1Vq/84aaxQWhAFSJp8V8slMlwrIhl0X8Ko
         SAhkC604C1q+yxg2hnQI4tZCcuQpm9zyV+3bCwbpfP+DT4ro+cpplsOo663Ho42VewD4
         KaZcV/9B9f6qn8A0Hh2SeElyI3nZ5xu+t3sjmHDeFZ4iSY9KVlN6j6FOIOTaOPrQukrV
         0WrPiwQMeyR6UHvmT0acFFn5Vec8y/6hDJl6oOdvwU3SuS0GaHrpZ0m44R+Xajd5lCCQ
         A0k2Jk2hHMYyWOWgaDEz3ffbp0ETf6lrFNTw34H8eBoUtlTOzMX0JgXw1Vx1Uf+XlS+a
         6ouw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 1si2778958qvx.176.2019.05.17.07.58.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 07:58:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0D90A309264C;
	Fri, 17 May 2019 14:58:44 +0000 (UTC)
Received: from [10.36.118.100] (unknown [10.36.118.100])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 123265DA63;
	Fri, 17 May 2019 14:58:33 +0000 (UTC)
Subject: Re: NULL pointer dereference during memory hotremove
To: Michal Hocko <mhocko@kernel.org>,
 Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "jmorris@namei.org" <jmorris@namei.org>, "tiwai@suse.de" <tiwai@suse.de>,
 "sashal@kernel.org" <sashal@kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>,
 "bp@suse.de" <bp@suse.de>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
 "jglisse@redhat.com" <jglisse@redhat.com>,
 "zwisler@kernel.org" <zwisler@kernel.org>, "Jiang, Dave"
 <dave.jiang@intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>,
 "Busch, Keith" <keith.busch@intel.com>,
 "thomas.lendacky@amd.com" <thomas.lendacky@amd.com>,
 "Huang, Ying" <ying.huang@intel.com>, "Wu, Fengguang"
 <fengguang.wu@intel.com>,
 "baiyaowei@cmss.chinamobile.com" <baiyaowei@cmss.chinamobile.com>
References: <CA+CK2bBeOJPnnyWBgj0CJ7E1z9GVWVg_EJAmDs07BSJDp3PYfQ@mail.gmail.com>
 <20190517143816.GO6836@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <75ae93ee-7897-2ab9-1f15-687ab5b87e72@redhat.com>
Date: Fri, 17 May 2019 16:58:33 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190517143816.GO6836@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 17 May 2019 14:58:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17.05.19 16:38, Michal Hocko wrote:
> On Fri 17-05-19 10:20:38, Pavel Tatashin wrote:
>> This panic is unrelated to circular lock issue that I reported in a
>> separate thread, that also happens during memory hotremove.
>>
>> xakep ~/x/linux$ git describe
>> v5.1-12317-ga6a4b66bd8f4
> 
> Does this happen on 5.0 as well?
> 

We have on the list

[PATCH V3 1/4] mm/hotplug: Reorder arch_remove_memory() call in
__remove_memory()

Can that help?

-- 

Thanks,

David / dhildenb

