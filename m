Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14001C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 16:35:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B81A820821
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 16:35:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B81A820821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C8CB6B0005; Thu, 18 Apr 2019 12:35:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 477C96B0006; Thu, 18 Apr 2019 12:35:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 390556B0007; Thu, 18 Apr 2019 12:35:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F29216B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 12:35:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i23so1727509pfa.0
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:35:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=sVRo1blcQGvaqZSMlBn6qCPALHJTmvqFqv8sG2j2qeM=;
        b=BlHILPfIVnWOtr7zRt1rBbQHAorZZBfEzOQ8pVVR7Cz1/GIwT4EqZw+W5POLTHOhb9
         mkhqk2TTlCnWn0aTOYFmKQa3gYrNiqMrro1OWcqAJazCeFBGJQbC/0KQvQDKg9rDzGzv
         4sSMaqcL2vPObXNPQWkb6FDsT+yztFPLpCc18m0bw45xuFISd/jEAMcDSwieVUNCACkC
         u1osZ0AG+H+Eo5wZgaPa8kyYHLzR1cLYj5cs8eAIx+2s3ZLUvXbSnlAe/01pe5P/CMQ9
         YwwnKDjpBOwUZCnwdbOSNQ8i9DGG7PqLBkGCz0M6XFTspMtcjNpCvrc+2iAofwqymTXa
         FzcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU0T69Pawm1Q8e1JT3BM1FRS1FDiFmGfgGYjuHVFYLVlq30Pdbg
	vFGNtgWAtWQ9/TEhOh0VBBB3k2eot0SwHRfj6V3ZPrj2O2sxJ0CKPEPj53cEbvVf5NqO5qvBy6+
	tTv9FlIEaOfoX6rEhiq+qV7dksflUdfFn/7bIAiVmHNupJw/66dJXOsqLja0bpCcX0A==
X-Received: by 2002:a65:6294:: with SMTP id f20mr6390655pgv.415.1555605345437;
        Thu, 18 Apr 2019 09:35:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNrH0T4gjp62jJsQ4L2KJ9/DaGawIlGUHhqc969hOF6aBS0VjrPo0bB3ElRYuPSecjudQc
X-Received: by 2002:a65:6294:: with SMTP id f20mr6390592pgv.415.1555605344549;
        Thu, 18 Apr 2019 09:35:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555605344; cv=none;
        d=google.com; s=arc-20160816;
        b=tkyPKxUDRLeONHERzPtRJs5t3SL5ZH+ehfo4G2Q9n81FxfxSJaUT7rN0IzlTudCXZy
         DBBo6WptBafqunsddold9fOtM30I2Ha0i9Pvpu/P0lP9j53lR4jIu+T0Fc906AHYWhfe
         U9MjtjvrwDlxtRMTCTXqf2HuawpA9mD2AbOm5I9F4XhwTGeYfESpp7HHI4Ko7VZME62W
         Dif0khersqU0alqnLy5liUtMN+CvAawVkQjU6kwvX7QzNG5D9QDRcj4WTeGQm4wR6OnS
         pugms4lPEfIk1nJveXQ7NXVTWK6c+FdeTTbsz2PuelXXZC+UVkSj+J/F5BjtqJeyHAAP
         NamQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=sVRo1blcQGvaqZSMlBn6qCPALHJTmvqFqv8sG2j2qeM=;
        b=UtuNDADjdQ0zBawNn8RF7l3VZcczqUpeRd8fo4PftiYn/pzPtIOrrYjwKYUgIZbfTn
         HTBpi/Fw+b8H7FN2QdXM+ekMcKWbHUsh4wcPkTKlLCvDbc6TaNKUnWILBKcfDYfM7m/s
         2o5hfMSKyUzXegrzVdwgdXbnXfNxfS82Mov6R7r16UORiGnDoy+6ge7u2tseey2G3Fsh
         VICf+O+0F2O7hz8izF5j/Olwe1CWkN+PEGCVxMroWnTW6Pznn+UPA9fsaUsEZOPDhu6f
         jeGX218KNgLv6Ze+OwSNg8SKFVSrAfK7JKFKvuK1tseMHU6AXqC2EexDfIHh5Gcmbocw
         3X+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f127si2719899pfc.176.2019.04.18.09.35.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 09:35:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Apr 2019 09:35:33 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,366,1549958400"; 
   d="scan'208";a="224675019"
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga001.jf.intel.com with ESMTP; 18 Apr 2019 09:35:33 -0700
Subject: Re: [PATCH 1/3] mm: security: introduce the init_allocations=1 boot
 option
To: Alexander Potapenko <glider@google.com>, akpm@linux-foundation.org,
 cl@linux.com, dvyukov@google.com, keescook@chromium.org, labbott@redhat.com
Cc: linux-mm@kvack.org, linux-security-module@vger.kernel.org,
 kernel-hardening@lists.openwall.com
References: <20190418154208.131118-1-glider@google.com>
 <20190418154208.131118-2-glider@google.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <981d439a-1107-2730-f27e-17635ee4a125@intel.com>
Date: Thu, 18 Apr 2019 09:35:32 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190418154208.131118-2-glider@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 8:42 AM, Alexander Potapenko wrote:
> This option adds the possibility to initialize newly allocated pages and
> heap objects with zeroes. This is needed to prevent possible information
> leaks and make the control-flow bugs that depend on uninitialized values
> more deterministic.

Isn't it better to do this at free time rather than allocation time?  If
doing it at free, you can't even have information leaks for pages that
are in the allocator.

