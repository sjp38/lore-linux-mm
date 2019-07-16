Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4F39C76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 14:41:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 975F320880
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 14:41:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 975F320880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 291586B000D; Tue, 16 Jul 2019 10:41:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 241796B000E; Tue, 16 Jul 2019 10:41:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10A538E0003; Tue, 16 Jul 2019 10:41:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CED016B000D
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 10:41:01 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d3so12732974pgc.9
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 07:41:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=8Bs8xpY1f2O9Qpu1XnYpVWUBk8X5RbwHnrhGtxZDQ+c=;
        b=Xa4TrA4LMxlTcButKGSA+NCjL1tGmUWJWyTbQeVu9itOlF5zE2nmigMVqXV0HFqamC
         J3PSc8kXwnNHdxasuQdQEGbkUKxyN64CQYydxBJsZiRoUeIJMXmC+uNM5zuOLA5eZVzO
         FKajuS1HN3JnPb9t79949Bavmb4Y8g0tfWbZPPe/EArlXnmcFN1tvnbluDzKucbNk/1F
         J3sq6JPBFajFbn8xGkeMPlBps9+nKBJWTAz7yIxnG6yzB1j3PENsKwHw2tzo0PVX9luk
         pb28D/jjEmwjh6SDeUt0GdekKVSmLtGvFlgu/dxZl3oC1TizTTi+g41J8aK7s/BX/T64
         +ZtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV0zu9rWv3r9m0cQGqoVihor2wjhNUjwppQqyr6wC3kSTuXVjZy
	tl649xU17DH8xZbSIw8Yz1GOicTBEfmoeG6sewRmjyK4IAypu8lzcy7EQam0EHv7JquwWr92zIL
	4HddQmKrOJYC4Zr5tmdI9Lg0+58So8jdYxJGlMbV42QgoG8+gbjd5OKiBzNNu0U46Mg==
X-Received: by 2002:a63:8643:: with SMTP id x64mr2653851pgd.307.1563288061471;
        Tue, 16 Jul 2019 07:41:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyawO6s/WJ/d6O63/ZZqwuVYoe2NCuZdYP5iaANwqDvv5MKrIedb9YE1jgnX6ta7Tj14fGn
X-Received: by 2002:a63:8643:: with SMTP id x64mr2653727pgd.307.1563288060585;
        Tue, 16 Jul 2019 07:41:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563288060; cv=none;
        d=google.com; s=arc-20160816;
        b=Jf5EaCXXiTPwxt1CYGBxUzxmhcb2ok0nod87dnVzLds/5yr9uDt1EHY06uxkkFpT7B
         VbHQWMNHdhaxAT6nFQ+Z5pYE1qLQ1FPj2YTKD2cgboa830Lwbz6DAEqlUD5rsGXdW2co
         lHAsSmWA6UuQTyEb+vnFauQJzcHedUrVwiDAeVpDiv8cuTE2FQKjoTQM5m8qazDveNc4
         8exT9oWM39OAVnOTi9L+pM0jM3G6W5Mp3dNt4IRFX0+N2Z8CAT3PBkZLH7pPCZFxah16
         G3Z+8mcfQRNLafiaQ/B+VKN3T8ioWMCBu8WkwMAqnU9DJz/Q2OwscqOrkBGwJ1Aqpp9c
         oVMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=8Bs8xpY1f2O9Qpu1XnYpVWUBk8X5RbwHnrhGtxZDQ+c=;
        b=uMqVg28hEyKrVmT1T0F7vo93KKhOdB4lodv62hkR/enE7WXIjTl8/dvQ2Qacuxt+9Y
         BgJPlcE6xUZ6zLaDH9UTHl9u8SIn9tg6kOj0yfOiJ4WlRPHNqksDhnNpYRXVRzGvTvIL
         GUGeXLQHFY/ryJfrogg4kbSAjI/GRKGSgRIOlIutWcaaf/AkReHBaxrwFR6ZbLyeDk80
         /JNnJCxzksD07pulXoV063KPdTe6eUb9N5lV7zzQP0ZfG6yIwYnEM7ayg50PWtfHLuZc
         wzjBCd+avb7pLY7uA/bP9uPjLure15avfUT1ADSNRffw7YW3CmlhkkScXVx3/ks3Y/B4
         MrmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c1si21512440pfc.80.2019.07.16.07.41.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 07:41:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Jul 2019 07:41:00 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,498,1557212400"; 
   d="scan'208";a="190932475"
Received: from smatond1-mobl1.amr.corp.intel.com (HELO [10.252.143.186]) ([10.252.143.186])
  by fmsmga004.fm.intel.com with ESMTP; 16 Jul 2019 07:40:58 -0700
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
To: David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin"
 <mst@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
 pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
 lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
 pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <20190619223338.1231.52537.stgit@localhost.localdomain>
 <20190716055017-mutt-send-email-mst@kernel.org>
 <cad839c0-bbe6-b065-ac32-f32c117cf07e@intel.com>
 <3f8b2a76-b2ce-fb73-13d4-22a33fc1eb17@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <bdb9564d-640d-138f-6695-3fa2c084fcc7@intel.com>
Date: Tue, 16 Jul 2019 07:41:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <3f8b2a76-b2ce-fb73-13d4-22a33fc1eb17@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/16/19 7:12 AM, David Hildenbrand wrote:
> On 16.07.19 16:00, Dave Hansen wrote:
>> On 7/16/19 2:55 AM, Michael S. Tsirkin wrote:
>>> The approach here is very close to what on-demand hinting that is
>>> already upstream does.
>> Are you referring to the s390 (and powerpc) stuff that is hidden behind
>> arch_free_page()?
>>
> I assume Michael meant "free page reporting".

Where is the page allocator integration?  The set you linked to has 5
patches, but only 4 were merged.  This one is missing:

	https://lore.kernel.org/patchwork/patch/961038/

